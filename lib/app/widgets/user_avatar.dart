import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

import '../core/styles/style.dart';
import '../modules/profile/controllers/profile_controller.dart';

class UserAvatar extends GetView<ProfileController> {
  const UserAvatar({
    super.key,
    this.width = 33,
    this.isShadow = false,
    this.padding = 0,
  });
  final double width, padding;
  final bool isShadow;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AvatarCustom(
        avatar: controller.user.value?.avatar,
        width: width,
        isShadow: isShadow,
        padding: padding,
      ),
    );
  }
}

class AvatarCustom extends StatelessWidget {
  const AvatarCustom({
    super.key,
    this.avatar,
    this.width = 33,
    this.bg,
    this.color,
    this.padding = 0,
    this.isShadow = false,
    this.child,
  });
  final Widget? child;
  final String? avatar;
  final double width, padding;
  final Color? bg, color;
  final bool isShadow;
  @override
  Widget build(BuildContext context) {
    return VxCircle(
      customDecoration: isShadow
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4,
                )
              ],
              shape: BoxShape.circle,
              color: bg ?? Colors.white,
            )
          : null,
      backgroundColor: bg ?? context.primaryColor,
      radius: width,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: child ??
            (avatar == null || avatar!.isEmpty
                ? Icon(Icons.person, color: color ?? Colors.white)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: avatar!,
                      errorWidget: (_, item, child) => Icon(
                        Icons.person,
                        color: color ?? Colors.white,
                        size: width * .4,
                      ),
                      fit: BoxFit.cover,
                    ),
                  )),
      ),
    );
  }
}
