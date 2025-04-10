// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/coupon.dart';
import 'dart:math' as math;

class CouponDetailBottomSheet extends StatefulWidget {
  final Coupon coupon;

  const CouponDetailBottomSheet({
    super.key,
    required this.coupon,
  });

  @override
  State<CouponDetailBottomSheet> createState() =>
      _CouponDetailBottomSheetState();
}

class _CouponDetailBottomSheetState extends State<CouponDetailBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format dates for display
    final DateTime endDate = DateTime.parse(widget.coupon.endDate);
    final createDate = DateTime.parse(widget.coupon.createdAt);
    final formattedEndDate = DateFormat('dd/MM/yyyy').format(endDate);
    final formattedCreateDate = DateFormat('dd/MM/yyyy').format(createDate);

    Color voucherColor = widget.coupon.discountType == 'fixed'
        ? const Color(0xFFFF6B6B)
        : const Color(0xFF5E60CE);

    // Gradient for background
    List<Color> gradientColors = widget.coupon.discountType == 'fixed'
        ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)]
        : [const Color(0xFF5E60CE), const Color(0xFF6A75E0)];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
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
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                            // ignore: duplicate_ignore
                            // ignore: deprecated_member_use
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
                            height: 110,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.coupon.discountType == 'fixed'
                                          ? '${NumberFormat('#,###').format(widget.coupon.amount)}đ'
                                          : '${widget.coupon.amount}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
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
                          ),
                          // Coupon details
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  widget.coupon.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF17252A),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _scaleAnimation.value,
                                      child: child,
                                    );
                                  },
                                  child: GestureDetector(
                                    onTapDown: (_) =>
                                        _animationController.forward(),
                                    onTapUp: (_) {
                                      _animationController.reverse();
                                      _copyCode();
                                    },
                                    onTapCancel: () =>
                                        _animationController.reverse(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
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
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
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
                                                widget.coupon.code,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: voucherColor,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              AnimatedSwitcher(
                                                duration:
                                                    const Duration(milliseconds: 300),
                                                child: _isCopied
                                                    ? const Icon(
                                                        Icons.check_circle,
                                                        color: Colors.green,
                                                        size: 22,
                                                        key: ValueKey('check'),
                                                      )
                                                    : Icon(
                                                        Icons.copy,
                                                        color: voucherColor,
                                                        size: 22,
                                                        key: const ValueKey('copy'),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Dotted line separator
                          SizedBox(
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
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            child: Row(
                              children: [
                                Icon(Icons.access_time,
                                    color: Colors.grey[700], size: 16),
                                const SizedBox(width: 8),
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              widget.coupon.discountType == 'fixed'
                                  ? 'Giảm số tiền cố định'
                                  : 'Giảm theo phần trăm',
                              Icons.card_giftcard),
                          _buildDetailItem(
                              'Mức giảm',
                              widget.coupon.discountType == 'fixed'
                                  ? '${NumberFormat('#,###').format(widget.coupon.amount)}đ'
                                  : '${widget.coupon.amount}%',
                              Icons.money),
                          _buildDetailItem('Ngày hết hạn', formattedEndDate,
                              Icons.event_busy),
                          if (widget.coupon.minTotal != null)
                            _buildDetailItem(
                                'Giá trị đơn hàng tối thiểu',
                                '${NumberFormat('#,###').format(widget.coupon.minTotal)}đ',
                                Icons.shopping_basket),
                          if (widget.coupon.maxTotal != null)
                            _buildDetailItem(
                                'Giá trị giảm tối đa',
                                '${NumberFormat('#,###').format(widget.coupon.maxTotal)}đ',
                                Icons.trending_down),
                          if (widget.coupon.quantityLimit != null)
                            _buildDetailItem(
                                'Số lượng mã',
                                '${widget.coupon.quantityLimit}',
                                Icons.confirmation_number),
                          if (widget.coupon.limitPerUser != null)
                            _buildDetailItem('Số lần sử dụng tối đa/người',
                                '${widget.coupon.limitPerUser}', Icons.person),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _copyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: voucherColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        shadowColor: voucherColor.withOpacity(0.4),
                      ),
                      child: const Row(
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
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
          const SizedBox(width: 15),
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
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
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
    // ignore: sized_box_for_whitespace
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

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.coupon.code));
    setState(() {
      _isCopied = true;
    });

    Get.snackbar(
      'Thành công',
      'Đã sao chép mã giảm giá',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      icon: Icon(Icons.check_circle, color: Colors.green[800]),
    );

    // Reset the copied state after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }
}
