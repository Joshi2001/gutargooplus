import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/screen/details_screen.dart';
import 'dart:ui';
import 'package:gutrgoopro/profile/getx/download_controller.dart';
import 'package:gutrgoopro/profile/model/download_model.dart';
import 'package:gutrgoopro/uitls/colors.dart';

class DownloadsScreen extends StatelessWidget {
  DownloadsScreen({super.key});

  // Initialize controller only once
  final DownloadsController downloadsController = Get.put(DownloadsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Downloads",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(
        () {
          if (downloadsController.downloads.isEmpty) {
            return const Center(
              child: Text(
                "No downloads yet",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }
    
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _summaryCard(),
              const SizedBox(height: 16),
              ...List.generate(
                downloadsController.downloads.length,
                (index) => _downloadCard(
                  downloadsController.downloads[index],
                  index,
                ),
              ),
            ],
          );
        },
      ),
     );
  }

  /// Summary Card at top
  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blackCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.download_rounded, color: AppColors.blue),
          ),
          const SizedBox(width: 12),
          Text(
            "${downloadsController.downloads.length} Downloads",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Row(
            children: const [
              Icon(Icons.wifi, color: Colors.green, size: 18),
              SizedBox(width: 6),
              Text(
                "Offline Ready",
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Single download card
  Widget _downloadCard(DownloadItem item, int index) {
    return GestureDetector(
      onTap: () {
         Get.to(() => VideoDetailScreen(
            videoTrailer: item.videoTrailer,
            videoTitle: item.title,
            subtitle: item.subtitle,
            image: item.image, videoMoives: "", dis: '', logoImage: '',
          ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.blackCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Movie thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item.image,
                height: 130,
                width: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 70,
                  width: 110,
                  color: Colors.grey,
                  child: const Icon(Icons.broken_image, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white70),
              onPressed: () {
                _showDeleteDialog(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Delete Dialog (Sign-out popup style)
  void _showDeleteDialog(int index) {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              width: screenWidth * 0.85,
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0A2A4F).withOpacity(0.95),
                    const Color(0xFF000000).withOpacity(0.95),
                    const Color(0xFF2B0A3D).withOpacity(0.90),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFFF97316).withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF97316).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with gradient background
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.3),
                          Colors.red.withOpacity(0.2),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.red,
                        Colors.red[300]!,
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      "Delete Download",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.015),

                  // Content
                  const Text(
                    "Are you sure you want to delete this download?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Action Buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: GestureDetector(
                          // borderRadius: BorderRadius.circular(15),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.shade800,
                                  Colors.grey.shade900,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade700,
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.03),

                      // Delete Button
                      Expanded(
                        child: GestureDetector(
                          // borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            downloadsController.deleteItem(index);
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.red,
                                  Color(0xFFEF4444),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
