import 'dart:typed_data';
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
        // final oldImage = user.value; // Not used

        // Tạo một URL tạm để hiển thị ảnh đã chọn ngay lập tức (Optional: can be complex)
        // final tempUrl = await _createLocalAvatarFromBytes(bytes);
        // if (tempUrl != null) {
        //   user.update((val) {
        //     if (val != null) {
        //       val.avatar = tempUrl;
        //     }
        //   });
        // }

        // Sau đó upload ảnh với độ ưu tiên cao
        final mediaResponse = await _userRepository.uploadMedia(bytes, 1);

        if (mediaResponse != null && mediaResponse['id'] != null) {
          final avatarId = mediaResponse['id'];
          final newAvatarUrl = mediaResponse['sizes']?['default'] ?? mediaResponse['url'];
          AppUtils.log('New avatar URL from media response: $newAvatarUrl');

          // Cập nhật UI với ảnh mới ngay
          if (newAvatarUrl != null) {
            user.update((val) {
              if (val != null) {
                val.avatar = newAvatarUrl;
              }
            });
            refreshAvatar(); // Force refresh with timestamp
            cachedAvatarUrl.value = newAvatarUrl; // Update cache variable if used elsewhere
          }

          // Cập nhật avatar_id lên server ở background
          final updateData = {
            // Use existing user data for other fields during avatar update
            'first_name': user.value?.firstName ?? '',
            'last_name': user.value?.lastName ?? '',
            'email': user.value?.email ?? '',
            // Convert phone *here as well* if it's part of the update
            // 'phone': _convertToE164(user.value?.phone ?? ''), // Example if phone is needed
            'avatar_id': avatarId
          };

          _userRepository.updateUserMe(updateData).then((updatedUser) {
            // Update user model if server returns more up-to-date info
            if (updatedUser.avatar != null && updatedUser.avatar != user.value?.avatar) {
              AppUtils.log('Updated avatar URL from server: ${updatedUser.avatar}');
              user.update((val) {
                if (val != null) {
                  val.avatar = updatedUser.avatar;
                }
              });
              cachedAvatarUrl.value = updatedUser.avatar ?? '';
              refreshAvatar();
            }
            // Update other fields from updatedUser if necessary
            // user.value = updatedUser; // Potentially replace the whole user object
            // _updateFormControllers(); // Refresh form fields if user object was replaced

            AppUtils.log('Cập nhật avatar_id thành công');
            AppUtils.toast('Cập nhật ảnh đại diện thành công'); // Move toast here?
          }).catchError((e) {
            AppUtils.log('Lỗi khi cập nhật avatar_id: $e');
            // Optionally revert avatar on screen if backend update fails?
            // user.update((val) => val?.avatar = oldAvatarUrl);
            AppUtils.toast('Lỗi khi cập nhật thông tin ảnh đại diện.');
          });
        } else {
          // Upload failed, revert UI change
          user.update((val) {
            if (val != null) {
              val.avatar = oldAvatarUrl;
            }
          });
          AppUtils.toast('Không thể tải lên ảnh đại diện');
        }
      } catch (e) {
        AppUtils.log('Avatar change error: $e');
        AppUtils.toast('Lỗi khi cập nhật ảnh đại diện: ${e.toString()}');
        // Revert UI change on error
        // final oldAvatarUrl = ... // Need to capture it before try block
        // user.update((val) => val?.avatar = oldAvatarUrl);
      } finally {
        avatarLoading.value = false;
        isChangingAvatar = false;
      }
    });
  }

  // Phương thức tạo URL tạm thời từ bytes ảnh (Optional - keep as is if not implemented)
  // Future<String?> _createLocalAvatarFromBytes(Uint8List bytes) async { ... }


  Future<ProfileController> getUserDetail({bool isLogin = false}) async {
    try {
      isLoading.value = true;
      user.value = await _userRepository.getUserMe();
      // hasBookings.value = false; // This seems static, maybe needs logic?
      _updateFormControllers(); // Update form fields with fetched data

      if (isLogin) {
        FirebaseAnalyticService.logEvent('Login');
      }
    } catch (e) {
      AppUtils.log('Error getting user detail: $e');
      // Decide error handling: show toast, clear prefs, navigate to login?
      // Preferences.clear(); // Be careful clearing prefs here on simple fetch error
      AppUtils.toast('Không thể tải thông tin người dùng: ${e.toString()}');
      // If critical failure (e.g., unauthorized), then clear prefs and logout
      // if (e is UnauthorizedException) { logout(); }
    } finally {
      isLoading.value = false;
    }
    return this;
  }

  // Helper function to convert local phone format (0...) to E.164 (+84...)
  String _convertToE164(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return '';
    }
    // Remove spaces just in case
    phoneNumber = phoneNumber.replaceAll(' ', '');

    if (phoneNumber.startsWith('0') && phoneNumber.length >= 9) { // Basic check for VN format
      // Remove leading '0' and prepend '+84'
      return '+84${phoneNumber.substring(1)}';
    } else if (phoneNumber.startsWith('+84') && phoneNumber.length >= 11) { // Already E.164
      return phoneNumber;
    }
    // Return original or empty if format is unexpected or invalid
    // You might want stricter validation here
    AppUtils.log('Phone number format not recognized for E.164 conversion: $phoneNumber');
    return phoneNumber; // Or return '' or throw an error if strict validation needed
  }

  // (Optional) Helper function to convert E.164 back to local format for display


  void _updateFormControllers() {
    if (user.value != null) {
      firstNameController.text = user.value!.firstName;
      lastNameController.text = user.value!.lastName;
      // Convert phone from E.164 (stored/fetched) to local format for display (Optional)
      // phoneController.text = _convertFromE164ForDisplay(user.value!.phone); // Use this line if you want '0...' in the TextField
      phoneController.text = user.value!.phone ?? ''; // Use this line if you want '+84...' in the TextField
      emailController.text = user.value!.email ?? '';
      selectedDate.value = user.value!.dateOfBirth;
      genderValue.value = user.value!.gender ?? 'Nam';
    } else {
      // Clear fields if user data is null
      firstNameController.clear();
      lastNameController.clear();
      phoneController.clear();
      emailController.clear();
      selectedDate.value = null;
      genderValue.value = 'Nam'; // Or a default value
    }
  }


  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;

      // --- *** FIX: Convert phone number before sending *** ---
      if (data.containsKey('phone')) {
        final originalPhone = data['phone'] as String?;
        if (originalPhone != null) {
          data['phone'] = _convertToE164(originalPhone);
          AppUtils.log('Converted phone for update: ${data['phone']}');
        } else {
          data['phone'] = ''; // Ensure it's an empty string if null
        }
      }
      // --- *** End Fix *** ---

      final updatedUser = await _userRepository.updateUserMe(data);
      user.value = updatedUser; // Update local user model with response
      _updateFormControllers(); // Update UI form fields to reflect successful update

      AppUtils.toast('Cập nhật thông tin thành công');

    } catch (e) {
      AppUtils.log('Error updating profile: ${e.toString()}');
      // Provide more specific feedback if possible
      if (e.toString().contains('Định dạng số điện thoại không hợp lệ')) {
        // This suggests the conversion might have failed or the input was bad
        AppUtils.toast('Lỗi: Định dạng số điện thoại không đúng. Vui lòng kiểm tra lại.');
      } else if (e.toString().contains("Update successfully")) {
        // This case seems odd (success message in error). Refetching might be safer.
        await getUserDetail(); // Refetch data from server
        AppUtils.toast('Cập nhật thông tin thành công.');
      } else {
        // Generic error
        AppUtils.toast('Lỗi khi cập nhật thông tin: ${e.toString()}');
      }
    } finally {
      isLoading.value = false;
    }
  }


  String getAvatarUrl() {
    if (user.value?.avatar == null || user.value!.avatar!.isEmpty) {
      return ''; // Return empty string for default avatar placeholder
    }

    String url = user.value!.avatar!;
    AppUtils.log('Original avatar URL: $url');

    if (!isValidAvatarUrl(url)) {
      AppUtils.log('Invalid avatar URL detected: $url. Returning empty.');
      return ''; // Return empty if URL format is wrong
    }

    // Always add a timestamp to try and bypass cache issues
    String finalUrl;
    try {
      Uri uri = Uri.parse(url);
      Map<String, String> queryParameters = Map.from(uri.queryParameters);
      queryParameters['t'] = _avatarTimestamp.toString(); // Add/update timestamp
      finalUrl = uri.replace(queryParameters: queryParameters).toString();
    } catch (e) {
      // If URL parsing fails, fallback to simple concatenation (less robust)
      AppUtils.log('URL parsing failed for $url: $e. Using simple concatenation.');
      if (url.contains('?')) {
        finalUrl = '$url&t=$_avatarTimestamp';
      } else {
        finalUrl = '$url?t=$_avatarTimestamp';
      }
    }

    AppUtils.log('Final avatar URL with timestamp: $finalUrl');
    return finalUrl;
  }


  void toggleNotify(bool newVal) async {
    bool originalValue = user.value?.isEnableNotification ?? !newVal;
    user.update((val) => val?.isEnableNotification = newVal);
    try {
      // Simulate API call - Replace with actual repository call
      // await _userRepository.updateNotificationSetting(newVal);
      await Future.delayed(const Duration(milliseconds: 500)); // Placeholder
      AppUtils.toast('Cập nhật thông báo thành công');
    } catch (e) {
      // Revert UI on failure
      user.update((val) => val?.isEnableNotification = originalValue);
      AppUtils.toast('Lỗi cập nhật thông báo: ${e.toString()}');
    }
  }

  void checkUpdateUser() async {
    // This method seems empty, what should it do?
    await 2.delay(); // Placeholder delay
  }

  updateAddress(int index, bool load) {
    // Ensure address list exists and index is valid
    if (user.value != null && user.value!.address.length > index) {
      user.update((val) {
        val?.address[index].loading = load;
      });
    } else {
      AppUtils.log('Attempted to update address loading state for invalid index: $index');
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void logout() {
    Preferences.clear();
    FirebaseAnalyticService.logEvent('User_Logout');
    Get.offAllNamed(Routes.login);
  }

  void navigateToChangePassword() {
    FirebaseAnalyticService.logEvent('Profile_Change_Password');
    ChangePasswordWidget.showBottom();
  }

  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      // locale: const Locale('vi', 'VN'), // Optional: Set locale if needed
    );

    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      // Note: This only updates the local state.
      // You need to call updateProfile later to save the DoB.
      // Example: In your save button's onPressed:
      // final data = { 'date_of_birth': selectedDate.value?.toIso8601String() };
      // controller.updateProfile(data);
    }
  }

  @override
  Future<void> onEndScroll() async {}

  @override
  Future<void> onTopScroll() async {}


  bool isValidAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    // Basic check for http/https scheme. More robust validation possible.
    return url.startsWith('http://') || url.startsWith('https://');
  }


  void precacheNetworkImage(String url) {
    if (!isValidAvatarUrl(url) || Get.context == null) return;
    try {
      final imageProvider = NetworkImage(url);
      precacheImage(imageProvider, Get.context!)
          .then((_) => AppUtils.log('Precached avatar image: $url'))
          .catchError((e, s) => AppUtils.log('Error precaching image $url: $e \n$s'));
    } catch (e) {
      AppUtils.log('Exception while trying to precache image $url: $e');
    }
  }


  void refreshAvatar() {
    _avatarTimestamp = DateTime.now().millisecondsSinceEpoch;
    update(); // Trigger a GetX update for widgets listening to the controller
  }

  // Load avatar directly method - keep as is, seems like a fallback/debug method
  Future<Image?> loadAvatarDirectly() async {
    // ... (Keep implementation)
    if (user.value?.avatar == null || user.value!.avatar!.isEmpty) {
      return null;
    }

    final avatarUrl = getAvatarUrl(); // Use the method that adds timestamp
    if (avatarUrl.isEmpty) return null; // Don't try if URL is invalid

    AppUtils.log('Directly loading avatar from: $avatarUrl');

    try {
      // Using Flutter's http client for simplicity here
      final client = HttpClient(); // Create a new client
      final request = await client.getUrl(Uri.parse(avatarUrl));
      // Optional: Add headers if needed (e.g., cache control)
      // request.headers.add('Cache-Control', 'no-cache');
      final response = await request.close();

      AppUtils.log('Direct load response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        client.close(); // Close the client
        return Image.memory(
          bytes,
          width: 80, // Or desired dimensions
          height: 80,
          fit: BoxFit.cover,
          // Optional: Add a key to force rebuild if bytes change
          // key: ValueKey(_avatarTimestamp),
        );
      } else {
        client.close(); // Close the client on error too
        AppUtils.log('Avatar HTTP request failed: ${response.statusCode} ${response.reasonPhrase}');
        return null; // Return null or a placeholder image
      }
    } catch (e) {
      AppUtils.log('Error directly loading avatar: $e');
      return null; // Return null or a placeholder image
    }
  }
}