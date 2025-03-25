import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../core/utilities/utilities.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../data/services/firebase_analytics_service.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/google_auth_service.dart';
import '../../../data/providers/providers.dart';

class ProfileController extends GetxController with ScrollMixin {
  final user = Rxn<UserModel>();
  final hasBookings = false.obs; // Biến kiểm tra xem user có lịch đặt hay không
  final isLoading = true.obs;
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getUserDetail();
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
        // Xử lý cập nhật avatar tại đây
        final updatedUser = await ApiProvider.uploadAvatar(bytes);
        user.value = updatedUser;
      } catch (e) {
        AppUtils.toast(e.toString());
      }
    });
  }

  Future<ProfileController> getUserDetail({bool isLogin = false}) async {
    try {
      isLoading.value = true;

      // Fetch real user data from the API
      final userId = Preferences.getString(StringUtils.currentId);
      if (userId != null && userId.isNotEmpty) {
        user.value = await ApiProvider.getDetail();

        // Check if user has bookings - this would be a separate API call
        // hasBookings.value = await BookingProvider.hasBookings();
      } else {
        // User is not logged in
        Preferences.clear();
        Get.offAllNamed(Routes.login);
        return this;
      }

      if (isLogin) {
        FirebaseAnalyticService.logEvent('Login');
      }
    } catch (e) {
      Preferences.clear();
      AppUtils.toast(e.toString());
      Get.offAllNamed(Routes.login);
    } finally {
      isLoading.value = false;
    }
    return this;
  }

  void toggleNotify(bool newVal) async {
    user.update((val) => val?.isEnableNotification = newVal);
    try {
      final success = await ApiProvider.toggleNotify(newVal);
      if (success) {
        AppUtils.toast('Cập nhật thông báo thành công');
      } else {
        throw Exception('Cập nhật thông báo thất bại');
      }
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
      if (val?.address != null && index < (val?.address?.length ?? 0)) {
        val?.address[index].loading = load;
      }
    });
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void logout() {
    GoogleAuthService.signOut();
    Preferences.clear();
    Get.offAllNamed('/login');
  }

  void navigateToChangePassword() {
    Get.toNamed('/change-password');
  }

  @override
  Future<void> onEndScroll() async {}

  @override
  Future<void> onTopScroll() async {}

  // Connect with Google account to update profile info
  void connectGoogleAccount() async {
    try {
      final userCredential = await GoogleAuthService.signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        final googleUser = userCredential.user!;

        // Update user information with Google data
        final userData = {
          'recipient': {
            'first_name': googleUser.displayName?.split(' ').first,
            'last_name': googleUser.displayName?.split(' ').length == 1
                ? ''
                : googleUser.displayName?.split(' ').sublist(1).join(' '),
            'email': googleUser.email,
          }
        };

        // If phone number is available, add it
        if (googleUser.phoneNumber != null) {
          userData['recipient']!['phone_number'] = googleUser.phoneNumber;
        }

        // Update user profile with Google data
        await ApiProvider.updateUser(userData);

        // Refresh user data
        await getUserDetail();

        Get.snackbar(
          'Thành công',
          'Đã cập nhật thông tin từ tài khoản Google',
          backgroundColor: const Color(0xFF2B7A78),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(20),
          borderRadius: 10,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể kết nối với tài khoản Google: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        borderRadius: 10,
      );
    }
  }
}
