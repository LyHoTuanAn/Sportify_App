import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/styles/style.dart';
// ignore: unused_import
import '../../../core/utilities/screen.dart';
// ignore: unused_import
import '../../../routes/app_pages.dart';
// ignore: unused_import
import '../../../widgets/app_button.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a local form key to avoid duplicate GlobalKey issues
    final localFormKey = GlobalKey<FormState>();

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF2B7A78),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF2B7A78),
        body: SafeArea(
          child: Column(
            children: [
              // Top spacing
              const SizedBox(height: 10),

              // Main content card
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: localFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Close button
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.grey),
                                onPressed: () => Get.back(),
                              ),
                            ),

                            // Logo
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/logo.png',
                                    height: 40,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Sportify',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2B7A78),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Title
                            const Center(
                              child: Text(
                                'Đặt Lại Mật Khẩu',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2B7A78),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Subtitle
                            Center(
                              child: Text(
                                'Đặt lịch sân thể thao dễ dàng',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // New password field
                            const Text(
                              'Mật khẩu mới',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(() => TextFormField(
                                  controller: controller.passwordController,
                                  obscureText:
                                      !controller.isPasswordVisible.value,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập mật khẩu mới',
                                    prefixIcon: const Icon(Icons.lock,
                                        color: Color(0xFF2B7A78)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isPasswordVisible.value
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: const Color(0xFF2B7A78),
                                      ),
                                      onPressed:
                                          controller.togglePasswordVisibility,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF2B7A78)),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  onChanged: (_) =>
                                      controller.validatePassword(),
                                )),

                            const SizedBox(height: 20),

                            // Confirm password field
                            const Text(
                              'Nhập lại mật khẩu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(() => TextFormField(
                                  controller:
                                      controller.confirmPasswordController,
                                  obscureText: !controller
                                      .isConfirmPasswordVisible.value,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập lại mật khẩu mới',
                                    prefixIcon: const Icon(Icons.lock,
                                        color: Color(0xFF2B7A78)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller
                                                .isConfirmPasswordVisible.value
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: const Color(0xFF2B7A78),
                                      ),
                                      onPressed: controller
                                          .toggleConfirmPasswordVisibility,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF2B7A78)),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  onChanged: (_) =>
                                      controller.validateConfirmPassword(),
                                )),

                            const SizedBox(height: 30),

                            // Reset password button
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2B7A78),
                                    Color(0xFF17252A)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x332B7A78),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              width: double.infinity,
                              height: 50,
                              child: Obx(() => ElevatedButton(
                                    onPressed: controller.isFormValid.value
                                        ? () => controller.resetPassword(
                                            formKey: localFormKey)
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: controller.isLoading.value
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          )
                                        : const Text(
                                            'XÁC NHẬN',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  )),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
