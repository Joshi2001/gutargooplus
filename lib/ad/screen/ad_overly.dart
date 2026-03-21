// import 'package:better_player_enhanced/better_player.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gutrgoopro/ad/controller/ad_controller.dart';
// import 'package:url_launcher/url_launcher.dart';

// class AdOverlayWidget extends StatelessWidget {
//   const AdOverlayWidget({super.key});

//   // ✅ GetView hatao — safe getter use karo
//   VastAdController? get _ctrl =>
//     Get.isRegistered<VastAdController>()
//         ? Get.find<VastAdController>()
//         : null;

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = _ctrl;
//     if (ctrl == null) return const SizedBox.shrink();

//   return Obx(() {
//   if (!Get.isRegistered<VastAdController>()) return const SizedBox.shrink();
//   final ctrl = _ctrl;
//   if (ctrl == null) return const SizedBox.shrink();
//   if (!ctrl.isAdVisible.value) return const SizedBox.shrink();

//       if (ctrl.adState.value == VastAdState.loading) {
//         return Positioned.fill(
//           child: Container(
//             color: Colors.black,
//             child: const Center(
//               child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
//             ),
//           ),
//         );
//       }

//       if (ctrl.adState.value == VastAdState.playing &&
//           ctrl.adPlayerController != null) {
//         return Positioned.fill(
//           child: Stack(children: [
//             // Ad Video
//             Positioned.fill(
//               child: GestureDetector(
//                 onTap: ctrl.onAdTap,
//                 child: BetterPlayer(controller: ctrl.adPlayerController!),
//               ),
//             ),

//             // Top progress bar
//             Positioned(
//               top: 0, left: 0, right: 0,
//               child: Obx(() => LinearProgressIndicator(
//                 value: ctrl.adProgress.value,
//                 backgroundColor: Colors.white24,
//                 valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
//                 minHeight: 3,
//               )),
//             ),

//             // Top bar: Ad badge + label + mute
//             Positioned(
//               top: 8, left: 10, right: 10,
//               child: Row(children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: Colors.black54,
//                     border: Border.all(color: Colors.white24),
//                     borderRadius: BorderRadius.circular(3),
//                   ),
//                   child: const Text('Ad',
//                       style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
//                 ),
//                 const SizedBox(width: 8),
//                 const Expanded(
//                   child: Text('Your video will play after the ad',
//                       style: TextStyle(color: Colors.white70, fontSize: 11),
//                       overflow: TextOverflow.ellipsis),
//                 ),
//                 Obx(() => GestureDetector(
//                   onTap: ctrl.toggleMute,
//                   child: Container(
//                     padding: const EdgeInsets.all(6),
//                     color: Colors.black45,
//                     child: Icon(
//                       ctrl.isMuted.value ? Icons.volume_off : Icons.volume_up,
//                       color: Colors.white, size: 18,
//                     ),
//                   ),
//                 )),
//               ]),
//             ),

//             // Bottom-left: Visit Site
//             Positioned(
//               bottom: 16, left: 12,
//               child: GestureDetector(
//                 onTap: ctrl.onAdTap,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.black54,
//                     borderRadius: BorderRadius.circular(4),
//                     border: Border.all(color: Colors.white24),
//                   ),
//                   child: const Text('Visit Site',
//                       style: TextStyle(color: Colors.white70, fontSize: 11)),
//                 ),
//               ),
//             ),

//             // Bottom-right: Skip button
//             Positioned(
//               bottom: 16, right: 12,
//               child: Obx(() {
//                 final model = ctrl.adModel.value;
//                 if (model == null) return const SizedBox.shrink();

//                 // Non-skippable ad — sirf countdown dikhao
//                 if (model.skipOffset < 0) {
//                   return _AdTimer(ctrl: ctrl);
//                 }

//                 // Skippable ad
//                 return ctrl.canSkip.value
//                     ? _SkipButton(onTap: ctrl.skipAd)
//                     : _SkipCountdown(ctrl: ctrl);
//               }),
//             ),

