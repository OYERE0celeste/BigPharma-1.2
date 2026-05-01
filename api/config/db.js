const mongoose = require("mongoose");

const connectDB = async () => {
  const mongoUri = process.env.MONGODB_URI;

  if (!mongoUri) {
    throw new Error("MONGODB_URI is required");
  }

  try {
    await mongoose.connect(mongoUri);
    console.log(
      `\x1b[32m[DB] MongoDB connecté avec succès sur la base : ${mongoose.connection.name}\x1b[0m`
    );
  } catch (error) {
    console.error("\x1b[31m[DB] Erreur de connexion MongoDB :\x1b[0m", error);
    throw error;
  }
};

module.exports = connectDB;
