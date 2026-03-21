// import 'package:better_player_enhanced/better_player.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
// import 'package:screen_brightness/screen_brightness.dart';
// import 'package:volume_controller/volume_controller.dart';
// import 'dart:async';

// class VideoScreen extends StatefulWidget {
//   final String url;
//   final String? title;
//   const VideoScreen({super.key, required this.url, this.title});

//   @override
//   State<VideoScreen> createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> with TickerProviderStateMixin {
//   late BetterPlayerController _controller;
//   bool showControls = true;
//   bool isLocked = false;
//   bool isFit = true;
//   double brightness = 0.5;
//   double volume = 0.5;
//   bool showBrightnessIndicator = false;
//   bool showVolumeIndicator = false;
//   bool showForwardIndicator = false;
//   bool showBackwardIndicator = false;
//   bool isBuffering = false;
//   Timer? _hideTimer;
//   double _currentSliderValue = 0.0;
//   bool _isDraggingSlider = false;

//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
  
//   late AnimationController _seekAnimController;
//   late Animation<double> _seekScaleAnimation;

//   // Easter Egg variables
//   int _tapCount = 0;
//   Timer? _tapTimer;

//   @override
//   void initState() {
//     super.initState();
//     WakelockPlus.enable();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
    
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     );
    
//     _seekAnimController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );
//     _seekScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
//       CurvedAnimation(parent: _seekAnimController, curve: Curves.easeOut),
//     );
    
//     _initPlayer();
//     _initSystem();
//     _fadeController.forward();
//   }

//   Future<void> _initSystem() async {
//     try {
//       brightness = await ScreenBrightness().current;
//       volume = await VolumeController().getVolume();
//       VolumeController().showSystemUI = false;
//     } catch (e) {
//       debugPrint('Error initializing system: $e');
//     }
//   }

//   void _initPlayer() {
//     final dataSource = BetterPlayerDataSource(
//       BetterPlayerDataSourceType.network,
//       widget.url,
//       useAsmsTracks: true,
//       useAsmsSubtitles: true,
//       videoFormat: BetterPlayerVideoFormat.hls,
//     );

//     _controller = BetterPlayerController(
//       BetterPlayerConfiguration(
//         autoPlay: true,
//         fit: BoxFit.contain,
//         allowedScreenSleep: false,
//         autoDetectFullscreenDeviceOrientation: true,
//         controlsConfiguration: const BetterPlayerControlsConfiguration(
//           showControls: false,
//         ),
//       ),
//       betterPlayerDataSource: dataSource,
//     );

//     _controller.addEventsListener((event) {
//       if (event.betterPlayerEventType == BetterPlayerEventType.bufferingStart) {
//         setState(() => isBuffering = true);
//       } else if (event.betterPlayerEventType == BetterPlayerEventType.bufferingEnd) {
//         setState(() => isBuffering = false);
//       }
//     });

//     _hideControlsAfterDelay();
//   }

//   void _hideControlsAfterDelay() {
//     _hideTimer?.cancel();
//     _hideTimer = Timer(const Duration(seconds: 3), () {
//       if (!mounted) return;
//       if (_controller.isPlaying() == true && !isLocked && !_isDraggingSlider) {
//         setState(() => showControls = false);
//         _fadeController.reverse();
//       }
//     });
//   }

//   void _toggleControls() {
//     if (isLocked) return;
//     setState(() => showControls = !showControls);
//     if (showControls) {
//       _fadeController.forward();
//       _hideControlsAfterDelay();
//     } else {
//       _fadeController.reverse();
//     }
//   }

//   void _toggleFit() {
//     setState(() {
//       isFit = !isFit;
//       _controller.setOverriddenFit(isFit ? BoxFit.contain : BoxFit.cover);
//     });
//     _hideControlsAfterDelay();
//   }

//   void _toggleLock() {
//     setState(() {
//       isLocked = !isLocked;
//       if (isLocked) {
//         showControls = false;
//         _fadeController.reverse();
//       }
//     });
//   }

//   void _seekForward() {
//     final pos = _controller.videoPlayerController?.value.position;
//     if (pos != null) {
//       _controller.seekTo(pos + const Duration(seconds: 10));
//       setState(() => showForwardIndicator = true);
//       _seekAnimController.forward().then((_) => _seekAnimController.reverse());
//       Timer(const Duration(milliseconds: 600), () {
//         if (mounted) setState(() => showForwardIndicator = false);
//       });
//     }
//   }

