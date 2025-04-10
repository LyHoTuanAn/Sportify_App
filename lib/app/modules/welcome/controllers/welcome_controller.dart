// ignore: unused_import
import 'dart:async';
// ignore: unused_import
import 'package:get/get.dart';

// ignore: unused_import
import '../../../core/styles/style.dart';
// ignore: unused_import
import '../../../core/utilities/utilities.dart';
// ignore: unused_import
import '../../../routes/app_pages.dart';

// Welcome screen is no longer used - navigating directly to login
// class WelcomeController extends GetxController {
//   final RxInt indexPage = 0.obs;
//   Timer? _timer;
//   PageController pageController = PageController(initialPage: 0);
//   List<SlideModel> slides = [
//     SlideModel(
//       AppImage.welcome_1,
//       'Delivery Scheduled',
//       'Your pharmacy schedules your medication delivery',
//     ),
//     SlideModel(
//       AppImage.welcome_2,
//       'Get Notified',
//       'You get notified when your medication is en route',
//     ),
//     SlideModel(
//       AppImage.welcome_3,
//       'Tracking',
//       'Track your order and view order history',
//     ),
//   ];

//   @override
//   void onInit() {
//     _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
//       if (indexPage.value < 2) {
//         indexPage.value++;
//       } else {
//         indexPage.value = 0;
//       }
//       pageController.animateToPage(
//         indexPage.value,
//         duration: const Duration(milliseconds: 350),
//         curve: Curves.easeIn,
//       );
//     });
//     super.onInit();
//   }

//   void changePage() {
//     Get.offAllNamed(Routes.login);
//   }

//   @override
//   void onClose() => _timer?.cancel();
// }

// class SlideModel {
//   final String image, title, subtitle;
//   SlideModel(this.image, this.title, this.subtitle);
// }
