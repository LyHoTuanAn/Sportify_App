import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/repositories.dart';
import '../../../data/services/firebase_analytics_service.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/google_auth_service.dart';
import '../../../modules/profile/controllers/profile_controller.dart';

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

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
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
        phone.startsWith('0') &&
        phone.length == 10 &&
        phone.isNumericOnly;
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

        // Simulate API call with delay
        await Future.delayed(const Duration(seconds: 2));

        // This is where we'll call the API in the future
        print('Phone: ${phoneController.text}');
        print('Password: ${passwordController.text}');

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

        // Chuyển đến trang chủ
        Get.offAllNamed(Routes.dashboard);
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

      final result = await Repo.auth.googleSignIn();

      if (result != null) {
        FirebaseAnalyticService.logLogin();

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

        // Load user details
        await Get.putAsync(
          () => ProfileController().getUserDetail(isLogin: true),
          permanent: true,
        );

        // Navigate to dashboard
        Get.offAllNamed(Routes.dashboard);
      } else {
        Get.snackbar(
          'Đăng nhập thất bại',
          'Không thể đăng nhập bằng Google, vui lòng thử lại',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(20),
          borderRadius: 10,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Đăng nhập thất bại',
        'Lỗi: ${e.toString()}',
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
