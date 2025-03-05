import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuccessfulPaymentView extends StatelessWidget {
  const SuccessfulPaymentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B7A78),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Decorations
            Positioned(
              top: -100,
              left: -100,
              child: _buildBackgroundDecor(200, 200),
            ),
            Positioned(
              bottom: -90,
              right: -90,
              child: _buildBackgroundDecor(180, 180),
            ),

            Column(
              children: [
                // Header
                _buildHeader(context),

                // Main Content
                Expanded(
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: _buildContainerDecoration(),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Success Icon
                            _buildSuccessIcon(),

                            // Success Message
                            _buildSuccessMessage(),

                            // Order Information
                            _buildOrderInfo(),

                            // Buttons
                            _buildButtonGroup(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Footer
                _buildFooter(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecor(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back Button
          Positioned(
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Title
          Text(
            'Thanh toán',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
      ],
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple Effect
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),

          // Success Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.green, Colors.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        Text(
          'Thanh toán thành công!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Sân cầu lông của bạn đã được đặt thành công',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildOrderInfoItem('Mã đơn hàng:', '#21344'),
          _buildOrderInfoItem('Sân đã đặt:', 'Sân cầu lông Hà Đông'),
          _buildOrderInfoItem('Thời gian:', '01/03/2025 - 17:00-19:00'),
          _buildOrderInfoItem('Tổng tiền:', '100.000 đ'),
        ],
      ),
    );
  }

  Widget _buildOrderInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: label.contains('Mã đơn hàng')
                  ? const Color(0xFF2B7A78)
                  : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildButtonGroup(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Home Button with Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2B7A78), Color(0xFF17252A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to home page
              },
              icon: const Icon(Icons.home, color: Colors.white),
              label: const Text('Về trang chủ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // View Bookings Button
          OutlinedButton.icon(
            onPressed: () {
              // Navigate to bookings page
            },
            icon: const Icon(
                Icons.remove_red_eye_outlined,
                color: Color(0xFF2B7A78)
            ),
            label: const Text(
              'Xem lịch đặt sân',
              style: TextStyle(color: Color(0xFF2B7A78)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2B7A78)),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Cảm ơn quý khách đã sử dụng dịch vụ của Sportify!',
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}