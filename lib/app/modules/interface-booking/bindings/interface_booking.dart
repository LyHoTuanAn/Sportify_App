import 'package:get/get.dart';

import '../controllers/interface_booking.dart';

class InterfaceBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InterfaceBookingController>(
      () => InterfaceBookingController(),
    );
  }
}
