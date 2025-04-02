import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/repositories.dart';
import '../../../routes/app_pages.dart';

class ForgotPasswordController extends GetxController {
  // Form controller
  final phoneController = TextEditingController();

  // Observable variables for form validation
  final isPhoneValid = true.obs;

  // Loading state
  final isLoading = false.obs;

  // Overall form validity
  final isFormValid = false.obs;

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // Add listeners to update form validity
    ever(isPhoneValid, (_) => updateFormValidity());

    // Initial validation
    validateAll();
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  // Validate phone
  void validatePhone() {
    final phone = phoneController.text.trim();
    // Simple Vietnamese phone number validation (10 digits starting with 0)
    isPhoneValid.value = phone.isNotEmpty &&
        (phone.startsWith('0') || phone.startsWith('+84')) &&
        ((phone.startsWith('0') && phone.length == 10) ||
            (phone.startsWith('+84') && phone.length == 12)) &&
        phone.replaceAll('+', '').isNumericOnly;
  }

  // Validate all fields
  void validateAll() {
    validatePhone();
  }

  // Update overall form validity
  void updateFormValidity() {
    isFormValid.value = isPhoneValid.value;
  }

  // Format phone number to ensure +84 format
  String _formatPhoneNumber(String phone) {
    if (phone.startsWith('0')) {
      return '+84${phone.substring(1)}';
    }
    return phone;
  }

  // Request password reset
  void requestPasswordReset({GlobalKey<FormState>? formKey}) async {
    validateAll();

    // Validate form if formKey is provided
    if (formKey != null) {
      if (!formKey.currentState!.validate()) {
        return;
      }
    }

    if (isFormValid.value) {
      try {
        isLoading.value = true;

        final phone = _formatPhoneNumber(phoneController.text.trim());

        // Call forgot password API
        final result = await Repo.auth.forgotPassword(phone);

        if (result['status'] == 1) {
          // Extract OTP from response for testing purposes
          String otpMessage =
              result['message'] ?? 'Vui lòng kiểm tra tin nhắn của bạn';
          String? otpValue;
          if (result['otp'] != null) {
            otpValue = result['otp'].toString();
            otpMessage = 'Mã OTP của bạn là: $otpValue';
          }

          // Show success message with OTP
          Get.snackbar(
            'Yêu cầu đã được gửi',
            otpMessage,
            backgroundColor: const Color(0xFF2B7A78),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(20),
            borderRadius: 10,
            duration: const Duration(seconds: 3),
          );

          // Navigate to OTP screen
          Map<String, dynamic> arguments = {
            'phone': phone,
            'from': 'forgot_password'
          };

          // Add OTP to arguments if available
          if (otpValue != null) {
            arguments['otp'] = otpValue;
          }

          Get.toNamed(Routes.otpCode, arguments: arguments);
        } else {
          // Show error message
          Get.snackbar(
            'Lấy lại mật khẩu thất bại',
            result['message'] ??
                'Vui lòng kiểm tra số điện thoại và thử lại sau',
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
          'Lấy lại mật khẩu thất bại',
          'Vui lòng kiểm tra số điện thoại và thử lại sau',
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
  }
}
