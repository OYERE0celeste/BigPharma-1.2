const Client = require("../models/client");
const Order = require("../models/order");
const Product = require("../models/product");
const Review = require("../models/review");
const { sendNotification, notifyStaff } = require("../utils/notificationHelper");
const { success, failure } = require("../utils/response");

const ELIGIBLE_REVIEW_ORDER_STATUSES = ["validee"];

async function resolveClient(req) {
  return Client.findOne({ userId: req.user._id, companyId: req.user.companyId });
}

async function findEligibleOrder({ req, productId, orderId }) {
  const query = {
    userId: req.user._id,
    companyId: req.user.companyId,
    status: { $in: ELIGIBLE_REVIEW_ORDER_STATUSES },
    "products.productId": productId,
  };

  if (orderId) {
    query._id = orderId;
  }

  return Order.findOne(query).sort({ createdAt: -1 });
}

exports.getProductReviews = async (req, res, next) => {
  try {
    const product = await Product.findById(req.params.productId);
    if (!product || !product.isActive) {
      return failure(res, { status: 404, message: "Produit introuvable" });
    }

    const reviews = await Review.find({ productId: product._id })
      .sort({ createdAt: -1 })
      .limit(Math.min(parseInt(req.query.limit, 10) || 50, 100));

    const total = reviews.length;
    const averageRating = total
      ? reviews.reduce((sum, review) => sum + review.rating, 0) / total
      : 0;
    const serviceRatings = reviews.filter((review) => Number.isFinite(review.serviceRating));
    const averageServiceRating = serviceRatings.length
      ? serviceRatings.reduce((sum, review) => sum + review.serviceRating, 0) / serviceRatings.length
      : 0;
    const dissatisfactionCount = reviews.filter(
      (review) => review.dissatisfactionLevel === "legere"
    ).length;

    return success(res, {
      data: reviews,
      extra: {
        summary: {
          averageRating,
          averageServiceRating,
          total,
          dissatisfactionCount,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.getMyReviews = async (req, res, next) => {
  try {
    const reviews = await Review.find({ userId: req.user._id }).sort({ createdAt: -1 });
    return success(res, { data: reviews });
  } catch (error) {
    next(error);
  }
};

exports.getCompanyReviews = async (req, res, next) => {
  try {
    const query = { companyId: req.user.companyId };

    if (req.query.rating) {
      query.rating = parseInt(req.query.rating, 10);
    }
    if (req.query.dissatisfactionOnly === "true") {
      query.dissatisfactionLevel = "legere";
    }
    if (req.query.search) {
      query.$or = [
        { productName: { $regex: req.query.search, $options: "i" } },
        { clientName: { $regex: req.query.search, $options: "i" } },
        { comment: { $regex: req.query.search, $options: "i" } },
      ];
    }

    const reviews = await Review.find(query).sort({ createdAt: -1 }).limit(200);
    return success(res, { data: reviews });
  } catch (error) {
    next(error);
  }
};

exports.createReview = async (req, res, next) => {
  try {
    if (req.user.role !== "client") {
      return failure(res, { status: 403, message: "Seuls les clients peuvent laisser un avis" });
    }

    const {
      productId,
      orderId,
      rating,
      comment,
      serviceRating,
      serviceComment,
      dissatisfactionLevel,
      wouldRecommend,
    } = req.body;

    if (!productId) {
      return failure(res, { status: 400, message: "Produit requis" });
    }

    const normalizedRating = parseInt(rating, 10);
    if (!Number.isInteger(normalizedRating) || normalizedRating < 1 || normalizedRating > 5) {
      return failure(res, { status: 400, message: "La note produit doit etre comprise entre 1 et 5" });
    }

    if (serviceRating !== undefined && serviceRating !== null) {
      const normalizedServiceRating = parseInt(serviceRating, 10);
      if (!Number.isInteger(normalizedServiceRating) || normalizedServiceRating < 1 || normalizedServiceRating > 5) {
        return failure(res, { status: 400, message: "La note service doit etre comprise entre 1 et 5" });
      }
    }

    const product = await Product.findOne({ _id: productId, isActive: true });
    if (!product) {
      return failure(res, { status: 404, message: "Produit introuvable" });
    }

    const client = await resolveClient(req);
    if (!client) {
      return failure(res, { status: 404, message: "Profil client introuvable" });
    }

    const eligibleOrder = await findEligibleOrder({ req, productId, orderId });
    if (!eligibleOrder) {
      return failure(res, {
        status: 400,
        message: "Vous devez avoir une commande validee pour noter ce produit",
      });
    }

    const existingReview = await Review.findOne({
      userId: req.user._id,
      productId: product._id,
      orderId: eligibleOrder._id,
    });
    if (existingReview) {
      return failure(res, {
        status: 409,
        message: "Vous avez deja laisse un avis pour ce produit dans cette commande",
      });
    }

    const review = await Review.create({
      productId: product._id,
      orderId: eligibleOrder._id,
      userId: req.user._id,
      clientId: client._id,
      companyId: product.companyId,
      productName: product.name,
      clientName: client.fullName,
      rating: normalizedRating,
      comment: comment || "",
      serviceRating: serviceRating !== undefined && serviceRating !== null ? parseInt(serviceRating, 10) : undefined,
      serviceComment: serviceComment || "",
      dissatisfactionLevel: dissatisfactionLevel === "legere" ? "legere" : "aucune",
      wouldRecommend: wouldRecommend !== false,
    });

    await notifyStaff({
      companyId: product.companyId,
      title: "Nouvel avis client",
      message: `${client.fullName} a note ${product.name} (${normalizedRating}/5).`,
      type: "review",
      data: { reviewId: review._id, productId: product._id, orderId: eligibleOrder._id },
    });

    return success(res, { status: 201, data: review });
  } catch (error) {
    next(error);
  }
};

exports.respondToReview = async (req, res, next) => {
  try {
    const { message } = req.body;
    if (!message || !message.trim()) {
      return failure(res, { status: 400, message: "Une reponse est requise" });
    }

    const review = await Review.findOneAndUpdate(
      { _id: req.params.id, companyId: req.user.companyId },
      {
        response: {
          message: message.trim(),
          respondedBy: req.user._id,
          responderName: req.user.fullName,
          respondedAt: new Date(),
        },
      },
      { new: true }
    );

    if (!review) {
      return failure(res, { status: 404, message: "Avis introuvable" });
    }

    await sendNotification({
      userId: review.userId,
      companyId: review.companyId,
      title: "Reponse a votre avis",
      message: `La pharmacie a repondu a votre avis sur ${review.productName}.`,
      type: "review",
      data: { reviewId: review._id, productId: review.productId },
    });

    return success(res, { data: review });
  } catch (error) {
    next(error);
  }
};
