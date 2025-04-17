import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:math' as math;
import '../controllers/qr_scanner_controller.dart';

class QrScannerView extends GetView<QrScannerController> {
  const QrScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildQrView(context),
          _buildOverlay(context),
          _buildBottomControls(context),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return MobileScanner(
      controller: controller.scannerController,
      onDetect: (BarcodeCapture capture) {
        controller.onDetect(capture);
      },
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final scanWindow = MediaQuery.of(context).size.width < 400 ? 220.0 : 280.0;
    final scanAreaHeight = scanWindow;
    const primaryColor = Color(0xFF2B7A78);

    return Stack(
      children: [
        // Transparent center area
        Center(
          child: Container(
            width: scanWindow,
            height: scanAreaHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.transparent),
            ),
          ),
        ),
        // Scan animation
        Center(
          child: AnimatedScannerOverlay(
            width: scanWindow,
            height: scanAreaHeight,
            borderColor: primaryColor,
            scanLineColor: primaryColor,
          ),
        ),
        // Top controls
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(102),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                      ),
                    ),
                    // Title
                    Text(
                      'Quét mã QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black.withAlpha(128),
                          ),
                        ],
                      ),
                    ),
                    // Flash button
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(102),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: controller.toggleFlash,
                            icon: Icon(
                              controller.flashOn.value
                                  ? Icons.flash_on
                                  : Icons.flash_off,
                            ),
                            color: Colors.white,
                          ),
                        )),
                  ],
                ),
              ),
              const Spacer(),
              // Instruction text
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                margin: const EdgeInsets.only(bottom: 100),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(102),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Đặt mã QR vào giữa khung hình để quét',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(102),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Gallery button
            _buildBottomButton(
              icon: Icons.photo_library,
              label: 'Thư viện',
              onTap: controller.pickImageFromGallery,
            ),
            // My QR code button
            _buildBottomButton(
              icon: Icons.qr_code,
              label: 'Mã của tôi',
              onTap: controller.showMyQRCode,
            ),
            // History button
            _buildBottomButton(
              icon: Icons.history,
              label: 'Lịch sử',
              onTap: controller.showScanHistory,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedScannerOverlay extends StatefulWidget {
  final double width;
  final double height;
  final Color borderColor;
  final Color scanLineColor;

  const AnimatedScannerOverlay({
    super.key,
    required this.width,
    required this.height,
    required this.borderColor,
    required this.scanLineColor,
  });

  @override
  State<AnimatedScannerOverlay> createState() => _AnimatedScannerOverlayState();
}

class _AnimatedScannerOverlayState extends State<AnimatedScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.repeat();
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: ScannerOverlayPainter(
            width: widget.width,
            height: widget.height,
            borderColor: widget.borderColor,
            scanLineColor: widget.scanLineColor,
            scanLinePosition: _animationController.value,
          ),
        );
      },
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double width;
  final double height;
  final Color borderColor;
  final Color scanLineColor;
  final double scanLinePosition;
  final double cornerLength = 30;
  final double cornerWidth = 5;
  final double scanLineHeight = 2;

  ScannerOverlayPainter({
    required this.width,
    required this.height,
    required this.borderColor,
    required this.scanLineColor,
    required this.scanLinePosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: width,
      height: height,
    );

    // Draw corners
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerWidth
      ..strokeCap = StrokeCap.round;

    // Top left corner
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft.translate(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft.translate(0, cornerLength),
      cornerPaint,
    );

    // Top right corner
    canvas.drawLine(
      rect.topRight,
      rect.topRight.translate(-cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.topRight,
      rect.topRight.translate(0, cornerLength),
      cornerPaint,
    );

    // Bottom left corner
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft.translate(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft.translate(0, -cornerLength),
      cornerPaint,
    );

    // Bottom right corner
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight.translate(-cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight.translate(0, -cornerLength),
      cornerPaint,
    );

    // Draw scan line
    final scanLinePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          scanLineColor.withAlpha(0),
          scanLineColor.withAlpha(204),
          scanLineColor.withAlpha(0),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rect);

    final scanLineY = rect.top + (rect.height * scanLinePosition);
    canvas.drawRect(
      Rect.fromLTWH(
        rect.left,
        scanLineY - scanLineHeight / 2,
        rect.width,
        scanLineHeight,
      ),
      scanLinePaint,
    );

    // Draw focus points
    final focusPointPaint = Paint()
      ..color = scanLineColor.withAlpha(128)
      ..style = PaintingStyle.fill;

    // Random focus points that change with animation
    final random = math.Random(scanLinePosition.toInt() * 10000);
    for (int i = 0; i < 5; i++) {
      final x = rect.left + random.nextDouble() * rect.width;
      final y = rect.top + random.nextDouble() * rect.height;
      final radius = 1.0 + random.nextDouble() * 2.0;
      canvas.drawCircle(Offset(x, y), radius, focusPointPaint);
    }
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanLinePosition != scanLinePosition;
  }
}
