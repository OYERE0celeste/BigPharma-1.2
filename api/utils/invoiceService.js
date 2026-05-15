const PDFDocument = require("pdfkit");

const Client = require("../models/client");
const Company = require("../models/Company");
const Invoice = require("../models/invoice");

const INVOICEABLE_ORDER_STATUSES = ["en_preparation", "pret_pour_recuperation", "validee"];

const PAYMENT_STATUS_BY_ORDER_STATUS = {
  en_attente: "en_attente",
  en_preparation: "en_attente",
  pret_pour_recuperation: "en_attente",
  validee: "payee",
  annulee: "annulee",
};

const ORDER_STATUS_LABELS = {
  en_attente: "En attente",
  en_preparation: "En preparation",
  pret_pour_recuperation: "Prete pour recuperation",
  validee: "Validee",
  annulee: "Annulee",
};

const PAYMENT_STATUS_LABELS = {
  en_attente: "En attente",
  payee: "Payee",
  annulee: "Annulee",
};

async function generateInvoiceNumber(companyId) {
  const year = new Date().getFullYear();
  const start = new Date(year, 0, 1);
  const end = new Date(year, 11, 31, 23, 59, 59, 999);
  const count = await Invoice.countDocuments({
    companyId,
    invoiceDate: { $gte: start, $lte: end },
  });

  return `FAC-${year}-${String(count + 1).padStart(5, "0")}`;
}

function isOrderInvoiceable(status) {
  return INVOICEABLE_ORDER_STATUSES.includes(status);
}

function resolvePaymentStatus(orderStatus) {
  return PAYMENT_STATUS_BY_ORDER_STATUS[orderStatus] || "en_attente";
}

async function resolveClientSnapshot(order, providedClient) {
  const client = providedClient || await Client.findById(order.clientId);
  if (!client) {
    return {
      client: null,
      snapshot: {},
    };
  }

  return {
    client,
    snapshot: {
      fullName: client.fullName || "",
      email: client.email || "",
      phone: client.phone || "",
      address: client.address || "",
    },
  };
}

async function resolveCompanySnapshot(order, providedCompany) {
  const company = providedCompany || await Company.findById(order.companyId);
  if (!company) {
    return {
      company: null,
      snapshot: {},
    };
  }

  return {
    company,
    snapshot: {
      name: company.name || "",
      email: company.email || "",
      phone: company.phone || "",
      address: company.address || "",
      city: company.city || "",
      country: company.country || "",
    },
  };
}

async function createInvoiceFromOrder(order, { client, company } = {}) {
  const existing = await Invoice.findOne({ orderId: order._id });
  if (existing) {
    return existing;
  }

  const { snapshot: clientSnapshot } = await resolveClientSnapshot(order, client);
  const { snapshot: pharmacySnapshot } = await resolveCompanySnapshot(order, company);

  const invoiceNumber = order.invoiceNumber || await generateInvoiceNumber(order.companyId);
  const invoiceDate = order.invoiceDate || new Date();

  const items = (order.products || []).map((item) => ({
    productId: item.productId,
    name: item.name,
    quantity: item.quantity,
    unitPrice: item.price,
    totalPrice: item.price * item.quantity,
  }));

  const invoice = await Invoice.create({
    invoiceNumber,
    orderId: order._id,
    userId: order.userId,
    clientId: order.clientId,
    companyId: order.companyId,
    orderNumber: order.orderNumber,
    invoiceDate,
    pickupMode: order.pickupMode || "sur_place",
    paymentStatus: resolvePaymentStatus(order.status),
    orderStatus: order.status,
    collectionCode: order.collectionCode,
    clientSnapshot,
    pharmacySnapshot,
    items,
    subtotal: order.totalPrice,
    totalAmount: order.totalPrice,
  });

  if (order.invoiceNumber !== invoiceNumber || !order.invoiceDate) {
    order.invoiceNumber = invoiceNumber;
    order.invoiceDate = invoiceDate;
    await order.save();
  }

  return invoice;
}

async function syncInvoiceForOrder(order, { client, company } = {}) {
  let invoice = await Invoice.findOne({ orderId: order._id });

  if (!invoice && isOrderInvoiceable(order.status)) {
    invoice = await createInvoiceFromOrder(order, { client, company });
  }

  if (!invoice) {
    return null;
  }

  const nextPaymentStatus = resolvePaymentStatus(order.status);
  const nextPickupMode = order.pickupMode || invoice.pickupMode || "sur_place";

  invoice = await Invoice.findOneAndUpdate(
    { orderId: order._id },
    {
      orderStatus: order.status,
      paymentStatus: nextPaymentStatus,
      pickupMode: nextPickupMode,
      collectionCode: order.collectionCode,
    },
    { new: true }
  );

  return invoice;
}

