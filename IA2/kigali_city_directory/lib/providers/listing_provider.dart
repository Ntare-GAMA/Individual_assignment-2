import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../models/review_model.dart';
import '../services/listing_service.dart';

class ListingProvider extends ChangeNotifier {
  final ListingService _listingService = ListingService();

  List<ListingModel> _listings = [];
  List<ListingModel> _userListings = [];
  List<ReviewModel> _currentReviews = [];
  Set<String> _bookmarkedIds = {};
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  StreamSubscription? _listingsSubscription;
  StreamSubscription? _userListingsSubscription;
  StreamSubscription? _reviewsSubscription;
  StreamSubscription? _bookmarksSubscription;

  static const double _kigaliLat = -1.9403;
  static const double _kigaliLng = 29.8739;

  List<ListingModel> get listings => _listings;
  List<ListingModel> get userListings => _userListings;
  List<ReviewModel> get currentReviews => _currentReviews;
  Set<String> get bookmarkedIds => _bookmarkedIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<ListingModel> get bookmarkedListings {
    return _listings.where((l) => _bookmarkedIds.contains(l.id)).toList();
  }

  // Filtered listings based on search and category
  List<ListingModel> get filteredListings {
    var filtered = List<ListingModel>.from(_listings);

    if (_selectedCategory != 'All') {
      filtered =
          filtered.where((l) => l.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((l) => l.name.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  double getDistance(double lat, double lng) {
    const R = 6371.0;
    final dLat = _toRad(lat - _kigaliLat);
    final dLng = _toRad(lng - _kigaliLng);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(_kigaliLat)) *
            cos(_toRad(lat)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRad(double deg) => deg * pi / 180;

  // Start listening to all listings
  void listenToListings() {
    _isLoading = true;
    notifyListeners();

    _listingsSubscription?.cancel();
    _listingsSubscription = _listingService.getListingsStream().listen(
      (listings) {
        _listings = listings;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load listings: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Seed sample data if Firestore is empty
  Future<void> seedIfEmpty(String userId) async {
    try {
      await _listingService.seedListingsIfEmpty(userId);
    } catch (e) {
      // Ignore seed errors — data will be added manually
    }
  }

  // Start listening to user-specific listings
  void listenToUserListings(String userId) {
    _userListingsSubscription?.cancel();
    _userListingsSubscription =
        _listingService.getUserListingsStream(userId).listen(
      (listings) {
        _userListings = listings;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load your listings: $e';
        notifyListeners();
      },
    );
  }

  void listenToReviews(String listingId) {
    _reviewsSubscription?.cancel();
    _reviewsSubscription =
        _listingService.getReviewsStream(listingId).listen(
      (reviews) {
        _currentReviews = reviews;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load reviews: $e';
        notifyListeners();
      },
    );
  }

  void listenToBookmarks(String userId) {
    _bookmarksSubscription?.cancel();
    _bookmarksSubscription =
        _listingService.getBookmarksStream(userId).listen(
      (ids) {
        _bookmarkedIds = ids.toSet();
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load bookmarks: $e';
        notifyListeners();
      },
    );
  }

  Future<bool> toggleBookmark(String userId, String listingId) async {
    try {
      if (_bookmarkedIds.contains(listingId)) {
        await _listingService.removeBookmark(userId, listingId);
        _bookmarkedIds.remove(listingId);
      } else {
        await _listingService.addBookmark(userId, listingId);
        _bookmarkedIds.add(listingId);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update bookmark: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addReview(String listingId, ReviewModel review) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _listingService.addReview(listingId, review);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add review: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Create listing
  Future<bool> createListing(ListingModel listing) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _listingService.createListing(listing);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create listing: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update listing
  Future<bool> updateListing(ListingModel listing) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _listingService.updateListing(listing);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update listing: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete listing
  Future<bool> deleteListing(String listingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _listingService.deleteListing(listingId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete listing: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Search
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Filter by category
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _listingsSubscription?.cancel();
    _userListingsSubscription?.cancel();
    _reviewsSubscription?.cancel();
    _bookmarksSubscription?.cancel();
    super.dispose();
  }
}
