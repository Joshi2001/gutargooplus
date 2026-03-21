import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/bottombar/bottom_controller.dart';
import 'package:gutrgoopro/bottombar/bottom_screen.dart';
import 'package:gutrgoopro/home/screen/home_screen.dart';
import 'package:gutrgoopro/profile/screen/favorites_profile.dart';
import 'package:gutrgoopro/profile/screen/profile_screen.dart';
import 'package:gutrgoopro/search.dart/search_screen.dart';
import 'package:gutrgoopro/uitls/colors.dart';

class BottomNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const BottomNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<BottomNavigationScreen> createState() =>
      _BottomNavigationScreenState();
}
class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  late final NavigationController controller;
  DateTime? lastBackPressed;

  @override
  void initState() {
    super.initState();
    controller = Get.find<NavigationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.currentIndex.value = widget.initialIndex;
      }
    });
  }

  Future<void> _onWillPop() async {
    if (controller.currentIndex.value != 0) {
      controller.changeTab(0);
      return;
    }
    
    final now = DateTime.now();
    if (lastBackPressed == null || 
        now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
      lastBackPressed = now;
      Get.snackbar(
        '',
        'Press back again to exit',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
Widget build(BuildContext context) {
  return PopScope(
    canPop: false,
    onPopInvokedWithResult: (bool didPop, dynamic result) async {
      if (!didPop) {
        await _onWillPop();
      }
    },
    child: Obx(
      () => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.background,
        body: _buildBody(controller.currentIndex.value),  
        bottomNavigationBar: controller.showBottomNav.value
            ? CustomBottomNavigation(
                currentIndex: controller.currentIndex.value,
                onTap: controller.changeTab,
              )
            : null,
      ),
    ),
  );
}

Widget _buildBody(int index) {
  switch (index) {
    case 0: return HomeScreen();
    case 1: return SearchScreen(fromBottomNav: true);
    case 2: return FavoritesScreen(fromProfile: false);
    case 3: return ProfileScreen();
    default: return HomeScreen();
  }
}}