// ignore_for_file: unused_local_variable, unnecessary_import, avoid_print

library providers;

import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http_parser/http_parser.dart';

import '../../core/utilities/utilities.dart';
import '../../core/utilities/app_utils.dart';
import '../../core/utilities/api_string.dart';
import '../../routes/app_pages.dart';
import '../http_client/http_client.dart';
import '../models/dashboard_model.dart';
import '../models/models.dart';

part 'yard_provider.dart';

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

  static Future<bool> sendPhoneOtp(String phone, String countryCode) async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.sendOtp,
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

  // Nâng cấp phương thức uploadMedia
  static Future<Map<String, dynamic>?> uploadMedia(
      Uint8List bytes, int folderId) async {
    try {
      // Nén ảnh trước khi upload
      final compressedBytes = await _compressImage(bytes);
      AppUtils.log(
          'Compressed image from ${bytes.length} to ${compressedBytes.length} bytes');

      final name = DateTime.now().millisecondsSinceEpoch;
      final contentType = MediaType('image', 'jpeg'); // JPEG thường nhỏ hơn PNG

      // Tạo FormData để upload file
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          compressedBytes,
          filename: '$name.jpg',
          contentType: contentType,
        ),
        'folder_id': '$folderId',
      });

      // Tối ưu config cho Dio
      final dioInstance = Dio();
      dioInstance.options.headers['Authorization'] =
          'Bearer ${Preferences.getString(StringUtils.token)}';
      dioInstance.options.headers['Content-Type'] = 'multipart/form-data';
      dioInstance.options.connectTimeout = const Duration(seconds: 10);
      dioInstance.options.receiveTimeout = const Duration(seconds: 10);
      dioInstance.options.sendTimeout = const Duration(seconds: 10);

      // Lấy base URL từ ApiClient
      final baseUrl = ApiClient.getBaseUrl().isNotEmpty
          ? ApiClient.getBaseUrl()
          : 'https://9259-2001-ee0-1b35-7e5e-65d5-9191-2fd3-c454.ngrok-free.app';

      // Loại bỏ dấu / ở cuối nếu có
      final normalizedBaseUrl = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;

      // Sử dụng đường dẫn API đầy đủ từ ApiUrl
      final apiUrl = '$normalizedBaseUrl${ApiUrl.mediaStore}';

      AppUtils.log('Using media upload URL: $apiUrl');

      // Cấu hình cache cho request
      final options = Options(
        headers: dioInstance.options.headers,
      );

      final dioResponse = await dioInstance.post(
        apiUrl,
        data: formData,
        options: options,
        onSendProgress: (sent, total) {
          // Chỉ log tiến trình cho debug, không log quá nhiều
          if (sent == total || sent % (total ~/ 10) == 0) {
            AppUtils.log(
                'Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      if (dioResponse.statusCode == 200 &&
          (dioResponse.data['status'] == true ||
              dioResponse.data['status'] == 1)) {
        return dioResponse.data['data'];
      } else {
        AppUtils.log('Upload failed: ${dioResponse.data}');
        return null;
      }
    } catch (e) {
      AppUtils.log('Lỗi khi upload media: $e');
      if (e is DioException) {
        AppUtils.log('DioError type: ${e.type}');
      }
      rethrow;
    }
  }

  // Thêm phương thức nén ảnh
  static Future<Uint8List> _compressImage(Uint8List bytes) async {
    try {
      // Cài đặt package flutter_image_compress
      // Phụ thuộc vào kích thước ảnh gốc, điều chỉnh thông số phù hợp
      const quality = 85; // Giảm chất lượng xuống 85%
      const minWidth = 800; // Giảm kích thước xuống tối đa 800px
      const minHeight = 600;

      // Sử dụng flutter_image_compress để nén ảnh
      // Nếu bạn đã có package flutter_image_compress, uncomment dòng dưới
      // final result = await FlutterImageCompress.compressWithList(
      //   bytes,
      //   minWidth: minWidth,
      //   minHeight: minHeight,
      //   quality: quality,
      //   format: CompressFormat.jpeg,
      // );
      // return result;

      // Nếu không có package, trả về bytes gốc
      return bytes;
    } catch (e) {
      AppUtils.log('Lỗi khi nén ảnh: $e');
      return bytes; // Trả về ảnh gốc nếu có lỗi
    }
  }

  // Authentication methods
  static Future<Map<String, dynamic>> register(
      String fullName, String phone, String email, String password) async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.register,
        method: ApiMethod.post,
        data: {
          "fullname": fullName,
          "phone": phone,
          "email": email,
          "password": password,
          "device_name": "mobile_app"
        },
      );
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.sendOtp,
        method: ApiMethod.post,
        data: {"phone": phone},
      );
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
      String phone, String otp, bool isRegister,
      {bool isPasswordReset = false}) async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.verifyOtp,
        method: ApiMethod.post,
        data: {
          "phone": phone,
          "otp": otp,
          "is_register": isRegister,
          "is_password_reset": isPasswordReset,
          "device_name": "mobile_app"
        },
      );

      if (res.statusCode == 200 && res.data['status'] == 1) {
        // Only attempt to save authentication info if this is a registration or login verification
        // not a password reset verification
        if (!isPasswordReset) {
          final userData = res.data['user'];
          final authToken = res.data['access_token'];

          if (userData != null && authToken != null) {
            // Save authentication info
            Preferences.setString(StringUtils.token, authToken.toString());
            Preferences.setString(
                StringUtils.currentId, userData['id'].toString());

            // Convert user data to match our UserModel structure
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

            return {'success': true, 'user': formattedData};
          }
        }

        // For password reset verification
        return {
          'success': true,
          'message': res.data['message'] ?? 'Verification successful',
          'phone': res.data['phone'] ?? phone
        };
      }

      return {
        'success': false,
        'message': res.data['message'] ?? 'Verification failed'
      };
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String phone) async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.forgotPassword,
        method: ApiMethod.post,
        data: {"phone": phone},
      );
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final deviceToken = await FirebaseMessaging.instance.getToken();
      final res = await ApiClient.connect(
        ApiUrl.login,
        method: ApiMethod.post,
        data: {
          "username": username,
          "password": password,
          "device_name": "mobile_app",
          "device_token": deviceToken,
          "device_type": Platform.operatingSystem
        },
      );

      if (res.statusCode == 200 && res.data['status'] == 1) {
        final userData = res.data['user'];
        final authToken = res.data['access_token'];

        if (userData != null && authToken != null) {
          // Save authentication info
          Preferences.setString(StringUtils.token, authToken.toString());
          Preferences.setString(
              StringUtils.currentId, userData['id'].toString());

          // Convert user data to match our UserModel structure
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

          return {'success': true, 'user': formattedData};
        }
      }

      return {
        'success': false,
        'message': res.data['message'] ?? 'Login failed'
      };
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    String? currentPassword,
    required String newPassword,
  }) async {
    try {
      // Prepare request data based on whether we have a current password
      final requestData = currentPassword != null
          ? {"current_password": currentPassword, "new_password": newPassword}
          : {"new_password": newPassword};

      final res = await ApiClient.connect(
        ApiUrl.changePassword,
        method: ApiMethod.post,
        data: requestData,
      );

      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await ApiClient.connect(
        ApiUrl.resetPassword,
        method: ApiMethod.post,
        data: {
          "phone": phone,
          "password": password,
          "password_confirmation": passwordConfirmation,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Coupon>> getCoupons() async {
    try {
      final res = await ApiClient.connect(ApiUrl.coupons);
      if (res.statusCode == 200) {
        final responseData = res.data;
        if (responseData['status'] == 'success' &&
            responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((item) => Coupon.fromMap(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      AppUtils.log('Error in ApiProvider.getCoupons: $e');
      return [];
    }
  }

  static Future<Coupon?> getCouponDetail(String id) async {
    try {
      final res = await ApiClient.connect(ApiUrl.couponDetail(id));
      if (res.statusCode == 200) {
        final responseData = res.data;
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return Coupon.fromMap(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      AppUtils.log('Error in ApiProvider.getCouponDetail: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> getFeaturedYards() async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.yardSearch,
        query: {"is_featured": "1"},
      );

      if (res.statusCode == 200) {
        return res.data;
      }
      return {"status": 0, "data": []};
    } catch (e) {
      AppUtils.log('Error fetching featured yards: $e');
      return {"status": 0, "data": []};
    }
  }

  // Yard search with location and filters
  static Future<Map<String, dynamic>> searchYards({
    double? userLat,
    double? userLng,
    String? orderBy,
    int? authorId,
  }) async {
    try {
      Map<String, dynamic> query = {};

      // Add location parameters if available
      if (userLat != null && userLng != null) {
        query["user_lat"] = userLat.toString();
        query["user_lng"] = userLng.toString();
      }

      // Add author_id filter if provided
      if (authorId != null) {
        query["author_id"] = authorId.toString();
      }

      // Add order parameter if specified
      if (orderBy != null && orderBy.isNotEmpty) {
        query["orderby"] = orderBy;
      }

      final res = await ApiClient.connect(
        ApiUrl.yardSearch,
        query: query,
      );

      if (res.statusCode == 200) {
        return res.data;
      }
      return {"status": 0, "data": []};
    } catch (e) {
      AppUtils.log('Error searching yards: $e');
      return {"status": 0, "data": []};
    }
  }

  // Get user's wishlist
  static Future<Map<String, dynamic>> getUserWishlist() async {
    try {
      final res = await ApiClient.connect(ApiUrl.userWishlist);

      if (res.statusCode == 200) {
        return res.data;
      }
      return {"status": 0, "data": []};
    } catch (e) {
      AppUtils.log('Error fetching user wishlist: $e');
      return {"status": 0, "data": []};
    }
  }

  // Toggle wishlist item (add/remove)
  static Future<Map<String, dynamic>> toggleWishlistItem(
      int objectId, String objectModel) async {
    try {
      final res = await ApiClient.connect(
        ApiUrl.toggleWishlist,
        method: ApiMethod.post,
        data: {"object_id": objectId, "object_model": objectModel},
      );

      if (res.statusCode == 200) {
        return res.data;
      }
      return {"status": 0, "message": "Failed to toggle wishlist item"};
    } catch (e) {
      AppUtils.log('Error toggling wishlist item: $e');
      return {"status": 0, "message": "Error: ${e.toString()}"};
    }
  }

  static Future<Map<String, dynamic>> getAvailabilityCalendar({
    required String date,
    required List<int> yardIds,
  }) async {
    try {
      final query = {
        "start_date": date,
        "yard_ids": yardIds.join(','),
      };

      final res = await ApiClient.connect(
        ApiUrl.availabilityCalendar,
        query: query,
      );

      if (res.statusCode == 200) {
        return res.data;
      }
      return {"status": "error", "data": []};
    } catch (e) {
      AppUtils.log('Error getting availability calendar: $e');
      return {"status": "error", "data": []};
    }
  }

  static Future<Map<String, dynamic>> addBookingToCart({
    required int serviceId,
    required String startDate,
    required int hour,
    required String startTime,
  }) async {
    try {
      final requestData = {
        "service_id": serviceId,
        "start_date": startDate,
        "hour": hour,
        "start_time": startTime
      };

      final res = await ApiClient.connect(
        ApiUrl.addToCart,
        method: ApiMethod.post,
        data: requestData,
      );

      if (res.statusCode == 200) {
        return res.data;
      }
      return {"status": "error", "message": "Failed to add booking to cart"};
    } catch (e) {
      AppUtils.log('Error adding booking to cart: $e');
      return {"status": "error", "message": e.toString()};
    }
  }

  // Apply coupon to booking
  static Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    required String bookingCode,
  }) async {
    try {
      final requestData = {
        "coupon_code": couponCode,
        "booking_code": bookingCode,
      };

      final res = await ApiClient.connect(
        ApiUrl.applyCoupon,
        method: ApiMethod.post,
        data: requestData,
      );

      if (res.statusCode == 200) {
        return res.data;
      }
      return {"status": "error", "message": "Failed to apply coupon"};
    } catch (e) {
      AppUtils.log('Error applying coupon: $e');
      return {"status": "error", "message": e.toString()};
    }
  }

  // Add checkout method
  static Future<Map<String, dynamic>> doCheckout({
    required String code,
    required String fullName,
    required String phone,
    required String email,
  }) async {
    try {
      final requestData = {
        "code": code,
        "full_name": fullName,
        "phone": phone,
        "email": email
      };

      print('Checkout request data: $requestData');

      final res = await ApiClient.connect(
        ApiUrl.doCheckout,
        method: ApiMethod.post,
        data: requestData,
      );

      print('Checkout response: ${res.data}');

      // Make sure the response contains the URL
      if (res.statusCode == 200) {
        if (res.data['url'] != null) {
          print('URL in response: ${res.data['url']}');
        } else {
          print('No URL found in response data: ${res.data}');
        }
      }

      return res.data;
    } catch (e) {
      print('Error during checkout: $e');
      return {"status": "error", "message": e.toString()};
    }
  }
}
