import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final String userName = 'LyHoTuanAn';
  final String userInitial = 'A';
  
  String getCurrentDate() {
    return DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  // Map string icon names to Flutter IconData
  IconData getIconForCategory(String icon) {
    switch (icon) {
      case 'table_tennis':
        return Icons.sports_tennis;
      case 'map':
        return Icons.map;
      case 'person':
        return Icons.person;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'trophy':
        return Icons.emoji_events;
      case 'map-marked-alt':
        return Icons.location_on;
      case 'user-friends':
        return Icons.people;
      default:
        return Icons.sports_tennis;
    }
  }

  final List<Map<String, dynamic>> categories = [
    {
      'icon': 'table_tennis',
      'name': 'Thiết bị',
    },
    {
      'icon': 'map',
      'name': 'Sân đấu',
    },
    {
      'icon': 'person',
      'name': 'Huấn luyện',
    },
    {
      'icon': 'trophy',
      'name': 'Giải đấu',
    },
  ];

  final List<Map<String, dynamic>> featuredCourts = [
    {
      'name': 'Sân cầu lông Hà Đông',
      'location': 'Quận Hà Đông',
      'rating': 4.8,
      'image': 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8YmFkbWludG9uJTIwY291cnR8ZW58MHx8MHx8&ixlib=rb-1.2.1&w=1000&q=80',
    },
    {
      'name': 'Elite Sports Thanh Xuân',
      'location': 'Quận Thanh Xuân',
      'rating': 4.6,
      'image': 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8YmFkbWludG9uJTIwY291cnR8ZW58MHx8MHx8&ixlib=rb-1.2.1&w=1000&q=80',
    },
    {
      'name': 'Elite Sports Thanh Xuân',
      'location': 'Quận Thanh Xuân',
      'rating': 4.6,
      'image': 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8YmFkbWludG9uJTIwY291cnR8ZW58MHx8MHx8&ixlib=rb-1.2.1&w=1000&q=80',
    },
    {
      'name': 'Trung tâm thể thao Đống Đa',
      'location': 'Quận Đống Đa',
      'rating': 4.7,
      'image': 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8YmFkbWludG9uJTIwY291cnR8ZW58MHx8MHx8&ixlib=rb-1.2.1&w=1000&q=80',
    },
  ];

  final List<Map<String, dynamic>> vouchers = [
    {
      'discount': '30',
      'title': 'Ưu đãi đầu tháng',
      'expiry': 'Hết hạn: 10/03/2025',
      'detail': 'Áp dụng cho tất cả sân',
      'color': 'red',
    },
    {
      'discount': '20',
      'title': 'Khung giờ trưa',
      'expiry': 'Hết hạn: 15/03/2025',
      'detail': '12:00 - 15:00 hàng ngày',
      'color': 'orange',
    },
    {
      'discount': '50',
      'title': 'Ưu đãi thành viên mới',
      'expiry': 'Hết hạn: 31/03/2025',
      'detail': 'Lần đặt sân đầu tiên',
      'color': 'purple',
    },
  ];

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
