const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const UserSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: [true, "Le nom complet est requis"],
      trim: true,
    },
    email: {
      type: String,
      required: [true, "L'email est requis"],
      unique: true,
      lowercase: true,
      match: [/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/, "Veuillez fournir un email valide"],
    },
    passwordHash: {
      type: String,
      required: [true, "Le mot de passe est requis"],
    },
    role: {
      type: String,
      enum: ["admin", "pharmacien", "assistant", "caissier"],
      default: "pharmacien",
    },
    companyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Company",
      required: [true, "La société est requise"],
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    lastLoginAt: {
      type: Date,
    },
  },
  {
    timestamps: true,
  }
);

// Indexations

//UserSchema.index({ companyId: 1 });

// Hachage du mot de passe avant enregistrement
UserSchema.pre("save", async function () {
  if (!this.isModified("passwordHash")) {
    console.log(`[User] Pre-save: passwordHash not modified for ${this.email}`);
    return;
  }

  console.log(`[User] Pre-save: Hashing password for ${this.email}, length: ${this.passwordHash.length}`);
  try {
    // bcryptjs supports both callback and promise-based usage
    const salt = await bcrypt.genSalt(10);
    this.passwordHash = await bcrypt.hash(this.passwordHash, salt);
    console.log(`[User] Pre-save: Password hashed successfully`);
  } catch (err) {
    console.error(`[User] Hashing error: ${err.message}`);
    throw err; // Mongoose picks up thrown errors in async hooks
  }
});

// Méthode pour comparer les mots de passe
UserSchema.methods.matchPassword = async function (enteredPassword) {
  console.log(`[User] Comparing passwords for user: ${this.email}`);
  console.log(`[User] Hash in DB: ${this.passwordHash ? "PRESENT" : "MISSING"}`);
  try {
    const isMatch = await bcrypt.compare(enteredPassword, this.passwordHash);
    console.log(`[User] Password match result: ${isMatch}`);
    return isMatch;
  } catch (err) {
    console.error(`[User] Bcrypt error: ${err.message}`);
    throw err;
  }
};

module.exports = mongoose.model("User", UserSchema);
