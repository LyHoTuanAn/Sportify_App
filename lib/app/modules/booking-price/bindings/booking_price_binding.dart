import 'package:get/get.dart';

import '../controllers/booking_price_controller.dart';

class BookingPriceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingPriceController>(
      () => BookingPriceController(),
    );
  }
}
