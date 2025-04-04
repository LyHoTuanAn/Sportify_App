

// Welcome screen is no longer used - navigating directly to login
// class WelcomeView extends GetView<WelcomeController> {
//   const WelcomeView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               height: context.height * .4,
//               child: Center(
//                 child: PageView.builder(
//                   controller: controller.pageController,
//                   itemCount: controller.slides.length,
//                   onPageChanged: (index) {
//                     controller.indexPage.value = index;
//                   },
//                   itemBuilder: (BuildContext context, int index) {
//                     return ItemPage(slider: controller.slides[index]);
//                   },
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 vertical: 10,
//               ),
//               child: Obx(
//                 () => PageIndicators(
//                   numberIndicators: controller.slides.length,
//                   currentIndex: controller.indexPage.value,
//                 ),
//               ),
//             ),
//             Dimes.height30,
//             SizedBox(
//               width: 140,
//               child: AppButton(
//                 'SKIP',
//                 borderRadius: 100,
//                 onPressed: controller.changePage,
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ItemPage extends StatelessWidget {
//   const ItemPage({
//     super.key,
//     required this.slider,
//   });
//   final SlideModel slider;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: Image.asset(slider.image),
//         ),
//         Dimes.height40,
//         slider.title.text
//             .size(20)
//             .color(const Color(0xff00AB97))
//             .medium
//             .center
//             .make(),
//         Dimes.height10,
//         slider.subtitle.text.center.make().pSymmetric(h: context.height * .02),
//       ],
//     );
//   }
// }
