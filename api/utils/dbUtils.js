const mongoose = require("mongoose");

/**
 * Exécute une fonction dans une transaction si possible, ou normalement sinon.
 * @param {Function} callback - La fonction à exécuter. Reçoit 'session' en argument.
 * @returns {Promise<any>} - Le résultat du callback.
 */
async function runInTransaction(callback) {
  let session = null;
  let useFallback = false;

  try {
    session = await mongoose.startSession();
    session.startTransaction();
  } catch (error) {
    // Si la session ne peut pas être créée (ex: pas de replica set)
    useFallback = true;
  }

  try {
    // Exécuter le callback avec la session (ou null si fallback)
    console.log(
      "[Transaction] Starting callback. session is function?",
      typeof session === "function"
    );
    const result = await callback(useFallback ? null : session);
    console.log("[Transaction] Callback completed.");

    // Valider la transaction si on en avait une
    if (session && !useFallback) {
      await session.commitTransaction();
    }

    return result;
  } catch (error) {
    // Annuler la transaction en cas d'erreur
    if (session && !useFallback) {
      try {
        await session.abortTransaction();
      } catch (abortError) {
        console.error("Erreur lors de l'annulation de la transaction:", abortError);
      }
    }

    // Si l'erreur est spécifiquement liée à l'absence de Replica Set au moment du startTransaction
    if (error.message.includes("Transaction numbers are only allowed on a replica set member")) {
      console.warn("⚠️ MongoDB Standalone détecté : Exécution sans transaction (non-atomique).");
      // On retente le callback sans session pour ce cas précis si on n'avait pas encore basculé en fallback
      if (!useFallback) {
        return callback(null);
      }
    }

    throw error;
  } finally {
    if (session) {
      session.endSession();
    }
  }
}

module.exports = { runInTransaction };
