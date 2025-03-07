import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            _buildCategories(),
            SizedBox(height: 20),
            _buildFeaturedCourts(),
            SizedBox(height: 20),
            _buildVouchers(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 390, minHeight: 180),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SPORTIFY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white, size: 16),
                    SizedBox(width: 5),
                    Text(
                      formattedDate,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            'Chào mừng đến Sportify',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Đặt sân cầu lông dễ dàng, nhanh chóng',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.teal),
                  SizedBox(width: 5),
                  Text('Đặt sân ngay', style: TextStyle(color: Colors.teal)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _categoryItem(Icons.sports, 'Thiết bị'),
        _categoryItem(Icons.map, 'Map'),
        _categoryItem(Icons.person, 'Huấn luyện'),
        _categoryItem(Icons.group, 'Ask'),
      ],
    );
  }

  Widget _categoryItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.teal),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}


Widget _buildFeaturedCourts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sân nổi bật', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _courtCard('Sân cầu lông Hà Đông', 'Quận Hà Đông', 4.8),
              _courtCard('Elite Sports Thủ Đức', 'Quận Thủ Đức', 4.7),
            ],
          ),
        ),
      ],
    );
  }

  Widget _courtCard(String name, String location, double rating) {
    return Container(
      width: 180,
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 100, color: Colors.grey[300]),
          SizedBox(height: 10),
          Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(location, style: TextStyle(color: Colors.grey)),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              Text(rating.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVouchers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Voucher giảm giá', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        _voucherItem('Ưu đãi đầu tháng', 'Hết hạn: 10/03/2025', 30, 'Áp dụng cho tất cả sân'),
        _voucherItem('Khung giờ trưa', 'Hết hạn: 15/03/2025', 20, '12:00 - 15:00 hàng ngày'),
        _voucherItem('Ưu đãi thành viên mới', 'Hết hạn: 31/03/2025', 50, 'Lần đặt sân đầu tiên'),
      ],
    );
  }

  Widget _voucherItem(String title, String expiry, int discount, String detail) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
            child: Text('$discount%', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(expiry, style: TextStyle(color: Colors.grey)),
                Text(detail, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

