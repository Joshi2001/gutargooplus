import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxBool showBottomNav = true.obs;
  DateTime? lastBackPressed;

  void changeTab(int index) {
    currentIndex.value = index;
  }
  
  void setInitialIndex(int index) {
    currentIndex.value = index;
  }

  // ✅ Handle back button
  Future<bool> handleBackPress() async {
    if (currentIndex.value != 0) {
      // Go to home
      changeTab(0);
      return false;
    } else {
      // Double back press to exit
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
        );
        return false;
      }
      SystemNavigator.pop();
      return true;
    }
  }
  Future<bool> showExitDialog() async {
    if (currentIndex.value != 0) {
      changeTab(0);
      return false;
    }
    
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Exit App',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Kya aap app se bahar nikalna chahte hain?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
              SystemNavigator.pop();
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}