//   void _seekBackward() {
//     final pos = _controller.videoPlayerController?.value.position;
//     if (pos != null) {
//       _controller.seekTo(pos - const Duration(seconds: 10));
//       setState(() => showBackwardIndicator = true);
//       _seekAnimController.forward().then((_) => _seekAnimController.reverse());
//       Timer(const Duration(milliseconds: 600), () {
//         if (mounted) setState(() => showBackwardIndicator = false);
//       });
//     }
//   }

//   void _handleVerticalDrag(DragUpdateDetails details) {
//     if (isLocked) return;

//     final screenWidth = MediaQuery.of(context).size.width;
//     final isLeftSide = details.localPosition.dx < screenWidth / 2;

//     if (isLeftSide) {
//       // Brightness control on left side
//       setState(() {
//         brightness -= details.delta.dy / 300;
//         brightness = brightness.clamp(0.0, 1.0);
//       });
//       ScreenBrightness().setScreenBrightness(brightness);
//       setState(() => showBrightnessIndicator = true);
//       _hideIndicator('brightness');
//     } else {
//       // Volume control on right side
//       setState(() {
//         volume -= details.delta.dy / 300;
//         volume = volume.clamp(0.0, 1.0);
//       });
//       VolumeController().setVolume(volume);
//       setState(() => showVolumeIndicator = true);
//       _hideIndicator('volume');
//     }
//   }

//   void _hideIndicator(String type) {
//     Timer(const Duration(milliseconds: 800), () {
//       if (!mounted) return;
//       setState(() {
//         if (type == 'brightness') {
//           showBrightnessIndicator = false;
//         } else {
//           showVolumeIndicator = false;
//         }
//       });
//     });
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     final seconds = duration.inSeconds.remainder(60);

//     if (hours > 0) {
//       return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
//     }
//     return '${twoDigits(minutes)}:${twoDigits(seconds)}';
//   }

//   // 🎉 EASTER EGG: Triple tap on title to activate!
//   void _handleTitleTap() {
//     _tapCount++;
    
//     _tapTimer?.cancel();
//     _tapTimer = Timer(const Duration(milliseconds: 500), () {
//       _tapCount = 0;
//     });

//     if (_tapCount == 3) {
//       _showEasterEgg();
//       _tapCount = 0;
//     }
//   }