function toInvoicePayload(invoice) {
  return {
    id: invoice._id,
    invoiceNumber: invoice.invoiceNumber,
    invoiceDate: invoice.invoiceDate,
    orderNumber: invoice.orderNumber,
    orderId: invoice.orderId,
    collectionCode: invoice.collectionCode,
    pickupMode: invoice.pickupMode,
    paymentStatus: invoice.paymentStatus,
    paymentStatusLabel: PAYMENT_STATUS_LABELS[invoice.paymentStatus] || invoice.paymentStatus,
    orderStatus: invoice.orderStatus,
    orderStatusLabel: ORDER_STATUS_LABELS[invoice.orderStatus] || invoice.orderStatus,
    client: invoice.clientSnapshot || {},
    pharmacy: invoice.pharmacySnapshot || {},
    items: (invoice.items || []).map((item) => ({
      productId: item.productId,
      name: item.name,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      total: item.totalPrice,
    })),
    totalAmount: invoice.totalAmount,
    subtotal: invoice.subtotal,
    currency: invoice.currency || "FCFA",
  };
}

function buildInvoicePdfBuffer(invoice) {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ margin: 40 });
    const chunks = [];

    doc.on("data", (chunk) => chunks.push(chunk));
    doc.on("end", () => resolve(Buffer.concat(chunks)));
    doc.on("error", reject);

    doc.fontSize(22).text("Facture client", { align: "center" });
    doc.moveDown();
    doc.fontSize(11).text(`Numero: ${invoice.invoiceNumber}`);
    doc.text(`Commande: ${invoice.orderNumber}`);
    doc.text(`Date: ${new Date(invoice.invoiceDate).toLocaleString("fr-FR")}`);
    doc.text(`Paiement: ${PAYMENT_STATUS_LABELS[invoice.paymentStatus] || invoice.paymentStatus}`);
    doc.text(`Statut commande: ${ORDER_STATUS_LABELS[invoice.orderStatus] || invoice.orderStatus}`);
    doc.text(`Retrait: ${invoice.pickupMode === "livraison" ? "Livraison" : "Sur place"}`);

    if (invoice.collectionCode) {
      doc.text(`Code de retrait: ${invoice.collectionCode}`);
    }

    doc.moveDown();
    doc.fontSize(14).text("Pharmacie");
    doc.fontSize(11).text(invoice.pharmacySnapshot?.name || "");
    doc.text(invoice.pharmacySnapshot?.address || "");
    if (invoice.pharmacySnapshot?.city || invoice.pharmacySnapshot?.country) {
      doc.text(
        [invoice.pharmacySnapshot?.city, invoice.pharmacySnapshot?.country].filter(Boolean).join(", ")
      );
    }
    doc.text(invoice.pharmacySnapshot?.phone || "");
    doc.text(invoice.pharmacySnapshot?.email || "");

    doc.moveDown();
    doc.fontSize(14).text("Client");
    doc.fontSize(11).text(invoice.clientSnapshot?.fullName || "");
    doc.text(invoice.clientSnapshot?.address || "");
    doc.text(invoice.clientSnapshot?.phone || "");
    doc.text(invoice.clientSnapshot?.email || "");

    doc.moveDown();
    doc.fontSize(14).text("Articles");
    doc.moveDown(0.5);
    (invoice.items || []).forEach((item) => {
      doc
        .fontSize(11)
        .text(
          `${item.name} - ${item.quantity} x ${item.unitPrice.toFixed(0)} FCFA = ${item.totalPrice.toFixed(0)} FCFA`
        );
    });

    doc.moveDown();
    doc.fontSize(14).text(`Total: ${invoice.totalAmount.toFixed(0)} FCFA`, { align: "right" });
    doc.moveDown();
    doc.fontSize(10).fillColor("gray").text("Document genere par BigPharma", { align: "center" });
    doc.end();
  });
}

module.exports = {
  buildInvoicePdfBuffer,
  createInvoiceFromOrder,
  generateInvoiceNumber,
  isOrderInvoiceable,
  resolvePaymentStatus,
  syncInvoiceForOrder,
  toInvoicePayload,
};
