import 'package:get/get.dart';
import '../../../data/models/yard_search.dart';
import '../../../data/models/wishlist.dart';
import '../../../data/repositories/repositories.dart';
import '../../../services/favorite_service.dart';
import '../../../data/models/yard_featured.dart';

class WishlistController extends GetxController {
  final isLoading = true.obs;
  final favoriteYards = <YardFeatured>[].obs;

  // Lấy reference đến favorite service để sử dụng
  FavoriteService get favoriteService => FavoriteService.to;

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    isLoading.value = true;

    try {
      // Lấy danh sách yard yêu thích từ FavoriteService
      List<WishlistItem> wishlistItems = favoriteService.wishlistItems;

      // Load yard details for each wishlist item
      await _loadFavoriteYards(wishlistItems);
    } catch (e) {
      print('Error loading wishlist: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFavoriteYards(List<WishlistItem> wishlistItems) async {
    try {
      // Get all yard IDs from wishlist
      final yardIds = wishlistItems
          .where((item) => item.objectModel == "boat")
          .map((item) => item.objectId)
          .toList();

      if (yardIds.isEmpty) {
        favoriteYards.clear();
        return;
      }

      // Tải toàn bộ sân nổi bật từ API
      final allFeaturedYards = await Repo.yard.getFeaturedYards();

      // Tải các sân thường từ searchYards API
      final regularYards = await Repo.yard.searchYards();

      // Kết hợp sân nổi bật và sân thường
      List<YardFeatured> allYards = [...allFeaturedYards];

      // Chuyển đổi các Yard thường thành YardFeatured nếu cần
      for (var yard in regularYards) {
        if (yardIds.contains(yard.id) &&
            !allYards.any((featured) => featured.id == yard.id)) {
          // Tạo địa chỉ cho sân
          String addressText = yard.location.name;
          if (yard.location.realAddress != null &&
              yard.location.realAddress!.containsKey("address") &&
              yard.location.realAddress!["address"] != null) {
            addressText = yard.location.realAddress!["address"];
          }

          // Chuyển đổi YardReviewScore sang ReviewScore
          ReviewScore reviewScore = ReviewScore(
              reviewText: yard.reviewScore.reviewText ?? 'Not rated');

          // Tạo YardFeatured từ Yard
          YardFeatured featuredYard = YardFeatured(
            id: yard.id,
            title: yard.title,
            price: yard.price,
            image: yard.image,
            realAddress: RealAddressModel(address: addressText),
            isFeatured: 0,
            reviewScore: reviewScore,
            isFavorite: true,
          );
          allYards.add(featuredYard);
        }
      }

      // Lọc chỉ lấy sân trong wishlist
      favoriteYards.value =
          allYards.where((yard) => yardIds.contains(yard.id)).toList();

      // Đánh dấu tất cả là đã thích
      for (var yard in favoriteYards) {
        yard.isFavorite = true;
      }
    } catch (e) {
      print('Error loading favorite yard details: $e');
    }
  }

  Future<void> toggleFavorite(int yardId) async {
    await favoriteService.toggleFavorite(yardId);

    // Update UI based on the new state
    if (!favoriteService.isFavorite(yardId)) {
      // If removed from favorites, remove from the list
      favoriteYards.removeWhere((yard) => yard.id == yardId);
    } else {
      // If somehow added to favorites (shouldn't happen in this view normally), reload
      loadWishlist();
    }
  }

  // Hàm refresh để gọi khi cần cập nhật danh sách yêu thích
  Future<void> refreshWishlist() async {
    await favoriteService.refreshFavorites();
    await loadWishlist();
  }
}
