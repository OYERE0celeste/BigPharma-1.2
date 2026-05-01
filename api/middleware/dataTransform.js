// Middleware pour harmoniser les types de données entre MongoDB et Flutter
const normalizeSupplierData = (data) => {
  if (!data) return data;

  const normalized = { ...data };

  // S'assurer que tous les champs texte sont bien des chaînes
  const stringFields = [
    "name",
    "contactName",
    "phone",
    "email",
    "address",
    "city",
    "country",
    "notes",
  ];
  stringFields.forEach((field) => {
    if (normalized[field] !== null && normalized[field] !== undefined) {
      normalized[field] = normalized[field].toString();
    }
  });

  // S'assurer que les champs numériques sont bien des nombres
  const numberFields = ["totalOrders", "totalAmount"];
  numberFields.forEach((field) => {
    if (normalized[field] !== null && normalized[field] !== undefined) {
      const num = Number(normalized[field]);
      normalized[field] = isNaN(num) ? 0 : num;
    }
  });

  // Gérer l'ID (MongoDB utilise _id)
  if (normalized._id && !normalized.id) {
    normalized.id = normalized._id.toString();
  }
  if (normalized.id !== null && normalized.id !== undefined) {
    normalized.id = normalized.id.toString();
  }

  // Normaliser le statut
  if (normalized.status) {
    const validStatuses = ["active", "inactive", "suspended"];
    normalized.status = validStatuses.includes(normalized.status.toString())
      ? normalized.status.toString()
      : "active";
  }

  return normalized;
};

const _toStringOrEmpty = (value) => {
  if (value === null || value === undefined) return "";
  return value.toString();
};

const _toNumberOrZero = (value) => {
  if (value === null || value === undefined || value === "") return 0;
  const n = Number(value);
  return Number.isFinite(n) ? n : 0;
};

const _toBoolean = (value) => {
  if (value === null || value === undefined) return false;
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return value !== 0;
  const s = value.toString().trim().toLowerCase();
  return s === "true" || s === "1" || s === "yes" || s === "y";
};

const _toIsoDateStringOrNull = (value) => {
  if (value === null || value === undefined || value === "") return null;
  const d = value instanceof Date ? value : new Date(value);
  return Number.isNaN(d.getTime()) ? null : d.toISOString();
};

// Normalisation Client (requêtes + réponses) pour correspondre aux modèles Flutter
const normalizeClientData = (data) => {
  if (!data) return data;

  const normalized = { ...data };

  // Harmoniser l'ID
  if (normalized._id && !normalized.id) {
    normalized.id = normalized._id.toString();
  }
  if (normalized.id !== null && normalized.id !== undefined) {
    normalized.id = normalized.id.toString();
  }

  // Champs attendus (Flutter)
  normalized.fullName = _toStringOrEmpty(normalized.fullName).trim();

  // Téléphone: uniquement chiffres
  const phoneRaw = _toStringOrEmpty(normalized.phone).trim();
  normalized.phone = phoneRaw.replace(/\D/g, "");

  normalized.address = _toStringOrEmpty(normalized.address).trim();

  // Enum gender (obligatoire)
  const validGenders = ["male", "female"];
  const genderStr = _toStringOrEmpty(normalized.gender).trim();
  normalized.gender = validGenders.includes(genderStr) ? genderStr : "male";

  // Bool (obligatoire)
  normalized.hasMedicalHistory = _toBoolean(normalized.hasMedicalHistory);

  // Date (obligatoire) -> ISO string (parseable dans Flutter)
  const dobIso = _toIsoDateStringOrNull(normalized.dateOfBirth);
  normalized.dateOfBirth = dobIso ?? _toIsoDateStringOrNull(new Date());

  return normalized;
};

const _transformEnvelope = (data, normalizer) => {
  if (!data) return data;
  // Cas 1: réponses "brutes" (tableau ou document)
  if (Array.isArray(data)) return data.map((item) => normalizer(item));
  if (data && typeof data === "object" && data.data !== undefined) {
    // Cas 2: enveloppe { success, message, data, ... }
    const out = { ...data };
    if (Array.isArray(out.data)) out.data = out.data.map((item) => normalizer(item));
    else if (out.data && typeof out.data === "object") out.data = normalizer(out.data);
    return out;
  }
  if (data && typeof data === "object") return normalizer(data);
  return data;
};

// Middleware Express pour transformer les réponses fournisseurs
const transformSupplierResponse = (req, res, next) => {
  const originalJson = res.json;
  res.json = function (data) {
    if (data && data.success && data.data) {
      if (Array.isArray(data.data)) {
        data.data = data.data.map(normalizeSupplierData);
      } else {
        data.data = normalizeSupplierData(data.data);
      }
    }
    return originalJson.call(this, data);
  };
  next();
};

// Middleware Express pour transformer les réponses clients
const transformClientResponse = (req, res, next) => {
  const originalJson = res.json;
  res.json = function (data) {
    if (data && data.success && data.data) {
      if (Array.isArray(data.data)) {
        data.data = data.data.map(normalizeClientData);
      } else {
        data.data = normalizeClientData(data.data);
      }
    }
    return originalJson.call(this, data);
  };
  next();
};

module.exports = {
  normalizeSupplierData,
  transformSupplierResponse,
  normalizeClientData,
  transformClientResponse,
};
