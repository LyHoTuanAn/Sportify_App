part of '../modules/profile/widgets/widgets.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.avatar, this.size = 100});
  final String? avatar;
  ProfileController get ctr => Get.find();
  final double size;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          GestureDetector(
            onTap: ctr.changeAvatar,
            child: AvatarCustom(
              width: size,
              avatar: avatar,
              padding: 2,
              bg: Colors.white,
              color: AppTheme.primary,
              isShadow: true,
              child: avatar == null
                  ? Image.asset(
                      AppImage.camera,
                      width: 40,
                      color: AppTheme.primary,
                    ).centered()
                  : null,
            ),
          ),
          Align(
            alignment:
                size == 100 ? Alignment.bottomRight : const Alignment(1.0, .8),
            child: const _ButtonChangeAvatar(),
          )
        ],
      ),
    );
  }
}

class _ButtonChangeAvatar extends StatelessWidget {
  // ignore: use_super_parameters
  const _ButtonChangeAvatar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: Get.find<ProfileController>().changeAvatar,
      child: CircleAvatar(
        radius: 15,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: CircleAvatar(
            backgroundColor: AppTheme.secondary,
            child: Image.asset(
              AppImage.edit,
              color: Colors.white,
              width: 14,
            ),
          ),
        ),
      ),
    );
  }
}
