import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/repositories.dart';
import '../../../routes/app_pages.dart';

class ResetPasswordController extends GetxController {
  // Form controllers
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable variables for form validation
  final isPasswordValid = false.obs;
  final isConfirmPasswordValid = false.obs;

  // Observable for password visibility
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  // Loading state
  final isLoading = false.obs;

  // Overall form validity
  final isFormValid = false.obs;

  // From arguments
  final phoneNumber = ''.obs;

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // Add listeners to update form validity
    ever(isPasswordValid, (_) => updateFormValidity());
    ever(isConfirmPasswordValid, (_) => updateFormValidity());

    // Get arguments passed from previous screen
    if (Get.arguments != null) {
      if (Get.arguments['phone'] != null) {
        phoneNumber.value = Get.arguments['phone'];
      }
    }

    // Initial validation
    validateAll();
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Validate password
  void validatePassword() {
    final password = passwordController.text.trim();
    isPasswordValid.value = password.length >= 6;
    // If confirm password is already filled, validate it against the new password
    if (confirmPasswordController.text.isNotEmpty) {
      validateConfirmPassword();
    }
  }

  // Validate confirm password
  void validateConfirmPassword() {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    isConfirmPasswordValid.value =
        password == confirmPassword && password.isNotEmpty;
  }

  // Validate all fields
  void validateAll() {
    validatePassword();
    validateConfirmPassword();
  }

  // Update overall form validity
  void updateFormValidity() {
    isFormValid.value = isPasswordValid.value && isConfirmPasswordValid.value;
  }

  // Reset password
  void resetPassword({GlobalKey<FormState>? formKey}) async {
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

        final password = passwordController.text.trim();
        final confirmPassword = confirmPasswordController.text.trim();

        // Call reset password API
        final result = await Repo.auth.resetPassword(
          phone: phoneNumber.value,
          password: password,
          passwordConfirmation: confirmPassword,
        );

        if (result['status'] == 1 || result['success'] == true) {
          // Show success message
          Get.snackbar(
            'Đổi mật khẩu thành công',
            result['message'] ?? 'Vui lòng đăng nhập với mật khẩu mới',
            backgroundColor: const Color(0xFF2B7A78),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(20),
            borderRadius: 10,
            duration: const Duration(seconds: 3),
          );

          // Navigate to login screen
          Get.offAllNamed(Routes.login);
        } else {
          // Show error message
          Get.snackbar(
            'Đổi mật khẩu thất bại',
            result['message'] ?? 'Vui lòng kiểm tra thông tin và thử lại sau',
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
          'Đổi mật khẩu thất bại',
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
  }
}
