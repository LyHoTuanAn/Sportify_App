// Remove this line
// import 'dart:typed_data';

// Keep this line if needed
import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/utilities/utilities.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../data/services/firebase_analytics_service.dart';
import '../../../routes/app_pages.dart';
import '../../../data/providers/providers.dart';
import '../../../data/http_client/http_client.dart';
import '../widgets/widgets.dart';

class ProfileController extends GetxController with ScrollMixin {
  final UserRepository _userRepository = Get.find<UserRepository>();

  final user = Rxn<UserModel>();
  final hasBookings = false.obs;
  final isLoading = true.obs;
  final avatarLoading = false.obs;
  final selectedTab = 0.obs;
  int _avatarTimestamp = DateTime.now().millisecondsSinceEpoch;

  // Form controllers for profile update
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final genderValue = "Nam".obs;

  // Thêm biến để cache URL ảnh đã tải
  final cachedAvatarUrl = ''.obs;
  bool isChangingAvatar = false;

  @override
  void onInit() {
    super.onInit();
    getUserDetail();
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
    if (isChangingAvatar) return; // Ngăn chặn nhiều lần gọi liên tiếp

    AppUtils.pickerImage(onTap: (bytes) async {
      try {
        isChangingAvatar = true;
        avatarLoading.value = true;

        // Hiển thị trước ảnh ngay lập tức
        final oldAvatarUrl = user.value?.avatar;
        final oldImage = user.value;

        // Tạo một URL tạm để hiển thị ảnh đã chọn ngay lập tức
        final tempUrl = await _createLocalAvatarFromBytes(bytes);
        if (tempUrl != null) {
          // Cập nhật UI với ảnh tạm ngay lập tức
          user.update((val) {
            if (val != null) {
              val.avatar = tempUrl;
            }
          });
        }

        // Sau đó upload ảnh với độ ưu tiên cao
        _userRepository.uploadMedia(bytes, 1).then((mediaResponse) {
          if (mediaResponse != null && mediaResponse['id'] != null) {
            final avatarId = mediaResponse['id'];

            // Lấy URL ảnh từ phản hồi nếu có
            final newAvatarUrl =
                mediaResponse['sizes']?['default'] ?? mediaResponse['url'];

            // Log URL để debug
            AppUtils.log('New avatar URL from media response: $newAvatarUrl');

            // Nếu có URL mới từ upload, cập nhật nó ngay
            if (newAvatarUrl != null) {
              user.update((val) {
                if (val != null) {
                  val.avatar = newAvatarUrl;
                }
              });

              // Force refresh avatar cache
              refreshAvatar();
              cachedAvatarUrl.value = newAvatarUrl;
            }

            // Sau đó cập nhật avatar_id lên server
            final updateData = {
              'first_name': user.value?.firstName ?? '',
              'last_name': user.value?.lastName ?? '',
              'email': user.value?.email ?? '',
              'avatar_id': avatarId
            };

            // Cập nhật thông tin user ở background
            _userRepository.updateUserMe(updateData).then((updatedUser) {
              // Cập nhật thông tin user nếu cần
              if (updatedUser.avatar != null &&
                  updatedUser.avatar != user.value?.avatar) {
                AppUtils.log(
                    'Updated avatar URL from server: ${updatedUser.avatar}');
                user.update((val) {
                  if (val != null) {
                    val.avatar = updatedUser.avatar;
                  }
                });
                // Force refresh UI
                cachedAvatarUrl.value = updatedUser.avatar ?? '';
                refreshAvatar();
              }
              AppUtils.log('Cập nhật avatar_id thành công');

              // Thông báo thành công
              AppUtils.toast('Cập nhật ảnh đại diện thành công');
            }).catchError((e) {
              AppUtils.log('Lỗi khi cập nhật avatar_id: $e');
              // Không hiển thị lỗi cho người dùng vì ảnh đã hiển thị
            });
          } else {
            // Upload thất bại, quay lại ảnh cũ
            user.update((val) {
              if (val != null) {
                val.avatar = oldAvatarUrl;
              }
            });
            AppUtils.toast('Không thể tải lên ảnh đại diện');
          }
        }).onError((error, stackTrace) {
          // Nếu upload lỗi, quay lại ảnh cũ
          AppUtils.log('Avatar upload error: $error');
          user.update((val) {
            if (val != null) {
              val.avatar = oldAvatarUrl;
            }
          });
          AppUtils.toast('Không thể tải lên ảnh đại diện');
        });
      } catch (e) {
        AppUtils.toast('Lỗi khi cập nhật ảnh đại diện: ${e.toString()}');
      } finally {
        avatarLoading.value = false;
        isChangingAvatar = false;
      }
    });
  }

