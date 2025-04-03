import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/coupon_controller.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class CouponDetailView extends GetView<CouponController> {
  const CouponDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments['id'] as String;
    // Fetch coupon details when the view is built
    controller.fetchCouponDetail(id);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Chi Tiết Mã Giảm Giá'),
        backgroundColor: const Color(0xFF2B7A78),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
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
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchCouponDetail(id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B7A78),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
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

        List<Color> gradientColors = coupon.discountType == 'fixed'
            ? [Color(0xFFFF6B6B), Color(0xFFFF8E8E)]
            : [Color(0xFF5E60CE), Color(0xFF6A75E0)];

        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coupon Hero Card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: voucherColor.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Banner with gradient
                      Container(
                        height: 130,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Decorative elements
                            Positioned(
                              right: -25,
                              top: -25,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              left: -15,
                              bottom: -15,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      coupon.discountType == 'fixed'
                                          ? '${NumberFormat('#,###').format(coupon.amount)}đ'
                                          : '${coupon.amount}%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'GIẢM GIÁ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                _buildDecorativeElement(),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Coupon details
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              coupon.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF17252A),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Mã Coupon:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        coupon.code,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: voucherColor,
                                          letterSpacing: 1,
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
                                            margin: EdgeInsets.all(10),
                                            borderRadius: 10,
                                            icon: Icon(Icons.check_circle,
                                                color: Colors.green[800]),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.copy,
                                          color: voucherColor,
                                          size: 22,
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

                      // Dotted line separator
                      Container(
                        height: 2,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 150,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 5,
                              color: index % 2 == 0
                                  ? Colors.transparent
                                  : Colors.grey[300],
                            );
                          },
                        ),
                      ),

                      // Expiration info
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        child: Row(
                          children: [
                            Icon(Icons.access_time,
                                color: Colors.grey[700], size: 16),
                            SizedBox(width: 8),
                            Text(
                              "Hết hạn: $formattedEndDate",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Coupon Details Section
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFFDEF2F1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: Color(0xFF2B7A78),
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Thông tin chi tiết',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF17252A),
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 25, color: Colors.grey[200]),
                      _buildDetailItem(
                        'Loại giảm giá',
                        coupon.discountType == 'fixed'
                            ? 'Giảm số tiền cố định'
                            : 'Giảm theo phần trăm',
                        Icons.card_giftcard,
                      ),
                      _buildDetailItem(
                        'Mức giảm',
                        coupon.discountType == 'fixed'
                            ? '${NumberFormat('#,###').format(coupon.amount)}đ'
                            : '${coupon.amount}%',
                        Icons.money,
                      ),
                      _buildDetailItem(
                        'Ngày hết hạn',
                        formattedEndDate,
                        Icons.event_busy,
                      ),
                      if (coupon.minTotal != null)
                        _buildDetailItem(
                          'Giá trị đơn hàng tối thiểu',
                          '${NumberFormat('#,###').format(coupon.minTotal)}đ',
                          Icons.shopping_basket,
                        ),
                      if (coupon.maxTotal != null)
                        _buildDetailItem(
                          'Giá trị giảm tối đa',
                          '${NumberFormat('#,###').format(coupon.maxTotal)}đ',
                          Icons.trending_down,
                        ),
                      if (coupon.quantityLimit != null)
                        _buildDetailItem(
                          'Số lượng mã',
                          '${coupon.quantityLimit}',
                          Icons.confirmation_number,
                        ),
                      if (coupon.limitPerUser != null)
                        _buildDetailItem(
                          'Số lần sử dụng tối đa/người',
                          '${coupon.limitPerUser}',
                          Icons.person,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: coupon.code));
                      Get.snackbar(
                        'Thành công',
                        'Đã sao chép mã giảm giá',
                        backgroundColor: Colors.green[100],
                        colorText: Colors.green[800],
                        snackPosition: SnackPosition.TOP,
                        margin: EdgeInsets.all(10),
                        borderRadius: 10,
                        icon:
                            Icon(Icons.check_circle, color: Colors.green[800]),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: voucherColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      shadowColor: voucherColor.withOpacity(0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.content_copy, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Sao chép mã',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
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

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF17252A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeElement() {
    return Container(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Transform.rotate(
            angle: math.pi / 8,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Colors.white.withOpacity(0.5), width: 4),
              ),
            ),
          ),
          Transform.rotate(
            angle: -math.pi / 8,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Colors.white.withOpacity(0.3), width: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
