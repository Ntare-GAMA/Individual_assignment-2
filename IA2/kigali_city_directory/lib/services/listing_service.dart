import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
import '../models/review_model.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _listingsRef => _firestore.collection('listings');

  // Create a new listing
  Future<String> createListing(ListingModel listing) async {
    final docRef = await _listingsRef.add(listing.toMap());
    return docRef.id;
  }

  // Seed sample Kigali listings if the collection is empty
  Future<void> seedListingsIfEmpty(String userId) async {
    final snapshot = await _listingsRef.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final now = DateTime.now();
    final sampleListings = [
      ListingModel(
        id: '',
        name: 'King Faisal Hospital',
        category: 'Hospital',
        address: 'KG 544 St, Kigali',
        contactNumber: '+250 788 000 001',
        description: 'A leading referral hospital in Kigali providing quality healthcare services.',
        latitude: -1.9478,
        longitude: 29.8567,
        createdBy: userId,
        timestamp: now,
      ),
      ListingModel(
        id: '',
        name: 'CHUK - University Teaching Hospital',
        category: 'Hospital',
        address: 'KN 4 Ave, Kigali',
        contactNumber: '+250 788 000 002',
        description: 'Centre Hospitalier Universitaire de Kigali, Rwanda\'s largest public hospital.',
        latitude: -1.9530,
        longitude: 29.8640,
        createdBy: userId,
        timestamp: now,
      ),
      ListingModel(
        id: '',
        name: 'Kigali City Library',
        category: 'Library',
        address: 'KN 3 Ave, Kigali',
        contactNumber: '+250 788 000 003',
        description: 'Public library with a vast collection of books and digital resources.',
        latitude: -1.9500,
        longitude: 29.8750,
        createdBy: userId,
        timestamp: now,
      ),
      ListingModel(
        id: '',
        name: 'Remera Police Station',
        category: 'Police Station',
        address: 'KG 11 Ave, Remera, Kigali',
        contactNumber: '+250 788 000 004',
        description: 'Rwanda National Police station serving the Remera sector.',
        latitude: -1.9560,
        longitude: 29.8930,
        createdBy: userId,
        timestamp: now,
      ),
      ListingModel(
        id: '',
        name: 'The Hut Restaurant',
        category: 'Restaurant',
        address: 'KG 9 Ave, Kigali',
        contactNumber: '+250 788 000 005',
        description: 'Popular restaurant offering traditional Rwandan and international cuisine.',
        latitude: -1.9450,
        longitude: 29.8800,
        createdBy: userId,
        timestamp: now,
      ),
      ListingModel(
        id: '',
        name: 'Bourbon Coffee Kiyovu',
        category: 'Café',
        address: 'KN 27 St, Kiyovu, Kigali',
        contactNumber: '+250 788 000 006',
        description: 'Premium Rwandan coffee shop with pastries and light meals.',
        latitude: -1.9580,
        longitude: 29.8630,
        createdBy: userId,
        timestamp: now,
      ),
      ListingModel(
        id: '',
        name: 'Pharmacie Conseil Kigali',
        category: 'Pharmacy',
        address: 'KN 4 Ave, Centre Ville, Kigali',
        contactNumber: '+250 788 000 007',
        description: 'Well-stocked pharmacy providing prescription and over-the-counter medications.',
        latitude: -1.9510,
        longitude: 29.8710,
        createdBy: userId,
        timestamp: now,
      ),
      ListingModel(
        id: '',
        name: 'Kigali Genocide Memorial',
        category: 'Tourist Attraction',
        address: 'KG 14 Ave, Gisozi, Kigali',
        contactNumber: '+250 788 000 008',
        description: 'A memorial to the victims of the 1994 genocide, with exhibitions and gardens.',
        latitude: -1.9340,
        longitude: 29.8610,
        createdBy: userId,
        timestamp: now,
      ),
      ListingModel(
        id: '',
        name: 'Nyamirambo Park',
        category: 'Park',
        address: 'Nyamirambo, Kigali',
        contactNumber: '+250 788 000 009',
        description: 'A green park in Nyamirambo ideal for walks and relaxation.',
        latitude: -1.9720,
        longitude: 29.8500,
        createdBy: userId,
        timestamp: now,
      ),
      ListingModel(
        id: '',
        name: 'WASAC Utility Office',
        category: 'Utility Office',
        address: 'KG 4 Ave, Kacyiru, Kigali',
        contactNumber: '+250 788 000 010',
        description: 'Water and Sanitation Corporation office for billing and service inquiries.',
        latitude: -1.9370,
        longitude: 29.8720,
        createdBy: userId,
        timestamp: now,
      ),
    ];

    final batch = _firestore.batch();
    for (final listing in sampleListings) {
      final docRef = _listingsRef.doc();
      batch.set(docRef, listing.toMap());
    }
    await batch.commit();
  }

  // Get all listings as a real-time stream
  Stream<List<ListingModel>> getListingsStream() {
    return _listingsRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ListingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get listings created by a specific user
  Stream<List<ListingModel>> getUserListingsStream(String userId) {
    return _listingsRef
        .where('createdBy', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ListingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Update an existing listing
  Future<void> updateListing(ListingModel listing) async {
    await _listingsRef.doc(listing.id).update(listing.toMap());
  }

  // Delete a listing
  Future<void> deleteListing(String listingId) async {
    await _listingsRef.doc(listingId).delete();
  }

  // Reviews
  Stream<List<ReviewModel>> getReviewsStream(String listingId) {
    return _listingsRef
        .doc(listingId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addReview(String listingId, ReviewModel review) async {
    await _listingsRef
        .doc(listingId)
        .collection('reviews')
        .add(review.toMap());

    // Recalculate average rating
    final reviewsSnap =
        await _listingsRef.doc(listingId).collection('reviews').get();
    final ratings = reviewsSnap.docs
        .map((d) => (d.data()['rating'] as num).toDouble())
        .toList();
    final avgRating =
        ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;

    await _listingsRef.doc(listingId).update({
      'rating': avgRating,
      'reviewCount': ratings.length,
    });
  }

  // Bookmarks
  Stream<List<String>> getBookmarksStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Future<void> addBookmark(String userId, String listingId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(listingId)
        .set({'timestamp': FieldValue.serverTimestamp()});
  }

  Future<void> removeBookmark(String userId, String listingId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(listingId)
        .delete();
  }
}
