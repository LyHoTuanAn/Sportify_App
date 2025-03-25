import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/utilities/utilities.dart';
import '../../data/models/models.dart';
import '../providers/providers.dart';
import 'firebase_analytics_service.dart';

class GoogleAuthService {
  GoogleAuthService._();
  static final GoogleAuthService _instance = GoogleAuthService._();
  factory GoogleAuthService() => _instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();

      if (gUser == null) {
        // User canceled the sign-in flow
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create new credential for user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Log analytics event
      FirebaseAnalyticService.logEvent('Google_SignIn_Attempt');

      // Sign in with credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      AppUtils.log('Error during Google sign in: $e');
      AppUtils.toast('Đăng nhập Google thất bại, vui lòng thử lại');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      AppUtils.log('Error during sign out: $e');
    }
  }

  // Extract UserModel from Firebase User
  static UserModel? mapFirebaseUserToUserModel(User user) {
    try {
      // Parse name into first and last name
      String fullName = user.displayName ?? '';
      List<String> nameParts = fullName.split(' ');
      String firstName = '';
      String lastName = '';

      if (nameParts.isNotEmpty) {
        lastName = nameParts.last;
        firstName = nameParts.length > 1
            ? nameParts.sublist(0, nameParts.length - 1).join(' ')
            : '';
      }

      return UserModel(
        firstName: firstName,
        lastName: lastName,
        email: user.email ?? '',
        phone: user.phoneNumber ?? '',
        avatar: user.photoURL,
        gender: '', // Not provided by Google
        dateOfBirth: null, // Not provided by Google
        isEnableNotification: true,
        address: [],
        isDeleted: false,
      );
    } catch (e) {
      AppUtils.log('Error mapping Firebase user to UserModel: $e');
      return null;
    }
  }
}