//             // Companion banner
//             Obx(() {
//               final companion = ctrl.adModel.value?.companionAd;
//               if (companion == null) return const SizedBox.shrink();
//               return Positioned(
//                 bottom: 0, left: 0, right: 0,
//                 child: GestureDetector(
//                   onTap: () {
//                     final url = companion.clickUrl;
//                     if (url != null && url.isNotEmpty) {
//                       launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//                     }
//                   },
//                   child: Image.network(companion.imageUrl,
//                       height: 52, width: double.infinity, fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => const SizedBox.shrink()),
//                 ),
//               );
//             }),
//           ]),
//         );
//       }

//       return const SizedBox.shrink();
//     });
//   }
// }

// // ── Skip button ──────────────────────────────────────────────────
// class _SkipButton extends StatelessWidget {
//   final VoidCallback onTap;
//   const _SkipButton({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.only(left: 16, right: 10, top: 10, bottom: 10),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.85),
//           border: Border.all(color: Colors.white38),
//         ),
//         child: const Row(mainAxisSize: MainAxisSize.min, children: [
//           Text('Skip Ad',
//               style: TextStyle(color: Colors.white, fontSize: 14,
//                   fontWeight: FontWeight.w600, letterSpacing: 0.3)),
//           SizedBox(width: 8),
//           Icon(Icons.skip_next, color: Colors.white, size: 20),
//         ]),
//       ),
//     );
//   }
// }

// // ── Skip countdown (skippable ad, skip se pehle) ─────────────────
// class _SkipCountdown extends StatelessWidget {
//   final VastAdController ctrl;
//   const _SkipCountdown({required this.ctrl});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final model = ctrl.adModel.value;
//       if (model == null) return const SizedBox.shrink();

//       // Skip kitne seconds baad — default 30
//       final skipAfter = model.skipOffset > 0 ? model.skipOffset : 30;
//       final elapsed   = model.duration - ctrl.countdown.value;
//       final remaining = (skipAfter - elapsed).clamp(0, skipAfter);
//       final progress  = (elapsed / skipAfter).clamp(0.0, 1.0);

//       return Container(
//         padding: const EdgeInsets.only(left: 16, right: 10, top: 10, bottom: 10),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.75),
//           border: Border.all(color: Colors.white24),
//         ),
//         child: Row(mainAxisSize: MainAxisSize.min, children: [
//           Text('Skip in $remaining',
//               style: const TextStyle(color: Colors.white70, fontSize: 14,
//                   fontWeight: FontWeight.w500)),
//           const SizedBox(width: 10),
//           SizedBox(
//             width: 20, height: 20,
//             child: CircularProgressIndicator(
//               value: progress,
//               strokeWidth: 2,
//               backgroundColor: Colors.white24,
//               valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
//             ),
//           ),
//         ]),
//       );
//     });
//   }
// }

// // ── Non-skippable ad timer ───────────────────────────────────────
// class _AdTimer extends StatelessWidget {
//   final VastAdController ctrl;
//   const _AdTimer({required this.ctrl});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.75),
//         border: Border.all(color: Colors.white24),
//         borderRadius: BorderRadius.circular(3),
//       ),
//       child: Text(
//         'Ad ends in ${ctrl.countdown.value}s',
//         style: const TextStyle(color: Colors.white70, fontSize: 12,
//             fontWeight: FontWeight.w500),
//       ),
//     ));
//   }
// }

// // // lib/ad/widgets/ad_overlay_widget.dart

// // import 'package:better_player_enhanced/better_player.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:gutrgoopro/ad/controller/ad_controller.dart';
// // import 'package:url_launcher/url_launcher.dart';

// // class AdOverlayWidget extends GetView<VastAdController> {
// //   const AdOverlayWidget({super.key});

// //   @override
// //   Widget build(BuildContext context) {
    
// //     return Obx(() {
// //       if (!controller.isAdVisible.value) return const SizedBox.shrink();

