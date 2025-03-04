import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import '../../../core/utilities/utilities.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  // Animation controllers
  late AnimationController _animationController;
  
  // Basic animations
  late Animation<double> fadeInAnimation;
  late Animation<double> textFadeInAnimation;
  late Animation<double> welcomeFadeInAnimation;
  late Animation<double> progressFadeInAnimation;
  late Animation<double> progressAnimation;
  late Animation<double> floatingAnimation;
  late Animation<Offset> slideUpAnimation;
  
  // Enhanced animations
  late Animation<double> rotationAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> shimmerAnimation;
  late Animation<double> letterSpacingAnimation;
  late Animation<double> pulseAnimation;
  
  // Top bubble animations
  late Animation<double> topBubbleAnimation1;
  late Animation<double> topBubbleAnimation2;
  
  // Particle animations
  late List<Animation<double>> particleAnimations;
  
  @override
  void onInit() {
    super.onInit();
    
    // Initialize animation controller with longer duration for more impressive animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    
    // Setup basic animations
    fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    
    textFadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    
    slideUpAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    
    welcomeFadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );
    
    progressFadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );
    
    progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeInOut),
      ),
    );
    
    // Enhanced animations
    
    // Floating animation with continuous loop
    floatingAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.repeat(reverse: true);
      }
    });
    
    // Subtle rotation animation
    rotationAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    // Breathing/pulsing scale animation
    scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    // Shimmer effect animation
    shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    // Letter spacing animation
    letterSpacingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.elasticOut),
      ),
    );
    
    // Pulse animation for various effects
    pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    // Top bubble animations with different timing and curves
    topBubbleAnimation1 = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    topBubbleAnimation2 = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    // Create multiple particle animations with different timings
    particleAnimations = List.generate(5, (index) {
      final random = math.Random(index);
      final startTime = random.nextDouble() * 0.5;
      final endTime = startTime + 0.5;
      
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(startTime, endTime, curve: Curves.easeInOut),
        ),
      );
    });
    
    // Start the animation
    _animationController.forward();
  }
  
  @override
  void onReady() async {
    super.onReady();
    
    // Wait for animations to complete before navigating
    await Future.delayed(const Duration(milliseconds: 6000));
    
    if (Preferences.getString(StringUtils.token) == null) {
      Get.offAllNamed(Routes.login);
    } else {
      Get.offAllNamed(Routes.dashboard);
    }
  }
  
  @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  }
}
