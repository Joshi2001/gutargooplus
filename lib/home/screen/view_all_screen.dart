import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/getx/view_all_controller.dart';
import 'package:gutrgoopro/home/screen/details_screen.dart';

class ViewAllScreen extends StatelessWidget {
  final String title;

  const ViewAllScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final ViewAllController controller = Get.put(ViewAllController());
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 18.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => GridView.builder(
          // padding: EdgeInsets.all(12.w),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            // crossAxisSpacing: 10.w,
            // mainAxisSpacing: 12.h,
            childAspectRatio: 0.65,
          ),
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final item = controller.items[index];
    
            return GestureDetector(
              onTap: () {
                Get.to(
                  () => VideoDetailScreen(
                    videoTrailer: item['videoTrailer'],
                    videoMoives: item['videoMovies'] ?? item['videoTrailer'],
                    image: item['image'] ?? "",
                    subtitle: item['subtitle'] ?? "",
                    videoTitle: item['title'],
                    dis: item['dis'], logoImage: '',
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: Image.asset(
                        item['image'],
                        height: 160.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
    
  }
  
}