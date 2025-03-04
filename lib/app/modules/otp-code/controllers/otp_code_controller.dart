import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class OtpCodeController extends GetxController {
  // Form controller
  final otpController = TextEditingController();

  // Observable variables for form validation
  final isOtpValid = false.obs;
  
  // Loading state
  final isLoading = false.obs;
  
  // Timer for OTP resend
  final remainingTime = 26.obs; // Starting timer at 26s as shown in screenshot
  final canResend = false.obs;
  Timer? _timer;

  // From arguments
  final phoneNumber = ''.obs;
  final fromScreen = ''.obs;

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    
    // Get arguments passed from previous screen
    if (Get.arguments != null) {
      if (Get.arguments['phone'] != null) {
        phoneNumber.value = Get.arguments['phone'];
      }
      
      if (Get.arguments['from'] != null) {
        fromScreen.value = Get.arguments['from'];
      }
    }
    
    // Start the countdown timer
    startTimer();
  }

  @override
  void onClose() {
    otpController.dispose();
    _timer?.cancel();
    super.onClose();
  }

  // Start countdown timer
  void startTimer() {
    remainingTime.value = 26; // 26s as shown in the screenshot
    canResend.value = false;
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  // Validate OTP code
  void validateOtp() {
    final otp = otpController.text.trim();
    // Simple 6-digit OTP validation
    isOtpValid.value = otp.length == 6 && otp.isNumericOnly;
  }

  // Resend OTP
  void resendOtp() {
    if (!canResend.value) return;
    
    // Simulate API call
    print('Resending OTP to $phoneNumber...');
    
    // Reset timer
    startTimer();
    
    // Show message
    Get.snackbar(
      'Đã gửi lại mã OTP',
      'Vui lòng kiểm tra tin nhắn của bạn',
      backgroundColor: const Color(0xFF2B7A78),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(20),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }

  // Verify OTP and reset password
  void verifyOtp() async {
    validateOtp();

    if (isOtpValid.value) {
      try {
        isLoading.value = true;
        
        // Simulate API call with delay
        await Future.delayed(const Duration(seconds: 2));
        
        // This is where we'll call the API in the future
        print('OTP: ${otpController.text} for phone: $phoneNumber');
        
        // Show success message
        Get.snackbar(
          'Xác thực thành công',
          'Bạn có thể đặt lại mật khẩu mới',
          backgroundColor: const Color(0xFF2B7A78),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(20),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
        );
        
        // Navigate based on where we came from
        if (fromScreen.value == 'forgot_password') {
          Get.toNamed(
            Routes.changePassword,
            arguments: {
              'phone': phoneNumber.value,
              'from': 'reset_password'
            }
          );
        } else if (fromScreen.value == 'register') {
          // Nếu từ đăng ký thì có thể chuyển đến màn hình đăng nhập hoặc trang chủ
          Get.offAllNamed(Routes.login);
        } else {
          // Mặc định chuyển đến đăng nhập
          Get.offAllNamed(Routes.login);
        }
        
      } catch (e) {
        // Show error message
        Get.snackbar(
          'Xác thực thất bại',
          'Mã OTP không đúng hoặc đã hết hạn',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(20),
          borderRadius: 10,
        );
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar(
        'Xác thực thất bại',
        'Vui lòng nhập đúng mã OTP 6 số',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        borderRadius: 10,
      );
    }
  }
} 