//   void _showEasterEgg() {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         child: TweenAnimationBuilder<double>(
//           duration: const Duration(milliseconds: 400),
//           tween: Tween(begin: 0.0, end: 1.0),
//           builder: (context, value, child) {
//             return Transform.scale(
//               scale: value,
//               child: Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       const Color(0xFFE50914),
//                       const Color(0xFFB20710),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFFE50914).withOpacity(0.5),
//                       blurRadius: 30,
//                       spreadRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.celebration_rounded,
//                       color: Colors.white,
//                       size: 80,
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       '🎬 Secret Unlocked! 🎬',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 12),
//                     const Text(
//                       'You found the hidden feature!\n\n'
//                       '🎨 Built with passion by your dev team\n'
//                       '🚀 Now enjoy OTT-level playback!\n'
//                       '💡 Pro tip: Swipe left/right for brightness & volume',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         height: 1.6,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 24),
//                     ElevatedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: const Color(0xFFE50914),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 32,
//                           vertical: 12,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                       ),
//                       child: const Text(
//                         'Awesome! 🎉',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _hideTimer?.cancel();
//     _tapTimer?.cancel();
//     _fadeController.dispose();
//     _seekAnimController.dispose();
//     WakelockPlus.disable();
//     SystemChrome.setEnabledSystemUIMode(
//       SystemUiMode.manual,
//       overlays: SystemUiOverlay.values,
//     );
//     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//     VolumeController().showSystemUI = true;
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: GestureDetector(
//         onTap: _toggleControls,
//         onVerticalDragUpdate: _handleVerticalDrag,
//         child: Stack(
//           children: [
//             // Video Player
//             Center(child: BetterPlayer(controller: _controller)),

//             // Buffering Indicator
//             if (isBuffering && !showForwardIndicator && !showBackwardIndicator)
//               Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.7),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 3,
//                   ),
//                 ),
//               ),

//             // Double tap gesture zones
//             Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onDoubleTap: _seekBackward,
//                     child: Container(color: Colors.transparent),
//                   ),
//                 ),
//                 Expanded(
//                   child: GestureDetector(
//                     onDoubleTap: _seekForward,
//                     child: Container(color: Colors.transparent),
//                   ),
//                 ),
//               ],
//             ),

//             // Brightness Indicator
//             if (showBrightnessIndicator && !isLocked)
//               Positioned(
//                 left: 50,
//                 top: MediaQuery.of(context).size.height / 2 - 70,
//                 child: _buildIndicator(
//                   icon: brightness > 0.5 ? Icons.brightness_high : Icons.brightness_low,
//                   value: brightness,
//                 ),
//               ),

//             // Volume Indicator
//             if (showVolumeIndicator && !isLocked)
//               Positioned(
//                 right: 50,
//                 top: MediaQuery.of(context).size.height / 2 - 70,
//                 child: _buildIndicator(
//                   icon: volume > 0.5
//                       ? Icons.volume_up
//                       : volume > 0
//                           ? Icons.volume_down
//                           : Icons.volume_off,
//                   value: volume,
//                 ),
//               ),

//             // Seek Indicators with Animation
//             if (showForwardIndicator && !isLocked)
//               Center(
//                 child: ScaleTransition(
//                   scale: _seekScaleAnimation,
//                   child: _buildSeekIndicator(Icons.forward_10, '+10'),
//                 ),
//               ),
//             if (showBackwardIndicator && !isLocked)
//               Center(
//                 child: ScaleTransition(
//                   scale: _seekScaleAnimation,
//                   child: _buildSeekIndicator(Icons.replay_10, '-10'),
//                 ),
//               ),

//             // Controls with Fade Animation
//             if (showControls && !isLocked)
//               FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: _buildControls(),
//               ),

//             // Lock Button
//             if (isLocked) _buildLockButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildIndicator({required IconData icon, required double value}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.75),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: Colors.white, size: 32),
//           const SizedBox(height: 12),
//           Text(
//             '${(value * 100).toInt()}%',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 15,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             height: 100,
//             width: 4,
//             child: RotatedBox(
//               quarterTurns: 2,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(2),
//                 child: LinearProgressIndicator(
//                   value: value,
//                   backgroundColor: Colors.white.withOpacity(0.3),
//                   valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSeekIndicator(IconData icon, String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.75),
//         borderRadius: BorderRadius.circular(50),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: Colors.white, size: 36),
//           const SizedBox(width: 8),
//           Text(
//             text,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildControls() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.black.withOpacity(0.8),
//             Colors.transparent,
//             Colors.transparent,
//             Colors.black.withOpacity(0.8),
//           ],
//           stops: const [0.0, 0.2, 0.8, 1.0],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           _buildTopBar(),
//           _buildCenterPlayButton(),
//           _buildBottomControls(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTopBar() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
//       child: Row(
//         children: [
//           Material(
//             color: Colors.transparent,
//             child: GestureDetector(
//               // borderRadius: BorderRadius.circular(50),
//               onTap: () => Navigator.pop(context),
//               child: Container(
//                 padding: const EdgeInsets.all(10),
//                 child: const Icon(
//                   Icons.arrow_back_ios_new_rounded,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           if (widget.title != null)
//             Expanded(
//               child: GestureDetector(
//                 onTap: _handleTitleTap,
//                 child: Text(
//                   widget.title!,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ),
//           const Spacer(),
//           Material(
//             color: Colors.transparent,
//             child: GestureDetector(
//               // borderRadius: BorderRadius.circular(50),
//               onTap: _toggleLock,
//               child: Container(
//                 padding: const EdgeInsets.all(10),
//                 child: const Icon(
//                   Icons.lock_outline_rounded,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCenterPlayButton() {
//     return Center(
//       child: ValueListenableBuilder(
//         valueListenable: _controller.videoPlayerController!,
//         builder: (context, value, child) {
//           return Material(
//             color: Colors.transparent,
//             child: GestureDetector(
//               // borderRadius: BorderRadius.circular(50),
//               onTap: () {
//                 if (value.isPlaying) {
//                   _controller.pause();
//                 } else {
//                   _controller.play();
//                 }
//                 _hideControlsAfterDelay();
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.5),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   value.isPlaying
//                       ? Icons.pause_rounded
//                       : Icons.play_arrow_rounded,
//                   color: Colors.white,
//                   size: 56,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBottomControls() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(
//         children: [
//           _buildProgressBar(),
//           const SizedBox(height: 16),
//           _buildControlButtons(),
//         ],
//       ),
//     );
//   }

