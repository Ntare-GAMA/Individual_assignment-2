import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../listings/listing_detail_screen.dart';
import '../listings/listing_form_screen.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  static const _amber = Color(0xFFD4A84B);
  static const _cardColor = Color(0xFF1E2A3A);

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    final categories = ['All', ...ListingModel.categories];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kigali City',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ListingFormScreen()),
          );
        },
        backgroundColor: _amber,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected =
                    listingProvider.selectedCategory == category;
                final count = category == 'All'
                    ? listingProvider.listings.length
                    : listingProvider.listings
                        .where((l) => l.category == category)
                        .length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      count > 0 && category != 'All'
                          ? '$category $count'
                          : category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[400],
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => listingProvider.setCategory(category),
                    backgroundColor: _cardColor,
                    selectedColor: _amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color:
                            isSelected ? _amber : Colors.grey[700]!,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: listingProvider.setSearchQuery,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for a service',
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                filled: true,
                fillColor: _cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              listingProvider.selectedCategory == 'All'
                  ? 'Near You'
                  : 'Services',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Listings
          Expanded(
            child: _buildListingsContent(context, listingProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsContent(
      BuildContext context, ListingProvider listingProvider) {
    if (listingProvider.isLoading && listingProvider.listings.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: _amber));
    }

    if (listingProvider.error != null &&
        listingProvider.listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(listingProvider.error!,
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => listingProvider.listenToListings(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final listings = listingProvider.filteredListings;

    if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No listings found',
              style: TextStyle(fontSize: 18, color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your search or filter',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        final distance = listingProvider.getDistance(
            listing.latitude, listing.longitude);
        return _buildListingTile(context, listing, distance);
      },
    );
  }

  Widget _buildListingTile(
      BuildContext context, ListingModel listing, double distance) {
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
        padding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
              bottom:
                  BorderSide(color: Colors.grey[800]!, width: 0.5)),
        ),
        child: Column(
          children: [
            // Row 1: Name + rating number
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
                      listing.rating > 0
                          ? listing.rating.toStringAsFixed(1)
                          : '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.star, size: 16, color: _amber),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Row 2: Star icons + distance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < listing.rating.round()
                          ? Icons.star
                          : Icons.star_border,
                      size: 14,
                      color: _amber,
                    );
                  }),
                ),
                Text(
                  '${distance.toStringAsFixed(1)} km',
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
