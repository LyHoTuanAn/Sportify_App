import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart'; // Make sure this import is included
import '../../../routes/app_pages.dart';

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

      final user = await Repo.auth.signInWithGoogle();

      if (user != null) {
        // Show success message
        Get.snackbar(
          'Đăng ký thành công',
          'Chào mừng ${user.fullName ?? 'bạn'} đến với Sportify!',
          backgroundColor: const Color(0xFF2B7A78),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(20),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
        );

        // Navigate to home
        Get.offAllNamed(Routes.dashboard);
      } else {
        // Show error message
        Get.snackbar(
          'Đăng ký thất bại',
          'Không thể đăng ký với Google, vui lòng thử lại sau',
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
        'Đăng ký thất bại',
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

// Add the extension to properly access the name
extension UserModelExtension on UserModel {
  String? get fullName {
    // Use only firstName and lastName which appear to exist in UserModel
    if (this.firstName != null && this.lastName != null) {
      return '${this.firstName} ${this.lastName}';
    } else if (this.firstName != null) {
      return this.firstName;
    } else if (this.lastName != null) {
      return this.lastName;
    }
    // Fall back to empty string if no name components available
    return '';
  }
}
