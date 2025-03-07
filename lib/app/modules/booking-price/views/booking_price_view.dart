import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            Text(
              'Giá Đặt lịch',
              style: TextStyle(
                fontSize: 20, // Đã đổi thành 20px
                fontWeight: FontWeight.w600, // Không đổi
                color: Color(0xFF2B7A78), // Đổi sang mã màu #2B7A78
                fontFamily: 'Poppins', // Thêm font-family Poppins
                fontStyle: FontStyle.normal, // Thiết lập font-style normal
                height: 1.0, // line-height normal tương đương với height 1.0
              ),
            ),

            Text(
              'Xác nhận thông tin để hoàn tất',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking Information Section
              _buildSectionHeader(Icons.info_outline, 'Thông tin đặt lịch'),
              _buildVenueInfo(),
              const SizedBox(height: 16),
              _buildBookingInfoGrid(),
              _buildVoucherSelector(),
              _buildPriceBreakdown(),

              // User Information Section
              const SizedBox(height: 20),
              _buildSectionHeader(Icons.person_outline, 'Thông tin người đặt'),
              _buildTextField('Tên của bạn', Icons.person, 'Nhập tên của bạn'),
              const SizedBox(height: 12),
              _buildTextField('Số điện thoại', Icons.phone, 'Nhập số điện thoại'),

              // Confirmation Button
              const SizedBox(height: 24),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền trắng
        borderRadius: BorderRadius.circular(8), // Bo góc
        border: Border.all(
          color: Color(0xFF2B7A78), // Màu viền xanh
          width: 1.5, // Độ dày viền
        ),
      ),
      child: Row(
        children: [
          Icon( // Sử dụng FaIcon thay vì Icon
            icon,
            color: Color(0xFF2B7A78), // Màu icon xanh
            size: 16, // Kích thước icon
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900, // Font weight 900
              fontFamily: 'FontAwesome5Free', // Font Awesome 5 Free
              fontStyle: FontStyle.normal,
              height: 1.0, // Line height tương đương 16px
              color: Color(0xFF2B7A78), // Màu chữ xanh
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildVenueInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDEF2F1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Badminton Ngọc Anh',
            style: TextStyle(
              fontWeight: FontWeight.w600, // Đúng theo yêu cầu
              fontSize: 13, // Đúng theo yêu cầu
              fontFamily: 'Poppins', // Sử dụng font Poppins
              fontStyle: FontStyle.normal, // Kiểu chữ bình thường
              height: 1.0, // Line height normal (tương đương 1.0)
              color: Color(0xFF17252A), // Màu sắc đúng yêu cầu
            ),
          ),

          const SizedBox(height: 4),
          Text(
            'B27 Tô Ký, Phường Trung Mỹ Tây, Quận 12, TP HCM',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfoGrid() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        shrinkWrap: true,
        childAspectRatio: 2.5,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildInfoItem('Ngày', '26/02/2025'),
          _buildInfoItem('Đối tượng', 'Khách hàng'),
          _buildInfoItem('Tổng giờ', '1 giờ'),
          _buildInfoItem('Tổng tiền', '100.000đ', isHighlighted: true),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isHighlighted = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isHighlighted ? const Color(0xFF2B7A78) : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF3AAFA9),
          style: BorderStyle.solid,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: ListTile(
        leading: Icon(
          Icons.confirmation_number_outlined,
          color: const Color(0xFF2B7A78),
        ),
        title: Text(
          'Chọn voucher giảm giá',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Nhập mã giảm giá hoặc chọn voucher có sẵn',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: const Color(0xFF2B7A78),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        dense: true,
        onTap: () {
          // Show voucher selection modal
          // controller.showVoucherSelectionModal();
        },
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
            style: BorderStyle.solid, // Đã đổi từ BorderStyle.dashed
          ),
        ),
      ),
      child: Column(
        children: [
          _buildPriceRow('Phí sân', '100.000đ'),
          // Dòng tổng thanh toán
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_money, // Icon hiển thị
                      color: Color(0xFF2B7A78), // Màu icon
                      size: 16, // Kích thước icon
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Tổng thanh toán',
                      style: TextStyle(
                        fontSize: 14, // Kích thước chữ 14px
                        fontWeight: FontWeight.w600, // Font weight 600
                        fontFamily: 'Poppins', // Font Poppins
                        fontStyle: FontStyle.normal,
                        height: 1.0, // Line height normal
                        color: Color(0xFF333333), // Màu chữ #333
                      ),
                    ),
                  ],
                ),
                Text(
                  '100.000đ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'FontAwesome5Free',
                    fontStyle: FontStyle.normal,
                    height: 1.0,
                    color: Color(0xFF2B7A78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDiscount ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: const Color(0xFF2B7A78),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: InputBorder.none,
              suffixIcon: Icon(
                Icons.cancel,
                color: Colors.grey,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }


}
Widget _buildConfirmButton() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () {
        // Handle confirmation
        // controller.confirmAndPay();
      },
      icon: Icon(
        Icons.check_circle,
        color: Colors.white, // Màu icon #FFF
        size: 14, // Kích thước icon 14px
      ),
      label: Text(
        'XÁC NHẬN VÀ THANH TOÁN',
        style: TextStyle(
          fontWeight: FontWeight.w900, // Font weight 900
          fontSize: 14, // Font size 14px
          fontFamily: 'FontAwesome5Free', // Font Awesome 5 Free
          fontStyle: FontStyle.normal,
          height: 1.0, // Line height 14px
          color: Colors.white, // Màu chữ trắng #FFF
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2B7A78),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
      ),
    ),
  );
}

