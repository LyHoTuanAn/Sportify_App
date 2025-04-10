// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repositories/repositories.dart';
import '../../../routes/app_pages.dart';
import '../views/payment_webview.dart';

class PaymentItem {
  final String? id;
  final String? title;
  final String? description;
  final String? imageUrl;
  final DateTime? createdAt;

  PaymentItem({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.createdAt,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

class PaymentController extends GetxController {
  final YardRepository yardRepository = Repo.yard;
  Timer? _timer;
  final RxInt remainingTime = 300.obs;
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  String get formattedTime {
    int minutes = remainingTime.value ~/ 60;
    int seconds = remainingTime.value % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void onInit() {
    super.onInit();
    // Get booking info from arguments
    final Map<String, dynamic>? bookingInfo = Get.arguments != null
        ? Get.arguments['bookingInfo'] as Map<String, dynamic>?
        : null;

    if (bookingInfo != null) {
      fullNameController.text = bookingInfo['full_name'] ?? '';
      phoneController.text = bookingInfo['phone'] ?? '';
      emailController.text = bookingInfo['email'] ?? '';
    }
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        _timer?.cancel();
        Get.snackbar(
          'Hết thời gian',
          'Thời gian thanh toán đã hết, vui lòng thử lại',
          snackPosition: SnackPosition.TOP,
        );
      }
    });
  }

  Future<void> doCheckout() async {
    try {
      // Validate form
      if (!formKey.currentState!.validate()) {
        print('Form validation failed');
        return;
      }

      // Get booking info
      final Map<String, dynamic>? bookingInfo = Get.arguments != null
          ? Get.arguments['bookingInfo'] as Map<String, dynamic>?
          : null;

      final String bookingCode = bookingInfo?['booking_code'] ?? '';
      print('Starting checkout process with booking code: $bookingCode');

      if (bookingCode.isEmpty) {
        errorMessage.value = 'Không tìm thấy mã đặt sân';
        print('Booking code is empty');
        return;
      }

      // Show loading state
      isLoading.value = true;
      errorMessage.value = '';

      // Call checkout API
      print('Calling checkout API...');
      final result = await yardRepository.doCheckout(
        code: bookingCode,
        fullName: fullNameController.text,
        phone: phoneController.text,
        email: emailController.text,
      );

      // Log API response
      print('Checkout API response: $result');
      print('Response URL: ${result['url']}');

      // Handle API response
      if (result['status'] == 'success' || result['status'] == 1) {
        if (result['url'] != null && result['url'].toString().isNotEmpty) {
          final paymentUrl = result['url'].toString();
          print('Opening payment URL: $paymentUrl');

          // Navigate to WebView
          await Get.to(
            () => PaymentWebView(paymentUrl: paymentUrl),
            fullscreenDialog: true,
            preventDuplicates: true,
          );
          print('WebView opened successfully');
        } else {
          print('Payment URL is empty or null');
          throw Exception('Không nhận được URL thanh toán');
        }
      } else {
        print('API returned error status: ${result['status']}');
        throw Exception(result['message'] ?? 'Không thể tạo đơn thanh toán');
      }
    } catch (e) {
      print('Checkout error: $e');
      errorMessage.value = e.toString();
      Get.snackbar(
        'Lỗi',
        'Không thể tạo đơn thanh toán: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    _timer?.cancel();
    super.onClose();
  }

  // Add fallback URL launcher method
  // ignore: unused_element
  Future<void> _launchUrlFallback(String url) async {
    try {
      print('Attempting to launch URL via launcher: $url');
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        print('Cannot launch URL: $url');
        errorMessage.value = 'Could not launch payment URL';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}
