import 'package:get/get.dart';

import '../../../core/styles/style.dart';
import '../../../core/utilities/utilities.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Image.asset(AppImage.logo),
        ),
      ),
    );
  }
}
