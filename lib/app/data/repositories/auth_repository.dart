part of 'repositories.dart';

abstract class AuthBase {
  Future<void> logout();
  Future<bool> sendEmailPassword(String email, String password);
  Future<dynamic> googleSignIn();
}

class AuthRepository implements AuthBase {
  @override
  Future<bool> sendEmailPassword(String email, String password) {
    return ApiProvider.sendEmailPassword(email, password);
  }

  @override
  Future<void> logout() {
    GoogleAuthService.signOut();
    return ApiProvider.logout();
  }

  @override
  Future<dynamic> googleSignIn() async {
    final userCredential = await GoogleAuthService.signInWithGoogle();

    if (userCredential != null && userCredential.user != null) {
      try {
        final result = await ApiProvider.googleAuth(userCredential.user!);
        if (result != null) {
          return result;
        }
        // Nếu API trả về null nhưng không throw exception, vẫn đăng xuất Firebase
        await GoogleAuthService.signOut();
        return null;
      } catch (e) {
        // Nếu API call thất bại, vẫn đăng xuất từ Firebase
        await GoogleAuthService.signOut();
        rethrow;
      }
    }
    return null;
  }
}
