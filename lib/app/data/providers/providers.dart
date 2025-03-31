library providers;

import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/utilities/utilities.dart';
import '../../routes/app_pages.dart';
import '../http_client/http_client.dart';
import '../models/dashboard_model.dart';
import '../models/models.dart';

class ApiProvider {
  factory ApiProvider() => _instance;

  ApiProvider._internal();
  static final ApiProvider _instance = ApiProvider._internal();

  static Future<bool> sendEmailPassword(String email, String password) async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.login,
        method: ApiMethod.post,
        data: {"email": email, "password": password},
      );
      if (res.statusCode == 200) {
        AppUtils.log(res.data);
        final data = res.data['data'];
        AppUtils.log('token:${data['token']}');
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> sendOtp(String phone, String countryCode) async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.sendOpt,
        method: ApiMethod.post,
        data: {
          "recipient": {
            "phone_number": phone,
            "country_code": countryCode,
          }
        },
      );
      return res.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> verify(
    String phone,
    String countryCode,
    String otpCode,
  ) async {
    try {
      final deviceToken = await FirebaseMessaging.instance.getToken();
      final res = await ApiClient.connect(
        ApiUrl.login,
        method: ApiMethod.post,
        data: {
          "recipient": {
            "phone_number": phone,
            "country_code": countryCode,
            "otp_code": otpCode,
            "device_token": deviceToken,
            "device_type": Platform.operatingSystem
          }
        },
      );
      AppUtils.log(res.data);
      final data = res.data['data'];
      if (res.statusCode == 200 && res.data['success'] == true) {
        Preferences.setString(StringUtils.token, data['access_token']);
        Preferences.setString(StringUtils.refreshToken, data['refresh_token']);
        Preferences.setString(StringUtils.currentId, data['id']);
        Preferences.setString(StringUtils.versionApp, data['version_app']);
        Preferences.setString(StringUtils.phoneNumber, data['phone_number']);
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<String?> refreshToken() async {
    try {
      final deviceToken = await FirebaseMessaging.instance.getToken();
      final res = await ApiClient.connect(
        ApiUrl.refreshToken,
        method: ApiMethod.post,
        data: {
          "recipient": {
            "refresh_token": Preferences.getString(StringUtils.refreshToken),
            "device_token": deviceToken,
            "device_type": Platform.operatingSystem
          }
        },
      );
      final data = res.data['data'];
      if (res.statusCode == 200 && res.data['success'] == true) {
        Preferences.setString(StringUtils.token, data['access_token']);
        Preferences.setString(StringUtils.refreshToken, data['refresh_token']);
        return data['access_token'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> logout() async {
    FirebaseMessaging.instance.deleteToken();
    try {
      await ApiClient.connect(ApiUrl.logout, method: ApiMethod.delete);
      Preferences.clear();

      Get.offNamedUntil(Routes.login, (route) => false);
    } catch (e) {
      Preferences.clear();
      Get.offNamedUntil(Routes.login, (route) => false);
      rethrow;
    }
  }

  static Future<ReposeData> getNotifications(
      {Map<String, dynamic>? query}) async {
    try {
      final res = await ApiClient.connect(ApiUrl.notifications, query: query);
      final data = res.data['data'] as List;
      var item = data.map((e) => NotificationModel.fromMap(e)).toList();
      return ReposeData(
        data: item,
        meta: Meta.fromMap(res.data['metadata']),
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> markRead(String id) async {
    try {
      final res =
          await ApiClient.connect(ApiUrl.markRead(id), method: ApiMethod.patch);
      return res.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  static Future<NotificationModel> detailNotify(String id) async {
    try {
      final res = await ApiClient.connect(ApiUrl.detailNotify(id));
      return NotificationModel.fromMap(res.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> deleteNotify(String id) async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.detailNotify(id),
        method: ApiMethod.delete,
      );
      return res.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> numberUnread() async {
    try {
      final res = await ApiClient.connect(ApiUrl.numberUnread);
      return res.data['data']['unread_notifications'];
    } catch (e) {
      return 0;
    }
  }

  static Future<UserModel> getDetail({String? userId}) async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.detailRecipient(
          userId ?? Preferences.getString(StringUtils.currentId)!,
        ),
      );
      return UserModel.fromMap(res.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> updateUser(Map<String, dynamic> data) async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.detailRecipient(Preferences.getString(StringUtils.currentId)!),
        method: ApiMethod.patch,
        data: data,
      );
      if (res.data['success'] == false) {
        AppUtils.toast((res.data['errors'] as List).first['message']);
      }
      return res.statusCode == 200 && res.data['success'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserModel> uploadAvatar(Uint8List bytes) async {
    try {
      final name = DateTime.now().millisecondsSinceEpoch;
      final file = MultipartFile.fromBytes(bytes, filename: '$name.png');
      final res = await ApiClient.connect(
        ApiUrl.updateAvatar(Preferences.getString(StringUtils.currentId)!),
        method: ApiMethod.put,
        data: FormData.fromMap({'recipient[avatar]': file}),
      );
      AppUtils.log(res);
      return UserModel.fromMap(res.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> addAddress(String address, String apartment) async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.addresses,
        method: ApiMethod.post,
        data: {
          "address": {"full_address": address, "apartment": apartment}
        },
      );
      if (res.data['success'] != true) {
        throw (res.data['errors']?.first);
      }
      return res.data['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> toggleNotify(bool val) async {
    try {
      final uid = Preferences.getString(StringUtils.currentId)!;
      final res = await ApiClient.connect(
        val ? ApiUrl.enableNotify(uid) : ApiUrl.disableNotify(uid),
        method: ApiMethod.put,
      );
      return res.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  static Future<MessageModel> sentMessage(String chatId, data) async {
    try {
      final name = DateTime.now().millisecondsSinceEpoch;
      final formData = FormData.fromMap({
        'message[message_thread_id]': chatId,
        'message[message]': (data is String) ? data : '',
        if (data is Uint8List)
          'message[attachment]':
              MultipartFile.fromBytes(data, filename: '$name.png'),
      });
      final res = await ApiClient.connect(
        ApiUrl.sentMessage,
        method: ApiMethod.post,
        data: formData,
      );
      return MessageModel.fromMap(res.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> markReadAll(String id) async {
    try {
      await ApiClient.connect(
        ApiUrl.markReadAll(id),
        method: ApiMethod.patch,
      );
    } catch (e) {
      rethrow;
    }
  }

  //delete/restore user
  static Future<UserModel> deleteRecipient() async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.deleteRecipient(Preferences.getString(StringUtils.currentId)!),
        method: ApiMethod.delete,
      );
      return UserModel.fromMap(res.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserModel> restoreRecipient() async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.restoreRecipient,
        method: ApiMethod.post,
      );
      return UserModel.fromMap(res.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Dashboard> getDashboard() async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.getDashboard,
        method: ApiMethod.get,
      );
      return Dashboard.fromJson(res.data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Sign out first to ensure fresh login

      // Start the Google Sign-In process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in flow
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Get the token for our backend
        final idToken = await user.getIdToken();

        return {
          'token': idToken,
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName,
          'photoUrl': user.photoURL
        };
      }
      return null;
    } catch (e) {
      AppUtils.log('Error signing in with Google: $e');
      rethrow;
    }
  }

  static Future<UserModel> authenticateWithFirebaseToken(
      String token, String name, String photoUrl) async {
    try {
      final deviceToken = await FirebaseMessaging.instance.getToken();
      final Map<String, dynamic> requestData = {
        'id_token': token,
        'device_token': deviceToken,
        'device_type': Platform.operatingSystem,
        'name': name,
        'photo_url': photoUrl
      };

      final res = await ApiClient.connect(
        ApiUrl.firebaseAuth,
        method: ApiMethod.post,
        data: requestData,
      );

      if (res.statusCode == 200 && res.data['status'] == 'success') {
        final userData = res.data['user'];
        final authToken = res.data['token'];

        if (userData != null && authToken != null) {
          // Lưu thông tin xác thực
          Preferences.setString(StringUtils.token, authToken.toString());
          Preferences.setString(StringUtils.refreshToken, '');
          Preferences.setString(
              StringUtils.currentId, userData['id'].toString());

          // Tạo bản sao an toàn của dữ liệu người dùng và chuyển ID thành string
          final userModelData = Map<String, dynamic>.from(userData);
          userModelData['id'] = userModelData['id'].toString();

          return UserModel.fromMap(userModelData);
        }
        throw Exception('Thiếu dữ liệu người dùng hoặc token trong phản hồi');
      }
      throw Exception(res.data['message'] ?? 'Xác thực thất bại');
    } catch (e) {
      AppUtils.log('Lỗi xác thực Firebase: $e');
      rethrow;
    }
  }

  static Future<UserModel> getUserMe() async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.userMe,
        method: ApiMethod.get,
      );

      if (res.statusCode == 200 && res.data['status'] == 1) {
        final userData = res.data['data'];

        // Convert some fields to match our UserModel structure
        Map<String, dynamic> formattedData = {
          'id': userData['id'].toString(),
          'email': userData['email'],
          'first_name': userData['first_name'],
          'last_name': userData['last_name'],
          'avatar': userData['avatar_url'],
          'phone_number': userData['phone'],
          'date_of_birth': userData['birthday'],
          'gender': userData['gender'],
          'is_enable_notification': true
        };

        return UserModel.fromMap(formattedData);
      }
      throw Exception(
          res.data['message'] ?? 'Không thể lấy thông tin người dùng');
    } catch (e) {
      AppUtils.log('Lỗi khi lấy thông tin từ /api/auth/me: $e');
      rethrow;
    }
  }

  // Thêm phương thức mới để cập nhật profile
  static Future<UserModel> updateUserMe(Map<String, dynamic> data) async {
    try {
      AppUtils.log('Sending update data: $data'); // In dữ liệu trước khi gửi

      final res = await ApiClient.connect(
        ApiUrl.updateUserMe,
        method: ApiMethod.post,
        data: data,
      );

      AppUtils.log('Update user response: ${res.data}'); // In phản hồi API

      if (res.statusCode == 200 &&
          (res.data['status'] == 1 || res.data['status'] == true)) {
        // If the response contains user data, use it
        if (res.data['data'] != null) {
          final userData = res.data['data'];

          // In thông tin cụ thể về avatar_url để kiểm tra
          AppUtils.log('Avatar URL in response: ${userData['avatar_url']}');

          // Convert some fields to match our UserModel structure
          Map<String, dynamic> formattedData = {
            'id': userData['id'].toString(),
            'email': userData['email'],
            'first_name': userData['first_name'],
            'last_name': userData['last_name'],
            'avatar': userData['avatar_url'],
            'phone_number': userData['phone'],
            'date_of_birth': userData['birthday'],
            'gender': userData['gender'],
            'is_enable_notification': true
          };

          AppUtils.log('Formatted data for UserModel: $formattedData');
          return UserModel.fromMap(formattedData);
        }
        // If response only contains success message but no data, get fresh user data
        else {
          // Fetch the updated user data after successful update
          return getUserMe();
        }
      }

      // Handle error case
      throw Exception(
          res.data['message'] ?? 'Không thể cập nhật thông tin người dùng');
    } catch (e) {
      AppUtils.log('Lỗi khi cập nhật thông tin: $e');
      rethrow;
    }
  }
}
