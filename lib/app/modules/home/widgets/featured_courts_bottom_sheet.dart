import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/yard_featured.dart';
import '../../../data/models/wishlist.dart';
import '../../../data/repositories/repositories.dart';
import '../../../widgets/favorite_button.dart';
import '../controllers/home_controller.dart';

class FeaturedCourtsBottomSheet extends StatelessWidget {
  final List<dynamic> featuredYards;

  const FeaturedCourtsBottomSheet({
    Key? key,
    required this.featuredYards,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    print("FeaturedCourtsBottomSheet build called");
    print("Number of featured yards: ${featuredYards.length}");

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 15),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_tennis,
                      color: Color(0xFF2B7A78),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tất cả Sân nổi bật',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF17252A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Info banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFDEF2F1),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: const Color(0xFF3AAFA9).withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF2B7A78), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nhấn vào sân để xem chi tiết và đặt lịch',
                    style: TextStyle(
                      color: Color(0xFF2B7A78),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content section
          Expanded(
            child: featuredYards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_tennis,
                          size: 60,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Không có sân nổi bật nào',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Các sân nổi bật sẽ hiển thị ở đây khi có',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: featuredYards.length,
                    itemBuilder: (context, index) {
                      final yard = featuredYards[index];
                      return InkWell(
                        onTap: () {
                          print("Court tapped: ${yard.title}");
                          // Close the bottom sheet and navigate to booking
                          Get.back();
                          Get.toNamed('/interface-booking',
                              arguments: {'yard_id': yard.id});
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                                    child: FavoriteButton(
                                      yardId: yard.id,
                                      size: 36,
                                      iconSize: 24,
                                      backgroundColor: Colors.black,
                                      opacity: 0.3,
                                      activeColor: Colors.red,
                                      inactiveColor: Colors.white,
                                    ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                                  yard.location.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF555555),
                                                    fontFamily: 'Poppins',
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Star Ratings aligned to the right
                                        Row(
                                          children: [
                                            if (yard.reviewScore.reviewText !=
                                                "Not rated")
                                              Row(
                                                children: List.generate(5, (i) {
                                                  return Icon(
                                                    i < 4
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    size: 20,
                                                    color:
                                                        const Color(0xFFFFD700),
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
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
