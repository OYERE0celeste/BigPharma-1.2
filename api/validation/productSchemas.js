const Joi = require("joi");

const lotSchema = Joi.object({
  lotNumber: Joi.string().required(),
  manufacturingDate: Joi.date().required(),
  expirationDate: Joi.date().required(),
  quantity: Joi.number().min(0).required(),
  quantityAvailable: Joi.number().min(0).required(),
  costPrice: Joi.number().min(0).required(),
});

exports.createProductSchema = Joi.object({
  name: Joi.string().required(),
  category: Joi.string().required(),
  description: Joi.string().allow(""),
  barcode: Joi.string().allow(""),
  prescriptionRequired: Joi.boolean(),
  purchasePrice: Joi.number().min(0).required(),
  sellingPrice: Joi.number().min(0).required(),
  lowStockThreshold: Joi.number().min(0),
  lots: Joi.array().items(lotSchema),
});

exports.updateProductSchema = Joi.object({
  name: Joi.string(),
  category: Joi.string(),
  description: Joi.string().allow(""),
  barcode: Joi.string().allow(""),
  prescriptionRequired: Joi.boolean(),
  purchasePrice: Joi.number().min(0),
  sellingPrice: Joi.number().min(0),
  lowStockThreshold: Joi.number().min(0),
  isActive: Joi.boolean(),
});
