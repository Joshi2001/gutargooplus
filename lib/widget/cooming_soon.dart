// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/src/extension_navigation.dart';

// void _showComingSoonDialog(String title, String subtitle) {
//     showDialog(
//       context: Get.context!,
//       barrierColor: Colors.black.withOpacity(0.5),
//       builder: (_) => BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Dialog(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           child: Container(
//             width: 0.8.sw,
//             padding: EdgeInsets.all(24.sp),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   // _getCurrentColor().withOpacity(0.95),
//                   Colors.black.withOpacity(0.95),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.grey.shade700),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(title,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 12),
//                 Text(subtitle,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Colors.grey.shade400, fontSize: 12.sp)),
//                 const SizedBox(height: 24),
//                 GestureDetector(
//                   onTap: () => Navigator.pop(Get.context!),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 40, vertical: 12),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(colors: [
//                         Colors.grey.shade800,
//                         Colors.grey.shade900,
//                       ]),
//                       borderRadius: BorderRadius.circular(25),
//                       border: Border.all(color: Colors.grey.shade600),
//                     ),
//                     child: const Text('OK',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }