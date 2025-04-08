import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:async' show unawaited;
import '../../../data/repositories/repositories.dart';
import '../../../data/models/models.dart';

class ListController extends GetxController {
  final yards = <Yard>[].obs;
  final filteredYards = <Yard>[].obs;
  final selectedFilterIndex = 0.obs;
  final filters = [
    'Tất cả',
    'Gần nhất',
    'Đánh giá cao',
    'Giá thấp đến cao',
    'Khuyến mãi',
    'Nổi bật'
  ];
  final filterValues = [
    '',
    'nearest',
    'rate_high',
    'price_low_high',
    'has_promotion',
    'is_featured'
  ];

  final isLoading = false.obs;
  final isLoadingLocation = false.obs;
  final searchQuery = ''.obs;
  final hasLocationPermission = false.obs;

  // User location
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final locationPrefs = GetStorage();

  // Wishlist
  final wishlistItems = <WishlistItem>[].obs;
  final isLoadingWishlist = false.obs;

  // Add this map to track favorite status directly to avoid delays
  final favoriteStatus = <int, RxBool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    getUserLocation().then((_) => loadYards());
    loadWishlist();
  }

  // Get user's location
  Future<void> getUserLocation() async {
    isLoadingLocation.value = true;
    try {
      // Check for location permission
      bool hasPermission = await _checkLocationPermission();

      if (hasPermission) {
        // Get current position
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ).catchError((error) {
          print('Error getting location: $error');
          return null;
        });

        if (position != null) {
          currentPosition.value = position;

          // Save location to storage for later use
          locationPrefs.write('last_latitude', position.latitude);
          locationPrefs.write('last_longitude', position.longitude);
          locationPrefs.write(
              'location_timestamp', DateTime.now().millisecondsSinceEpoch);
        }
      } else {
        // Try to use last saved location if available
        final lastLat = locationPrefs.read('last_latitude');
        final lastLng = locationPrefs.read('last_longitude');

        if (lastLat != null && lastLng != null) {
          currentPosition.value = Position(
            latitude: lastLat,
            longitude: lastLng,
            timestamp: DateTime.fromMillisecondsSinceEpoch(
                locationPrefs.read('location_timestamp') ??
                    DateTime.now().millisecondsSinceEpoch),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        }
      }
    } catch (e) {
      print('Error handling location: $e');
    } finally {
      isLoadingLocation.value = false;
    }
  }

  // Check for location permission
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    hasLocationPermission.value = !(permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever);
    return hasLocationPermission.value;
  }

  // Load yards from API
  Future<void> loadYards() async {
    isLoading.value = true;

    try {
      // Get filter parameter
      String? orderBy;
      if (selectedFilterIndex.value > 0) {
        orderBy = filterValues[selectedFilterIndex.value];
      }

      // Get user location coordinates
      double? userLat, userLng;
      if (currentPosition.value != null) {
        userLat = currentPosition.value!.latitude;
        userLng = currentPosition.value!.longitude;
      }

      // Fetch yards from API
      final results = await Repo.yard.searchYards(
        userLat: userLat,
        userLng: userLng,
        orderBy: orderBy,
      );

      // If we have wishlist data, mark favorites
      if (wishlistItems.isNotEmpty) {
        for (var yard in results) {
          yard.isFavorite = isYardInWishlist(yard.id);
        }
      }

      yards.value = results;
      _applySearchFilter(); // Apply text search filter
    } catch (e) {
      print('Error loading yards: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load user's wishlist
  Future<void> loadWishlist() async {
    isLoadingWishlist.value = true;

    try {
      final items = await Repo.yard.getUserWishlist();
      wishlistItems.value = items;

      // Update favorite status for any loaded yards
      if (yards.isNotEmpty) {
        for (var yard in yards) {
          yard.isFavorite = isYardInWishlist(yard.id);
        }

        // Refresh the filtered yards to update UI
        _applySearchFilter();
        update(); // Required for GetBuilder to update
      }
    } catch (e) {
      print('Error loading wishlist: $e');
    } finally {
      isLoadingWishlist.value = false;
    }
  }

  // Check if a yard is in the wishlist - optimized version
  bool isYardInWishlist(int yardId) {
    // First check our reactive map for immediate feedback
    if (favoriteStatus.containsKey(yardId)) {
      return favoriteStatus[yardId]!.value;
    }
    // Fall back to checking the wishlist items
    return wishlistItems
        .any((item) => item.objectId == yardId && item.objectModel == "boat");
  }

  // Toggle yard in wishlist - optimized for responsiveness
  Future<void> toggleFavorite(int yardId) async {
    try {
      // If we don't have a reactive boolean for this yard yet, create one
      if (!favoriteStatus.containsKey(yardId)) {
        favoriteStatus[yardId] = isYardInWishlist(yardId).obs;
      }

      // Toggle status immediately for instant UI feedback
      final newStatus = !favoriteStatus[yardId]!.value;
      favoriteStatus[yardId]!.value = newStatus;

      // Also update the yard's isFavorite property immediately for consistent state
      final yardInList = yards.firstWhereOrNull((y) => y.id == yardId) ??
          filteredYards.firstWhereOrNull((y) => y.id == yardId);
      if (yardInList != null) {
        yardInList.isFavorite = newStatus;
      }

      // Refresh lists to ensure UI updates
      yards.refresh();
      filteredYards.refresh();

      // Call API in the background
      unawaited(_updateFavoriteOnServer(yardId, newStatus));
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  // Make the API call in a separate method to not block the UI
  Future<void> _updateFavoriteOnServer(int yardId, bool expectedStatus) async {
    try {
      final response = await Repo.yard.toggleWishlistItem(yardId);
      print(
          'Toggle wishlist response: status=${response.status}, class="${response.toggleClass}", message="${response.message}"');
      print('Is active based on response: ${response.isActive}');

      if (response.status == 1) {
        final serverStatus = response.isActive;
        print(
            'Server status (${serverStatus}) from class="${response.toggleClass}"');

        // If server response doesn't match our expected status, fix the discrepancy
        if (serverStatus != expectedStatus &&
            favoriteStatus.containsKey(yardId)) {
          print(
              'Server status ($serverStatus) doesn\'t match expected status ($expectedStatus), correcting...');

          // Update our reactive status map with the server response
          favoriteStatus[yardId]?.value = serverStatus;

          // Also update the yard in our lists
          final yardInList = yards.firstWhereOrNull((y) => y.id == yardId) ??
              filteredYards.firstWhereOrNull((y) => y.id == yardId);
          if (yardInList != null) {
            yardInList.isFavorite = serverStatus;
            print('Updated yard.isFavorite to ${yardInList.isFavorite}');
          }

          // Refresh UI
          yards.refresh();
          filteredYards.refresh();
        } else {
          print(
              'Status already matches expected: $serverStatus, no correction needed');
        }

        // Update wishlist data to match server state
        if (serverStatus) {
          // If favorited, make sure it's in the wishlist
          if (!wishlistItems.any((item) => item.objectId == yardId)) {
            wishlistItems.add(WishlistItem(
              id: 0,
              objectId: yardId,
              objectModel: "boat",
            ));
            wishlistItems.refresh();
            print('Added item to wishlist');
          }
        } else {
          // If unfavorited, remove from wishlist
          final initialCount = wishlistItems.length;
          wishlistItems.removeWhere(
              (item) => item.objectId == yardId && item.objectModel == "boat");
          final newCount = wishlistItems.length;
          if (initialCount != newCount) {
            print(
                'Removed item from wishlist (${initialCount} -> ${newCount})');
            wishlistItems.refresh();
          }
        }

        // Force update UI elements using GetBuilder
        update();
      } else {
        // If server request failed, revert to previous state
        print(
            'Server request failed (status != 1), reverting to previous state');
        _revertFavoriteStatus(yardId, !expectedStatus);
      }
    } catch (e) {
      print('Error updating favorite on server: $e');
      // Revert the local status if server call failed
      _revertFavoriteStatus(yardId, !expectedStatus);
    }
  }

  // Helper method to revert favorite status in case of errors
  void _revertFavoriteStatus(int yardId, bool status) {
    // Update reactive status
    if (favoriteStatus.containsKey(yardId)) {
      favoriteStatus[yardId]!.value = status;
    }

    // Update yard object
    final yardInList = yards.firstWhereOrNull((y) => y.id == yardId) ??
        filteredYards.firstWhereOrNull((y) => y.id == yardId);
    if (yardInList != null) {
      yardInList.isFavorite = status;
    }

    // Refresh UI
    yards.refresh();
    filteredYards.refresh();
  }

  // Set filter
  void setFilter(int index) {
    if (selectedFilterIndex.value == index) return;

    selectedFilterIndex.value = index;
    loadYards(); // Reload with new filter
  }

  // Search yards by query
  void searchYards(String query) {
    searchQuery.value = query;
    _applySearchFilter();
  }

  // Apply search filter to yards
  void _applySearchFilter() {
    if (searchQuery.isEmpty) {
      filteredYards.value = yards;
      return;
    }

    final query = searchQuery.value.toLowerCase();
    filteredYards.value = yards.where((yard) {
      return yard.title.toLowerCase().contains(query) ||
          yard.location.name.toLowerCase().contains(query);
    }).toList();
  }
}
