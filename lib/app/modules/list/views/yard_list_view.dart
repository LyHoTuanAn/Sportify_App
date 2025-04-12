// ignore_for_file: unused_local_variable, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../data/models/models.dart';
import '../controllers/list_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/favorite_button.dart';

class YardListView extends GetView<ListController> {
  const YardListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar color to match design
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              // Header with logo
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B7A78),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: const Color(0xFF2B7A78).withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset('assets/images/logo.png',
                        width: 20, height: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SPORTIFY',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B7A78),
                        ),
                      ),
                      Text(
                        'BADMINTON',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF3AAFA9),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Color(0xFF777777),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: controller.searchYards,
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm sân thể thao...',
                          hintStyle: TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Filter buttons
              _buildFilterButtons(),

              const SizedBox(height: 20),

              // Yard List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.filteredYards.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2B7A78),
                      ),
                    );
                  }

                  if (controller.filteredYards.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không tìm thấy sân phù hợp',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: controller.filteredYards.length,
                    itemBuilder: (context, index) {
                      final yard = controller.filteredYards[index];
                      return _buildYardItem(yard, index);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Obx(() {
        return Row(
          children: List.generate(
            controller.filters.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                  right: index < controller.filters.length - 1 ? 10 : 0),
              child: _buildFilterButton(
                controller.filters[index],
                isActive: index == controller.selectedFilterIndex.value,
                onTap: () => controller.setFilter(index),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFilterButton(String text,
      {bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2B7A78) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isActive ? const Color(0xFF2B7A78) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF333333),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildYardItem(Yard yard, int index) {
    // Staggered animation timing
    final animationDelay = Duration(milliseconds: 100 * (index + 1));

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
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
          children: [
            // Yard Image
            if (yard.image.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: Image.network(
                    yard.image,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFF2B7A78),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFEEEEEE),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Color(0xFF999999),
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Heart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          yard.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      // Favorite button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => controller.toggleFavorite(yard.id),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            topRight: Radius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: FavoriteButton(
                              yardId: yard.id,
                              size: 28,
                              iconSize: 22,
                              showBackground: false,
                              activeColor: Colors.red,
                              inactiveColor: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Price Row with Original Price and Discount
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Price - show either the sale price or regular price
                      Text(
                        // If discount_percent exists, use sale_price_per_hour, otherwise use price
                        yard.discount != null &&
                                yard.discount!.contains('%') &&
                                yard.salePricePerHour != null
                            ? yard.formattedSalePrice
                            : yard.formattedPrice,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B7A78),
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Original Price with Strikethrough (only if there's a discount)
                      if (yard.discount != null && yard.discount!.contains('%'))
                        Text(
                          yard.formattedPrice,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF999999),
                            decoration: TextDecoration.lineThrough,
                            fontFamily: 'Poppins',
                          ),
                        ),

                      const SizedBox(width: 10),

                      // Discount Badge (only if there's a discount percentage)
                      if (yard.discount != null && yard.discount!.contains('%'))
                        _buildPromoBadge(yard.discount!),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Color(0xFF2B7A78),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          yard.location.realAddressText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF555555),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Distance
                  if (yard.distanceInKm != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.route,
                          size: 18,
                          color: Color(0xFF2B7A78),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          yard.formattedDistance,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF555555),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 5),

                  // Ratings and Booking Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Star Ratings
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (i) {
                              final score = yard.reviewScore.score ?? 0;
                              if (i < score.floor()) {
                                return const Icon(Icons.star,
                                    size: 20, color: Color(0xFFFFD700));
                              } else if (i < score) {
                                return const Icon(Icons.star_half,
                                    size: 20, color: Color(0xFFFFD700));
                              } else {
                                return const Icon(Icons.star_border,
                                    size: 20, color: Color(0xFFFFD700));
                              }
                            }),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            yard.reviewScore.totalReview != null
                                ? "(${yard.reviewScore.totalReview})"
                                : yard.reviewScore.reviewText,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF777777),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),

                      // Book Button
                      Container(
                        height: 35, // Set fixed height
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF2B7A78),
                              Color(0xFF17252A),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.toNamed(Routes.interfaceBooking,
                                arguments: {'yard_id': yard.id});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Đặt lịch"),
                              SizedBox(width: 3),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build features list
  // ignore: unused_element
  List<Widget> _buildFeaturesList(Yard yard) {
    List<Widget> widgetList = [];

    // Add all features
    for (var i = 0; i < yard.features.length; i++) {
      widgetList.add(Padding(
        padding: const EdgeInsets.only(right: 6),
        child: _buildBadge(yard.features[i]),
      ));
    }

    // We no longer add discount badge here as it's now next to the price
    return widgetList;
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFDEF2F1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2B7A78),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildPromoBadge(String text) {
    // Check if text is a discount percentage
    bool isPercentage = text.contains('%');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isPercentage ? const Color(0xFFFFF3CD) : const Color(0xFFFFECB3),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: TextStyle(
          color:
              isPercentage ? const Color(0xFFFF6B00) : const Color(0xFFFF8F00),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
