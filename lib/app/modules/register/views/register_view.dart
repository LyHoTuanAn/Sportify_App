import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

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
                                onPressed: () => controller.goToLogin(),
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
                                'Đăng ký',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2B7A78),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Subtitle
                            const Center(
                              child: Text(
                                'Đặt lịch sân thể thao dễ dàng',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Phone field
                            const Text(
                              'Số điện thoại',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(() => TextFormField(
                                  controller: controller.phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập số điện thoại',
                                    prefixIcon: const Icon(Icons.phone,
                                        color: Color(0xFF2B7A78)),
                                    suffixIcon: controller.isPhoneValid.value
                                        ? null
                                        : const Icon(Icons.error,
                                            color: Colors.red),
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
                                  onChanged: (_) => controller.validatePhone(),
                                )),

                            const SizedBox(height: 20),

                            // Full name field
                            const Text(
                              'Họ và tên',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(() => TextFormField(
                                  controller: controller.nameController,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập họ và tên',
                                    prefixIcon: const Icon(Icons.person,
                                        color: Color(0xFF2B7A78)),
                                    suffixIcon: controller.isNameValid.value
                                        ? null
                                        : const Icon(Icons.error,
                                            color: Colors.red),
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
                                  onChanged: (_) => controller.validateName(),
                                )),

                            const SizedBox(height: 20),

                            // Email field (changed from Password)
                            const Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(() => TextFormField(
                                  controller: controller.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập email',
                                    prefixIcon: const Icon(Icons.email,
                                        color: Color(0xFF2B7A78)),
                                    suffixIcon: controller.isEmailValid.value
                                        ? null
                                        : const Icon(Icons.error,
                                            color: Colors.red),
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
                                  onChanged: (_) => controller.validateEmail(),
                                )),

                            const SizedBox(height: 20),

                            // Password field (changed from Confirm password)
                            const Text(
                              'Mật khẩu',
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
                                    hintText: 'Nhập mật khẩu',
                                    prefixIcon: const Icon(Icons.lock,
                                        color: Color(0xFF2B7A78)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isPasswordVisible.value
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey,
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

                            const SizedBox(height: 40),

                            // Register button
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
                                        ? () => controller.register(
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
                                            'ĐĂNG KÝ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  )),
                            ),

                            const SizedBox(height: 20),

                            // Or sign in with text
                            const Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('Hoặc đăng ký với',
                                      style: TextStyle(color: Colors.grey)),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Google sign in button
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextButton.icon(
                                onPressed: controller.signInWithGoogle,
                                icon: Image.asset(
                                  'assets/images/google.png',
                                  height: 24,
                                ),
                                label: const Text(
                                  'Google',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Login link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Đã có tài khoản?',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                TextButton(
                                  onPressed: () => controller.goToLogin(),
                                  child: const Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      color: Color(0xFF2B7A78),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
