import 'package:get/get.dart';

import '../controllers/successful_payment_controller.dart';

class SuccessfulPaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuccessfulPaymentController>(
          () => SuccessfulPaymentController(),
    );
  }
}
