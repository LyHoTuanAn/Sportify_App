import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/firebase_analytics_service.dart';
import '../../../routes/app_pages.dart';
import '../../../data/repositories/repositories.dart';
import '../../../data/services/google_auth_service.dart';
import '../../../core/utilities/utilities.dart';
import '../../../modules/profile/controllers/profile_controller.dart';

class RegisterController extends GetxController {
  // Form controllers
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable variables for form validation
  final isPhoneValid = true.obs;
  final isNameValid = true.obs;
  final isPasswordValid = true.obs;
  final isConfirmPasswordValid = true.obs;

  // Observable for password visibility
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

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
    ever(isNameValid, (_) => updateFormValidity());
    ever(isPasswordValid, (_) => updateFormValidity());
    ever(isConfirmPasswordValid, (_) => updateFormValidity());

    // Initial validation
    validateAll();
  }

  @override
  void onClose() {
    phoneController.dispose();
    nameController.dispose();
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

  // Validate phone number
  void validatePhone() {
    final phone = phoneController.text.trim();
    // Simple Vietnamese phone number validation (10 digits starting with 0)
    isPhoneValid.value = phone.isNotEmpty &&
        phone.startsWith('0') &&
        phone.length == 10 &&
        phone.isNumericOnly;
  }

  // Validate name
  void validateName() {
    final name = nameController.text.trim();
    isNameValid.value = name.isNotEmpty && name.length >= 3;
  }

  // Validate password
  void validatePassword() {
    final password = passwordController.text.trim();
    // Password must be at least 6 characters
    isPasswordValid.value = password.length >= 6;

    // Also validate confirm password when password changes
    if (confirmPasswordController.text.isNotEmpty) {
      validateConfirmPassword();
    }
  }

  // Validate confirm password
  void validateConfirmPassword() {
    isConfirmPasswordValid.value =
        confirmPasswordController.text == passwordController.text &&
            confirmPasswordController.text.trim().isNotEmpty;
  }

  // Validate all fields
  void validateAll() {
    validatePhone();
    validateName();
    validatePassword();
    validateConfirmPassword();
  }

  // Update overall form validity
  void updateFormValidity() {
    isFormValid.value = isPhoneValid.value &&
        isNameValid.value &&
        isPasswordValid.value &&
        isConfirmPasswordValid.value;
  }

  // Navigate to login screen
  void goToLogin() {
    Get.offAllNamed(Routes.login);
  }

  // Register user
  void register({GlobalKey<FormState>? formKey}) async {
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
        print('Name: ${nameController.text}');
        print('Password: ${passwordController.text}');

        // Show success message
        Get.snackbar(
          'Đăng ký thành công',
          'Chào mừng bạn đến với Sportify!',
          backgroundColor: const Color(0xFF2B7A78),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(20),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
        );

        // Trong trường hợp xác thực số điện thoại, chuyển đến màn hình OTP
        Get.toNamed(Routes.otpCode, arguments: {
          'phone': phoneController.text.trim(),
          'from': 'register'
        });
      } catch (e) {
        // Show error message
        Get.snackbar(
          'Đăng ký thất bại',
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
  void signInWithGoogle() async {
    try {
      isLoading.value = true;

      final result = await Repo.auth.googleSignIn();

      if (result != null) {
        FirebaseAnalyticService.logEvent('Register_With_Google');

        Get.snackbar(
          'Đăng ký thành công',
          'Chào mừng bạn đến với Sportify!',
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
      }
    } catch (e) {
      Get.snackbar(
        'Đăng ký thất bại',
        'Không thể đăng ký bằng Google, vui lòng thử lại',
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
