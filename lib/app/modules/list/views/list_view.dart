import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/list_controller.dart';

class ListPageView extends GetView<ListController> {
  const ListPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Logo
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sportify',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B7A78),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sân thể thao...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      // Add filter functionality
                    },
                  ),
                ),
              ),
            ),

            // Rest of the previous implementation remains the same
            _buildFilterTabs(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  _buildVenueCard(
                    name: 'Sân Cầu Lông Gia Định',
                    address: '248 Nguyễn Thành Vinh, Q.12',
                    distance: '16.4m từ bạn',
                    rating: 4.8,
                    reviewCount: 100,
                  ),
                  const SizedBox(height: 10),
                  _buildVenueCard(
                    name: 'Sân Cầu Lông Thành Phát',
                    address: '48 Lê Duẩn, Gò Vấp',
                    distance: '2.5km từ bạn',
                    rating: 4.5,
                    reviewCount: 156,
                  ),
                  const SizedBox(height: 10),
                  _buildVenueCard(
                    name: 'CLB Cầu Lông Tân Bình',
                    address: '122 Hoàng Hoa Thám, Tân Bình',
                    distance: '3.7km từ bạn',
                    rating: 4.2,
                    reviewCount: 162,
                  ),
                  const SizedBox(height: 10),
                  _buildVenueCard(
                    name: 'CLB Cầu Lông Tân Bình',
                    address: '122 Hoàng Hoa Thám, Tân Bình',
                    distance: '3.7km từ bạn',
                    rating: 4.2,
                    reviewCount: 162,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Danh sách',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Nổi bật',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          _buildFilterButton('Tất cả', isActive: true),
          const SizedBox(width: 10),
          _buildFilterButton('Đánh giá cao'),
          const SizedBox(width: 10),
          _buildFilterButton('Giá ưu đãi'),
          const SizedBox(width: 10),
          _buildFilterButton('Khuyến mãi'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.teal : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildVenueCard({
    required String name,
    required String address,
    required String distance,
    required double rating,
    required int reviewCount,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'Mở cửa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  address,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              distance,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(
                  5,
                      (index) => Icon(
                    Icons.star,
                    color: index < rating.floor() ? Colors.amber : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text('($reviewCount)'),
              ],
            ),
            const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2B7A78), Color(0xFF17252A)], // Gradient colors
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10), // Match button shape
          ),
            child:ElevatedButton(
              onPressed: () {
                // Add booking functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // Transparent to show gradient
                shadowColor: Colors.transparent, // Optional: Remove shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),

              child: const Text(
                'Đặt lịch',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ),
          ],
        ),
      ),
    );
  }