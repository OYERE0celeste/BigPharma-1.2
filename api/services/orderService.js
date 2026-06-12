const Order = require("../models/order");
const OrderTimeline = require("../models/orderTimeline");
const Product = require("../models/product");
const Finance = require("../models/finance");
const Client = require("../models/client");
const Company = require("../models/Company");
const User = require("../models/User");

const { runInTransaction } = require("../utils/dbUtils");
const { sendNotification, notifyStaff } = require("../utils/notificationHelper");
const {
  sendOrderConfirmationEmail,
  sendOrderStatusUpdateEmail,
  sendInvoiceReadyEmail,
} = require("../utils/mailService");
const {
  createInvoiceFromOrder,
  syncInvoiceForOrder,
} = require("../utils/invoiceService");
const { logActivity } = require("../utils/activityLogger");

const {
  availableOrderableStockForProduct,
  allocateStock,
  restoreStock,
} = require("./stockService");

const ORDER_STATUSES = [
  "en_attente",
  "en_preparation",
  "pret_pour_recuperation",
  "validee",
  "annulee",
];

const ORDER_TRANSITIONS = {
  en_attente: ["en_preparation", "pret_pour_recuperation", "validee", "annulee"],
  en_preparation: ["pret_pour_recuperation", "validee", "annulee"],
  pret_pour_recuperation: ["validee", "annulee"],
  validee: [],
  annulee: [],
};

const ORDER_STATUS_LABELS = {
  en_attente: "en attente",
  en_preparation: "en préparation",
  pret_pour_recuperation: "prête pour récupération",
  validee: "validée (récupérée)",
  annulee: "annulée",
};

const buildOrderQuery = (query = {}) =>
  Order.findOne(query)
    .populate("userId", "fullName email phone")
    .populate("clientId", "fullName email phone address userId")
    .populate("products.productId", "name sellingPrice stockQuantity");

