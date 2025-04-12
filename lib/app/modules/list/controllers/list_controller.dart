// ignore_for_file: deprecated_member_use, prefer_const_constructors, avoid_print, invalid_return_type_for_catch_error, unnecessary_brace_in_string_interps

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:async' show unawaited;
import '../../../data/repositories/repositories.dart';
import '../../../data/models/models.dart';
import '../../../services/favorite_service.dart';

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

  // Lấy reference đến favorite service để sử dụng
  FavoriteService get favoriteService => FavoriteService.to;

  @override
  void onInit() {
    super.onInit();
    getUserLocation().then((_) => loadYards());
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

        // ignore: unnecessary_null_comparison
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

      // Cập nhật trạng thái yêu thích dựa trên FavoriteService
      for (var yard in results) {
        yard.isFavorite = favoriteService.isFavorite(yard.id);
      }

      yards.value = results;
      _applySearchFilter(); // Apply text search filter
    } catch (e) {
      print('Error loading yards: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Check if a yard is in the wishlist
  bool isYardInWishlist(int yardId) {
    return favoriteService.isFavorite(yardId);
  }

  // Toggle yard in wishlist - sử dụng FavoriteService
  Future<void> toggleFavorite(int yardId) async {
    await favoriteService.toggleFavorite(yardId);

    // Cập nhật trạng thái yêu thích trong danh sách yards
    final yardInList = yards.firstWhereOrNull((y) => y.id == yardId) ??
        filteredYards.firstWhereOrNull((y) => y.id == yardId);
    if (yardInList != null) {
      yardInList.isFavorite = favoriteService.isFavorite(yardId);
      // Refresh lists
      yards.refresh();
      filteredYards.refresh();
    }
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
