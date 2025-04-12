import 'package:get/get.dart';
import '../../../data/models/coupon.dart';
import '../../../data/repositories/repositories.dart';

class CouponController extends GetxController {
  final RxList<Coupon> coupons = <Coupon>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<Coupon?> selectedCoupon = Rx<Coupon?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await Repo.coupon.getCoupons();
      coupons.value = result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Không thể tải danh sách mã giảm giá: $e';
      // ignore
      print('Error fetching coupons: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCouponDetail(String id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final coupon = await Repo.coupon.getCouponDetail(id);
      if (coupon != null) {
        selectedCoupon.value = coupon;
      } else {
        hasError.value = true;
        errorMessage.value = 'Không tìm thấy mã giảm giá';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Không thể tải chi tiết mã giảm giá: $e';
      // ignore
      print('Error fetching coupon detail: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
