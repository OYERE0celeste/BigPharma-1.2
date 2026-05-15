class ReviewResponse {
  final String message;
  final String responderName;
  final DateTime? respondedAt;

  const ReviewResponse({
    required this.message,
    required this.responderName,
    this.respondedAt,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    return ReviewResponse(
      message: (data['message'] ?? '').toString(),
      responderName: (data['responderName'] ?? '').toString(),
      respondedAt: data['respondedAt'] != null
          ? DateTime.tryParse(data['respondedAt'].toString())
          : null,
    );
  }
}

class ReviewModel {
  final String id;
  final String productId;
  final String orderId;
  final String productName;
  final String clientName;
  final int rating;
  final String comment;
  final int? serviceRating;
  final String serviceComment;
  final String dissatisfactionLevel;
  final bool wouldRecommend;
  final ReviewResponse? response;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.productId,
    required this.orderId,
    required this.productName,
    required this.clientName,
    required this.rating,
    required this.comment,
    this.serviceRating,
    required this.serviceComment,
    required this.dissatisfactionLevel,
    required this.wouldRecommend,
    this.response,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: (json['_id'] ?? '').toString(),
      productId: (json['productId'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      clientName: (json['clientName'] ?? 'Client').toString(),
      rating: ((json['rating'] ?? 0) as num).toInt(),
      comment: (json['comment'] ?? '').toString(),
      serviceRating: json['serviceRating'] != null
          ? (json['serviceRating'] as num).toInt()
          : null,
      serviceComment: (json['serviceComment'] ?? '').toString(),
      dissatisfactionLevel: (json['dissatisfactionLevel'] ?? 'aucune')
          .toString(),
      wouldRecommend: json['wouldRecommend'] != false,
      response: json['response'] is Map<String, dynamic>
          ? ReviewResponse.fromJson(json['response'] as Map<String, dynamic>)
          : null,
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  bool get hasResponse =>
      response != null && response!.message.trim().isNotEmpty;
  bool get isLightDissatisfaction => dissatisfactionLevel == 'legere';
}

class ReviewSummary {
  final double averageRating;
  final double averageServiceRating;
  final int total;
  final int dissatisfactionCount;

  const ReviewSummary({
    required this.averageRating,
    required this.averageServiceRating,
    required this.total,
    required this.dissatisfactionCount,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    return ReviewSummary(
      averageRating: ((data['averageRating'] ?? 0) as num).toDouble(),
      averageServiceRating: ((data['averageServiceRating'] ?? 0) as num)
          .toDouble(),
      total: ((data['total'] ?? 0) as num).toInt(),
      dissatisfactionCount: ((data['dissatisfactionCount'] ?? 0) as num)
          .toInt(),
    );
  }
}
