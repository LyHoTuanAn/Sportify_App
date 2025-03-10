import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class UserProfileController extends GetxController {
  // Form controllers
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable variables for form validation
  final isNewPasswordValid = true.obs;
  final isConfirmPasswordValid = true.obs;
  
  // Observable for password visibility
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  
  // Loading state
  final isLoading = false.obs;
  
  // Overall form validity
  final isFormValid = false.obs;

  // From arguments
  final phoneNumber = ''.obs;
  final fromScreen = ''.obs;

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // Add listeners to update form validity
    ever(isNewPasswordValid, (_) => updateFormValidity());
    ever(isConfirmPasswordValid, (_) => updateFormValidity());
    
    // Get arguments passed from previous screen
    if (Get.arguments != null) {
      if (Get.arguments['phone'] != null) {
        phoneNumber.value = Get.arguments['phone'];
      }
      
      if (Get.arguments['from'] != null) {
        fromScreen.value = Get.arguments['from'];
      }
    }
    
    // Initial validation
    validateAll();
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Toggle new password visibility
  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }
  
  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Validate new password
  void validateNewPassword() {
    final password = newPasswordController.text.trim();
    // Password must be at least 6 characters
    isNewPasswordValid.value = password.length >= 6;
    
    // Also validate confirm password when password changes
    validateConfirmPassword();
  }
  
  // Validate confirm password
  void validateConfirmPassword() {
    final confirmPassword = confirmPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    
    isConfirmPasswordValid.value = confirmPassword.isNotEmpty && 
                                  confirmPassword == newPassword;
  }
  
  // Validate all fields
  void validateAll() {
    validateNewPassword();
    validateConfirmPassword();
  }
  
  // Update overall form validity
  void updateFormValidity() {
    isFormValid.value = isNewPasswordValid.value && isConfirmPasswordValid.value;
  }

  // Change password
  void changePassword({GlobalKey<FormState>? formKey}) async {
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
        print('Changing password for phone: $phoneNumber');
        print('New Password: ${newPasswordController.text}');
        
        // Show success message
        Get.snackbar(
          'Đổi mật khẩu thành công',
          'Mật khẩu của bạn đã được cập nhật',
          backgroundColor: const Color(0xFF2B7A78),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(20),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
        );
        
        // Navigate based on where we came from
        if (fromScreen.value == 'reset_password') {
          // Nếu từ quên mật khẩu thì chuyển về đăng nhập
          Get.offAllNamed(Routes.login);
        } else {
          // Nếu từ trang cá nhân thì quay lại
          Get.back();
        }
        
      } catch (e) {
        // Show error message
        Get.snackbar(
          'Đổi mật khẩu thất bại',
          'Vui lòng thử lại sau',
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

  // Sign in with Google
  void signInWithGoogle() {
    // TODO: Implement Google Sign-In
    Get.snackbar(
      'Google Sign-In',
      'Tính năng đang được phát triển',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(20),
      borderRadius: 10,
    );
  }
}
