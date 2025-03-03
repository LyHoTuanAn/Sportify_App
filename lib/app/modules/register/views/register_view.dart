import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/styles/style.dart';
import '../../../core/utilities/screen.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/app_button.dart';
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
                                icon: const Icon(Icons.close, color: Colors.grey),
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
                            
                            // Phone number field
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
                                prefixIcon: Icon(Icons.person, color: Color(0xFF2B7A78)),
                                suffixIcon: controller.isPhoneValid.value 
                                    ? null 
                                    : Icon(Icons.error, color: Colors.red),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2B7A78)),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
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
                                hintText: 'Nhập họ và tên đầy đủ',
                                prefixIcon: Icon(Icons.badge, color: Color(0xFF2B7A78)),
                                suffixIcon: controller.isNameValid.value 
                                    ? null 
                                    : Icon(Icons.error, color: Colors.red),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2B7A78)),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              onChanged: (_) => controller.validateName(),
                            )),
                            
                            const SizedBox(height: 20),
                            
                            // Password field
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
                              obscureText: !controller.isPasswordVisible.value,
                              decoration: InputDecoration(
                                hintText: 'Tạo mật khẩu của bạn',
                                prefixIcon: Icon(Icons.lock, color: Color(0xFF2B7A78)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordVisible.value 
                                        ? Icons.visibility 
                                        : Icons.visibility_off,
                                    color: Color(0xFF2B7A78),
                                  ),
                                  onPressed: controller.togglePasswordVisibility,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2B7A78)),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              onChanged: (_) => controller.validatePassword(),
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
                              controller: controller.confirmPasswordController,
                              obscureText: !controller.isConfirmPasswordVisible.value,
                              decoration: InputDecoration(
                                hintText: 'Xác nhận mật khẩu',
                                prefixIcon: Icon(Icons.lock, color: Color(0xFF2B7A78)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isConfirmPasswordVisible.value 
                                        ? Icons.visibility 
                                        : Icons.visibility_off,
                                    color: Color(0xFF2B7A78),
                                  ),
                                  onPressed: controller.toggleConfirmPasswordVisibility,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xFF2B7A78)),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              onChanged: (_) => controller.validateConfirmPassword(),
                            )),
                            
                            const SizedBox(height: 30),
                            
                            // Register button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () => controller.register(formKey: localFormKey),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ).copyWith(
                                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                  elevation: MaterialStateProperty.all(0),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF2B7A78), Color(0xFF17252A)],
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
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'ĐĂNG KÝ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Login link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Bạn đã có tài khoản? ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Get.toNamed(Routes.login),
                                  child: const Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2B7A78),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Or sign up with
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[400],
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'hoặc đăng ký với',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[400],
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Google sign in button
                            Center(
                              child: GestureDetector(
                                onTap: controller.signInWithGoogle,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Image.asset(
                                      'assets/images/google.png',
                                      height: 24,
                                    ),
                                  ),
                                ),
                              ),
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