// //       // ── Loading ────────────────────────────────────────────────
// //       if (controller.adState.value == VastAdState.loading) {
// //         return Positioned.fill(
// //           child: Container(
// //             color: Colors.black,
// //             child: const Center(
// //               child: CircularProgressIndicator(
// //                 strokeWidth: 2,
// //                 color: Colors.white54,
// //               ),
// //             ),
// //           ),
// //         );
// //       }

// //       // ── Playing ────────────────────────────────────────────────
// //       if (controller.adState.value == VastAdState.playing &&
// //           controller.adPlayerController != null) {
// //         return Positioned.fill(
// //           child: Stack(
// //             children: [
// //               // ── Ad Video (BetterPlayer) ────────────────────────
// //               Positioned.fill(
// //                 child: GestureDetector(
// //                   onTap: controller.onAdTap,
// //                   child: BetterPlayer(
// //                     controller: controller.adPlayerController!,
// //                   ),
// //                 ),
// //               ),

// //               // ── Top progress bar (red thin line) ──────────────
// //               Positioned(
// //                 top: 0,
// //                 left: 0,
// //                 right: 0,
// //                 child: Obx(
// //                   () => LinearProgressIndicator(
// //                     value: controller.adProgress.value,
// //                     backgroundColor: Colors.white24,
// //                     valueColor: const AlwaysStoppedAnimation<Color>(
// //                       Colors.redAccent,
// //                     ),
// //                     minHeight: 3,
// //                   ),
// //                 ),
// //               ),

// //               // ── Top bar: Ad badge + label + mute ──────────────
// //               Positioned(
// //                 top: 8,
// //                 left: 10,
// //                 right: 10,
// //                 child: Row(
// //                   children: [
// //                     // AD badge
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 7,
// //                         vertical: 3,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: Colors.black54,
// //                         border: Border.all(color: Colors.white24),
// //                         borderRadius: BorderRadius.circular(3),
// //                       ),
// //                       child: const Text(
// //                         'Ad',
// //                         style: TextStyle(
// //                           color: Colors.white,
// //                           fontSize: 11,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),

// //                     // YouTube style label
// //                     const Text(
// //                       'Your video will play after the ad',
// //                       style: TextStyle(color: Colors.white70, fontSize: 11),
// //                     ),

// //                     const Spacer(),

// //                     // Mute button
// //                     Obx(
// //                       () => GestureDetector(
// //                         onTap: controller.toggleMute,
// //                         child: Container(
// //                           padding: const EdgeInsets.all(6),
// //                           color: Colors.black45,
// //                           child: Icon(
// //                             controller.isMuted.value
// //                                 ? Icons.volume_off
// //                                 : Icons.volume_up,
// //                             color: Colors.white,
// //                             size: 18,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               Positioned(
// //                 bottom: 16,
// //                 left: 12,
// //                 child: GestureDetector(
// //                   onTap: controller.onAdTap,
// //                   child: Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 10,
// //                       vertical: 6,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: Colors.black54,
// //                       borderRadius: BorderRadius.circular(4),
// //                       border: Border.all(color: Colors.white24),
// //                     ),
// //                     child: const Text(
// //                       'Visit Site',
// //                       style: TextStyle(color: Colors.white70, fontSize: 11),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               Positioned(
// //                 bottom: 16,
// //                 right: 12,
// //                 child: Obx(() {
// //                   final model = controller.adModel.value;
// //                   if (model == null) return const SizedBox.shrink();
// //                   if (model.skipOffset < 0) {
// //                     return _AdTimer(controller: controller);
// //                   }
// //                   return controller.canSkip.value
// //                       ? _SkipButton(onTap: controller.skipAd)
// //                       : _SkipCountdown();
// //                 }),
// //               ),
// //               Obx(() {
// //                 final companion = controller.adModel.value?.companionAd;
// //                 if (companion == null) return const SizedBox.shrink();
// //                 return Positioned(
// //                   bottom: 0,
// //                   left: 0,
// //                   right: 0,
// //                   child: GestureDetector(
// //                     onTap: () {
// //                       final url = companion.clickUrl;
// //                       if (url != null && url.isNotEmpty) {
// //                         launchUrl(
// //                           Uri.parse(url),
// //                           mode: LaunchMode.externalApplication,
// //                         );
// //                       }
// //                     },
// //                     child: Image.network(
// //                       companion.imageUrl,
// //                       height: 52,
// //                       width: double.infinity,
// //                       fit: BoxFit.cover,
// //                       errorBuilder: (_, __, ___) => const SizedBox.shrink(),
// //                     ),
// //                   ),
// //                 );
// //               }),
// //             ],
// //           ),
// //         );
// //       }

