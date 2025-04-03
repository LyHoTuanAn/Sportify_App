import 'package:get/get.dart';
import '../../../data/repositories/repositories.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Register the UserRepository
    Get.put<UserRepository>(UserRepository());

    // Register the ProfileController
    Get.put<ProfileController>(ProfileController());
  }
}
