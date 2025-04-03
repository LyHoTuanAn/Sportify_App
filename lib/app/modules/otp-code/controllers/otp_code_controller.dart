import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../routes/app_pages.dart';

class OtpCodeController extends GetxController {
  // Form controller
  final otpController = TextEditingController();

  // Observable variables for form validation
  final isOtpValid = false.obs;

  // Loading state
  final isLoading = false.obs;

  // Timer for OTP resend
  final remainingTime = 60.obs; // 60s countdown
  final canResend = false.obs;
  Timer? _timer;

  // From arguments
  final phoneNumber = ''.obs;
  final fromScreen = ''.obs;
  final otpValue = ''.obs;

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

      // Check if OTP is directly passed from previous screen
      if (Get.arguments['otp'] != null) {
        otpValue.value = Get.arguments['otp'];
        otpController.text = otpValue.value;
        validateOtp();
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
    remainingTime.value = 60; // 60s countdown
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
  void resendOtp() async {
    if (!canResend.value) return;

    try {
      isLoading.value = true;

      // Call API to resend OTP
      final result = await Repo.auth.sendOtp(phoneNumber.value);

      if (result['status'] == 1) {
        // Reset timer
        startTimer();

        // Extract OTP from response for testing purposes
        String otpMessage =
            result['message'] ?? 'Vui lòng kiểm tra tin nhắn của bạn';
        if (result['otp'] != null) {
          otpMessage = 'Mã OTP của bạn là: ${result['otp']}';
        }

        // Show success message with OTP
        Get.snackbar(
          'Đã gửi lại mã OTP',
          otpMessage,
          backgroundColor: const Color(0xFF2B7A78),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(20),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Show error message
        Get.snackbar(
          'Gửi OTP thất bại',
          result['message'] ?? 'Vui lòng thử lại sau',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(20),
          borderRadius: 10,
        );
      }
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Gửi OTP thất bại',
        'Có lỗi xảy ra, vui lòng thử lại sau',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        borderRadius: 10,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP
  void verifyOtp() async {
    validateOtp();

    if (isOtpValid.value) {
      try {
        isLoading.value = true;

        final otp = otpController.text.trim();

        // Call API to verify OTP
        final isRegister = fromScreen.value == 'register';
        final isPasswordReset = fromScreen.value == 'forgot_password';
        final result = await Repo.auth.verifyOtp(
            phoneNumber.value, otp, isRegister,
            isPasswordReset: isPasswordReset);

        if (result['success'] == true) {
          // Show success message
          Get.snackbar(
            'Xác thực thành công',
            'Bạn đã xác thực thành công',
            backgroundColor: const Color(0xFF2B7A78),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(20),
            borderRadius: 10,
            duration: const Duration(seconds: 3),
          );

          // Navigate based on where we came from
          if (fromScreen.value == 'forgot_password') {
            Get.toNamed(Routes.resetPassword,
                arguments: {'phone': phoneNumber.value});
          } else if (fromScreen.value == 'register') {
            // If from registration, go to homepage
            Get.offAllNamed(Routes.dashboard);
          } else {
            // Default go to login
            Get.offAllNamed(Routes.login);
          }
        } else {
          // Show error message
          Get.snackbar(
            'Xác thực thất bại',
            result['message'] ?? 'Mã OTP không đúng hoặc đã hết hạn',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(20),
            borderRadius: 10,
          );
        }
      } catch (e) {
        // Show error message
        Get.snackbar(
          'Xác thực thất bại',
          'Có lỗi xảy ra, vui lòng thử lại sau',
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