// //       return const SizedBox.shrink();
// //     });
// //   }
// // }

// // // Non-skippable ad ke liye sirf timer dikhao
// // class _AdTimer extends StatelessWidget {
// //   final VastAdController controller;
// //   const _AdTimer({required this.controller});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Obx(
// //       () => Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //         decoration: BoxDecoration(
// //           color: Colors.black.withOpacity(0.75),
// //           border: Border.all(color: Colors.white24),
// //           borderRadius: BorderRadius.circular(3),
// //         ),
// //         child: Text(
// //           'Ad ends in ${controller.countdown.value}s',
// //           style: const TextStyle(
// //             color: Colors.white70,
// //             fontSize: 12,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // ── Skip button (5s ke baad active) ─────────────────────────────
// // class _SkipButton extends StatelessWidget {
// //   final VoidCallback onTap;
// //   const _SkipButton({required this.onTap});

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.only(
// //           left: 16,
// //           right: 10,
// //           top: 10,
// //           bottom: 10,
// //         ),
// //         decoration: BoxDecoration(
// //           color: Colors.black.withOpacity(0.85),
// //           border: Border.all(color: Colors.white38),
// //         ),
// //         child: const Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Text(
// //               'Skip Ad',
// //               style: TextStyle(
// //                 color: Colors.white,
// //                 fontSize: 14,
// //                 fontWeight: FontWeight.w600,
// //                 letterSpacing: 0.3,
// //               ),
// //             ),
// //             SizedBox(width: 8),
// //             Icon(Icons.skip_next, color: Colors.white, size: 20),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _SkipCountdown extends StatelessWidget {
// //   late final VastAdController controller;
// //   @override
// //   Widget build(BuildContext context) {
// //     return Obx(() {
// //       final model = controller.adModel.value;
// //       if (model == null) return const SizedBox.shrink();

// //       final skipAfter = model.skipOffset > 0 ? model.skipOffset : 30;
// //       final elapsed = skipAfter - controller.countdown.value < 0
// //           ? 0
// //           : skipAfter -
// //                 (model.duration -
// //                     (model.duration -
// //                         (skipAfter -
// //                             (skipAfter - controller.countdown.value))));

// //       // Simple calculation:
// //       final secondsElapsed = model.duration - controller.countdown.value;
// //       final remaining = (skipAfter - secondsElapsed).clamp(0, skipAfter);

// //       return Container(
// //         padding: const EdgeInsets.only(
// //           left: 16,
// //           right: 10,
// //           top: 10,
// //           bottom: 10,
// //         ),
// //         decoration: BoxDecoration(
// //           color: Colors.black.withOpacity(0.75),
// //           border: Border.all(color: Colors.white24),
// //         ),
// //         child: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Text(
// //               'Skip in $remaining',
// //               style: const TextStyle(
// //                 color: Colors.white70,
// //                 fontSize: 14,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //             const SizedBox(width: 10),
// //             SizedBox(
// //               width: 20,
// //               height: 20,
// //               child: CircularProgressIndicator(
// //                 value: secondsElapsed / skipAfter, // ✅ skipAfter use karo
// //                 strokeWidth: 2,
// //                 backgroundColor: Colors.white24,
// //                 valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     });
// //   }
// // }
