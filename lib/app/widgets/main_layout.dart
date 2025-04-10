import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final _navigatorKey = GlobalKey<NavigatorState>();

  MainLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  void _onItemTapped(int index) {
    if (index != currentIndex) {
      String route = '';
      switch (index) {
        case 0:
          route = '/home';
          break;
        case 1:
          route = '/list';
          break;
        case 2:
          route = '/outstanding';
          break;
        case 3:
          route = '/profile';
          break;
      }
      Get.offNamed(
        route,
        preventDuplicates: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (_navigatorKey.currentState?.canPop() ?? false) {
          _navigatorKey.currentState?.pop();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Navigator(
          key: _navigatorKey,
          onGenerateRoute: (settings) {
            return GetPageRoute(
              routeName: settings.name,
              page: () => child,
              transition: Transition.noTransition,
            );
          },
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: currentIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
} 