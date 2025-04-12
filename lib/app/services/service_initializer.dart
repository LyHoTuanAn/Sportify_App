import 'package:get/get.dart';
import 'favorite_service.dart';

/// Lớp này quản lý việc khởi tạo tất cả các service
class ServiceInitializer {
  /// Khởi tạo tất cả các service cần thiết cho ứng dụng
  static Future<void> init() async {
    // Khởi tạo FavoriteService là singleton
    await Get.putAsync<FavoriteService>(() => FavoriteService().init(),
        permanent: true);

    // Thêm các service khác nếu cần
  }
}
