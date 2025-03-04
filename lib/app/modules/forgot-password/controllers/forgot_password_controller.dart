import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                         phone.startsWith('0') && 
                         phone.length == 10 &&
                         phone.isNumericOnly;
  }
  
  // Validate all fields
  void validateAll() {
    validatePhone();
  }
  
  // Update overall form validity
  void updateFormValidity() {
    isFormValid.value = isPhoneValid.value;
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
        
        // Simulate API call with delay
        await Future.delayed(const Duration(seconds: 2));
        
        // This is where we'll call the API in the future
        print('Phone: ${phoneController.text}');
        
        // Show success message
        Get.snackbar(
          'Yêu cầu đã được gửi',
          'Vui lòng kiểm tra tin nhắn của bạn',
          backgroundColor: const Color(0xFF2B7A78),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(20),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
        );
        
        // Lưu số điện thoại để sử dụng ở màn hình OTP
        Get.toNamed(
          Routes.otpCode, 
          arguments: {
            'phone': phoneController.text.trim(),
            'from': 'forgot_password'
          }
        );
        
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