//   Widget _buildProgressBar() {
//     return ValueListenableBuilder(
//       valueListenable: _controller.videoPlayerController!,
//       builder: (context, value, child) {
//         final position = value.position;
//         final duration = value.duration ?? Duration.zero;
//         final progress = duration.inMilliseconds > 0
//             ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
//             : 0.0;

//         if (!_isDraggingSlider) {
//           _currentSliderValue = progress;
//         }

//         double bufferedProgress = 0.0;
//         if (value.buffered.isNotEmpty && duration.inMilliseconds > 0) {
//           final bufferedEnd = value.buffered.last.end.inMilliseconds;
//           bufferedProgress = (bufferedEnd / duration.inMilliseconds).clamp(0.0, 1.0);
//         }

//         return Row(
//           children: [
//             Text(
//               _formatDuration(position),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   return GestureDetector(
//                     onHorizontalDragStart: (details) {
//                       setState(() => _isDraggingSlider = true);
//                       _hideTimer?.cancel();
//                     },
//                     onHorizontalDragUpdate: (details) {
//                       final localPosition = details.localPosition.dx.clamp(0.0, constraints.maxWidth);
//                       final newProgress = (localPosition / constraints.maxWidth).clamp(0.0, 1.0);
//                       setState(() => _currentSliderValue = newProgress);
//                     },
//                     onHorizontalDragEnd: (details) {
//                       final newPosition = duration * _currentSliderValue;
//                       _controller.seekTo(newPosition);
//                       setState(() => _isDraggingSlider = false);
//                       _hideControlsAfterDelay();
//                     },
//                     onTapDown: (details) {
//                       final localPosition = details.localPosition.dx.clamp(0.0, constraints.maxWidth);
//                       final newProgress = (localPosition / constraints.maxWidth).clamp(0.0, 1.0);
//                       final newPosition = duration * newProgress;
//                       _controller.seekTo(newPosition);
//                       setState(() => _currentSliderValue = newProgress);
//                     },
//                     child: Container(
//                       height: 40,
//                       alignment: Alignment.center,
//                       child: Stack(
//                         alignment: Alignment.centerLeft,
//                         children: [
//                           // Background track
//                           Container(
//                             height: 4,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.3),
//                               borderRadius: BorderRadius.circular(2),
//                             ),
//                           ),
//                           // Buffered
//                           if (bufferedProgress > 0)
//                             FractionallySizedBox(
//                               widthFactor: bufferedProgress,
//                               child: Container(
//                                 height: 4,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.5),
//                                   borderRadius: BorderRadius.circular(2),
//                                 ),
//                               ),
//                             ),
//                           // Played
//                           FractionallySizedBox(
//                             widthFactor: _currentSliderValue,
//                             child: Container(
//                               height: 4,
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFE50914),
//                                 borderRadius: BorderRadius.circular(2),
//                               ),
//                             ),
//                           ),
//                           // Thumb with smooth animation
//                           AnimatedPositioned(
//                             duration: _isDraggingSlider 
//                                 ? Duration.zero 
//                                 : const Duration(milliseconds: 100),
//                             curve: Curves.easeOut,
//                             left: (constraints.maxWidth * _currentSliderValue) - 7,
//                             child: Container(
//                               width: 14,
//                               height: 14,
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFE50914),
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.3),
//                                     blurRadius: 4,
//                                     spreadRadius: 1,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               _formatDuration(duration),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildControlButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         // 10 sec backward button
//         _buildControlButton(
//           icon: Icons.replay_10_rounded,
//           label: '-10s',
//           onTap: _seekBackward,
//         ),
//         _buildControlButton(
//           icon: Icons.hd_rounded,
//           label: 'Quality',
//           onTap: _showQualityDialog,
//         ),
//         _buildControlButton(
//           icon: isFit ? Icons.fit_screen_rounded : Icons.zoom_out_map_rounded,
//           label: isFit ? 'Fit' : 'Fill',
//           onTap: _toggleFit,
//         ),
//         _buildControlButton(
//           icon: Icons.closed_caption_rounded,
//           label: 'Subtitles',
//           onTap: _showSubtitlesDialog,
//         ),
//         _buildControlButton(
//           icon: Icons.speed_rounded,
//           label: 'Speed',
//           onTap: _showPlaybackSpeedDialog,
//         ),
//         // 10 sec forward button
//         _buildControlButton(
//           icon: Icons.forward_10_rounded,
//           label: '+10s',
//           onTap: _seekForward,
//         ),
//       ],
//     );
//   }

