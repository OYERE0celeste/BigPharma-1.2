const Joi = require("joi");

const email = Joi.string().email().required();
const password = Joi.string().min(8).max(72).required();

const loginSchema = Joi.object({
  email,
  password: Joi.string().required(),
});

const registerSchema = Joi.object({
  name: Joi.string().min(2).required(),
  email: Joi.string().email().required(),
  phone: Joi.string().min(8).required(),
  address: Joi.string().min(3).required(),
  city: Joi.string().allow("", null),
  country: Joi.string().allow("", null),
  fullName: Joi.string().min(2).required(),
  adminEmail: Joi.string().email().required(),
  password,
});

const registerClientSchema = Joi.object({
  fullName: Joi.string().min(2).required(),
  email: Joi.string().email().required(),
  phone: Joi.string().min(8).required(),
  password: Joi.string().min(6).required(),
  dateOfBirth: Joi.date().required(),
  gender: Joi.string().valid("male", "female").required(),
  address: Joi.string().allow("", null),
  companyId: Joi.string().required(),
});

const forgotSchema = Joi.object({
  email,
});

const resetSchema = Joi.object({
  token: Joi.string().required(),
  password,
});

const updateMeSchema = Joi.object({
  fullName: Joi.string().min(2).max(120).required(),
  email: Joi.string().email().required(),
  phoneNumber: Joi.string().allow("", null),
  phone: Joi.string().allow("", null),
  address: Joi.string().allow("", null),
});

const changePasswordSchema = Joi.object({
  currentPassword: Joi.string().required(),
  newPassword: password,
  confirmPassword: Joi.string().required(),
});

module.exports = {
  loginSchema,
  registerSchema,
  registerClientSchema,
  forgotSchema,
  resetSchema,
  updateMeSchema,
  changePasswordSchema,
};