  // Phương thức tạo URL tạm thời từ bytes ảnh
  Future<String?> _createLocalAvatarFromBytes(Uint8List bytes) async {
    try {
      // Nếu đã cài đặt thư viện path_provider, có thể lưu ảnh tạm vào storage
      // Ở đây chúng ta return null vì chưa thực sự cần thiết
      return null;
    } catch (e) {
      AppUtils.log('Lỗi khi tạo URL tạm: $e');
      return null;
    }
  }

  // Phương thức được cập nhật để sử dụng repository
  Future<ProfileController> getUserDetail({bool isLogin = false}) async {
    try {
      isLoading.value = true;

      // Sử dụng repository thay vì trực tiếp ApiProvider
      user.value = await _userRepository.getUserMe();
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

  // Phương thức cập nhật profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;

      // Sử dụng repository thay vì trực tiếp ApiProvider
      final updatedUser = await _userRepository.updateUserMe(data);
      user.value = updatedUser;
      _updateFormControllers();

      AppUtils.toast('Cập nhật thông tin thành công');
    } catch (e) {
      if (e.toString().contains("Update successfully")) {
        getUserDetail();
        AppUtils.toast('Cập nhật thông tin thành công');
      } else {
        AppUtils.toast('Lỗi khi cập nhật thông tin: ${e.toString()}');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Phương thức cho avatar url với timestamp để tránh cache
  String getAvatarUrl() {
    if (user.value?.avatar == null || user.value!.avatar!.isEmpty) {
      return '';
    }

    // Always add a timestamp to force refresh
    String url = user.value!.avatar!;

    // Detailed log for debugging
    AppUtils.log('Original avatar URL: $url');

    // Check if URL is valid
    if (!isValidAvatarUrl(url)) {
      AppUtils.log('Invalid avatar URL detected: $url');
      return '';
    }

    // Check if URL already has query parameters
    String finalUrl;
    if (url.contains('?')) {
      finalUrl = '$url&t=$_avatarTimestamp';
    } else {
      finalUrl = '$url?t=$_avatarTimestamp';
    }

    AppUtils.log('Final avatar URL with timestamp: $finalUrl');
    return finalUrl;
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
    // Xóa các preferences trước
    Preferences.clear();

    // Log sự kiện đăng xuất
    FirebaseAnalyticService.logEvent('User_Logout');

    // Điều hướng đến trang login, xóa tất cả các routes trước đó
    Get.offAllNamed(Routes.login);
  }

  void navigateToChangePassword() {
    FirebaseAnalyticService.logEvent('Profile_Change_Password');
    // Sử dụng widget bottom sheet thay vì điều hướng
    ChangePasswordWidget.showBottom();
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

  // Add this method to force refresh the avatar
  void refreshAvatar() {
    _avatarTimestamp = DateTime.now().millisecondsSinceEpoch;
    update(); // Force UI update
  }

  // Phương thức để tải ảnh trực tiếp như một phương thức thay thế
  Future<Image?> loadAvatarDirectly() async {
    if (user.value?.avatar == null || user.value!.avatar!.isEmpty) {
      return null;
    }

    final avatarUrl = getAvatarUrl();
    AppUtils.log('Directly loading avatar from: $avatarUrl');

    try {
      // Tạo một HttpClient mới
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(avatarUrl));
      final response = await request.close();

      if (response.statusCode == 200) {
        AppUtils.log('Avatar HTTP request successful');
        final bytes = await consolidateHttpClientResponseBytes(response);
        return Image.memory(
          bytes,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        );
      } else {
        AppUtils.log('Avatar HTTP request failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      AppUtils.log('Error directly loading avatar: $e');
      return null;
    }
  }
}
