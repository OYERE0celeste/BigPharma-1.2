import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/review_model.dart';

class ReviewSection extends StatelessWidget {
  final ReviewSummary summary;
  final List<ReviewModel> reviews;
  final bool isLoading;
  final VoidCallback? onWriteReview;

  const ReviewSection({
    super.key,
    required this.summary,
    required this.reviews,
    this.isLoading = false,
    this.onWriteReview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Avis et retours clients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (onWriteReview != null)
              TextButton.icon(
                onPressed: onWriteReview,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Donner un avis'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              summary.averageRating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < summary.averageRating.round()
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
                Text(
                  '${summary.total} avis client',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (summary.averageServiceRating > 0)
                  Text(
                    'Service: ${summary.averageServiceRating.toStringAsFixed(1)}/5',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ],
        ),
        if (summary.dissatisfactionCount > 0) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${summary.dissatisfactionCount} retour(s) signalent une insatisfaction légère.',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (reviews.isEmpty)
          Text(
            'Aucun avis pour ce produit pour le moment.',
            style: TextStyle(color: Colors.grey[600]),
          )
        else
          ...reviews.take(4).map(_buildReviewItem),
      ],
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    final formatter = DateFormat('dd/MM/yyyy');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.clientName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                formatter.format(review.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: Colors.amber,
                size: 14,
              );
            }),
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(review.comment, style: const TextStyle(fontSize: 14)),
          ],
          if (review.serviceComment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Service: ${review.serviceComment}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
          if (review.hasResponse) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                review.response!.message,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
          const Divider(),
        ],
      ),
    );
  }
}
