import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../listings/listing_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  static const _amber = Color(0xFFD4A84B);
  static const _cardColor = Color(0xFF1E2A3A);

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    final bookmarked = listingProvider.bookmarkedListings;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookmarks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Bookmarks toggle header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bookmarks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Switch(
                  value: bookmarked.isNotEmpty,
                  onChanged: null,
                  activeColor: _amber,
                ),
              ],
            ),
          ),
          // Bookmarked listings
          Expanded(
            child: bookmarked.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border,
                            size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text(
                          'No bookmarks yet',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bookmark services to find them quickly',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: bookmarked.length,
                    itemBuilder: (context, index) {
                      final listing = bookmarked[index];
                      final distance = listingProvider.getDistance(
                          listing.latitude, listing.longitude);
                      return _buildBookmarkTile(
                          context, listing, distance, listingProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkTile(BuildContext context, listing, double distance,
      ListingProvider listingProvider) {
    final authProvider = context.read<AuthProvider>();
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Colors.grey[800]!, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                        '${distance.toStringAsFixed(1)} km',
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark, color: _amber),
              onPressed: () {
                if (authProvider.user != null) {
                  listingProvider.toggleBookmark(
                      authProvider.user!.uid, listing.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
