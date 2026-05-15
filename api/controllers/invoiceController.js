const Invoice = require("../models/invoice");
const { buildInvoicePdfBuffer, toInvoicePayload } = require("../utils/invoiceService");
const { success, failure } = require("../utils/response");

function buildInvoiceQuery(req) {
  const query = req.user.role === "client"
    ? { userId: req.user._id }
    : { companyId: req.user.companyId };

  if (req.query.paymentStatus) {
    query.paymentStatus = req.query.paymentStatus;
  }
  if (req.query.orderStatus) {
    query.orderStatus = req.query.orderStatus;
  }
  if (req.query.clientId && req.user.role !== "client") {
    query.clientId = req.query.clientId;
  }
  if (req.query.startDate || req.query.endDate) {
    query.invoiceDate = {};
    if (req.query.startDate) {
      query.invoiceDate.$gte = new Date(req.query.startDate);
    }
    if (req.query.endDate) {
      query.invoiceDate.$lte = new Date(req.query.endDate);
    }
  }
  if (req.query.search) {
    query.$or = [
      { invoiceNumber: { $regex: req.query.search, $options: "i" } },
      { orderNumber: { $regex: req.query.search, $options: "i" } },
      { "clientSnapshot.fullName": { $regex: req.query.search, $options: "i" } },
    ];
  }

  return query;
}

exports.getMyInvoices = async (req, res, next) => {
  try {
    const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 20, 1), 100);
    const query = buildInvoiceQuery(req);

    const [invoices, total] = await Promise.all([
      Invoice.find(query)
        .sort({ invoiceDate: -1, createdAt: -1 })
        .limit(limit)
        .skip((page - 1) * limit),
      Invoice.countDocuments(query),
    ]);

    return success(res, {
      data: invoices.map(toInvoicePayload),
      extra: {
        pagination: {
          total,
          page,
          limit,
          pages: Math.max(1, Math.ceil(total / limit)),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.getInvoiceById = async (req, res, next) => {
  try {
    const query = req.user.role === "client"
      ? { _id: req.params.id, userId: req.user._id }
      : { _id: req.params.id, companyId: req.user.companyId };

    const invoice = await Invoice.findOne(query);
    if (!invoice) {
      return failure(res, { status: 404, message: "Facture introuvable" });
    }

    return success(res, { data: toInvoicePayload(invoice) });
  } catch (error) {
    next(error);
  }
};

exports.getInvoicePdf = async (req, res, next) => {
  try {
    const query = req.user.role === "client"
      ? { _id: req.params.id, userId: req.user._id }
      : { _id: req.params.id, companyId: req.user.companyId };

    const invoice = await Invoice.findOne(query);
    if (!invoice) {
      return failure(res, { status: 404, message: "Facture introuvable" });
    }

    const pdfBuffer = await buildInvoicePdfBuffer(invoice);
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", `inline; filename=\"${invoice.invoiceNumber}.pdf\"`);
    return res.send(pdfBuffer);
  } catch (error) {
    next(error);
  }
};
