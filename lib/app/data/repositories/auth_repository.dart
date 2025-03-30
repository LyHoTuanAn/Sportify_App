part of 'repositories.dart';

abstract class AuthBase {
  Future<void> logout();
  Future<bool> sendEmailPassword(String email, String password);
  Future<UserModel?> signInWithGoogle();
  Future<UserModel?> authenticateWithFirebaseToken(
      String token, String name, String photoUrl);
}

class AuthRepository implements AuthBase {
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
