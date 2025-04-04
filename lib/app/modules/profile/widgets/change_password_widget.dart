part of 'widgets.dart';

class ChangePasswordWidget extends StatefulWidget {
  const ChangePasswordWidget({super.key});

  static void showBottom() {
    Get.bottomSheet(
      const ChangePasswordWidget(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<ChangePasswordWidget> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();

  // Observable variables for password visibility
  final _isNewPasswordVisible = false.obs;
  final _isConfirmPasswordVisible = false.obs;
  final _isCurrentPasswordVisible = false.obs;

  // Validation status
  final _isNewPasswordValid = true.obs;
  final _isConfirmPasswordValid = true.obs;
  final _isCurrentPasswordValid = true.obs;
  final _isFormValid = false.obs;

  // Loading state
  final _isLoading = false.obs;

  // Workers list for cleanup
  final List<Worker> _workers = [];

  @override
  void initState() {
    super.initState();

    // Setup listeners for validation
    _workers.add(ever(_isNewPasswordValid, (_) => _updateFormValidity()));
    _workers.add(ever(_isConfirmPasswordValid, (_) => _updateFormValidity()));
    _workers.add(ever(_isCurrentPasswordValid, (_) => _updateFormValidity()));

    // Initial validation
    _validateAll();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordController.dispose();

    // Dispose all workers
    for (final worker in _workers) {
      worker.dispose();
    }

    super.dispose();
  }

  // Toggle password visibility
  void _toggleNewPasswordVisibility() {
    _isNewPasswordVisible.value = !_isNewPasswordVisible.value;
  }

  void _toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible.value = !_isConfirmPasswordVisible.value;
  }

  void _toggleCurrentPasswordVisibility() {
    _isCurrentPasswordVisible.value = !_isCurrentPasswordVisible.value;
  }

  // Validation methods
  void _validateNewPassword() {
    final password = _newPasswordController.text.trim();
    _isNewPasswordValid.value = password.length >= 6;
    _validateConfirmPassword();
  }

  void _validateConfirmPassword() {
    final confirmPassword = _confirmPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    _isConfirmPasswordValid.value =
        confirmPassword.isNotEmpty && confirmPassword == newPassword;
  }

  void _validateCurrentPassword() {
    final currentPassword = _currentPasswordController.text.trim();
    _isCurrentPasswordValid.value = currentPassword.length >= 6;
  }

  void _validateAll() {
    _validateNewPassword();
    _validateConfirmPassword();
    _validateCurrentPassword();
  }

  void _updateFormValidity() {
    _isFormValid.value = _isNewPasswordValid.value &&
        _isConfirmPasswordValid.value &&
        _isCurrentPasswordValid.value;
  }

  // Method to change password
  Future<void> _changePassword() async {
    Get.focusScope?.unfocus();
    _validateAll();

    if (_formKey.currentState!.validate()) {
      try {
        _isLoading.value = true;

        // Get form values
        final newPassword = _newPasswordController.text.trim();
        final currentPassword = _currentPasswordController.text.trim();

        // Call API to change password
        final result = await Repo.auth.changePassword(
            currentPassword: currentPassword, newPassword: newPassword);

        if (result['status'] == 1) {
          // Close the bottom sheet first
          Get.back();

          // Show success message after returning to profile
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar(
              'Đổi mật khẩu thành công',
              'Mật khẩu của bạn đã được cập nhật',
              backgroundColor: const Color(0xFF2B7A78),
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              margin: const EdgeInsets.all(20),
              borderRadius: 10,
              duration: const Duration(seconds: 2),
            );
          });
        } else {
          Get.snackbar(
            'Đổi mật khẩu thất bại',
            result['message'] ?? 'Vui lòng thử lại sau',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(20),
            borderRadius: 10,
          );
        }
      } catch (e) {
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
        _isLoading.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.screenHeight * .9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2B7A78),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thay đổi mật khẩu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    // Current password field
                    const Text(
                      'Mật khẩu hiện tại',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => TextFormField(
                          controller: _currentPasswordController,
                          obscureText: !_isCurrentPasswordVisible.value,
                          onChanged: (_) => _validateCurrentPassword(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu hiện tại';
                            }
                            if (value.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Nhập mật khẩu hiện tại',
                            prefixIcon: const Icon(Icons.lock,
                                color: Color(0xFF2B7A78)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isCurrentPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xFF2B7A78),
                              ),
                              onPressed: _toggleCurrentPasswordVisibility,
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
                              borderSide:
                                  const BorderSide(color: Color(0xFF2B7A78)),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                        )),

                    const SizedBox(height: 20),

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
                          controller: _newPasswordController,
                          obscureText: !_isNewPasswordVisible.value,
                          onChanged: (_) => _validateNewPassword(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu mới';
                            }
                            if (value.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Nhập mật khẩu mới',
                            prefixIcon: const Icon(Icons.lock,
                                color: Color(0xFF2B7A78)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isNewPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xFF2B7A78),
                              ),
                              onPressed: _toggleNewPasswordVisibility,
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
                              borderSide:
                                  const BorderSide(color: Color(0xFF2B7A78)),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
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
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible.value,
                          onChanged: (_) => _validateConfirmPassword(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập lại mật khẩu mới';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Mật khẩu không khớp';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Nhập lại mật khẩu mới',
                            prefixIcon: const Icon(Icons.lock,
                                color: Color(0xFF2B7A78)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xFF2B7A78),
                              ),
                              onPressed: _toggleConfirmPasswordVisibility,
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
                              borderSide:
                                  const BorderSide(color: Color(0xFF2B7A78)),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                        )),

                    const SizedBox(height: 30),

                    // Change password button
                    Container(
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
                      width: double.infinity,
                      height: 50,
                      child: Obx(() => ElevatedButton(
                            onPressed: (_isFormValid.value && !_isLoading.value)
                                ? _changePassword
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading.value
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
