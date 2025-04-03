import 'package:get/get.dart';
import 'dart:async';

class PaymentItem {
  final String? id;
  final String? title;
  final String? description;
  final String? imageUrl;
  final DateTime? createdAt;

  PaymentItem({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.createdAt,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

class PaymentController extends GetxController {
  // Timer để đếm ngược thời gian
  Timer? _timer;

  // Thời gian ban đầu: 15 phút = 15 * 60 = 900 giây
  final RxInt remainingTime = 300.obs;

  // Định dạng thời gian dạng mm:ss
  String get formattedTime {
    int minutes = remainingTime.value ~/ 60;
    int seconds = remainingTime.value % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        // Khi hết thời gian
        _timer?.cancel();
        // Có thể thêm xử lý khi hết thời gian, ví dụ: hiển thị thông báo, chuyển trang...
        Get.snackbar(
          'Hết thời gian',
          'Thời gian thanh toán đã hết, vui lòng thử lại',
          snackPosition: SnackPosition.TOP,
        );
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
