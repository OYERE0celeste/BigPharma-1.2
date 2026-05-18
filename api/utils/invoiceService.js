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
    // Thermal receipt size: ~80mm wide (approx 226 points), height can be long
    const doc = new PDFDocument({ size: [250, 800], margin: 15 });
    const chunks = [];

    doc.on("data", (chunk) => chunks.push(chunk));
    doc.on("end", () => resolve(Buffer.concat(chunks)));
    doc.on("error", reject);

    doc.font("Courier");
    const phName = invoice.pharmacySnapshot?.name || "PHARMACIE LA FLORALE";
    const phPhone = invoice.pharmacySnapshot?.phone || "06 857 57 84";

    doc.fontSize(10).font("Courier-Bold").text(phName, { align: "center" });
    doc.fontSize(9).font("Courier").text(`TEL : ${phPhone}`, { align: "center" });
    doc.text("Dr Flora ONDELE", { align: "center" });
    doc.moveDown(0.5);

    const invoiceDate = new Date(invoice.invoiceDate);
    const dateOptions = { day: '2-digit', month: 'short', year: '2-digit', hour: '2-digit', minute: '2-digit' };
    let dateStr = invoiceDate.toLocaleDateString("fr-FR", dateOptions).replace(',', '');
    
    const clientName = invoice.clientSnapshot?.fullName || "CLIENT";
    doc.text(`OP: ${clientName.substring(0, 10).toUpperCase()} le ${dateStr}`);
    doc.text(`Bon de livraison  Caisse 1`);
    doc.text("------------------------------------");
    doc.text(`Facture N ${invoice.invoiceNumber} du ${invoiceDate.toLocaleDateString("fr-FR")}`);
    doc.moveDown(0.5);

    doc.text("Désign.    Prix  Qte %rem. Montant");
    (invoice.items || []).forEach((item) => {
      doc.text(item.name.substring(0, 36));
      const price = item.unitPrice.toFixed(0);
      const qty = item.quantity.toString().padStart(2, '0');
      const total = item.totalPrice.toFixed(0);
      const lineStr = `           ${price} x ${qty}       ${total}`;
      doc.text(lineStr);
    });

    doc.moveDown(0.5);
    const totalAmount = invoice.totalAmount.toFixed(0);
    doc.text(`Total:     ${totalAmount} Assur :          0 F`);
    doc.text("------------------------------------");
    const eur = (invoice.totalAmount / 655.957).toFixed(2);
    doc.text(`Total ticket: ${totalAmount} FCFA (${eur} Euros)`);
    doc.text(`Encaiss :          0 F`);
    doc.text(`A recevoir:     ${totalAmount} F`);
    doc.text("===");
    doc.text("|||||| |||||||||| |||||||| ||| |||||", { align: "center" });
    doc.text(`*${invoice.invoiceNumber}*`, { align: "center" });

    doc.moveDown();
    doc.text("MERCI ET PROMPTE GUERISON", { align: "center" });
    doc.text("Les produits achetés ne sont ni repris ni", { align: "center" });
    doc.text("echanges", { align: "center" });

    doc.end();
  });
}

function buildReceiptPdfBuffer(sale, company) {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ size: [250, 800], margin: 15 });
    const chunks = [];

    doc.on("data", (chunk) => chunks.push(chunk));
    doc.on("end", () => resolve(Buffer.concat(chunks)));
    doc.on("error", reject);

    doc.font("Courier");
    const phName = company?.name || "PHARMACIE LA FLORALE";
    const phPhone = company?.phone || "06 857 57 84";

    doc.fontSize(10).font("Courier-Bold").text(phName, { align: "center" });
    doc.fontSize(9).font("Courier").text(`TEL : ${phPhone}`, { align: "center" });
    doc.text("Dr Flora ONDELE", { align: "center" });
    doc.moveDown(0.5);

    const saleDate = new Date(sale.createdAt || Date.now());
    const dateOptions = { day: '2-digit', month: 'short', year: '2-digit', hour: '2-digit', minute: '2-digit' };
    let dateStr = saleDate.toLocaleDateString("fr-FR", dateOptions).replace(',', '');
    
    const opName = sale.pharmacist || "NELLE";
    doc.text(`OP: ${opName.substring(0, 10).toUpperCase()} le ${dateStr}`);
    doc.text(`Bon de livraison  Caisse 1`);
    doc.text("------------------------------------");
    doc.text(`Facture N ${sale.invoiceNumber} du ${saleDate.toLocaleDateString("fr-FR")}`);
    doc.moveDown(0.5);

    doc.text("Désign.    Prix  Qte %rem. Montant");
    (sale.items || []).forEach((item) => {
      const name = item.product?.name || item.productName || "Produit";
      doc.text(name.substring(0, 36));
      const price = (item.unitPrice || 0).toFixed(0);
      const qty = (item.quantity || 1).toString().padStart(2, '0');
      const total = (item.total || item.unitPrice * item.quantity || 0).toFixed(0);
      const lineStr = `           ${price} x ${qty}       ${total}`;
      doc.text(lineStr);
    });

    doc.moveDown(0.5);
    const totalAmount = (sale.total || 0).toFixed(0);
    doc.text(`Total:     ${totalAmount} Assur :          0 F`);
    doc.text("------------------------------------");
    const eur = ((sale.total || 0) / 655.957).toFixed(2);
    doc.text(`Total ticket: ${totalAmount} FCFA (${eur} Euros)`);
    const amountReceived = (sale.amountReceived || sale.total || 0).toFixed(0);
    doc.text(`Encaiss :     ${amountReceived} F`);
    doc.text(`A rendre:     ${(Math.max(0, (sale.amountReceived || sale.total) - sale.total)).toFixed(0)} F`);
    doc.text("===");
    doc.text("|||||| |||||||||| |||||||| ||| |||||", { align: "center" });
    doc.text(`*${sale.invoiceNumber}*`, { align: "center" });

    doc.moveDown();
    doc.text("MERCI ET PROMPTE GUERISON", { align: "center" });
    doc.text("Les produits achetés ne sont ni repris ni", { align: "center" });
    doc.text("echanges", { align: "center" });

    doc.end();
  });
}

module.exports = {
  buildInvoicePdfBuffer,
  buildReceiptPdfBuffer,
  createInvoiceFromOrder,
  generateInvoiceNumber,
  isOrderInvoiceable,
  resolvePaymentStatus,
  syncInvoiceForOrder,
  toInvoicePayload,
};
