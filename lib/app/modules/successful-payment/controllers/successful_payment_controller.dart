import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListItem {
  final String? id;
  final String? title;
  final String? description;
  final DateTime? createdAt;

  ListItem({
    this.id,
    this.title,
    this.description,
    this.createdAt,
  });

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

// Confetti Particle class
class ConfettiParticle {
  late double x;
  late double y;
  late double size;
  late Color color;
  late double rotation;
  late double speed;
  late double rotationSpeed;
  late double oscillationSpeed;
  late double angle;

  ConfettiParticle({
    required double maxWidth,
    required double maxHeight,
  }) {
    final random = Random();
    final colors = [
      const Color(0xFF2B7A78),
      const Color(0xFF4CAF50),
      const Color(0xFFDEF2F1),
      Colors.white,
      const Color(0xFF8BC34A),
    ];

    x = random.nextDouble() * maxWidth;
    y = random.nextDouble() * maxHeight - maxHeight; // Start above screen
    size = random.nextDouble() * 5 + 3;
    color = colors[random.nextInt(colors.length)];
    rotation = random.nextDouble() * 360;
    speed = random.nextDouble() * 3 + 2;
    rotationSpeed = (random.nextDouble() - 0.5) * 2;
    oscillationSpeed = random.nextDouble() * 1.5 + 0.5;
    angle = random.nextDouble() * pi * 2;
  }

  void update() {
    y += speed;
    rotation += rotationSpeed;
    x += sin(angle) * oscillationSpeed;
  }
}

class SuccessfulPaymentController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Booking information
  final RxString bookingCode = ''.obs;
  final RxString venueName = ''.obs;
  final RxString bookingTime = ''.obs;
  final RxString totalAmount = ''.obs;
  final RxString courtFee = ''.obs;
  final RxString serviceFee = ''.obs;

  // Animation controllers
  late AnimationController pulseController;
  late Animation<double> pulseAnimation;

  // Success icon animations
  late Animation<double> iconScaleAnimation;
  late Animation<double> rippleAnimation;

  // Container fade in animation
  late Animation<double> containerFadeAnimation;
  late Animation<Offset> containerSlideAnimation;

  // Success message animation
  late Animation<double> messageOpacityAnimation;

  // Button group animation
  late Animation<double> buttonOpacityAnimation;

  // Confetti
  final List<ConfettiParticle> confettiParticles = [];
  final int particleCount = 100;

  @override
  void onInit() {
    super.onInit();

    // Get booking info from arguments
    final Map<String, dynamic>? bookingInfo = Get.arguments != null
        ? Get.arguments['bookingInfo'] as Map<String, dynamic>?
        : null;

    if (bookingInfo != null) {
      bookingCode.value = bookingInfo['booking_code'] ?? '';
      venueName.value = bookingInfo['venueName'] ?? '';
      bookingTime.value = bookingInfo['date'] ?? '';

      // Format amounts
      if (bookingInfo['totalPrice'] != null) {
        totalAmount.value = _formatCurrency(bookingInfo['totalPrice']);
      }

      // Format court fee
      if (bookingInfo['totalBeforeFees'] != null) {
        courtFee.value = _formatCurrency(bookingInfo['totalBeforeFees']);
      }

      // Format service fee
      if (bookingInfo['commission'] != null) {
        serviceFee.value = _formatCurrency(bookingInfo['commission']);
      }
    }

    // Initialize the pulse animation controller
    pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Pulse animation for the success icon
    pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Scale animation for the check icon
    iconScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: pulseController,
        curve: const Interval(0.1, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Ripple animation for the success icon
    rippleAnimation = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(
        parent: pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Container animations
    containerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: pulseController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    containerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: pulseController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Success message animation
    messageOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: pulseController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    // Button animation
    buttonOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: pulseController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
      ),
    );

    // Repeat the pulse animation
    pulseController.repeat(reverse: true);

    // Initialize confetti particles
    _initializeConfettiParticles();
  }

  void _initializeConfettiParticles() {
    // Get screen dimensions
    final size = Get.size;

    for (int i = 0; i < particleCount; i++) {
      confettiParticles.add(ConfettiParticle(
        maxWidth: size.width,
        maxHeight: size.height,
      ));
    }
  }

  void updateConfetti() {
    for (var particle in confettiParticles) {
      particle.update();

      // Reset particle when it falls out of view
      if (particle.y > Get.height) {
        particle.y = -20;
        particle.x = Random().nextDouble() * Get.width;
      }
    }
    update(); // Trigger UI update to redraw confetti
  }

  @override
  void onClose() {
    pulseController.dispose();
    super.onClose();
  }

  // Helper method to format currency values
  String _formatCurrency(dynamic amount) {
    if (amount == null) return "0đ";

    double price = 0;
    if (amount is double) {
      price = amount;
    } else if (amount is int) {
      price = amount.toDouble();
    } else if (amount is String) {
      price = double.tryParse(amount) ?? 0;
    }

    String priceString = price.toInt().toString();
    final pattern = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    priceString =
        priceString.replaceAllMapped(pattern, (Match m) => '${m[1]}.');
    return '${priceString}vnđ';
  }
}
