import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarUtil {
  static void showSuccess(String message, {Duration? duration}) {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Thành công',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF2B7A78),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: duration ?? const Duration(seconds: 3),
      icon: const Icon(
        Icons.check_circle,
        color: Colors.white,
      ),
    );
  }

  static void showError(String message, {Duration? duration}) {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Lỗi',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: duration ?? const Duration(seconds: 3),
      icon: const Icon(
        Icons.error,
        color: Colors.white,
      ),
    );
  }

  static void showInfo(String message, {Duration? duration}) {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Thông báo',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: duration ?? const Duration(seconds: 3),
      icon: const Icon(
        Icons.info,
        color: Colors.white,
      ),
    );
  }

  static void showWarning(String message, {Duration? duration}) {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Cảnh báo',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: duration ?? const Duration(seconds: 3),
      icon: const Icon(
        Icons.warning,
        color: Colors.white,
      ),
    );
  }

  static void showConfirmation(
    String message, {
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String confirmText = 'Xác nhận',
    String cancelText = 'Huỷ',
  }) {
    Get.closeAllSnackbars();
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              if (onCancel != null) {
                onCancel();
              }
            },
            child: Text(
              cancelText,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B7A78),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
