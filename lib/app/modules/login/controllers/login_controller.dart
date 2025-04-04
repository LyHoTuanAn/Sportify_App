import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../routes/app_pages.dart';
import '../../../modules/dashboard/controllers/dashboard_controller.dart';
import '../../register/controllers/register_controller.dart';
import '../../forgot-password/controllers/forgot_password_controller.dart';
class LoginController extends GetxController {
  // Form controllers
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable variables for form validation
  final isPhoneValid = true.obs;
  final isPasswordValid = true.obs;

  // Observable for password visibility
  final isPasswordVisible = false.obs;

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
    ever(isPasswordValid, (_) => updateFormValidity());

    // Initial validation
    validateAll();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Validate phone number
  void validatePhone() {
    final phone = phoneController.text.trim();
    // Simple Vietnamese phone number validation (10 digits starting with 0)
    isPhoneValid.value = phone.isNotEmpty &&
        (phone.startsWith('0') || phone.startsWith('+84')) &&
        ((phone.startsWith('0') && phone.length == 10) ||
            (phone.startsWith('+84') && phone.length == 12)) &&
        phone.replaceAll('+', '').isNumericOnly;
  }

  @override  
  void dispose() {
    if (Get.isRegistered<RegisterController>()) {
      Get.delete<RegisterController>();
    }
    if (Get.isRegistered<ForgotPasswordController>()) {
      Get.delete<ForgotPasswordController>();
    }
    super.dispose();
  }
  
  // Validate password
  void validatePassword() {
    final password = passwordController.text.trim();
    // Password must be at least 6 characters
    isPasswordValid.value = password.length >= 6;
  }

  // Validate all fields
  void validateAll() {
    validatePhone();
    validatePassword();
  }

  // Update overall form validity
  void updateFormValidity() {
    isFormValid.value = isPhoneValid.value && isPasswordValid.value;
  }

  // Navigate to forgot password screen
  void goToForgotPassword() {
    Get.toNamed(Routes.forgotPassword);
  }

  // Navigate to registration screen
  void goToRegister() {
    Get.toNamed(Routes.register);
  }

  // Format phone number to ensure +84 format
  String _formatPhoneNumber(String phone) {
    if (phone.startsWith('0')) {
      return '+84${phone.substring(1)}';
    }
    return phone;
  }

  // Login user
  void login({GlobalKey<FormState>? formKey}) async {
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
        final password = passwordController.text.trim();

        // Call login API
        final result = await Repo.auth.login(phone, password);

        if (result['success'] == true) {
          // Show success message
          Get.snackbar(
            'Đăng nhập thành công',
            'Chào mừng bạn trở lại với Sportify!',
            backgroundColor: const Color(0xFF2B7A78),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(20),
            borderRadius: 10,
            duration: const Duration(seconds: 3),
          );

          // Navigate to home
          Get.offAllNamed(Routes.dashboard);
          // Wait for navigation to complete, then set the tab
          Future.delayed(const Duration(milliseconds: 100), () {
            if (Get.isRegistered<DashboardController>()) {
              final dashboardController = Get.find<DashboardController>();
              dashboardController.changePage(0);
            }
          });
        } else {
          // Show error message
          Get.snackbar(
            'Đăng nhập thất bại',
            result['message'] ?? 'Vui lòng kiểm tra thông tin đăng nhập',
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
          'Đăng nhập thất bại',
          'Vui lòng kiểm tra thông tin đăng nhập',
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
  void signInWithGoogle() async {
    try {
      isLoading.value = true;

      final user = await Repo.auth.signInWithGoogle();

      if (user != null) {
        // Show success message
        Get.snackbar(
          'Đăng nhập thành công',
          'Chào mừng ${user.fullName} đã trở lại với Sportify!',
          backgroundColor: const Color(0xFF2B7A78),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(20),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
        );

        // Navigate to home
        Get.offAllNamed(Routes.dashboard);
        // Wait for navigation to complete, then set the tab
        Future.delayed(const Duration(milliseconds: 100), () {
          if (Get.isRegistered<DashboardController>()) {
            final dashboardController = Get.find<DashboardController>();
            dashboardController.changePage(0);
          }
        });
      } else {
        // Show error message
        Get.snackbar(
          'Đăng nhập thất bại',
          'Không thể đăng nhập với Google, vui lòng thử lại sau',
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
        'Đăng nhập thất bại',
        'Có lỗi xảy ra: ${e.toString()}',
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

extension UserModelExtension on UserModel {
  String? get fullName {
    // Use only firstName and lastName which appear to exist in UserModel
    return '$firstName $lastName';
      // Fall back to empty string if no name components available
  }
}

