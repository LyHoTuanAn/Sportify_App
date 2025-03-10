import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/widgets.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: controller.pages,
      )),
      bottomNavigationBar: Obx(() => BottomNavBar(
        currentIndex: controller.currentIndex.value,
        onTap: (index) => controller.changePage(index),
      )),
    );
  }
}
