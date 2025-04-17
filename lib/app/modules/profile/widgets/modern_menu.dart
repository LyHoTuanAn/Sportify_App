import 'package:flutter/material.dart';

class ModernMenu extends StatelessWidget {
  final List<ModernMenuItem> items;
  final String title;
  final VoidCallback? onClose;

  const ModernMenu({
    super.key,
    required this.items,
    this.title = 'Menu',
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ...items.map((item) => _buildMenuItem(context, item)),
          // Version info at the bottom
          if (items.any((item) => item.isVersionInfo))
            _buildVersionInfo(
              items.firstWhere((item) => item.isVersionInfo).title,
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, ModernMenuItem item) {
    if (item.isVersionInfo) return const SizedBox.shrink();

    return InkWell(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withAlpha(50),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: item.iconBackgroundColor.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  item.icon,
                  color: item.iconBackgroundColor,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Arrow icon
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo(String version) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            version,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class ModernMenuItem {
  final String title;
  final IconData icon;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;
  final bool isVersionInfo;

  const ModernMenuItem({
    required this.title,
    required this.icon,
    this.iconBackgroundColor = Colors.blue,
    this.onTap,
    this.isVersionInfo = false,
  });
}

void showModernMenu(
  BuildContext context, {
  required List<ModernMenuItem> items,
  String title = '',
  Offset offset = const Offset(0, 50),
}) {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay =
      Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(offset, ancestor: overlay),
      button.localToGlobal(button.size.bottomRight(Offset.zero) + offset,
          ancestor: overlay),
    ),
    Offset.zero & overlay.size,
  );

  showMenu<void>(
    context: context,
    position: position,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.grey[200],
    items: [
      PopupMenuItem<void>(
        padding: EdgeInsets.zero,
        child: ModernMenu(
          title: title,
          items: items,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    ],
  );
}
