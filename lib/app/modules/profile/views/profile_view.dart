// ignore_for_file: unused_element

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';

import '../../../core/styles/style.dart';
import '../../../core/utilities/theme_manager.dart';

import '../../../widgets/widgets.dart';
import '../../../widgets/theme_switcher.dart';
import '../controllers/profile_controller.dart';
import '../widgets/widgets.dart';

class ProfileView extends GetView<ProfileController> {
  // ignore: use_super_parameters
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B7A78),
        elevation: 0,
        toolbarHeight: 45,
        leading: IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Keep the flag display in the center
            LanguageSwitcher(
              showTitle: false,
              iconSize: 24,
              iconColor: Colors.white,
              usePopupMenu: true, // Use the popup menu version
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.grey[200],
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                padding: EdgeInsets.zero,
                height: 0,
                child: _buildModernMenuContent(context),
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
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    clipBehavior: Clip.none,
                    children: [
                      Obx(() {
                        if (controller.avatarLoading.value) {
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF3AAFA9),
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        } else {
                          final avatarUrl = controller.getAvatarUrl();
                          if (avatarUrl.isNotEmpty) {
                            debugPrint('Attempting to load avatar: $avatarUrl');
                            // Force the image to refresh using key based on timestamp
                            return CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: Image.network(
                                  avatarUrl,
                                  key: ValueKey(
                                      'avatar_${DateTime.now().millisecondsSinceEpoch}'),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  cacheWidth:
                                      300, // Increased cache size for better quality
                                  cacheHeight: 300,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      debugPrint('Avatar loaded successfully');
                                      return child;
                                    }
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                        color: const Color(0xFF3AAFA9),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint(
                                        'Avatar image error: $error, URL: $avatarUrl');
                                    debugPrint('Stack trace: $stackTrace');
                                    // Try to ping the URL to check connectivity
                                    _checkImageUrl(avatarUrl);
                                    return const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Color(0xFF3AAFA9),
                                    );
                                  },
                                ),
                              ),
                            );
                          } else {
                            return const CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xFF3AAFA9),
                              ),
                            );
                          }
                        }
                      }),
                      Positioned(
                        right: 0,
                        bottom: 5,
                        child: Obx(() => GestureDetector(
                              onTap: controller.avatarLoading.value
                                  ? null
                                  : controller.changeAvatar,
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Color(0xFF2B7A78),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    '${controller.user.value?.firstName ?? ''} ${controller.user.value?.lastName ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
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
                            // ignore: deprecated_member_use
                            color: const Color(0xFF3AAFA9).withAlpha(102),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                      margin: const EdgeInsets.symmetric(horizontal: 120),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: const Color(0xFF3AAFA9).withAlpha(102),
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
                                  color: Colors.white, fontSize: 11),
                              textAlign: TextAlign.center,
                              maxLines: 1, // limit to one line only
                              softWrap: false, // don't wrap text
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
                              context.tr('profile.bookings'),
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
                              context.tr('profile.member_info'),
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
                  // Tab 1 - Bookings
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
                        Text(
                          context.tr('profile.no_bookings'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: controller.navigateToBookingPage,
                          icon: Text(
                            context.tr('profile.book_now'),
                            style: const TextStyle(color: Colors.white),
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

                  // Tab 2 - Member Information
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('profile.personal_info'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B7A78),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoItem(
                          icon: Icons.person_outline,
                          label: context.tr('profile.full_name'),
                          value:
                              '${controller.user.value?.firstName ?? ''} ${controller.user.value?.lastName ?? ''}',
                        ),
                        _buildInfoItem(
                          icon: Icons.email_outlined,
                          label: context.tr('profile.email'),
                          value: controller.user.value?.email ?? '',
                        ),
                        _buildInfoItem(
                          icon: Icons.phone_outlined,
                          label: context.tr('profile.phone_number'),
                          value: controller.user.value?.phone?.isEmpty ?? true
                              ? context.tr('profile.not_updated')
                              : controller.user.value?.phone ?? '',
                        ),
                        _buildInfoItem(
                          icon: Icons.calendar_today_outlined,
                          label: context.tr('profile.date_of_birth'),
                          value: controller.user.value?.dateOfBirth != null
                              ? '${controller.user.value?.dateOfBirth?.day}/${controller.user.value?.dateOfBirth?.month}/${controller.user.value?.dateOfBirth?.year}'
                              : context.tr('profile.not_updated'),
                        ),
                        _buildGenderInfoItem(
                          controller.user.value?.gender ??
                              context.tr('profile.not_updated'),
                        ),
                        if (controller.user.value?.address.isNotEmpty ?? false)
                          _buildInfoItem(
                            icon: Icons.location_on_outlined,
                            label: context.tr('profile.address'),
                            value: controller
                                    .user.value?.address.first.fullAddress ??
                                context.tr('profile.not_updated'),
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

  // New widget to display gender in a more attractive way
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
          const Icon(Icons.people_outline, size: 20, color: Color(0xFF2B7A78)),
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
                    // ignore: deprecated_member_use
                    color: genderColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        // ignore: deprecated_member_use
                        color: genderColor.withAlpha(128),
                        width: 1),
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

  NetworkImage _getCachedAvatarImage(String url) {
    debugPrint('Creating network image for: $url');
    return NetworkImage(url);
  }

  void _checkImageUrl(String url) {
    debugPrint('Checking image URL availability: $url');
    HttpClient()
        .getUrl(Uri.parse(url))
        .then((HttpClientRequest request) => request.close())
        .then((HttpClientResponse response) {
      debugPrint('URL check result: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('Image URL returned invalid status: ${response.statusCode}');
      }
    }).catchError((error) {
      debugPrint('Error checking URL: $error');
    });
  }

  IconData _getThemeIcon() {
    try {
      return ThemeManager.isDarkMode() ? Icons.dark_mode : Icons.light_mode;
    } catch (e) {
      debugPrint('Error getting theme icon: $e');
      return Icons.settings_brightness; // Fallback icon
    }
  }

  Widget _buildModernMenuContent(BuildContext context) {
    return ModernMenu(
      title: '',
      items: [
        ModernMenuItem(
          title: context.tr('menu.edit_profile'),
          icon: Icons.edit_outlined,
          iconBackgroundColor: const Color(0xFF2B7A78),
          onTap: () {
            Navigator.of(context).pop();
            EditProfileBottom.showBottom();
          },
        ),
        ModernMenuItem(
          title: context.tr('menu.change_password'),
          icon: Icons.lock_outline,
          iconBackgroundColor: const Color(0xFF3AAFA9),
          onTap: () {
            Navigator.of(context).pop();
            controller.navigateToChangePassword();
          },
        ),
        ModernMenuItem(
          title: context.tr('menu.language'),
          icon: Icons.language,
          iconBackgroundColor: const Color(0xFF2B7A78),
          onTap: () {
            Navigator.of(context).pop();
            LanguageSwitcher.showLanguageDialogStatic(context);
          },
        ),
        ModernMenuItem(
          title: context.tr('menu.theme'),
          icon: _getThemeIcon(),
          iconBackgroundColor: const Color(0xFF2B7A78),
          onTap: () {
            Navigator.of(context).pop();
            ThemeSwitcher.showThemeDialogStatic(context);
          },
        ),
        ModernMenuItem(
          title: context.tr('menu.logout'),
          icon: Icons.logout_outlined,
          iconBackgroundColor: Colors.redAccent,
          onTap: () {
            Navigator.of(context).pop();
            controller.logout();
          },
        ),
        ModernMenuItem(
          title: context.tr('menu.version', namedArgs: {'version': '2.6.6'}),
          icon: Icons.info_outline,
          iconBackgroundColor: Colors.grey,
          isVersionInfo: true,
        ),
      ],
    );
  }
}