//   Widget _buildControlButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: GestureDetector(
//         // borderRadius: BorderRadius.circular(8),
//         onTap: () {
//           onTap();
//           _hideControlsAfterDelay();
//         },
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, color: Colors.white, size: 26),
//               const SizedBox(height: 4),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLockButton() {
//     return Positioned(
//       left: 24,
//       top: MediaQuery.of(context).size.height / 2 - 28,
//       child: Material(
//         color: Colors.transparent,
//         child: GestureDetector(
//           // borderRadius: BorderRadius.circular(50),
//           onTap: _toggleLock,
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.7),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.lock_open_rounded,
//               color: Colors.white,
//               size: 28,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showQualityDialog() {
//     final tracks = _controller.betterPlayerAsmsTracks;
//     final currentTrack = _controller.betterPlayerAsmsTrack;

//     if (tracks.isEmpty) {
//       _showSnackBar('No quality options available');
//       return;
//     }

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) {
//         return Container(
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).size.height * 0.6,
//           ),
//           decoration: const BoxDecoration(
//             color: Color(0xFF1C1C1E),
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 margin: const EdgeInsets.only(top: 12),
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.hd_rounded, color: Colors.white, size: 24),
//                     const SizedBox(width: 12),
//                     const Text(
//                       'Video Quality',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const Spacer(),
//                     IconButton(
//                       icon: const Icon(Icons.close_rounded, color: Colors.white),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(color: Colors.white12, height: 1),
//               Flexible(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   itemCount: tracks.length,
//                   itemBuilder: (context, index) {
//                     final track = tracks[index];
//                     final isSelected = currentTrack?.id == track.id;
//                     final quality = _getQualityLabel(track);

