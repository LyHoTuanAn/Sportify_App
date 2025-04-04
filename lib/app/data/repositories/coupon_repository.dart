part of 'repositories.dart';


class CouponRepository {
  Future<List<Coupon>> getCoupons() async {
    try {
      return await ApiProvider.getCoupons();
    } catch (e) {
      app_utils.log('Error in CouponRepository.getCoupons: $e');
      return [];
    }
  }

  Future<Coupon?> getCouponDetail(String id) async {
    try {
      return await ApiProvider.getCouponDetail(id);
    } catch (e) {
      app_utils.log('Error in CouponRepository.getCouponDetail: $e');
      return null;
    }
  }
}
