const Joi = require("joi");

const email = Joi.string().email().required();
const password = Joi.string().min(8).max(72).required();

// `identifier` accepte email OU nom d'utilisateur
// On garde aussi `email` pour la rétrocompatibilité avec les apps existantes
const loginSchema = Joi.object({
  identifier: Joi.string().min(3).max(254),
  email: Joi.string().email(),
  password: Joi.string().required(),
}).or("identifier", "email"); // au moins l'un des deux est requis

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
  password,
  dateOfBirth: Joi.date().required(),
  gender: Joi.string().valid("male", "female").required(),
  address: Joi.string().allow("", null),
  companyId: Joi.string().required(),
});

const createStaffSchema = Joi.object({
  fullName: Joi.string().min(2).required(),
  email: Joi.string().email().required(),
  password,
  role: Joi.string()
    .valid(
      "administrateur",
      "pharmacien",
      "caissier",
      "gestionnaire de stock",
      "assistante de gestion",
      "client"
    )
    .required(),
  phone: Joi.string().allow("", null),
  address: Joi.string().allow("", null),
  permissions: Joi.object().optional(),
});

const forgotSchema = Joi.object({
  // Accepte email OU nom d'utilisateur
  identifier: Joi.string().min(3).max(254),
  email: Joi.string().email(),
}).or("identifier", "email");

const resetSchema = Joi.object({
  otp: Joi.string().length(6).pattern(/^[0-9]+$/).messages({
    "string.length": "Le code OTP doit contenir exactement 6 chiffres",
    "string.pattern.base": "Le code OTP ne doit contenir que des chiffres",
  }),
  token: Joi.string(), // Compatibilité avec l'ancien format
  password,
  confirmPassword: Joi.string().optional(),
}).or("otp", "token");

const updateMeSchema = Joi.object({
  fullName: Joi.string().min(2).max(120).required(),
  email: Joi.string().email().required(),
  username: Joi.string()
    .min(3)
    .max(30)
    .lowercase()
    .pattern(/^[a-z0-9_.]+$/)
    .allow("", null)
    .messages({
      "string.pattern.base": "Le nom d'utilisateur ne peut contenir que des lettres, chiffres, points et underscores",
    }),
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
  createStaffSchema,
  forgotSchema,
  resetSchema,
  updateMeSchema,
  changePasswordSchema,
};
