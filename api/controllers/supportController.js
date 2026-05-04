const SupportQuestion = require("../models/support");
const Client = require("../models/client");
const { success, failure } = require("../utils/response");

/**
 * Get all support questions
 */
exports.getQuestions = async (req, res, next) => {
  try {
    const { status, clientId: queryClientId } = req.query;
    let query = { companyId: req.user.companyId };

    // If client, only show their questions
    if (req.user.role === "client") {
      // Find client profile linked to this user
      const clientProfile = await Client.findOne({ userId: req.user._id });
      if (!clientProfile) {
        return failure(res, { status: 404, message: "Client profile not found" });
      }
      query.clientId = clientProfile._id;
    } else if (queryClientId) {
      // Pharmacy can filter by client
      query.clientId = queryClientId;
    }

    if (status) query.status = status;

    const questions = await SupportQuestion.find(query)
      .populate("clientId", "fullName phone email")
      .sort({ updatedAt: -1 });

    return success(res, { data: questions });
  } catch (error) {
    next(error);
  }
};

/**
 * Get question by ID
 */
exports.getQuestionById = async (req, res, next) => {
  try {
    const question = await SupportQuestion.findOne({
      _id: req.params.id,
      companyId: req.user.companyId,
    }).populate("clientId", "fullName phone email");

    if (!question) {
      return failure(res, { status: 404, message: "Question non trouvée" });
    }

    // Check authorization for client
    if (req.user.role === "client") {
      const clientProfile = await Client.findOne({ userId: req.user._id });
      if (!clientProfile || question.clientId._id.toString() !== clientProfile._id.toString()) {
        return failure(res, { status: 403, message: "Non autorisé" });
      }
    }

    return success(res, { data: question });
  } catch (error) {
    next(error);
  }
};

/**
 * Create new question (Client only)
 */
exports.createQuestion = async (req, res, next) => {
  try {
    const { subject, content, companyId } = req.body;

    if (req.user.role !== "client") {
      return failure(res, { status: 403, message: "Seuls les clients peuvent poser des questions" });
    }

    const clientProfile = await Client.findOne({ userId: req.user._id });
    if (!clientProfile) {
      return failure(res, { status: 404, message: "Profil client non trouvé" });
    }

    const question = await SupportQuestion.create({
      clientId: clientProfile._id,
      companyId: companyId || req.user.companyId,
      subject: subject || "Nouvelle question",
      messages: [
        {
          senderId: req.user._id,
          senderType: "client",
          content,
        },
      ],
    });

    return success(res, { status: 201, data: question });
  } catch (error) {
    next(error);
  }
};

/**
 * Add message to a question
 */
exports.addMessage = async (req, res, next) => {
  try {
    const { content } = req.body;
    const question = await SupportQuestion.findOne({
      _id: req.params.id,
      companyId: req.user.companyId,
    });

    if (!question) {
      return failure(res, { status: 404, message: "Question non trouvée" });
    }

    if (question.status === "ferme") {
      return failure(res, { status: 400, message: "Cette discussion est fermée" });
    }

    const senderType = req.user.role === "client" ? "client" : "pharmacie";
    
    // Authorization check for client
    if (senderType === "client") {
      const clientProfile = await Client.findOne({ userId: req.user._id });
      if (!clientProfile || question.clientId.toString() !== clientProfile._id.toString()) {
        return failure(res, { status: 403, message: "Non autorisé" });
      }
    }

    question.messages.push({
      senderId: req.user._id,
      senderType,
      content,
    });

    // Update status
    question.status = senderType === "pharmacie" ? "repondu" : "en_attente";
    await question.save();

    return success(res, { data: question });
  } catch (error) {
    next(error);
  }
};

/**
 * Close question (Pharmacy/Admin only)
 */
exports.closeQuestion = async (req, res, next) => {
  try {
    const question = await SupportQuestion.findOneAndUpdate(
      { _id: req.params.id, companyId: req.user.companyId },
      { status: "ferme" },
      { new: true }
    );

    if (!question) {
      return failure(res, { status: 404, message: "Question non trouvée" });
    }

    return success(res, { data: question });
  } catch (error) {
    next(error);
  }
};
