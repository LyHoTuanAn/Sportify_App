import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  // Form controllers
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable variables for form validation
  final isPhoneValid = true.obs;
  final isNameValid = true.obs;
  final isEmailValid = true.obs;
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
    ever(isNameValid, (_) => updateFormValidity());
    ever(isEmailValid, (_) => updateFormValidity());
    ever(isPasswordValid, (_) => updateFormValidity());

    // Initial validation
    validateAll();
  }

  @override
  void onClose() {
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
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
        (phone.startsWith('0') || phone.startsWith('+84')) &&
        ((phone.startsWith('0') && phone.length == 10) ||
            (phone.startsWith('+84') && phone.length == 12)) &&
        phone.replaceAll('+', '').isNumericOnly;
  }

  // Validate name
  void validateName() {
    final name = nameController.text.trim();
    isNameValid.value = name.isNotEmpty && name.length >= 3;
  }

  // Validate email
  void validateEmail() {
    final email = emailController.text.trim();
    // Email validation using GetX's built-in email validator
    isEmailValid.value = email.isNotEmpty && email.isEmail;
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
    validateName();
    validateEmail();
    validatePassword();
  }

  // Update overall form validity
  void updateFormValidity() {
    isFormValid.value = isPhoneValid.value &&
        isNameValid.value &&
        isEmailValid.value &&
        isPasswordValid.value;
  }

  // Navigate to login screen
  void goToLogin() {
    Get.offAllNamed(Routes.login);
  }

  // Format phone number to ensure +84 format
  String _formatPhoneNumber(String phone) {
    if (phone.startsWith('0')) {
      return '+84${phone.substring(1)}';
    }
    return phone;
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

        final phone = _formatPhoneNumber(phoneController.text.trim());
        final name = nameController.text.trim();
        final email = emailController.text.trim();
        final password = passwordController.text.trim();

        // Call register API
        final result = await Repo.auth.register(name, phone, email, password);

        if (result['status'] == 1 && result['require_verification'] == true) {
          // Extract OTP from response for testing purposes
          String otpMessage =
              result['message'] ?? 'Chào mừng bạn đến với Sportify!';
          String? otpValue;
          if (result['otp'] != null) {
            otpValue = result['otp'].toString();
            otpMessage = 'Mã OTP của bạn là: $otpValue';
          }

          // Show success message with OTP
          Get.snackbar(
            'Đăng ký thành công',
            otpMessage,
            backgroundColor: const Color(0xFF2B7A78),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(20),
            borderRadius: 10,
            duration: const Duration(seconds: 3),
          );

          // Navigate to OTP screen for verification
          Map<String, dynamic> arguments = {'phone': phone, 'from': 'register'};

          // Add OTP to arguments if available
          if (otpValue != null) {
            arguments['otp'] = otpValue;
          }

          Get.toNamed(Routes.otpCode, arguments: arguments);
        } else {
          // Show error message
          Get.snackbar(
            'Đăng ký thất bại',
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
          'Chào mừng ${user.fullName} đến với Sportify!',
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
    return '$firstName $lastName';
      // Fall back to empty string if no name components available
  }
}

