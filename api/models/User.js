const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const UserSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: [true, "Full name is required"],
      trim: true,
    },
    email: {
      type: String,
      required: [true, "Email is required"],
      unique: true,
      lowercase: true,
      match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, "Provide a valid email"],
    },
    passwordHash: {
      type: String,
      required: [true, "Password is required"],
      select: false,
    },
    role: {
      type: String,
      enum: ["admin", "pharmacien", "assistant", "caissier", "client"],
      default: "pharmacien",
    },
    companyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Company",
      required: [true, "Company is required"],
    },
    phone: {
      type: String,
      trim: true,
      maxlength: 200, // Increased for encrypted content
      default: "",
      set: (v) => require("../utils/encryption").encrypt(v),
      get: (v) => require("../utils/encryption").decrypt(v),
    },
    address: {
      type: String,
      trim: true,
      maxlength: 500, // Increased for encrypted content
      default: "",
      set: (v) => require("../utils/encryption").encrypt(v),
      get: (v) => require("../utils/encryption").decrypt(v),
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    permissions: {
      type: Map,
      of: Boolean,
      default: {},
    },
    twoFactorEnabled: {
      type: Boolean,
      default: false,
    },
    lastLoginAt: {
      type: Date,
    },
    passwordResetToken: {
      type: String,
      select: false,
    },
    passwordResetExpires: {
      type: Date,
      select: false,
    },
    refreshTokens: [
      {
        token: { type: String, required: true },
        expiresAt: { type: Date, required: true },
        createdAt: { type: Date, default: Date.now },
        replacedByToken: { type: String },
        revokedAt: { type: Date },
      },
    ],
  },
  {
    timestamps: true,
    toJSON: { getters: true },
    toObject: { getters: true },
  }
);

UserSchema.pre("save", async function hashPasswordBeforeSave() {
  if (!this.isModified("passwordHash")) {
    return;
  }

  const salt = await bcrypt.genSalt(10);
  this.passwordHash = await bcrypt.hash(this.passwordHash, salt);
});

UserSchema.methods.matchPassword = async function matchPassword(enteredPassword) {
  return bcrypt.compare(enteredPassword, this.passwordHash);
};

module.exports = mongoose.model("User", UserSchema);
