import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/coupon.dart';

class CouponDetailBottomSheet extends StatelessWidget {
  final Coupon coupon;

  const CouponDetailBottomSheet({
    required this.coupon,
  }) : super(key: const Key('couponDetailBottomSheet'));


  @override
  Widget build(BuildContext context) {
    // Format dates for display
    final DateTime endDate = DateTime.parse(coupon.endDate);
    final createDate = DateTime.parse(coupon.createdAt);
    final formattedEndDate = DateFormat('dd/MM/yyyy').format(endDate);
    final formattedCreateDate = DateFormat('dd/MM/yyyy').format(createDate);

    Color voucherColor = coupon.discountType == 'fixed'
        ? const Color(0xFFFF6B6B)
        : const Color(0xFF5E60CE);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF808080).withValues(alpha: (0.1 * 255).toInt() /255),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Chi Tiết Mã Giảm Giá',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17252A),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
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
                            color: const Color(0xFF808080).withValues(alpha: (0.1 * 255).toInt() /255),
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
                                                ClipboardData(
                                                    text: coupon.code),
                                              );
                                              Get.snackbar(
                                                'Thành công',
                                                'Đã sao chép mã giảm giá',
                                                backgroundColor:
                                                    Colors.green[100],
                                                colorText: Colors.green[800],
                                                snackPosition:
                                                    SnackPosition.TOP,
                                                duration:
                                                    const Duration(seconds: 1),
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
                      _buildDetailItem(
                          'Số lượng mã', '${coupon.quantityLimit}'),
                    if (coupon.limitPerUser != null)
                      _buildDetailItem('Số lần sử dụng tối đa/người',
                          '${coupon.limitPerUser}'),

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
                            duration: const Duration(seconds: 1),
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
            ),
          ),
        ],
      ),
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