//                     return Material(
//                       color: Colors.transparent,
//                       child: GestureDetector(
//                         onTap: () {
//                           _controller.setTrack(track);
//                           Navigator.pop(context);
//                           _showSnackBar('Quality changed to $quality');
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 24,
//                             vertical: 16,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isSelected ? const Color(0xFFE50914).withOpacity(0.1) : Colors.transparent,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 24,
//                                 height: 24,
//                                 decoration: BoxDecoration(
//                                   color: isSelected ? const Color(0xFFE50914) : Colors.transparent,
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: isSelected ? const Color(0xFFE50914) : Colors.white54,
//                                     width: 2,
//                                   ),
//                                 ),
//                                 child: isSelected
//                                     ? const Icon(
//                                         Icons.check_rounded,
//                                         color: Colors.white,
//                                         size: 16,
//                                       )
//                                     : null,
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       quality,
//                                       style: TextStyle(
//                                         color: isSelected ? const Color(0xFFE50914) : Colors.white,
//                                         fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                     if (track.bitrate != null)
//                                       Text(
//                                         '${(track.bitrate! / 1000000).toStringAsFixed(2)} Mbps',
//                                         style: TextStyle(
//                                           color: Colors.white.withOpacity(0.6),
//                                           fontSize: 13,
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showSubtitlesDialog() {
//     final subtitles = _controller.betterPlayerSubtitlesSourceList ;
//     final currentSubtitle = _controller.betterPlayerSubtitlesSource;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) {
//         return Container(
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).size.height * 0.6,
//           ),
//           decoration: const BoxDecoration(
//             color: Color(0xFF1C1C1E),
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 margin: const EdgeInsets.only(top: 12),
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.closed_caption_rounded, color: Colors.white, size: 24),
//                     const SizedBox(width: 12),
//                     const Text(
//                       'Subtitles & Audio',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const Spacer(),
//                     IconButton(
//                       icon: const Icon(Icons.close_rounded, color: Colors.white),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(color: Colors.white12, height: 1),
//               Material(
//                 color: Colors.transparent,
//                 child: GestureDetector(
//                   onTap: () {
//                     _controller.setupSubtitleSource(
//                       BetterPlayerSubtitlesSource(type: BetterPlayerSubtitlesSourceType.none),
//                     );
//                     Navigator.pop(context);
//                     _showSnackBar('Subtitles turned off');
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                     child: Row(
//                       children: [
//                         Icon(
//                           currentSubtitle == null ? Icons.check_circle_rounded : Icons.circle_outlined,
//                           color: currentSubtitle == null ? const Color(0xFFE50914) : Colors.white54,
//                           size: 24,
//                         ),
//                         const SizedBox(width: 16),
//                         Text(
//                           'Off',
//                           style: TextStyle(
//                             color: currentSubtitle == null ? const Color(0xFFE50914) : Colors.white,
//                             fontWeight: currentSubtitle == null ? FontWeight.bold : FontWeight.w500,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               if (subtitles.isNotEmpty)
//                 Flexible(
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     padding: const EdgeInsets.only(bottom: 16),
//                     itemCount: subtitles.length,
//                     itemBuilder: (context, index) {
//                       final subtitle = subtitles[index];
//                       final isSelected = currentSubtitle?.urls?.first == subtitle.urls?.first;
//                       final name = subtitle.name ?? 'Subtitle ${index + 1}';

//                       return Material(
//                         color: Colors.transparent,
//                         child: GestureDetector(
//                           onTap: () {
//                             _controller.setupSubtitleSource(subtitle);
//                             Navigator.pop(context);
//                             _showSnackBar('Subtitle: $name');
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 24,
//                               vertical: 16,
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
//                                   color: isSelected ? const Color(0xFFE50914) : Colors.white54,
//                                   size: 24,
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         name,
//                                         style: TextStyle(
//                                           color: isSelected ? const Color(0xFFE50914) : Colors.white,
//                                           fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                       if (subtitle.type != null)
//                                         Text(
//                                           subtitle.type.toString().split('.').last.toUpperCase(),
//                                           style: TextStyle(
//                                             color: Colors.white.withOpacity(0.6),
//                                             fontSize: 13,
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showPlaybackSpeedDialog() {
//     final speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
//     final currentSpeed = _controller.videoPlayerController?.value.speed ?? 1.0;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Color(0xFF1C1C1E),
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 margin: const EdgeInsets.only(top: 12),
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.speed_rounded, color: Colors.white, size: 24),
//                     const SizedBox(width: 12),
//                     const Text(
//                       'Playback Speed',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const Spacer(),
//                     IconButton(
//                       icon: const Icon(Icons.close_rounded, color: Colors.white),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(color: Colors.white12, height: 1),
//               ListView.builder(
//                 shrinkWrap: true,
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 itemCount: speeds.length,
//                 itemBuilder: (context, index) {
//                   final speed = speeds[index];
//                   final isSelected = (speed - currentSpeed).abs() < 0.01;

//                   return Material(
//                     color: Colors.transparent,
//                     child: GestureDetector(
//                       onTap: () {
//                         _controller.setSpeed(speed);
//                         Navigator.pop(context);
//                         _showSnackBar('Speed: ${speed}x');
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 16,
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
//                               color: isSelected ? const Color(0xFFE50914) : Colors.white54,
//                               size: 24,
//                             ),
//                             const SizedBox(width: 16),
//                             Text(
//                               speed == 1.0 ? 'Normal' : '${speed}x',
//                               style: TextStyle(
//                                 color: isSelected ? const Color(0xFFE50914) : Colors.white,
//                                 fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   String _getQualityLabel(BetterPlayerAsmsTrack track) {
//     if (track.height != null) {
//       return '${track.height}p';
//     } else if (track.bitrate != null) {
//       final bitrateMbps = track.bitrate! / 1000000;
//       if (bitrateMbps >= 4) return '1080p HD';
//       if (bitrateMbps >= 2) return '720p HD';
//       if (bitrateMbps >= 1) return '480p';
//       return '360p';
//     }
//     return 'Auto';
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.black87,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 2),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.all(20),
//       ),
//     );
//   }
// }