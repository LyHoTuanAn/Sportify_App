import 'package:get/get.dart';

import 'delete_account_controller.dart';

class DeleteAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DeleteAccountController());
  }
}
