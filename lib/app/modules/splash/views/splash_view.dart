import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import '../../../core/styles/style.dart';
import '../../../core/utilities/utilities.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3AAFA9), // Lighter teal
              Color(0xFF2B7A78), // Original teal
              Color(0xFF17252A), // Darker shade for depth
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(15, (index) {
              final random = math.Random(index);
              final size = random.nextDouble() * 100 + 50;
              final left = random.nextDouble() * MediaQuery.of(context).size.width;
              final top = random.nextDouble() * MediaQuery.of(context).size.height;
              final opacity = random.nextDouble() * 0.15;
              
              return AnimatedBuilder(
                animation: controller.particleAnimations[index % controller.particleAnimations.length],
                builder: (context, child) {
                  final animation = controller.particleAnimations[index % controller.particleAnimations.length];
                  return Positioned(
                    left: left + (animation.value * 20 * (index % 2 == 0 ? 1 : -1)),
                    top: top + (animation.value * 20 * (index % 3 == 0 ? 1 : -1)),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: (0.1 * 255).toInt() /255),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            
            // Two additional prominent bubbles at the top
            // First top bubble
            AnimatedBuilder(
              animation: controller.topBubbleAnimation1,
              builder: (context, child) {
                return Positioned(
                  top: MediaQuery.of(context).size.height * 0.1,
                  left: MediaQuery.of(context).size.width * 0.2,
                  child: Transform.translate(
                    offset: Offset(
                      controller.topBubbleAnimation1.value * 15,
                      controller.topBubbleAnimation1.value * 10,
                    ),
                    child: Opacity(
                      opacity: 0.25,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: (0.2 * 255).toInt() /255),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Second top bubble
            AnimatedBuilder(
              animation: controller.topBubbleAnimation2,
              builder: (context, child) {
                return Positioned(
                  top: MediaQuery.of(context).size.height * 0.05,
                  right: MediaQuery.of(context).size.width * 0.15,
                  child: Transform.translate(
                    offset: Offset(
                      controller.topBubbleAnimation2.value * -12,
                      controller.topBubbleAnimation2.value * 8,
                    ),
                    child: Opacity(
                      opacity: 0.2,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: (0.15 * 255).toInt() /255),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Animated gradient overlay
            AnimatedBuilder(
              animation: controller.pulseAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: Opacity(
                    opacity: 0.1 + (controller.pulseAnimation.value * 0.05),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.8 + (controller.pulseAnimation.value * 0.2),
                          colors: const [
                            Colors.white,
                            Colors.transparent,
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with enhanced animation - keeping original size and removing shadow
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      controller.floatingAnimation,
                      controller.rotationAnimation,
                      controller.scaleAnimation,
                    ]),
                    builder: (context, child) {
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..translate(
                            controller.floatingAnimation.value * 8,
                            controller.floatingAnimation.value * 10,
                          )
                          ..rotateZ(controller.rotationAnimation.value * 0.05)
                          ..scale(1.0 + (controller.scaleAnimation.value * 0.05)),
                        child: FadeTransition(
                          opacity: controller.fadeInAnimation,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
                            // Removed the Container with BoxDecoration and shadow
          child: Image.asset(AppImage.logo),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // SPORTIFY text with enhanced animation
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: (0.8 * 255).toInt() /255),
                          Colors.white,
                        ],
                        stops: [
                          0.0,
                          0.5 + (controller.shimmerAnimation.value * 0.5),
                          1.0,
                        ],
                      ).createShader(bounds);
                    },
                    child: FadeTransition(
                      opacity: controller.fadeInAnimation,
                      child: const Text(
                        'SPORTIFY',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // BADMINTON text with enhanced animation
                  SlideTransition(
                    position: controller.slideUpAnimation,
                    child: FadeTransition(
                      opacity: controller.textFadeInAnimation,
                      child: AnimatedBuilder(
                        animation: controller.letterSpacingAnimation,
                        builder: (context, child) {
                          return Text(
                            'BADMINTON',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: (0.9 * 255).toInt() /255),
                              letterSpacing: 4 + (controller.letterSpacingAnimation.value * 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Welcome message with enhanced animation
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: controller.welcomeFadeInAnimation,
                child: AnimatedBuilder(
                  animation: controller.pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (controller.pulseAnimation.value * 0.03),
                      child: const Center(
                        child: Text(
                          'Chào mừng trở lại!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Enhanced progress bar
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: controller.progressFadeInAnimation,
                child: Center(
                  child: Container(
                    width: 200,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: (0.2 * 255).toInt() /255),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: (0.2 * 255).toInt() /255),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: controller.progressAnimation,
                      builder: (context, child) {
                        return Stack(
                          children: [
                            // Main progress
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: controller.progressAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Color(0xFFDEF2F1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: (0.5 * 255).toInt() /255),
                                      blurRadius: 8,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Animated glow effect
                            AnimatedBuilder(
                              animation: controller.pulseAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  left: (controller.progressAnimation.value * 200) - 10,
                                  top: -3,
                                  child: Container(
                                    width: 20,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: ((0.3 + (controller.pulseAnimation.value * 0.2)) * 255).toInt() /255),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: (0.5 * 255).toInt() /255),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
