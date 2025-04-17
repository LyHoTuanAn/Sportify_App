import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/favorite_service.dart';

class FavoriteButton extends StatelessWidget {
  final int yardId;
  final double size;
  final double iconSize;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;
  final double opacity;
  final bool showBackground;

  const FavoriteButton({
    super.key,
    required this.yardId,
    this.size = 36,
    this.iconSize = 20,
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.opacity = 0.3,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => FavoriteService.to.toggleFavorite(yardId),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: showBackground
                // ignore: deprecated_member_use
                ? backgroundColor.withOpacity(opacity)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Obx(() {
              final isFavorite =
                  FavoriteService.to.favoriteStates.containsKey(yardId)
                      ? FavoriteService.to.favoriteStates[yardId]!.value
                      : false;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey<bool>(isFavorite),
                  color: isFavorite ? activeColor : inactiveColor,
                  size: iconSize,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
