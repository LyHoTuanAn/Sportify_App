import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payment_controller.dart';

class PaymentView extends GetView<PaymentController> {
  const PaymentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Thanh toán",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2B7A78), // Đổi màu thành #2B7A78
                fontSize: 20,
                fontWeight: FontWeight.w700, // Font-weight 700 tương ứng FontWeight.bold
                fontFamily: 'Poppins', // Thêm font Poppins (đảm bảo font đã được khai báo)
                fontStyle: FontStyle.normal,
                height: 1.0, // line-height: normal
              ),
            ),
            Text(
              "Hoàn tất thanh toán để đặt sân",
              style: TextStyle(
                color: Color(0xFF777777),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                // Time Remaining Notice
                _buildTimeRemainingNotice(),
                const SizedBox(height: 16),

                // Content - Order info, bank info, QR code
                _buildOrderInfo(),
                const SizedBox(height: 16),
                _buildBankInfo(),
                const SizedBox(height: 16),
                _buildQrCode(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRemainingNotice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Đơn hàng sẽ hết hạn sau: ",
            style: TextStyle(
              color: Color(0xFF17252A),
              fontSize: 14,
            ),
          ),
          Obx(() => Text(
            controller.formattedTime,
            style: const TextStyle(
              color: Color(0xFF17252A),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          )),
          const Text(
            " phút",
            style: TextStyle(
              color: Color(0xFF17252A),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildOrderInfo() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Thông tin đơn hàng",
            style: TextStyle(
              color: Color(0xFF17252A), // Giữ nguyên mã màu
              fontFamily: 'Poppins', // Thêm font Poppins
              fontSize: 17, // Đổi thành 17px
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w700, // Đổi thành 700
              height: 1.0, // Line height normal tương đương với 1.0
            ),
          ),

      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFDEF2F1), // Cập nhật màu nền
          borderRadius: BorderRadius.circular(20), // Giữ nguyên border-radius 20px
        ),
        child: const Text(
          "Chờ thanh toán",
          style: TextStyle(
            color: Color(0xFF2B7A78), // Giữ nguyên mã màu
            fontFamily: 'Poppins', // Thêm font Poppins
            fontSize: 12, // Giữ nguyên 12px
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w500, // Giữ nguyên 500
            height: 1.0, // Line height normal tương đương với 1.0
          ),
        ),

      ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoItem("Họ và tên", "Bảo Long"),
                _buildInfoItem("Số điện thoại", "0868135350", isHighlighted: true),
                _buildInfoItem("Mã đơn", "#21344", isOrderId: true,),
                _buildInfoItem("Đối tượng", "Khách hàng"),
                _buildInfoItem("Tổng tiền", "100.000 đ", isHighlighted: true),
                _buildInfoItem("Thời gian đặt", "28/02/2025 15:48"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value,
      {bool isHighlighted = false, bool isOrderId = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 14,
            ),
          ),
          isOrderId
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFDEF2F1), // Cập nhật màu nền
              borderRadius: BorderRadius.circular(6), // Bo góc 6px
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF17252A), // Màu chữ
                fontFamily: "Poppins", // Font chữ
                fontSize: 13, // Cỡ chữ
                fontStyle: FontStyle.normal, // Kiểu chữ bình thường
                fontWeight: FontWeight.w700, // Độ đậm 700
                height: 1.0, // Line height mặc định
              ),
            ),
          )
              : Text(
            value,
            style: TextStyle(
              color: isHighlighted ? const Color(0xFF2B7A78) : const Color(0xFF17252A),
              fontFamily: "Poppins",
              fontSize: 14,
              fontStyle: FontStyle.normal,
              fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w400,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBankInfo() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: const Row(
              children: [
                Text(
                  "Thông tin chuyển khoản",
                  style: TextStyle(
                    color: Color(0xFF17252A), // Giữ nguyên mã màu
                    fontFamily: 'Poppins', // Thêm font Poppins
                    fontSize: 17, // Đổi thành 17px
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700, // Đổi thành 700
                    height: 1.0, // Line height normal tương đương với 1.0
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildBankDetailItem("Tên tài khoản", "PHAN QUOC HUNG"),
                _buildBankDetailItem("Số tài khoản", "0334043054"),
                _buildBankDetailItem("Ngân hàng", "MBBank", hasImage: true),
                _buildBankDetailItem("Nội dung CK", "#21344 BALONG"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailItem(String label, String value, {bool hasImage = false, Widget? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              if (hasImage)
                Container(
                  margin: const EdgeInsets.only(right: 5),
                  child: Image.asset(
                    'assets/images/logo_mbbank.png', // Đường dẫn tương đối trong dự án Flutter
                    width: 24, // Kích thước logo
                    height: 24,
                  ),
                ),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF17252A),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrCode() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Quét mã để thanh toán",
                  style: TextStyle(
                    color: Color(0xFF17252A), // Màu chữ
                    fontFamily: "Poppins", // Font chữ
                    fontSize: 16, // Cỡ chữ
                    fontStyle: FontStyle.normal, // Kiểu chữ bình thường
                    fontWeight: FontWeight.w700, // Độ đậm 700
                    height: 1.0, // Giữ line-height mặc định
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Ảnh QR Code (bank.png)
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/bank.png', // Ảnh QR Code
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.qr_code,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 5), // Tạo khoảng cách giữa hai ảnh

                // Icon tải xuống
                Icon(
                  Icons.file_download_rounded, // Sử dụng icon tải xuống có viền tròn đẹp hơn
                  size: 35,
                  color: Color(0xFF2B7A78), // Sử dụng màu chủ đạo của app
                ),
              ],
            ),
          ),


          const SizedBox(height: 0),

                // Instructions
                const Text(
                  "Sử dụng ứng dụng ngân hàng để quét mã QR code hoặc chuyển khoản theo thông tin bên trên",
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
  }
}