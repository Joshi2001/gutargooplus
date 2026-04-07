import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/getx/view_all_controller.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:gutrgoopro/home/screen/details_screen.dart';

class ViewAllScreen extends StatelessWidget {
  final String title;

  const ViewAllScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final ViewAllController controller = Get.put(
      ViewAllController(),
      tag: title,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadSection(title);
    });

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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (controller.items.isEmpty) {
          return Center(
            child: Text(
              'No content available',
              style: TextStyle(color: Colors.white54, fontSize: 14.sp),
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 4.h,
            childAspectRatio: 0.55,
          ),
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final item = controller.items[index];
            final String imageUrl = item['image']?.toString() ?? '';

            return GestureDetector(
              onTap: () {
                // Rebuild full MovieModel so detail screen gets all data
                final MovieModel movie = MovieModel.fromLegacyMap(
                  Map<String, dynamic>.from(item),
                );
                Get.to(
                  () => VideoDetailScreen.fromModel(movie),
                  transition: Transition.fadeIn,
                );
              },
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    color: Colors.grey[900],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white54,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stack) {
                                  return Container(
                                    color: Colors.grey[850],
                                    child: Icon(
                                      Icons.movie,
                                      color: Colors.white30,
                                      size: 36.sp,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[850],
                                child: Icon(
                                  Icons.movie,
                                  color: Colors.white30,
                                  size: 36.sp,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item['title']?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}