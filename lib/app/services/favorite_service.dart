import 'package:get/get.dart';
import '../data/models/wishlist.dart';
import '../data/repositories/repositories.dart';

class FavoriteService extends GetxService {
  static FavoriteService get to => Get.find<FavoriteService>();

  // Reactive map to track favorite status by yard ID
  final RxMap<int, RxBool> favoriteStates = <int, RxBool>{}.obs;
  final RxList<WishlistItem> wishlistItems = <WishlistItem>[].obs;
  final RxBool isLoading = false.obs;

  // Initialize service and load favorites
  Future<FavoriteService> init() async {
    await loadFavorites();
    return this;
  }

  // Load favorites from API
  Future<void> loadFavorites() async {
    isLoading.value = true;
    try {
      final items = await Repo.yard.getUserWishlist();
      wishlistItems.value = items;

      // Initialize reactive favorites map
      favoriteStates.clear(); // Xóa map hiện tại để tránh dữ liệu cũ
      for (var item in items) {
        if (item.objectModel == "boat") {
          favoriteStates[item.objectId] = true.obs;
        }
      }
    } catch (e) {
      print('Error loading favorites: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Check if a yard is favorited
  bool isFavorite(int yardId) {
    return favoriteStates.containsKey(yardId)
        ? favoriteStates[yardId]!.value
        : false;
  }

  // Toggle favorite status for a yard
  Future<void> toggleFavorite(int yardId) async {
    // If we don't have an entry for this yard, create one with default value false
    if (!favoriteStates.containsKey(yardId)) {
      favoriteStates[yardId] = false.obs;
    }

    // Toggle immediately for responsive UI
    final newStatus = !favoriteStates[yardId]!.value;
    favoriteStates[yardId]!.value = newStatus;

    try {
      // Call API in background
      final response = await Repo.yard.toggleWishlistItem(yardId);

      if (response.status == 1) {
        // Update wishlist items collection based on new status
        if (newStatus) {
          // Add to wishlist if not already present
          if (!wishlistItems.any((item) => item.objectId == yardId)) {
            wishlistItems.add(WishlistItem(
              id: 0,
              objectId: yardId,
              objectModel: "boat",
            ));
            wishlistItems.refresh();
          }
        } else {
          // Remove from wishlist
          wishlistItems.removeWhere(
              (item) => item.objectId == yardId && item.objectModel == "boat");
          wishlistItems.refresh();
        }
      } else {
        // Revert if API call failed
        favoriteStates[yardId]!.value = !newStatus;
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      // Revert on error
      favoriteStates[yardId]!.value = !newStatus;
    }
  }

  // Thêm method này để refresh dữ liệu khi cần
  Future<void> refreshFavorites() async {
    await loadFavorites();
  }
}
