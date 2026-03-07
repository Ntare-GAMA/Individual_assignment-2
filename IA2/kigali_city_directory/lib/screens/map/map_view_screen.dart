import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../listings/listing_detail_screen.dart';

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

  static const _amber = Color(0xFFD4A84B);
  static const _cardColor = Color(0xFF1E2A3A);

  // Kigali center
  static final LatLng _kigaliCenter = const LatLng(-1.9403, 29.8739);

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    final listings = listingProvider.filteredListings;

    final markers = listings.map((listing) {
      return Marker(
        point: LatLng(listing.latitude, listing.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            _showListingPopup(context, listing);
          },
          child: const Icon(Icons.location_on, color: Colors.red, size: 36),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Map View',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: listings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    'No listings to display on map',
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : FlutterMap(
              options: MapOptions(
                initialCenter: _kigaliCenter,
                initialZoom: 12,
                minZoom: 7,
                maxZoom: 18,
                cameraConstraint: CameraConstraint.contain(
                  bounds: LatLngBounds(
                    const LatLng(-2.8400, 28.8500),
                    const LatLng(-1.0500, 30.9000),
                  ),
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.kigali_city_directory',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
    );
  }

  void _showListingPopup(BuildContext context, dynamic listing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listing.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  listing.category,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star, size: 14, color: _amber),
                const SizedBox(width: 2),
                Text(
                  listing.rating > 0 ? listing.rating.toStringAsFixed(1) : '-',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingDetailScreen(listing: listing),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _amber,
                  foregroundColor: Colors.white,
                ),
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
