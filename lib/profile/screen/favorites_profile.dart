import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/bottombar/bottom_controller.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/uitls/colors.dart';

class FavoritesScreen extends StatelessWidget {
  final bool fromProfile;
  FavoritesScreen({super.key, this.fromProfile = false});

  final FavoritesController controller = Get.find<FavoritesController>();

  @override
  Widget build(BuildContext context) { 
    return PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) {
    if (didPop) return;
    _goBack();
  },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white,size: 20.sp),
            onPressed:   _goBack,
          ),
          title:  Text(
            "My Favorites",
            style: TextStyle(color: Colors.white,fontSize: 20.sp),
          ),
        ),
        body: Obx(
          () {
            if (controller.favorites.isEmpty) {
              return  Center(
                child: Text(
                  "No Favorites yet",
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
              );
            }
      
            return GridView.builder(
              padding:  EdgeInsets.all(16.w),
              itemCount: controller.favorites.length,
              gridDelegate:
                   SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16.w,
                crossAxisSpacing: 16.r,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                return _favoriteCard(index);
              },
            );
          },
        ),
      ),
    );
  }
  void _goBack() {
    if (fromProfile) {
      // ✅ Opened from profile tab — just pop back to profile
      Get.back();
    } else {
      // ✅ Opened from bottom nav tab — switch to home tab
      Get.find<NavigationController>().changeTab(0);
    }
  }

  Widget _favoriteCard(int index) {
  final item = controller.favorites[index];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                item.image,
                height: 200.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 5.h,
              right: 5.w,
              child: GestureDetector(
                onTap: () {
                  controller.toggleFavorite(index);
                },
                child:  CircleAvatar(
                  radius: 10.r,
                  backgroundColor: Colors.black54,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 10.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

}