const updateOrderStatusService = async ({ orderId, companyId, userId, userFullName, status, note }) => {
  if (!ORDER_STATUSES.includes(status)) {
    throw new Error("Statut de commande invalide");
  }

  let transactionResult;
  try {
    transactionResult = await runInTransaction(async (session) => {
      const order = await Order.findOne({
        _id: orderId,
        companyId: companyId,
      }).session(session);

      if (!order) {
        throw new Error("Commande non trouvée");
      }

      if (order.status === status) {
        throw new Error(`La commande est déjà ${ORDER_STATUS_LABELS[status]}`);
      }

      const allowedTransitions = ORDER_TRANSITIONS[order.status] || [];

      if (!allowedTransitions.includes(status)) {
        throw new Error(`Transition invalide de ${ORDER_STATUS_LABELS[order.status]} vers ${ORDER_STATUS_LABELS[status]}`);
      }

      const isActiveStatus = ["en_preparation", "pret_pour_recuperation", "validee"].includes(status);
      const wasAllocated = order.stockAllocations && order.stockAllocations.length > 0;

      if (isActiveStatus && !wasAllocated) {
        const allocations = [];

        const productIds = order.products.map((product) => product.productId);
        const products = await Product.find({
          _id: { $in: productIds },
          companyId: companyId,
        }).session(session);
        const productsById = new Map(products.map((product) => [String(product._id), product]));

        for (const orderedProduct of order.products) {
          const product = productsById.get(String(orderedProduct.productId));
          if (!product) {
            throw new Error(`Produit introuvable : ${orderedProduct.name}`);
          }

          if (availableOrderableStockForProduct(product) < orderedProduct.quantity) {
            throw new Error(`Stock insuffisant pour ${orderedProduct.name}`);
          }
        }

        for (const orderedProduct of order.products) {
          const product = productsById.get(String(orderedProduct.productId));
          const lotAllocations = allocateStock(product, orderedProduct.quantity);
          product.markModified("lots");
          await product.save({ session });

          if (product.stockQuantity <= (product.minStockLevel || 0)) {
            await notifyStaff({
              companyId: companyId,
              title: "Alerte Stock Faible",
              message: `Le stock de ${product.name} est bas (${product.stockQuantity} restants).`,
              type: "stock",
              data: { productId: product._id },
            });
          }

          allocations.push({
            productId: product._id,
            lotAllocations,
          });
        }

        order.stockAllocations = allocations;
      }

      if (status === "annulee" && wasAllocated) {
        for (const allocation of order.stockAllocations || []) {
          const product = await Product.findOne({
            _id: allocation.productId,
            companyId: companyId,
          }).session(session);

          if (!product) {
            continue;
          }

          restoreStock(product, allocation.lotAllocations);
          product.markModified("lots");
          await product.save({ session });
        }

        order.stockAllocations = [];
      }

      const previousStatus = order.status;
      const shouldNotifyInvoiceAvailability =
        !order.invoiceNumber && ["en_preparation", "pret_pour_recuperation", "validee"].includes(status);

      order.status = status;
      await order.save({ session });

      let invoice = null;
      if (["en_preparation", "pret_pour_recuperation", "validee"].includes(status)) {
        const [clientProfile, company] = await Promise.all([
          Client.findById(order.clientId).session(session),
          Company.findById(order.companyId).session(session),
        ]);
        invoice = await createInvoiceFromOrder(order, {
          client: clientProfile,
          company,
        });
      }
      invoice = await syncInvoiceForOrder(order);

      if (status === "validee") {
        await new Finance({
          dateTime: new Date(),
          type: "sale",
          sourceModule: "Commandes",
          reference: order.orderNumber,
          description: `Commande ${order.orderNumber} récupérée par le client`,
          amount: order.totalPrice,
          isIncome: true,
          paymentMethod: "other",
          employeeName: userFullName,
          orderId: order._id,
          companyId: companyId,
        }).save({ session });
      }

      await new OrderTimeline({
        orderId: order._id,
        status,
        userId: userId,
        note:
          note ||
          `Statut changé de ${ORDER_STATUS_LABELS[previousStatus]} vers ${ORDER_STATUS_LABELS[status]}`,
        companyId: companyId,
      }).save({ session });

      const updatedOrder = await buildOrderQuery({ _id: order._id }).session(session);
      return { updatedOrder, invoice, shouldNotifyInvoiceAvailability };
    });
  } catch (txError) {
    throw new Error(txError.message);
  }

  const { updatedOrder, invoice, shouldNotifyInvoiceAvailability } = transactionResult;

  if (global.io) {
    global.io.to(companyId.toString()).emit("order-status-update", updatedOrder);
  }

  const clientUser = await User.findById(updatedOrder.userId).select("email fullName").lean();
  if (clientUser) {
    await sendOrderStatusUpdateEmail({
      email: clientUser.email,
      fullName: clientUser.fullName,
      orderNumber: updatedOrder.orderNumber,
      statusLabel: ORDER_STATUS_LABELS[status],
      companyName: "BigPharma",
    });
  }

  await sendNotification({
    userId: updatedOrder.userId,
    companyId: companyId,
    title: "Mise à jour de votre commande",
    message: `Votre commande ${updatedOrder.orderNumber} est maintenant ${ORDER_STATUS_LABELS[status]}.`,
    type: "order",
    data: { orderId: updatedOrder._id, orderNumber: updatedOrder.orderNumber, status },
  });

  if (invoice && shouldNotifyInvoiceAvailability) {
    if (clientUser) {
      await sendInvoiceReadyEmail({
        email: clientUser.email,
        fullName: clientUser.fullName,
        invoiceNumber: invoice.invoiceNumber,
        orderNumber: updatedOrder.orderNumber,
        companyName: "BigPharma",
      });
    }

    await sendNotification({
      userId: updatedOrder.userId,
      companyId: companyId,
      title: "Votre facture est disponible",
      message: `La facture ${invoice.invoiceNumber} de la commande ${updatedOrder.orderNumber} est maintenant disponible.`,
      type: "invoice",
      data: {
        invoiceId: invoice._id,
        invoiceNumber: invoice.invoiceNumber,
        orderId: updatedOrder._id,
        orderNumber: updatedOrder.orderNumber,
      },
    });
  }

  return updatedOrder;
};

const getClientForUser = async (user) =>
  Client.findOne({
    userId: user._id,
    companyId: user.companyId,
  });

const normalizeOrderProducts = (rawProducts) => {
  if (typeof rawProducts === "string") {
    try {
      rawProducts = JSON.parse(rawProducts);
    } catch (_) {
      rawProducts = [];
    }
  }

  if (!Array.isArray(rawProducts)) {
    return [];
  }

  return rawProducts.map((item) => ({
    productId: item.productId || item.product || item._id || item.id,
    quantity: Number.isFinite(Number(item.quantity))
      ? (Number(item.quantity) > 0 ? parseInt(item.quantity, 10) : null)
      : null,
  }));
};

