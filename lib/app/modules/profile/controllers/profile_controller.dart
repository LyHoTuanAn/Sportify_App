import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';

import '../../../core/utilities/utilities.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../data/services/firebase_analytics_service.dart';
import '../../../routes/app_pages.dart';
import '../../../data/providers/providers.dart';
import '../../../data/http_client/http_client.dart';

class ProfileController extends GetxController with ScrollMixin {
  final user = Rxn<UserModel>();
  final hasBookings = false.obs;
  final isLoading = true.obs;
  final selectedTab = 0.obs;

  // Form controllers for profile update
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final genderValue = "Nam".obs;

  final avatarLoading = false.obs;
  int _avatarTimestamp = DateTime.now().millisecondsSinceEpoch;

  @override
  void onInit() {
    super.onInit();
    getUserDetail().then((_) {
      // Preload avatar image if exists
      if (user.value?.avatar != null && user.value!.avatar!.isNotEmpty) {
        precacheNetworkImage(user.value!.avatar!);
      }
    });
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  // Chuyển hướng đến trang đặt lịch
  void navigateToBookingPage() {
    // Thay 'booking' bằng route thực tế của bạn
    Get.toNamed('/booking');
  }

  void changeAvatar() {
    FirebaseAnalyticService.logEvent('Profile_Edit_Avatar');
    AppUtils.pickerImage(onTap: (bytes) async {
      try {
        avatarLoading.value = true;

        // Bước 1: Upload ảnh lên server
        final mediaResponse = await _uploadMedia(bytes);
        AppUtils.log('Media Response: $mediaResponse');

        if (mediaResponse != null && mediaResponse['id'] != null) {
          // Bước 2: Cập nhật avatar_id cho người dùng
          final avatarId = mediaResponse['id'];
          AppUtils.log('Avatar ID to update: $avatarId');

          // Chuẩn bị dữ liệu để cập nhật profile
          final updateData = {
            'first_name': user.value?.firstName ?? '',
            'last_name': user.value?.lastName ?? '',
            'email': user.value?.email ?? '',
            'avatar_id': avatarId
          };

          AppUtils.log('Sending update data to API: $updateData');

          // Gọi API cập nhật profile thông qua API riêng biệt
          try {
            final res = await ApiClient.connect(
              ApiUrl.updateUserMe,
              method: ApiMethod.post,
              data: updateData,
            );

            AppUtils.log('Profile update response: ${res.data}');

            if (res.statusCode == 200) {
              // Không gọi getUserDetail() để tránh load lại toàn bộ trang

              // Nếu API trả về URL ảnh mới trong phản hồi, sử dụng nó trực tiếp
              if (res.data['data'] != null &&
                  res.data['data']['avatar_url'] != null) {
                final newAvatarUrl = res.data['data']['avatar_url'];

                // Chỉ cập nhật thuộc tính avatar trong user model
                user.update((val) {
                  if (val != null) {
                    val.avatar = newAvatarUrl;
                  }
                });

                // Xóa cache ảnh cũ
                clearAvatarCache(newAvatarUrl);
              } else {
                // Nếu API không trả về URL ảnh mới, chỉ lấy thông tin avatar
                // mà không load toàn bộ thông tin người dùng
                try {
                  final userResponse = await ApiClient.connect(
                    ApiUrl.userMe,
                    method: ApiMethod.get,
                  );

                  if (userResponse.statusCode == 200 &&
                      userResponse.data['data'] != null &&
                      userResponse.data['data']['avatar_url'] != null) {
                    final newAvatarUrl =
                        userResponse.data['data']['avatar_url'];

                    // Chỉ cập nhật thuộc tính avatar trong user model
                    user.update((val) {
                      if (val != null) {
                        val.avatar = newAvatarUrl;
                      }
                    });

                    // Xóa cache ảnh cũ
                    clearAvatarCache(newAvatarUrl);
                  }
                } catch (e) {
                  AppUtils.log('Error fetching updated avatar: $e');
                }
              }

              AppUtils.toast('Cập nhật ảnh đại diện thành công');
            } else {
              AppUtils.toast('Không thể cập nhật ảnh đại diện');
            }
          } catch (apiError) {
            AppUtils.log('API Error: $apiError');
            AppUtils.toast('Lỗi khi cập nhật profile: $apiError');
          }
        } else {
          AppUtils.toast('Không thể lấy thông tin từ ảnh đã upload');
        }
      } catch (e) {
        AppUtils.toast('Lỗi khi cập nhật ảnh đại diện: ${e.toString()}');
      } finally {
        avatarLoading.value = false;
      }
    });
  }

  // Thêm phương thức này để xóa cache ảnh
  void clearAvatarCache(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      try {
        imageCache.clear();
        imageCache.clearLiveImages();

        // Thêm timestamp mới cho URL avatar
        _avatarTimestamp = DateTime.now().millisecondsSinceEpoch;

        AppUtils.log('Cleared avatar cache for URL: $imageUrl');
      } catch (e) {
        AppUtils.log('Error clearing image cache: $e');
      }
    }
  }

