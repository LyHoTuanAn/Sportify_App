import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/wishlist_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/favorite_button.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B7A78),
        title: const Text(
          'Sân yêu thích',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Thêm refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.refreshWishlist(),
          ),
        ],
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2B7A78),
            ),
          );
        }

        if (controller.favoriteYards.isEmpty) {
          return _buildEmptyState();
        }

        return _buildFavoriteList();
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 60,
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có sân yêu thích',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bạn có thể thêm sân vào danh sách yêu thích\nbằng cách nhấn vào biểu tượng trái tim',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.toNamed(Routes.list),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B7A78),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Khám phá sân',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.favoriteYards.length,
      itemBuilder: (context, index) {
        final yard = controller.favoriteYards[index];
        return _buildYardCard(yard);
      },
    );
  }

  Widget _buildYardCard(yard) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.interfaceBooking, arguments: {'yard_id': yard.id});
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Court image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    yard.image,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 170,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              color: Colors.grey, size: 40),
                        ),
                      );
                    },
                  ),
                ),
                // Heart icon
                Positioned(
                  top: 10,
                  right: 10,
                  child: _buildCustomFavoriteButton(yard.id),
                ),
              ],
            ),

            // Court details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    yard.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Price
                  Text(
                    yard.formattedPrice,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B7A78),
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Location info on the left
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 18,
                              color: Color(0xFF2B7A78),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                yard.realAddress.address,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF555555),
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Star Ratings aligned to the right
                      Row(
                        children: [
                          if (yard.reviewScore.reviewText != "Not rated")
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < 4 ? Icons.star : Icons.star_border,
                                  size: 20,
                                  color: const Color(0xFFFFD700),
                                );
                              }),
                            ),
                          const SizedBox(width: 5),
                          Text(
                            yard.reviewScore.reviewText,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF777777),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tạo custom FavoriteButton để sử dụng WishlistController
  Widget _buildCustomFavoriteButton(int yardId) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.toggleFavorite(yardId),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Obx(() {
              final isFavorite = controller.favoriteService.isFavorite(yardId);

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey<bool>(isFavorite),
                  color: isFavorite ? Colors.red : Colors.white,
                  size: 24,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
