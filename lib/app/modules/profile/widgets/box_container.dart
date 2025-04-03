part of 'widgets.dart';

class BoxContainer extends StatelessWidget {
  const BoxContainer({
    super.key,
    required this.child,
    this.isShowHeader = false,
    this.isShowDivider = true,
    this.isLoading = false,
    this.headerTitle = '',
    this.headerButtonTitle = '',
    this.headerButtonTap,
    this.headerButtonIcon,
    this.margin,
    this.padding,
  });

  final Widget child;
  final bool isShowHeader, isShowDivider, isLoading;
  final IconData? headerButtonIcon;
  final String headerTitle, headerButtonTitle;
  final VoidCallback? headerButtonTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: padding ?? const EdgeInsets.all(15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (isShowHeader) ...[
            Row(
              children: [
                headerTitle.text
                    .size(16)
                    .medium
                    .color(const Color(0xFF2B7A78))
                    .make()
                    .expand(),
                isLoading
                    ? const SizedBox(
                        height: 30,
                        width: 30,
                        child: Loading(padding: 0.0, strokeWidth: 2),
                      )
                    : Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: headerButtonTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            child: Row(
                              children: [
                                Icon(headerButtonIcon,
                                    color: const Color(0xFF2B7A78)),
                                Dimes.width5,
                                headerButtonTitle.text
                                    .color(const Color(0xFF2B7A78))
                                    .size(14)
                                    .medium
                                    .make(),
                              ],
                            ),
                          ),
                        ),
                      )
              ],
            ),
            if (isShowDivider) const Divider(height: 20)
          ],
          child,
        ],
      ),
    );
  }
}
