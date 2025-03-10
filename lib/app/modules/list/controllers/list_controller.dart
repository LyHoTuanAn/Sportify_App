import 'package:get/get.dart';

class Venue {
  final String id;
  final String name;
  final String address;
  final String distance;
  final double rating;
  final int reviewCount;
  final List<String> features;
  final String? discount;
  final bool isOpen;

  Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.rating,
    required this.reviewCount,
    this.features = const [],
    this.discount,
    this.isOpen = true,
  });
}

class ListController extends GetxController {
  final venues = <Venue>[].obs;
  final filteredVenues = <Venue>[].obs;
  final selectedFilterIndex = 0.obs;
  final filters = ['Tất cả', 'Gần nhất', 'Đánh giá cao', 'Giá tốt', 'Khuyến mãi'];
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadVenues();
  }

  void loadVenues() {
    isLoading.value = true;
    
    // In a real app, this would fetch data from an API
    Future.delayed(const Duration(milliseconds: 500), () {
      venues.value = [
        Venue(
          id: '1',
          name: 'Sân Cầu Lông Gia Định',
          address: '24B Nguyễn Thành Vinh, Q.12',
          distance: '115.4m từ bạn',
          rating: 5.0,
          reviewCount: 120,
          features: ['4 sân', 'Có xe'],
          discount: '-10%',
        ),
        Venue(
          id: '2',
          name: 'Sân Cầu Lông Thành Phát',
          address: '48 Lê Đức Thọ, Gò Vấp',
          distance: '2.3km từ bạn',
          rating: 4.0,
          reviewCount: 86,
          features: ['6 sân', 'Có nước'],
        ),
        Venue(
          id: '3',
          name: 'CLB Cầu Lông Tân Bình',
          address: '122 Hoàng Hoa Thám, Tân Bình',
          distance: '3.7km từ bạn',
          rating: 4.5,
          reviewCount: 152,
          features: ['8 sân', 'Có HLV'],
          discount: '-15%',
        ),
        Venue(
          id: '4',
          name: 'CLB Cầu Lông Tân Bình',
          address: '122 Hoàng Hoa Thám, Tân Bình',
          distance: '3.7km từ bạn',
          rating: 4.5,
          reviewCount: 152,
          features: ['8 sân', 'Có HLV'],
          discount: '-15%',
        ),
      ];
      
      filteredVenues.value = venues;
      isLoading.value = false;
    });
  }

  void setFilter(int index) {
    if (selectedFilterIndex.value == index) return;
    
    selectedFilterIndex.value = index;
    _applyFilters();
  }

  void searchVenues(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    isLoading.value = true;
    
    // Apply search query filter
    var results = venues.where((venue) {
      if (searchQuery.isEmpty) return true;
      
      return venue.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
             venue.address.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
    
    // Apply selected filter
    switch (selectedFilterIndex.value) {
      case 0: // All - no additional filtering
        break;
      case 1: // Nearest
        results.sort((a, b) => _parseDistance(a.distance).compareTo(_parseDistance(b.distance)));
        break;
      case 2: // Highest rated
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 3: // Best price - this would require a price field, for now we'll just show all
        break;
      case 4: // Promotions
        results = results.where((venue) => venue.discount != null).toList();
        break;
    }
    
    // Update filtered venues
    Future.delayed(const Duration(milliseconds: 300), () {
      filteredVenues.value = results;
      isLoading.value = false;
    });
  }
  
  // Helper to parse distance strings like "115.4m từ bạn" or "2.3km từ bạn" into comparable values in meters
  double _parseDistance(String distanceStr) {
    try {
      final parts = distanceStr.split(' ');
      final valueStr = parts[0];
      final value = double.parse(valueStr);
      
      if (distanceStr.contains('km')) {
        return value * 1000; // Convert to meters
      } else {
        return value; // Already in meters
      }
    } catch (e) {
      return double.maxFinite; // If parsing fails, place at the end of the list
    }
  }
}