const generateOrderNumber = async () => {
  const year = new Date().getFullYear();
  const startOfYear = new Date(year, 0, 1);
  const endOfYear = new Date(year, 11, 31, 23, 59, 59);

  const count = await Order.countDocuments({
    createdAt: { $gte: startOfYear, $lte: endOfYear },
  });

  return `CMD-${year}-${String(count + 1).padStart(4, "0")}`;
};

const createOrderService = async ({ user, body, io, request, file }) => {
  const rawProducts = body.products || body.items || [];
  const normalizedProducts = normalizeOrderProducts(rawProducts);

  if (normalizedProducts.length === 0 || normalizedProducts.some((item) => !item.productId || item.quantity === null)) {
    throw new Error("La commande doit contenir au moins un article avec une quantité valide");
  }

  const client = await getClientForUser(user);
  if (!client) {
    throw new Error("Profil client introuvable pour cet utilisateur");
  }

  const productIds = normalizedProducts.map((item) => String(item.productId));
  if (new Set(productIds).size !== productIds.length) {
    throw new Error("Un produit ne peut apparaître qu'une seule fois dans la commande");
  }

  const products = await Product.find({
    _id: { $in: productIds },
    isActive: true,
  });

  if (products.length !== productIds.length) {
    throw new Error("Un ou plusieurs produits de la commande sont introuvables");
  }

  const targetCompanyIds = new Set(products.map((product) => String(product.companyId)));
  if (targetCompanyIds.size > 1) {
    throw new Error("Tous les produits de la commande doivent provenir de la même pharmacie");
  }

  const targetCompanyId = products[0].companyId;
  const productsById = new Map(products.map((product) => [String(product._id), product]));

  let totalPrice = 0;
  const orderProducts = normalizedProducts.map((requestedProduct) => {
    const product = productsById.get(String(requestedProduct.productId));
    if (!product) {
      throw new Error(`Produit introuvable : ${requestedProduct.productId}`);
    }

    if (availableOrderableStockForProduct(product) < requestedProduct.quantity) {
      throw new Error(`Stock insuffisant pour ${product.name}`);
    }

    totalPrice += product.sellingPrice * requestedProduct.quantity;

    return {
      productId: product._id,
      name: product.name,
      price: product.sellingPrice,
      quantity: requestedProduct.quantity,
    };
  });

  const orderPayload = {
    orderNumber: await generateOrderNumber(),
    userId: user._id,
    clientId: client._id,
    companyId: targetCompanyId,
    products: orderProducts,
    totalPrice,
    status: "en_attente",
    notes: body.notes,
    pickupMode: body.pickupMode === "livraison" ? "livraison" : "sur_place",
    collectionCode: Math.floor(100000 + Math.random() * 900000).toString(),
  };

  if (body.file) {
    orderPayload.prescription = {
      fileName: body.file.originalname,
      mimeType: body.file.mimetype,
      data: body.file.buffer,
      uploadedBy: user._id,
      uploadedAt: new Date(),
    };
  }

  const order = await Order.create(orderPayload);

  await new OrderTimeline({
    orderId: order._id,
    status: "en_attente",
    userId: user._id,
    note: "Commande créée par le client",
    companyId: targetCompanyId,
  }).save();

  await logActivity(
    {
      actionType: "create",
      entityType: "order",
      entityId: order._id.toString(),
      entityName: order.orderNumber,
      description: `Nouvelle commande ${order.orderNumber} créée`,
      companyId: targetCompanyId,
      user: user.fullName || "Client",
      clientOrSupplierName: client.fullName,
      totalAmount: order.totalPrice,
      quantity: order.products.reduce((sum, p) => sum + p.quantity, 0),
      status: "pending",
      listOfItems: order.products.map((p) => ({
        productName: p.name,
        quantity: p.quantity,
        unitPrice: p.price,
        totalPrice: p.price * p.quantity,
      })),
    },
    request
  );

  const savedOrder = await buildOrderQuery({ _id: order._id });

  if (io) {
    io.to(targetCompanyId.toString()).emit("new-order", savedOrder);
  }

  await notifyStaff({
    companyId: targetCompanyId,
    title: "Nouvelle commande",
    message: `Une nouvelle commande ${order.orderNumber} a été reçue de ${client.fullName}.`,
    type: "order",
    data: { orderId: order._id, orderNumber: order.orderNumber },
  });

  await sendOrderConfirmationEmail({
    email: user.email,
    fullName: user.fullName,
    orderNumber: order.orderNumber,
    pickupMode: order.pickupMode,
    companyName: "BigPharma",
    collectionCode: order.collectionCode,
  });

  return savedOrder;
};

module.exports = {
  createOrderService,
  updateOrderStatusService,
  buildOrderQuery,
};
