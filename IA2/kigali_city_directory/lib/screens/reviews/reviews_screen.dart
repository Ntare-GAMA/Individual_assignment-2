import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../listings/listing_detail_screen.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  static const _amber = Color(0xFFD4A84B);

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    // Show all listings that have reviews, sorted by rating
    final reviewedListings = listingProvider.listings
        .where((l) => l.reviewCount > 0)
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reviews',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: reviewedListings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined,
                      size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    'No reviews yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Visit a service to leave a review',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reviewedListings.length,
              itemBuilder: (context, index) {
                final listing = reviewedListings[index];
                return _buildReviewedTile(context, listing, listingProvider);
              },
            ),
    );
  }

  Widget _buildReviewedTile(
      BuildContext context, listing, ListingProvider listingProvider) {
    final distance =
        listingProvider.getDistance(listing.latitude, listing.longitude);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailScreen(listing: listing),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Colors.grey[800]!, width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    listing.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      listing.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 16, color: _amber),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Stars + review count + distance
            Row(
              children: [
                ...List.generate(5, (i) {
                  return Icon(
                    i < listing.rating.round()
                        ? Icons.star
                        : Icons.star_border,
                    size: 14,
                    color: _amber,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${listing.reviewCount} reviews',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                const Spacer(),
                Text(
                  '${distance.toStringAsFixed(1)} km',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
