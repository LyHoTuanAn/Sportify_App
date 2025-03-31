import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/styles/style.dart';
import '../../../data/services/firebase_analytics_service.dart';

import '../../../widgets/widgets.dart';
import '../controllers/profile_controller.dart';
import '../widgets/widgets.dart';
import '../../../widgets/loading.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                EditProfileBottom.showBottom();
              } else if (value == 'password') {
                controller.navigateToChangePassword();
              } else if (value == 'logout') {
                controller.logout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                height: 48,
                child: Center(
                  child: Text(
                    'Chỉnh sửa thông tin',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const PopupMenuDivider(height: 1),
              const PopupMenuItem<String>(
                value: 'password',
                height: 48,
                child: Center(
                  child: Text(
                    'Thay đổi mật khẩu',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem<String>(
                value: 'logout',
                height: 48,
                child: Center(
                  child: Text(
                    'Đăng xuất',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem<String>(
                enabled: false,
                height: 48,
                child: Center(
                  child: Text(
                    'Version: 2.6.6',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Loading(),
          );
        }

        return Column(
          children: [
            // Profile section
            Container(
              color: const Color(0xFF2B7A78),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Obx(() {
                        if (controller.avatarLoading.value) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF3AAFA9),
                              ),
                            ),
                          );
                        } else {
                          return Hero(
                            tag: 'profileAvatar',
                            child: controller.user.value?.avatar != null
                                ? CachedNetworkImage(
                                    imageUrl: controller.user.value!.avatar!,
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.white,
                                      backgroundImage: imageProvider,
                                    ),
                                    placeholder: (context, url) =>
                                        const CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.white,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF3AAFA9),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                    ),
                                  )
                                : const CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Color(0xFF3AAFA9),
                                    ),
                                  ),
                          );
                        }
                      }),
                      Obx(() => GestureDetector(
                            onTap: controller.avatarLoading.value
                                ? null
                                : controller.changeAvatar,
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.black,
                              child: Icon(
                                Icons.camera_alt,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Name
                  Text(
                    '${controller.user.value?.firstName ?? ''} ${controller.user.value?.lastName ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Phone number section
                  if (controller.user.value?.phone == null ||
                      controller.user.value?.phone?.isEmpty == true)
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 65),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3AAFA9).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.phone, color: Colors.white, size: 18),
                              SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  'Bạn chưa cung cấp số điện thoại',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 180,
                          margin: const EdgeInsets.only(top: 10),
                          child: ElevatedButton.icon(
                            onPressed: () => EditProfileBottom.showBottom(),
                            icon: const Icon(Icons.add,
                                color: Color(0xFF2B7A78), size: 16),
                            label: const Text(
                              'Thêm số điện thoại',
                              style: TextStyle(
                                  color: Color(0xFF2B7A78), fontSize: 11),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 125),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3AAFA9).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone,
                              color: Colors.white, size: 18),
                          Expanded(
                            child: Text(
                              controller.user.value!.phone!,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Tab bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changeTab(0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Lịch đã đặt',
                              style: TextStyle(
                                color: controller.selectedTab.value == 0
                                    ? const Color(0xFF2B7A78)
                                    : Colors.grey,
                                fontWeight: controller.selectedTab.value == 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          Container(
                            height: 3,
                            color: controller.selectedTab.value == 0
                                ? const Color(0xFF2B7A78)
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changeTab(1),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Thông tin thành viên',
                              style: TextStyle(
                                color: controller.selectedTab.value == 1
                                    ? const Color(0xFF2B7A78)
                                    : Colors.grey,
                                fontWeight: controller.selectedTab.value == 1
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          Container(
                            height: 3,
                            color: controller.selectedTab.value == 1
                                ? const Color(0xFF2B7A78)
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content based on selected tab
            Expanded(
              child: IndexedStack(
                index: controller.selectedTab.value,
                children: [
                  // Tab 1 - Lịch đã đặt
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 60,
                          color: Color(0xFF3AAFA9),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Bạn chưa có lịch đặt nào',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: controller.navigateToBookingPage,
                          icon: const Text(
                            'Đặt lịch ngay',
                            style: TextStyle(color: Colors.white),
                          ),
                          label: const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 16),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B7A78),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab 2 - Thông tin thành viên
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin cá nhân',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B7A78),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoItem(
                          icon: Icons.person_outline,
                          label: 'Họ và tên',
                          value:
                              '${controller.user.value?.firstName ?? ''} ${controller.user.value?.lastName ?? ''}',
                        ),
                        _buildInfoItem(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: controller.user.value?.email ?? '',
                        ),
                        _buildInfoItem(
                          icon: Icons.phone_outlined,
                          label: 'Số điện thoại',
                          value: controller.user.value?.phone?.isEmpty ?? true
                              ? 'Chưa cập nhật'
                              : controller.user.value?.phone ?? '',
                        ),
                        _buildInfoItem(
                          icon: Icons.calendar_today_outlined,
                          label: 'Ngày sinh',
                          value: controller.user.value?.dateOfBirth != null
                              ? '${controller.user.value?.dateOfBirth?.day}/${controller.user.value?.dateOfBirth?.month}/${controller.user.value?.dateOfBirth?.year}'
                              : 'Chưa cập nhật',
                        ),
                        _buildGenderInfoItem(
                          controller.user.value?.gender ?? 'Chưa cập nhật',
                        ),
                        if (controller.user.value?.address?.isNotEmpty ?? false)
                          _buildInfoItem(
                            icon: Icons.location_on_outlined,
                            label: 'Địa chỉ',
                            value: controller
                                    .user.value?.address?.first.fullAddress ??
                                'Chưa cập nhật',
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2B7A78)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget mới để hiển thị giới tính theo cách hấp dẫn hơn
  Widget _buildGenderInfoItem(String gender) {
    IconData genderIcon = Icons.person;
    Color genderColor = const Color(0xFF2B7A78);

    if (gender.toLowerCase() == 'nam') {
      genderIcon = Icons.male;
      genderColor = Colors.blue;
    } else if (gender.toLowerCase() == 'nữ') {
      genderIcon = Icons.female;
      genderColor = Colors.pink;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.people_outline, size: 20, color: const Color(0xFF2B7A78)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giới tính',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: genderColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: genderColor.withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(genderIcon, size: 18, color: genderColor),
                      const SizedBox(width: 8),
                      Text(
                        gender,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: genderColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getCachedAvatarImage(String? url) {
    if (url == null || url.isEmpty)
      return const AssetImage('assets/default_avatar.png');

    // Cache ảnh để sử dụng lại
    final imageProvider = NetworkImage(url);

    // Precache ảnh ngay lập tức để ngăn loading lại
    precacheImage(imageProvider, Get.context!);

    return imageProvider;
  }
}
