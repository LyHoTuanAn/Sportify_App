import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/styles/style.dart';
import '../../../core/utilities/screen.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/app_button.dart';
import '../controllers/user_profile_controller.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.notifications_none, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) {
              // Handle menu item selection
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit',
                child: Text('Chỉnh sửa thông tin'),
              ),
              PopupMenuItem<String>(
                value: 'password',
                child: Text('Thay đổi mật khẩu'),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Đăng xuất'),
              ),
              PopupMenuItem<String>(
                value: 'version',
                child: Text('Version: 2.6.6'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile section
          Container(
            color: Color(0xFF2B7A78),
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF3AAFA9),
                      ),
                    ),
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.black,
                      child: Icon(
                        Icons.camera_alt,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Name
                Text(
                  'Bảo Long',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                // Phone number
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFF3AAFA9).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, color: Colors.white, size: 18),
                      SizedBox(width: 5),
                      Text(
                        'Bạn chưa cung cấp số điện thoại',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Add phone number button
                Container(
                  width: 180,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.add, color: Color(0xFF2B7A78), size: 16),
                    label: Text(
                      'Thêm số điện thoại',
                      style: TextStyle(color: Color(0xFF2B7A78), fontSize: 11),
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
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Lịch đã đặt',
                          style: TextStyle(
                            color: Color(0xFF2B7A78),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        height: 3,
                        color: Color(0xFF2B7A78),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Thông tin thành viên',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        height: 3,
                        color: Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Empty state
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 60,
                    color: Color(0xFF3AAFA9),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Bạn chưa có lịch đặt nào',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Text(
                      'Đặt lịch ngay',
                      style: TextStyle(color: Colors.white),
                    ),
                    label: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2B7A78),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom navigation
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Trang chủ', false),
                _buildNavItem(Icons.list, 'Danh sách', false),
                _buildNavItem(Icons.star, 'Nổi bật', false),
                _buildNavItem(Icons.person, 'Tài khoản', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? Color(0xFF2B7A78) : Colors.grey,
          size: 24,
        ),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Color(0xFF2B7A78) : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}