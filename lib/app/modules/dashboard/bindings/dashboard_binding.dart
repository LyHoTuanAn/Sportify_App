import 'package:get/get.dart';

import '../../home/bindings/home_binding.dart';
import '../../list/bindings/list_binding.dart';
import '../../outstanding/bindings/outstanding_binding.dart';
import '../../profile/bindings/profile_binding.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController(), permanent: true);
    
    // Đảm bảo các controllers cần thiết được inject
    HomeBinding().dependencies();
    ListBinding().dependencies();
    OutstandingBinding().dependencies();
    
    // Profile controller là permanent
    if (!Get.isRegistered<ProfileController>()) {
      ProfileBinding().dependencies();
    }
  }
}
