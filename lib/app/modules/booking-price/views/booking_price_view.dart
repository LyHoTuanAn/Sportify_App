import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../../../core/styles/style.dart';
import '../../../core/utilities/screen.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/app_button.dart';
import '../controllers/booking_price_controller.dart';

class BookingPriceView extends GetView<BookingPriceController> {
  const BookingPriceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B7A78),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Column(
          children: [
            Text(
              'Giá Đặt lịch',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Xác nhận thông tin để hoàn tất',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                fontFamily: 'Poppins',
                color: Colors.white70,
              ),
            ),
          ],
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          // Background Decorations
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            right: -90,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 390),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            icon: Icons.info_outline,
                            title: 'Thông tin đặt lịch',
                          ),
                          const SizedBox(height: 12),
                          _buildVenueInfo(),
                          const SizedBox(height: 16),
                          _buildBookingInfoGrid(),
                          const SizedBox(height: 12),
                          _buildVoucherSelector(),
                          _buildPriceBreakdown(),
                          _buildSectionHeader(
                            icon: Icons.person_outline,
                            title: 'Thông tin người đặt',
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'Tên của bạn',
                            icon: Icons.person_outline,
                            hint: 'Nhập tên của bạn',
                            controller: controller.nameController,
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            label: 'Số điện thoại',
                            icon: Icons.phone_outlined,
                            hint: 'Nhập số điện thoại',
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'Email',
                            icon: Icons.email_outlined,
                            hint: 'Nhập email của bạn',
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          _buildConfirmButton(),
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

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF2B7A78)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Color(0xFF2B7A78),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 1,
          color: const Color(0xFFE0E0E0),
        ),
      ],
    );
  }

  Widget _buildVenueInfo() {
    return Obx(() => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFDEF2F1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.bookingInfo.value.venueName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Color(0xFF17252A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.bookingInfo.value.venueAddress,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: Color(0xFF333333),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildBookingInfoGrid() {
    return Obx(() => Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Ngày',
                    controller.bookingInfo.value.date,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Giờ đặt',
                    controller.bookingInfo.value.totalHours,
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _buildInfoItem(String label, String value,
      {bool isHighlighted = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            color: Color(0xFF777777),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: isHighlighted
                ? const Color(0xFF2B7A78)
                : const Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherSelector() {
    return Obx(() => GestureDetector(
          onTap: () => controller.showVoucherSelectionModal(),
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF3AAFA9),
                width: 1,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF9F9F9),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  size: 16,
                  color: Color(0xFF2B7A78),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.hasSelectedVoucher.value
                            ? controller.selectedVoucher.value!.code
                            : 'Chọn voucher giảm giá',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        controller.hasSelectedVoucher.value
                            ? 'Giảm ${controller.formatCurrency(controller.voucherDiscount)}'
                            : 'Nhập mã giảm giá hoặc chọn voucher có sẵn',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Poppins',
                          color: controller.hasSelectedVoucher.value
                              ? const Color(0xFFE74C3C)
                              : const Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Color(0xFF2B7A78),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildPriceBreakdown() {
    return Obx(() => Container(
          margin: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Container(
                height: 1,
                color: const Color(0xFFE0E0E0),
              ),
              const SizedBox(height: 8),
              // Court fee
              _buildPriceRow(
                'Phí sân',
                controller.formatCurrency(controller.courtFee),
              ),
              const SizedBox(height: 8),
              // Sportify service fee
              _buildPriceRow(
                'Phí dịch vụ Sportify',
                controller.formatCurrency(controller.serviceFee),
                isHighlighted: true,
              ),
              if (controller.hasSelectedVoucher.value) ...[
                const SizedBox(height: 8),
                _buildPriceRow(
                  'Giảm giá',
                  '-${controller.formatCurrency(controller.voucherDiscount)}',
                  isDiscount: true,
                ),
              ],
              const SizedBox(height: 8),
              Container(
                height: 1,
                color: const Color(0xFFE0E0E0),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng thanh toán',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFF333333),
                    ),
                  ),
                  Text(
                    controller.formatCurrency(controller.finalTotal),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFF2B7A78),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
            ],
          ),
        ));
  }

  Widget _buildPriceRow(String label, String value,
      {bool isDiscount = false, bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Poppins',
            color: Color(0xFF777777),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: isDiscount
                ? const Color(0xFFE74C3C)
                : (isHighlighted
                    ? const Color(0xFF2B7A78)
                    : const Color(0xFF333333)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: const Color(0xFF2B7A78)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFF9F9F9),
          ),
          child: Theme(
            data: ThemeData(
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Color(0xFF2B7A78),
                selectionColor: Color(0x1A2B7A78),
                selectionHandleColor: Color(0xFF2B7A78),
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Color(0xFF333333),
              ),
              cursorColor: const Color(0xFF2B7A78),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Color(0xFF777777),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: InputBorder.none,
                suffixIcon: GestureDetector(
                  onTap: () => controller.clear(),
                  child: const Icon(
                    Icons.cancel_outlined,
                    size: 14,
                    color: Color(0xFF2B7A78),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF2B7A78), Color(0xFF17252A)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: const Color(0xFF2B7A78).withOpacity(0.2),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => controller.confirmAndPay(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.circle,
                    size: 18,
                    color: Colors.white,
                  ),
                  Icon(
                    Icons.check,
                    size: 15,
                    color: Color(0xFF2B7A78),
                  ),
                ],
              ),
              SizedBox(width: 8),
              Text(
                'XÁC NHẬN VÀ THANH TOÁN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
