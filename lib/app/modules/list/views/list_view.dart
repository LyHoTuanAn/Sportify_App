import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../controllers/list_controller.dart';

class ListPageView extends GetView<ListController> {
  const ListPageView({Key? key}) : super(key: key);

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
                        color: Color(0xFF2B7A78),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF2B7A78).withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset('assets/images/logo.png', width: 20, height: 20, color: Colors.white)
                  ),
                  SizedBox(width: 10),
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
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        onChanged: controller.searchVenues,
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
              
              // Venue List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.filteredVenues.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2B7A78),
                      ),
                    );
                  }
                  
                  if (controller.filteredVenues.isEmpty) {
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
                    itemCount: controller.filteredVenues.length,
                    itemBuilder: (context, index) {
                      final venue = controller.filteredVenues[index];
                      return _buildVenueItem(venue, index);
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
      child: Obx(() => Row(
        children: List.generate(
          controller.filters.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: index < controller.filters.length - 1 ? 10 : 0),
            child: _buildFilterButton(
              controller.filters[index],
              isActive: index == controller.selectedFilterIndex.value,
              onTap: () => controller.setFilter(index),
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildFilterButton(String text, {bool isActive = false, VoidCallback? onTap}) {
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

  Widget _buildVenueItem(Venue venue, int index) {
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  // Court header
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      venue.name,
                  style: const TextStyle(
                    fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Court details
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Color(0xFF2B7A78),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                venue.address,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF777777),
                                  fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
                        
                        const SizedBox(height: 6),
                        
                        // Distance
            Row(
              children: [
                            const Icon(
                              Icons.route,
                              size: 14,
                              color: Color(0xFF2B7A78),
                            ),
                const SizedBox(width: 8),
                Text(
                              venue.distance,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF777777),
                                fontFamily: 'Poppins',
                              ),
                ),
              ],
            ),
                        
                        const SizedBox(height: 10),
                        
                        // Badges
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...venue.features.map((feature) => _buildBadge(feature)),
                            if (venue.discount != null) 
                              _buildPromoBadge(venue.discount!),
                          ],
                        ),
                        
                        // Rating and booking
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Stars
            Row(
              children: [
                                Row(
                                  children: List.generate(5, (i) {
                                    if (i < venue.rating.floor()) {
                                      return const Icon(Icons.star, size: 14, color: Color(0xFFffc107));
                                    } else if (i < venue.rating) {
                                      return const Icon(Icons.star_half, size: 14, color: Color(0xFFffc107));
                                    } else {
                                      return const Icon(Icons.star_border, size: 14, color: Color(0xFFffc107));
                                    }
                                  }),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "(${venue.reviewCount})",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF777777),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                            
                            // Book button
        Container(
                              height: 36,
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
                                  // Handle booking
              },
              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                  minimumSize: Size.zero, // No minimum size
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap target
                                  textStyle: const TextStyle(
                                    fontSize: 12, // Smaller font
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Đặt lịch"),
                                    SizedBox(width: 6), // Smaller gap
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 13, // Smaller icon
                                      color: Color(0xFFFFFFFF),
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
            
            // Status badge
            if (venue.isOpen)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite, // biểu tượng trái tim
                    color: Colors.grey,
                    size: 20, // có thể điều chỉnh kích thước tùy ý
                  ),
            ),
        ),
          ],
        ),
      ),
    );
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECB3),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFFF8F00),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
  }