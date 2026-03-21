// import 'package:better_player_enhanced/better_player.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:gutrgoopro/home/getx/home_controller.dart';
// import 'package:gutrgoopro/home/screen/fullscreen_player.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// class NewVideoDetailScreen extends StatefulWidget {
//   final String videoTrailer;
//   final String subtitle;
//   final String videoTitle;
//   final String image;
//   final String videoMoives;
//   final String dis;

//   const NewVideoDetailScreen({
//     Key? key,
//     required this.videoTrailer,
//     required this.subtitle,
//     required this.image,
//     required this.videoTitle,
//     required this.videoMoives,
//     required this.dis,
//   }) : super(key: key);

//   @override
//   State<NewVideoDetailScreen> createState() => _NewVideoDetailScreenState();
// }

// class _NewVideoDetailScreenState extends State<NewVideoDetailScreen> {
//   final HomeController homeController = Get.find<HomeController>();

//   late BetterPlayerController _playerController;
//   bool isVideoInitialized = false;
//   bool showPlayButton = true;

//   @override
//   void initState() {
//     super.initState();
//     WakelockPlus.enable();
//     _initializePlayer();
//   }

//   void _initializePlayer() {
//     _playerController = BetterPlayerController(
//       BetterPlayerConfiguration(
//         autoPlay: false,
//         looping: false,
//         fit: BoxFit.cover,
//         aspectRatio: 16 / 9,
//         allowedScreenSleep: false,
//         controlsConfiguration: const BetterPlayerControlsConfiguration(
//           showControls: false,
//         ),
//       ),
//       betterPlayerDataSource: BetterPlayerDataSource(
//         BetterPlayerDataSourceType.network,
//         widget.videoTrailer,
//         videoFormat: BetterPlayerVideoFormat.hls,
//         useAsmsTracks: true,
//         useAsmsSubtitles: true,
//       ),
//     );

//     _playerController.addEventsListener((event) {
//       if (!mounted) return;

//       if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
//         setState(() {
//           isVideoInitialized = true;
//         });
//       } else if (event.betterPlayerEventType == BetterPlayerEventType.play) {
//         setState(() {
//           showPlayButton = false;
//         });
//       } else if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
//         setState(() {
//           showPlayButton = true;
//         });
//       }
//     });
//   }

//   void _openFullscreenPlayer() {
//     // Pause current player
//     if (_playerController.isPlaying() == true) {
//       _playerController.pause();
//     }

//     // Navigate to fullscreen player
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FullscreenPlayerScreen(
//           url: widget.videoMoives,
//           title: widget.videoTitle,
//           subtitle: widget.subtitle,
//         ),
//       ),
//     ).then((_) {
//       // Resume if needed when coming back
//       SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//     });
//   }

//   @override
//   void dispose() {
//     _playerController.dispose();
//     WakelockPlus.disable();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Video Player Section
//               _buildVideoPlayerSection(),

//               SizedBox(height: 16.h),

//               // Title
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16.w),
//                 child: Text(
//                   widget.videoTitle,
//                   style: TextStyle(
//                     fontSize: 20.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),

//               SizedBox(height: 8.h),

//               // Subtitle
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16.w),
//                 child: Text(
//                   widget.subtitle,
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: Colors.grey[400],
//                   ),
//                 ),
//               ),

//               SizedBox(height: 24.h),

//               // Similar Videos Section
//               _buildSimilarVideosSection(),

//               SizedBox(height: 40.h),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVideoPlayerSection() {
//     return Stack(
//       children: [
//         // Video Player
//         Container(
//           height: 220.h,
//           width: double.infinity,
//           color: Colors.black,
//           child: isVideoInitialized
//               ? BetterPlayer(controller: _playerController)
//               : const Center(
//                   child: CircularProgressIndicator(
//                     color: Colors.red,
//                   ),
//                 ),
//         ),

//         // Overlay with controls
//         if (isVideoInitialized)
//           Positioned.fill(
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   if (_playerController.isPlaying() == true) {
//                     _playerController.pause();
//                   } else {
//                     _playerController.play();
//                   }
//                 });
//               },
//               child: Container(
//                 color: Colors.transparent,
//               ),
//             ),
//           ),

//         // Play Button
//         if (showPlayButton && isVideoInitialized)
//           Positioned.fill(
//             child: Center(
//               child: GestureDetector(
//                 onTap: () {
//                   _playerController.play();
//                 },
//                 child: Container(
//                   padding: EdgeInsets.all(16.w),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.6),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.play_arrow,
//                     color: Colors.white,
//                     size: 40.sp,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//         // Top Gradient with Back Button
//         Positioned(
//           top: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.black.withOpacity(0.7),
//                   Colors.transparent,
//                 ],
//               ),
//             ),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // Fullscreen Button
//         Positioned(
//           bottom: 12.h,
//           right: 12.w,
//           child: GestureDetector(
//             onTap: _openFullscreenPlayer,
//             child: Container(
//               padding: EdgeInsets.all(10.w),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.7),
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//               child: Icon(
//                 Icons.fullscreen,
//                 color: Colors.white,
//                 size: 24.sp,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSimilarVideosSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.w),
//           child: Text(
//             'Similar Videos',
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         SizedBox(height: 16.h),
//         homeController.trendingList.isEmpty
//             ? SizedBox(
//                 height: 200.h,
//                 child: Center(
//                   child: Text(
//                     "No Similar Videos",
//                     style: TextStyle(color: Colors.grey, fontSize: 14.sp),
//                   ),
//                 ),
//               )
//             : SizedBox(
//                 height: 200.h,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   padding: EdgeInsets.only(left: 16.w),
//                   itemCount: homeController.trendingList.length,
//                   itemBuilder: (context, index) {
//                     final item = homeController.trendingList[index];

//                     return GestureDetector(
//                       onTap: () {
//                         // Stop current video
//                         if (_playerController.isVideoInitialized() == true) {
//                           _playerController.pause();
//                         }

//                         // Navigate to new video
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => NewVideoDetailScreen(
//                               videoTrailer: item['videoTrailer']?.toString() ?? '',
//                               videoMoives: item['videoMovies']?.toString() ??
//                                   item['videoTrailer']?.toString() ??
//                                   '',
//                               image: item['image']?.toString() ?? '',
//                               subtitle: item['subtitle']?.toString() ?? '',
//                               videoTitle: item['title']?.toString() ?? 'Untitled',
//                               dis: item['dis']?.toString() ?? '',
//                             ),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         width: 120.w,
//                         margin: EdgeInsets.only(right: 12.w),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(8.r),
//                               child: Image.asset(
//                                 item['image']?.toString() ?? '',
//                                 height: 160.h,
//                                 width: 120.w,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return Container(
//                                     height: 160.h,
//                                     width: 120.w,
//                                     color: Colors.grey[800],
//                                     child: Icon(
//                                       Icons.error,
//                                       color: Colors.grey,
//                                       size: 32.sp,
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                             SizedBox(height: 6.h),
//                             Text(
//                               item['title']?.toString() ?? '',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12.sp,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//       ],
//     );
//   }
// }