  // Phương thức để upload media với xử lý lỗi tốt hơn
  Future<Map<String, dynamic>?> _uploadMedia(Uint8List bytes) async {
    try {
      // Tạo FormData cho việc upload file
      final name = DateTime.now().millisecondsSinceEpoch;

      // Tạo MediaType đúng cách
      final contentType = MediaType('image', 'png');

      // Tạo form data sử dụng Dio trực tiếp với alias dio.
      final dioFormData = dio.FormData.fromMap({
        'file': dio.MultipartFile.fromBytes(
          bytes,
          filename: '$name.png',
          contentType: contentType,
        ),
        'folder_id': '1',
      });

      // In ra thông tin để debug
      AppUtils.log('Uploading image with size: ${bytes.length} bytes');

      final dioInstance = dio.Dio();
      dioInstance.options.headers['Authorization'] =
          'Bearer ${Preferences.getString(StringUtils.token)}';
      dioInstance.options.headers['Content-Type'] = 'multipart/form-data';

      final dioResponse = await dioInstance.post(
        'https://6325-171-250-162-200.ngrok-free.app/api/media/store',
        data: dioFormData,
        onSendProgress: (sent, total) {
          AppUtils.log(
              'Upload progress: ${(sent / total * 100).toStringAsFixed(2)}%');
        },
      );

      // Kiểm tra phản hồi
      AppUtils.log('Media upload response: ${dioResponse.data}');

      // Sửa điều kiện này để chấp nhận cả status: true và status: 1
      if (dioResponse.statusCode == 200 &&
          (dioResponse.data['status'] == true ||
              dioResponse.data['status'] == 1)) {
        return dioResponse.data['data'];
      } else {
        AppUtils.log('Upload failed: ${dioResponse.data}');
        return null;
      }
    } catch (e) {
      AppUtils.log('Lỗi chi tiết khi upload media: $e');
      if (e is dio.DioException) {
        AppUtils.log('DioError type: ${e.type}');
        AppUtils.log('DioError message: ${e.message}');
        AppUtils.log('DioError response: ${e.response?.data}');
      }
      rethrow;
    }
  }

  // Phương thức được cập nhật để chỉ sử dụng API
  Future<ProfileController> getUserDetail({bool isLogin = false}) async {
    try {
      isLoading.value = true;

      // Chỉ sử dụng API thực tế, không có dữ liệu giả
      user.value = await ApiProvider.getUserMe();
      hasBookings.value = false;

      // Cập nhật các controller với dữ liệu hiện tại
      _updateFormControllers();

      if (isLogin) {
        FirebaseAnalyticService.logEvent('Login');
      }
    } catch (e) {
      Preferences.clear();
      AppUtils.toast(e.toString());
    } finally {
      isLoading.value = false;
    }
    return this;
  }

  // Cập nhật các controller form với dữ liệu người dùng
  void _updateFormControllers() {
    if (user.value != null) {
      firstNameController.text = user.value!.firstName;
      lastNameController.text = user.value!.lastName;
      phoneController.text = user.value!.phone ?? '';
      emailController.text = user.value!.email ?? '';
      selectedDate.value = user.value!.dateOfBirth;
      genderValue.value = user.value!.gender ?? 'Nam';
    }
  }

  // Phương thức mới để cập nhật profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;

      // Gọi API cập nhật profile
      final updatedUser = await ApiProvider.updateUserMe(data);

      // Cập nhật user model
      user.value = updatedUser;

      // Cập nhật form controllers
      _updateFormControllers();

      // Thông báo thành công
    } catch (e) {
      // Kiểm tra nếu thông báo lỗi chứa "Update successfully", thì đây thực chất là thành công
      if (e.toString().contains("Update successfully")) {
        // Cập nhật lại thông tin người dùng từ API
        getUserDetail();
      } else {
        AppUtils.toast('Lỗi khi cập nhật thông tin: ${e.toString()}');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void toggleNotify(bool newVal) async {
    user.update((val) => val?.isEnableNotification = newVal);
    try {
      // Giả lập API call
      await Future.delayed(const Duration(milliseconds: 500));
      AppUtils.toast('Cập nhật thông báo thành công');
    } catch (e) {
      user.update((val) => val?.isEnableNotification = !newVal);
      AppUtils.toast(e.toString());
    }
  }

  void checkUpdateUser() async {
    await 2.delay();
  }

  updateAddress(int index, bool load) {
    user.update((val) {
      val?.address[index].loading = load;
    });
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void logout() {
    Preferences.clear();
    Get.offAllNamed('/login');
  }

  void navigateToChangePassword() {
    Get.toNamed('/change-password');
  }

  // Phương thức mới để chọn ngày sinh
  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  @override
  Future<void> onEndScroll() async {}

  @override
  Future<void> onTopScroll() async {}

  // Thêm phương thức kiểm tra URL avatar
  bool isValidAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    // Kiểm tra URL có đúng định dạng không
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      AppUtils.log('Invalid avatar URL: $url');
      return false;
    }

    return true;
  }

  // Thêm phương thức để lấy URL avatar với timestamp
  String getAvatarUrl() {
    if (user.value?.avatar == null || user.value!.avatar!.isEmpty) {
      return '';
    }
    return '${user.value!.avatar!}?t=$_avatarTimestamp';
  }

  // Thêm phương thức để preload ảnh
  void precacheNetworkImage(String url) {
    try {
      final imageProvider = NetworkImage(url);
      if (Get.context != null) {
        precacheImage(imageProvider, Get.context!);
        AppUtils.log('Precached avatar image: $url');
      }
    } catch (e) {
      AppUtils.log('Error precaching image: $e');
    }
  }
}
