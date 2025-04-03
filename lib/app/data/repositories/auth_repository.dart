part of 'repositories.dart';

abstract class AuthBase {
  Future<void> logout();
  Future<bool> sendEmailPassword(String email, String password);
  Future<bool> sendPhoneOtp(String phone, String countryCode);
  Future<Map<String, dynamic>> login(String username, String password);
  Future<Map<String, dynamic>> register(
      String fullName, String phone, String email, String password);
  Future<Map<String, dynamic>> sendOtp(String phone);
  Future<Map<String, dynamic>> verifyOtp(
      String phone, String otp, bool isRegister,
      {bool isPasswordReset = false});
  Future<Map<String, dynamic>> forgotPassword(String phone);
  Future<Map<String, dynamic>> changePassword(
      {String? currentPassword, required String newPassword});
  Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String password,
    required String passwordConfirmation,
  });
  Future<UserModel?> signInWithGoogle();
  Future<UserModel?> authenticateWithFirebaseToken(
      String token, String name, String photoUrl);
}

class AuthRepository implements AuthBase {
  @override
  Future<Map<String, dynamic>> login(String username, String password) {
    return ApiProvider.login(username, password);
  }

  @override
  Future<Map<String, dynamic>> register(
      String fullName, String phone, String email, String password) {
    return ApiProvider.register(fullName, phone, email, password);
  }

  @override
  Future<Map<String, dynamic>> sendOtp(String phone) {
    return ApiProvider.sendOtp(phone);
  }

  @override
  Future<bool> sendPhoneOtp(String phone, String countryCode) {
    return ApiProvider.sendPhoneOtp(phone, countryCode);
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(
      String phone, String otp, bool isRegister,
      {bool isPasswordReset = false}) {
    return ApiProvider.verifyOtp(phone, otp, isRegister,
        isPasswordReset: isPasswordReset);
  }

  @override
  Future<Map<String, dynamic>> forgotPassword(String phone) {
    return ApiProvider.forgotPassword(phone);
  }

  @override
  Future<Map<String, dynamic>> changePassword(
      {String? currentPassword, required String newPassword}) {
    return ApiProvider.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) {
    return ApiProvider.resetPassword(
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  @override
  Future<bool> sendEmailPassword(String email, String password) {
    return ApiProvider.sendEmailPassword(email, password);
  }

  @override
  Future<void> logout() {
    return ApiProvider.logout();
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Get Firebase auth info from ApiProvider
      final authResult = await ApiProvider.signInWithGoogle();
      if (authResult != null) {
        // Send Firebase token to backend
        return await authenticateWithFirebaseToken(authResult['token'],
            authResult['name'] ?? '', authResult['photoUrl'] ?? '');
      }
      return null;
    } catch (e) {
      AppUtils.log('Error in signInWithGoogle: $e');
      return null;
    }
  }

  @override
  Future<UserModel?> authenticateWithFirebaseToken(
      String token, String name, String photoUrl) {
    return ApiProvider.authenticateWithFirebaseToken(token, name, photoUrl);
  }
}
