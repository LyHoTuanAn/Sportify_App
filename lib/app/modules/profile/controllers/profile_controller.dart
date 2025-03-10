import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../core/utilities/utilities.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../data/services/firebase_analytics_service.dart';
import '../../../routes/app_pages.dart';

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
      } catch (e) {
        AppUtils.toast(e.toString());
      }
    });
  }

  // Tạo dữ liệu giả lập
  UserModel _createMockUser() {
    return UserModel(
      firstName: "Anh",
      lastName: "Long",
      email: "anhlong@gmail.com",
      phone: "",
      avatar: "https://scontent.fsgn2-7.fna.fbcdn.net/v/t39.30808-6/472766639_2110637802724872_6038201334895326166_n.jpg?_nc_cat=100&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeFagjyU-w2R2E8ZeYJzYFk8Kjzn1AEt7LoqPOfUAS3sunYi7X71gaPmg1sATYwz1uMBOpvN1i3AcbYBD69ovHnQ&_nc_ohc=kBKfAbysbwAQ7kNvgFOD4jM&_nc_oc=Adhr15tYeT7BDttnVpNLM3m7WurYdUBMylTaFESGcLcAh84a6qrTZ91JRWbi2t5HqXY&_nc_zt=23&_nc_ht=scontent.fsgn2-7.fna&_nc_gid=AXSuayAPSV7uG1T2F5puh5B&oh=00_AYGFcX9a1PuHsKn9wQxN6a91QpYrSf4-s7BX_O3AaLDptw&oe=67D4AA98", // Using Facebook Graph API to get direct image URL
      dateOfBirth: DateTime(1990, 1, 1),
      gender: "Nam",
      isEnableNotification: true,
      address: [
        Address(
          id: "1",
          fullAddress: "123 Đường ABC, Quận 1, TP.HCM",
          city: "TP.HCM",
          state: "",
          apartment: "Apt 101",
          isDefault: true,
          loading: false,
        ),
      ],
      isDeleted: false,
    );
  }

  Future<ProfileController> getUserDetail({bool isLogin = false}) async {
    try {
      isLoading.value = true;
      
      // Giả lập delay call API
      await Future.delayed(const Duration(seconds: 2));
      
      // Sử dụng dữ liệu giả lập thay vì gọi API
      user.value = _createMockUser();
      hasBookings.value = false;

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

  @override
  Future<void> onEndScroll() async {}

  @override
  Future<void> onTopScroll() async {}
}
