
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/getx/category_controller.dart';
import 'package:gutrgoopro/uitls/colors.dart';



class CricketScreen extends StatelessWidget {
  CricketScreen({super.key});

  final controller = Get.put(CricketController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
  onWillPop: () async {
    Get.back(); // ya apna logic
    return true;
  },
  child:
    Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 200,
        leading:  Row(
          children: [
            BackButton(color: Colors.white),
             Text("Cricket",style: TextStyle(color: AppColors.white,fontSize: 18,fontWeight: FontWeight.w800),)
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _liveNow(),
            const SizedBox(height: 12),
            _liveCard(controller),
            const SizedBox(height: 24),
            const Text(
              "All Videos",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _videoGrid(controller),
          ],
        ),
      ),
        )    );
  }
}

Widget _liveNow() {
  return const Row(
    children: [
      Icon(Icons.circle, color: Colors.red, size: 12),
      SizedBox(width: 8),
      Text("Live Now", style: TextStyle(color: Colors.white70, fontSize: 16)),
    ],
  );
}

Widget _liveCard(CricketController controller) {
  final live = controller.liveMatch;

  return Container(
    
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.blue.withOpacity(0.6)),
      gradient: LinearGradient(
        colors: [Colors.blue.withOpacity(0.15), Colors.transparent],
      ),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.asset(
                live["image"]!,
                height: 90,
                width: 140,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "LIVE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                live["title"]!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                live["subtitle"]!,
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: const StadiumBorder(),
                ),
                child: const Text("Watch Live"),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _videoGrid(CricketController controller) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: controller.videos.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.68,
    ),
    itemBuilder: (context, index) {
      final video = controller.videos[index];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  video["image"]!,
                  fit: BoxFit.cover,
                  height: 150,
                  width: 200,
                  // errorBuilder: (context, error, stackTrace) {
                  //   return Container(
                  //     color: Colors.grey,
                  //     child: const Icon(
                  //       Icons.broken_image,
                  //       color: Colors.white,
                  //     ),
                  //   );
                  // },
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    video["duration"]!,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            video["title"]!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            video["subtitle"]!,
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      );
    },
  );
}
