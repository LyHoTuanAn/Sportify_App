import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../core/styles/style.dart';
import '../../../core/utilities/utilities.dart';
import '../../../data/http_client/http_client.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../data/services/firebase_analytics_service.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../home/views/home_view.dart';
import '../../list/views/list_view.dart';
import '../../outstanding/views/outstanding_view.dart';
import '../../profile/views/profile_view.dart';

class BottomBarModel {
  final String image, title, appBarTitle;
  int notify;
  IconData? iconData;
  BottomBarModel(this.image, this.title, this.notify,
      {this.iconData, this.appBarTitle = ''});
}

class DashboardController extends GetxController {
  final currentIndex = 0.obs;
  
  // Biến để tương thích với code cũ
  final numberUnread = 0.obs;
  final messageUnread = 0.obs;

  final pages = [
    const HomeView(),
    const ListPageView(),
    const OutstandingView(),
    const ProfileView(),
  ];

  void changePage(int index) {
    currentIndex.value = index;
  }
  
  // Các phương thức trống để tương thích với code cũ
  Future<void> getNumberNotify() async {
    // Phương thức trống để tránh lỗi khi được gọi từ controllers khác
    // Logic đã bị xóa khi đơn giản hóa Dashboard
  }
  
  void readNotify() {
    // Phương thức trống để tránh lỗi khi được gọi từ controllers khác
    if (numberUnread.value > 0) {
      numberUnread.value--;
    }
  }
  
  // Thêm các phương thức khác có thể bị thiếu
  void changeTab(int index) {
    changePage(index);
  }
}
