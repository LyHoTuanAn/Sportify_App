part of repositories;

class CouponRepository {
  Future<List<Coupon>> getCoupons() async {
    try {
      return await ApiProvider.getCoupons();
    } catch (e) {
      AppUtils.log('Error in CouponRepository.getCoupons: $e');
      return [];
    }
  }

  Future<Coupon?> getCouponDetail(String id) async {
    try {
      return await ApiProvider.getCouponDetail(id);
    } catch (e) {
      AppUtils.log('Error in CouponRepository.getCouponDetail: $e');
      return null;
    }
  }
}
