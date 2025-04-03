import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/coupon_controller.dart';
import 'package:intl/intl.dart';

class CouponDetailView extends GetView<CouponController> {
  const CouponDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments['id'] as String;

    // Fetch coupon details when the view is built
    controller.fetchCouponDetail(id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Mã Giảm Giá'),
        backgroundColor: const Color(0xFF2B7A78),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2B7A78),
            ),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchCouponDetail(id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B7A78),
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final coupon = controller.selectedCoupon.value;
        if (coupon == null) {
          return const Center(
            child: Text(
              'Không tìm thấy thông tin mã giảm giá',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // Format dates for display
        final DateTime endDate = DateTime.parse(coupon.endDate);
        final createDate = DateTime.parse(coupon.createdAt);
        final formattedEndDate = DateFormat('dd/MM/yyyy').format(endDate);
        final formattedCreateDate = DateFormat('dd/MM/yyyy').format(createDate);

        Color voucherColor = coupon.discountType == 'fixed'
            ? const Color(0xFFFF6B6B)
            : const Color(0xFF5E60CE);

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coupon Card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: voucherColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                coupon.discountType == 'fixed'
                                    ? '${NumberFormat('#,###').format(coupon.amount)}đ'
                                    : '${coupon.amount}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'GIẢM GIÁ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              coupon.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF17252A),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Mã Coupon:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        coupon.code,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2B7A78),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Clipboard.setData(
                                            ClipboardData(text: coupon.code),
                                          );
                                          Get.snackbar(
                                            'Thành công',
                                            'Đã sao chép mã giảm giá',
                                            backgroundColor: Colors.green[100],
                                            colorText: Colors.green[800],
                                            snackPosition: SnackPosition.TOP,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.copy,
                                          color: Color(0xFF2B7A78),
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Coupon Details
                const Text(
                  'Thông tin chi tiết',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17252A),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailItem(
                    'Loại giảm giá',
                    coupon.discountType == 'fixed'
                        ? 'Giảm số tiền cố định'
                        : 'Giảm theo phần trăm'),
                _buildDetailItem(
                    'Mức giảm',
                    coupon.discountType == 'fixed'
                        ? '${NumberFormat('#,###').format(coupon.amount)}đ'
                        : '${coupon.amount}%'),
                _buildDetailItem('Ngày tạo', formattedCreateDate),
                _buildDetailItem('Ngày hết hạn', formattedEndDate),
                if (coupon.minTotal != null)
                  _buildDetailItem('Giá trị đơn hàng tối thiểu',
                      '${NumberFormat('#,###').format(coupon.minTotal)}đ'),
                if (coupon.maxTotal != null)
                  _buildDetailItem('Giá trị giảm tối đa',
                      '${NumberFormat('#,###').format(coupon.maxTotal)}đ'),
                if (coupon.quantityLimit != null)
                  _buildDetailItem('Số lượng mã', '${coupon.quantityLimit}'),
                if (coupon.limitPerUser != null)
                  _buildDetailItem(
                      'Số lần sử dụng tối đa/người', '${coupon.limitPerUser}'),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: coupon.code));
                      Get.snackbar(
                        'Thành công',
                        'Đã sao chép mã giảm giá',
                        backgroundColor: Colors.green[100],
                        colorText: Colors.green[800],
                        snackPosition: SnackPosition.TOP,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B7A78),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Sao chép mã',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF17252A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
