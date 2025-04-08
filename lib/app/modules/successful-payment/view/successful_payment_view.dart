import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../controllers/successful_payment_controller.dart';
import '../../../routes/app_pages.dart';

class SuccessfulPaymentView extends GetView<SuccessfulPaymentController> {
  const SuccessfulPaymentView({super.key});

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

                // Main Content without container animations
                Expanded(
                  child: Center(
                    child: _buildMainContainer(),
                  ),
                ),

                // Footer
                _buildFooter(),
              ],
            ),

            // Confetti Layer
            Positioned.fill(
              child: IgnorePointer(
                child: GetBuilder<SuccessfulPaymentController>(
                  builder: (_) => CustomPaint(
                    painter: ConfettiPainter(controller.confettiParticles),
                    child: Container(),
                  ),
                ),
              ),
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
      child: const Text(
        'Thanh toán',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMainContainer() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: _buildContainerDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top gradient line
              Container(
                height: 5,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2B7A78), Color(0xFF3AAFA9)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),

              // Success Icon with animations
              _buildSuccessIcon(),

              // Success Message without fade animation
              _buildSuccessMessage(),

              // Buttons without fade animation
              _buildButtonGroup(),
            ],
          ),
        ),
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
      child: AnimatedBuilder(
        animation: controller.pulseController,
        builder: (context, child) {
          // Animate the confetti
          Future.delayed(Duration.zero, () => controller.updateConfetti());

          return Stack(
            alignment: Alignment.center,
            children: [
              // Ripple Effect - Outer circle
              Transform.scale(
                scale: controller.rippleAnimation.value,
                child: Container(
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
              ),

              // Success Icon with pulse animation
              Transform.scale(
                scale: controller.pulseAnimation.value * 0.9,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.green, Color(0xFF8BC34A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: controller.iconScaleAnimation.value,
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Thanh toán thành công!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Sân cầu lông của bạn đã được đặt thành công',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF777777),
          ),
        ),
        const SizedBox(height: 20),
        // Order Information
        _buildOrderInfo(),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Obx(() => _buildOrderInfoItem(
              'Mã đơn hàng:', controller.bookingCode.value,
              isOrderId: true)),
          Obx(() =>
              _buildOrderInfoItem('Sân đã đặt:', controller.venueName.value)),
          Obx(() =>
              _buildOrderInfoItem('Thời gian:', controller.bookingTime.value)),
          Obx(() =>
              _buildOrderInfoItem('Tổng tiền:', controller.totalAmount.value)),
        ],
      ),
    );
  }

  Widget _buildOrderInfoItem(String label, String value,
      {bool isOrderId = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF777777),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: isOrderId
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEF2F1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF17252A),
                        fontFamily: "Poppins",
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      color:
                          isOrderId ? const Color(0xFF2B7A78) : Colors.black87,
                      fontSize: 14,
                      fontWeight: isOrderId ? FontWeight.w600 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonGroup() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          // Home Button with Gradient Background and hover effect
          _buildHomeButton(),
          const SizedBox(height: 12),

          // View Bookings Button
          _buildViewBookingsButton(),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildHomeButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B7A78), Color(0xFF17252A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B7A78).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to dashboard page
          Get.offAllNamed(Routes.dashboard);
        },
        icon: const Icon(Icons.home, color: Colors.white),
        label: const Text(
          'Về trang chủ',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildViewBookingsButton() {
    return OutlinedButton.icon(
      onPressed: () {
        // Navigate to interface booking page
        Get.toNamed(Routes.home);
      },
      icon: const Icon(
        Icons.remove_red_eye_outlined,
        color: Color(0xFF2B7A78),
      ),
      label: const Text(
        'Xem lịch đặt sân',
        style: TextStyle(
          color: Color(0xFF2B7A78),
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF2B7A78)),
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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

// Custom painter for confetti animation
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..strokeWidth = particle.size / 2
        ..strokeCap = StrokeCap.round;

      final startPoint = Offset(particle.x, particle.y);
      final endPoint = Offset(
        particle.x + particle.size * cos(particle.rotation * pi / 180),
        particle.y + particle.size * sin(particle.rotation * pi / 180),
      );

      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
