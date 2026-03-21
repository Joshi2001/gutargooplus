import 'package:better_player_enhanced/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:gutrgoopro/home/getx/details_controller.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/home/screen/video_screen.dart';
import 'package:gutrgoopro/profile/getx/download_controller.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/profile/model/download_model.dart';
import 'package:gutrgoopro/profile/model/favorite_model.dart';
import 'package:gutrgoopro/profile/screen/downloads_profile.dart';
import 'package:gutrgoopro/widget/trailer_full_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:gutrgoopro/navigation/route_observer.dart';

class VideoDetailScreen extends StatefulWidget {
  final String videoTrailer;
  final String videoMoives;
  final String image;
  final String subtitle;
  final String videoTitle;
  final String dis;
  final String logoImage;

  const VideoDetailScreen({
    Key? key,
    required this.videoTrailer,
    required this.videoMoives,
    required this.image,
    required this.subtitle,
    required this.videoTitle,
    required this.dis,
    required this.logoImage,
  }) : super(key: key);

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> with RouteAware {
  final DetailsController detailsController = Get.put(DetailsController());
  final HomeController homeController = Get.find<HomeController>();
  final FavoritesController favoritesController =
      Get.find<FavoritesController>();
  bool _isExpanded = false;
  final DownloadsController downloadsController = Get.find();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _createAndAttachController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      // DeviceOrientation.landscapeRight,
      // DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _createAndAttachController() {
    try {
      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.videoTrailer,
        videoFormat: BetterPlayerVideoFormat.hls,
        useAsmsTracks: true,
        useAsmsSubtitles: true,
      );

      betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          handleLifecycle: true,
          looping: false,
          aspectRatio: 16 / 9,
          fit: BoxFit.cover,
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            showControls: false,
          ),
        ),
        betterPlayerDataSource: dataSource,
      );

      _attachPlayerListeners();
    } catch (e) {
      debugPrint('Error creating BetterPlayerController: $e');
    }
  }

  BetterPlayerController? betterPlayerController;
  bool isVideoInitialized = false;
  String? errorMessage;

  bool showControls = true;
  bool isPlaying = false;
  bool isMuted = false;

  final isDownloaded = false.obs;
  final isShared = false.obs;
  final isLiked = false.obs;
  final isInMyList = false.obs;
  final isShare = false.obs;

  void _shareMovie() {
    Share.share(
      'Watch "${widget.videoTitle}" now!\n\n'
      'Genre: ${widget.subtitle}\n'
      'IMDB: 8.6 • U/A 16+\n\n'
      'Watch here: ${widget.videoMoives}',
      subject: 'Movie Recommendation',
    );
  }

  void toggleShareButton() async {
    isShared.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    isShared.value = false;
  }

  void toggleDownload() {
    isDownloaded.value = true;
  }

  void toggleFavorite() {
    isLiked.value = !isLiked.value;
    if (isLiked.value) {
      isShare.value = false;
    }
  }

  void toggleShare() {
    isShare.value = !isShare.value;
    if (isShare.value) {
      isLiked.value = false;
    }
  }


  void _attachPlayerListeners() {
    betterPlayerController?.addEventsListener((event) {
      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        switch (event.betterPlayerEventType) {
          case BetterPlayerEventType.initialized:
            setState(() {
              isVideoInitialized = true;
              isPlaying = true;
            });
            _hideControlsAfterDelay();
            break;

          case BetterPlayerEventType.play:
            setState(() => isPlaying = true);
            _hideControlsAfterDelay();
            break;

          case BetterPlayerEventType.pause:
            setState(() {
              isPlaying = false;
              showControls = true;
            });
            break;

          case BetterPlayerEventType.finished:
            setState(() {
              isPlaying = false;
              showControls = true;
            });
            break;

          case BetterPlayerEventType.exception:
            setState(() => errorMessage = "Video failed to load");
            break;

          default:
            break;
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPushNext() {
    // another route has been pushed on top of this one — dispose player
    try {
      WakelockPlus.disable();
    } catch (_) {}

    try {
      if (betterPlayerController?.isVideoInitialized() == true) {
        betterPlayerController?.pause();
      }
    } catch (_) {}

    try {
      betterPlayerController?.clearCache();
      betterPlayerController?.dispose();
      betterPlayerController = null;
    } catch (e) {
      debugPrint('Error disposing betterPlayerController in didPushNext: $e');
    }

    try {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } catch (_) {}
  }

  @override
  void didPopNext() {
    if (betterPlayerController == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          isVideoInitialized = false;
          errorMessage = null;
        });
        _createAndAttachController();
      });
    }
  }

  @override
  void deactivate() {
    try {
      if (betterPlayerController?.isVideoInitialized() == true) {
        betterPlayerController?.pause();
      }
    } catch (e) {
      debugPrint('Error pausing betterPlayerController on deactivate: $e');
    }
    super.deactivate();
  }

  void _togglePlayPause() {
    if (betterPlayerController?.isVideoInitialized() != true) return;

    setState(() {
      if (betterPlayerController?.isPlaying() == true) {
        betterPlayerController?.pause();
        isPlaying = false;
        showControls = true;
      } else {
        betterPlayerController?.play();
        isPlaying = true;
        _hideControlsAfterDelay();
      }
    });
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (isPlaying) {
        setState(() => showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => showControls = !showControls);
    if (showControls && betterPlayerController?.isPlaying() == true) {
      _hideControlsAfterDelay();
    }
  }
  
  void _handleBackPress() {
    if (!mounted) return;
    try {
      betterPlayerController?.pause();
    } catch (_) {}
    try {
      WakelockPlus.disable();
    } catch (_) {}
    Get.back();
    Future.delayed(const Duration(milliseconds: 300), () {
      try {
        betterPlayerController?.clearCache();
        betterPlayerController?.dispose();
        betterPlayerController = null;
      } catch (_) {}
      if (Get.isRegistered<DetailsController>()) {
        Get.delete<DetailsController>(force: true);
      }
    });
  }

  Widget _buildVideoPlayer() {
    if (errorMessage != null) {
      return SizedBox(
        height: 220.h,
        child: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (betterPlayerController == null || !isVideoInitialized) {
      return SizedBox(
        height: 220.h,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: BetterPlayer(controller: betterPlayerController!),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: _toggleControls,
            behavior: HitTestBehavior.translucent,
          ),
        ),
        if (showControls)
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36.sp,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // @override
  // void dispose() {
  //   try {
  //     routeObserver.unsubscribe(this);
  //   } catch (_) {}
  //   WakelockPlus.disable();
  //   SystemChrome.setEnabledSystemUIMode(
  //     SystemUiMode.manual,
  //     overlays: SystemUiOverlay.values,
  //   );

  //   // ✅ Safe dispose
  //   //    try {
  //   //   betterPlayerController.pause();
  //   // } catch (_) {}

  //   try {
  //     betterPlayerController?.pause();
  //     betterPlayerController?.clearCache();
  //     betterPlayerController?.dispose();
  //     betterPlayerController = null;
  //   } catch (_) {}
  //   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //   super.dispose();
  // }
  @override
  void dispose() {
    try {
      routeObserver.unsubscribe(this);
    } catch (_) {}
    try {
      WakelockPlus.disable();
    } catch (_) {}
    try {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } catch (_) {}
    try {
      betterPlayerController?.pause();
      betterPlayerController?.clearCache();
      betterPlayerController?.dispose();
      betterPlayerController = null;
    } catch (_) {}

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          betterPlayerController?.pause();
        } catch (_) {}
        try {
          WakelockPlus.disable();
        } catch (_) {}

        Future.delayed(const Duration(milliseconds: 300), () {
          try {
            betterPlayerController?.clearCache();
            betterPlayerController?.dispose();
            betterPlayerController = null;
          } catch (_) {}
          if (Get.isRegistered<DetailsController>()) {
            Get.delete<DetailsController>(force: true);
          }
        });

        return true;
      },

      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(children: [

                    ],),
                    Column(children: [

                    ],),
                    _buildVideoPlayer(),
                    Padding(
                      padding: EdgeInsets.only(
                        right: 20.w,
                        left: 14.w,
                        top: 10.h,
                      ),
                      child: widget.logoImage.isNotEmpty
                          ? Image.asset(widget.logoImage)
                          : Text(
                              widget.videoTitle,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    _buildInfoSection(),
                    SizedBox(height: 24.h),
                    _buildWatchButton(),
                    SizedBox(height: 8.h),
                    // _buildDownloadButton(),
                    // SizedBox(height: 16.h),
                    _buildDescription(),
                    SizedBox(height: 10.h),
                    _buildActionButtons(),
                    SizedBox(height: 32.h),
                    // _buildCastCrew(),
                    // SizedBox(height: 10.h), 
                    _buildExploreMore(),
                    SizedBox(height: 24.h),
                    _trendingSection(homeController),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
              _buildTopBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: -40,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: 50.h,
          left: 10.w,
          right: 16.w,
          bottom: 16.h,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
              onPressed: _handleBackPress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'IMDB 8.6',
                style: TextStyle(
                  color: const Color(0xFFFFA500),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 4.w),
              Container(
                width: 4.w,
                height: 4.h,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                widget.subtitle,
                style: TextStyle(color: Colors.grey, fontSize: 10.sp),
              ),
              SizedBox(width: 4.w),
              Container(
                width: 4.w,
                height: 4.h,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                'U/A 16+',
                style: TextStyle(color: Colors.grey, fontSize: 10.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

//   Widget _buildDownloadButton() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w),
//       child: Obx(() {
//         final isDownloaded = downloadsController.isDownloaded(
//           widget.videoMoives,
//         );
//         return GestureDetector(
//          onTap: () {
//   if (!isDownloaded) {
//     downloadsController.addDownload(
//       DownloadItem(
//         title: widget.videoTitle,
//         subtitle: widget.subtitle,
//         image: widget.image,
//         videoTrailer: widget.videoMoives,
//       ),
//     );
//     Get.to(() => DownloadsScreen());
//   } else {
//     Get.to(() => DownloadsScreen());
//   }
// },
//           child: Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(vertical: 8.h),
//             decoration: BoxDecoration(
//               color: isDownloaded ? Colors.red.shade900 : Colors.grey.shade800,
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   isDownloaded ? Icons.check_circle : Icons.download_outlined,
//                   color: Colors.white,
//                   size: 20.sp,
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(
//                   isDownloaded ? 'Downloaded' : 'Download',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

  Widget _buildWatchButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onTap: () {
         Get.to(
  () => VideoScreen(
    url: widget.videoMoives,
    title: widget.videoTitle,
    image: widget.image,
    vastTagUrl: 'https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&impl=s&correlator=',
  ),
);
        },
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
              Color(0xFF9e1119),
               Color(0xFFdf4119),
               Color(0xFF9e1119)
                // Color.fromARGB(255, 179, 5, 5),
                // Color.fromARGB(255, 240, 60, 60),
                // Color.fromARGB(255, 189, 8, 8),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, color: Colors.white, size: 20.sp),
              SizedBox(width: 4.w),
              Text(
                'Play',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    final bool isLongText = widget.dis.length > 100;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.dis,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade400),
            maxLines: _isExpanded ? null : 3,
            overflow: _isExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
          ),

          if (isLongText)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  _isExpanded ? "Read Less" : "Read More",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            imagePath: "assets/t.png",
            label: 'Trailer',
            onTap: () {
              Get.to(
                () => TrailerFullScreen(url: widget.videoTrailer),
                transition: Transition.fadeIn,
              );
            },
            color: Colors.white,
          ),
          Obx(
            () => _buildActionButton(
              icon: isLiked.value ? Icons.thumb_up : Icons.thumb_up_outlined,
              label: 'Rate',
              onTap: toggleFavorite,
              color: isLiked.value ? Colors.red : Colors.white,
            ),
          ),
          // Obx(() => _buildActionButton(
          //       icon: isShare.value
          //           ? Icons.thumb_down
          //           : Icons.thumb_down_outlined,
          //       label: 'Not for Me',
          //       onTap: toggleShare,
          //       color: isShare.value ? Colors.red : Colors.white,
          //     )),
          Obx(() {
            final inMyList = favoritesController.isInMyList(widget.videoTrailer);
            return _buildActionButton(
              icon: inMyList ? Icons.check_circle : Icons.add_outlined,
              label: 'Save',
              onTap: () {
                if (inMyList) {
                  favoritesController.removeByvideoTrailer(widget.videoTrailer);
                } else {
                  favoritesController.addFavorite(
                    FavoriteItem(
                      title: widget.videoTitle,
                      image: widget.image,
                      videoTrailer: widget.videoTrailer,
                      subtitle: widget.subtitle,
                    ),
                  );
                }
              },
              color: inMyList ? Colors.red : Colors.white,
            );
          }),

          Obx(
            () => _buildActionButton(
              icon: Icons.share,
              label: 'Share',
              onTap: () async {
                _shareMovie();
                isShared.value = true;
                await Future.delayed(const Duration(milliseconds: 300));
                isShared.value = false;
              },
              color: isShared.value ? Colors.red : Colors.white,
            ),
          ),
          // Obx(() {
          //   final isDownloaded =
          //       downloadsController.isDownloaded(widget.videoMoives);
          //   return _buildActionButton(
          //     icon: isDownloaded
          //         ? Icons.check_circle
          //         : Icons.download_outlined,
          //     label: 'Download',
          //     onTap: () {
          //       if (!isDownloaded) {
          //         downloadsController.addDownload(
          //           DownloadItem(
          //             title: widget.videoTitle,
          //             subtitle: widget.subtitle,
          //             image: widget.image,
          //             videoTrailer: widget.videoMoives,
          //           ),
          //         );
          //       }
          //     },
          //    color: isDownloaded ? Colors.red : Colors.white,
          //   );
          // }),
        ],
      ),
    );
  }

  // Widget _buildActionButton({
  //   required IconData icon,
  //   required String label,
  //   required VoidCallback onTap,
  //   required Color colors,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Column(
  //       children: [
  //         Icon(icon, color: colors, size: 20.sp),
  //         SizedBox(height: 4.h),
  //         Text(
  //           label,
  //           style: TextStyle(fontSize: 11.sp, color: colors),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildActionButton({
    IconData? icon,
    String? imagePath,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    final double iconSize = 16.sp;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath,
                width: 26.w,
                height: 18.h,
                fit: BoxFit.fill,
                color: color,
              )
            else
              Icon(icon, color: color, size: iconSize),
            SizedBox(width: imagePath != null ? 0.w : 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCastCrew() {
    return Padding(
      padding: EdgeInsets.only(left: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cast & Crew",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 120.h,
            child: Obx(() {
              final castList = detailsController.castList;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: castList.length,
                separatorBuilder: (_, __) => SizedBox(width: 14.w),
                itemBuilder: (context, index) {
                  final item = castList[index];

                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 40.r,
                        backgroundColor: Colors.grey.shade800,
                        child: ClipOval(
                          child: Image.asset(
                            item['image'] ?? '',
                            fit: BoxFit.cover,
                            width: 70.w,
                            height: 70.h,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30.sp,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      SizedBox(
                        width: 70.w,
                        child: Text(
                          item['name']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item['role']!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreMore() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Explore More',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendingSection(HomeController controller) {
    return controller.trendingList.isEmpty
        ? SizedBox(
            height: 260.h,
            child: const Center(
              child: Text(
                "No Trending Data",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        : SizedBox(
            height: 260.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 15.w),
              itemCount: controller.trendingList.length,
              itemBuilder: (context, index) {
                final item = controller.trendingList[index];

                return GestureDetector(
                  onTap: () {
                    try {
                      betterPlayerController?.pause();
                    } catch (_) {}
                    try {
                      betterPlayerController?.clearCache();
                      betterPlayerController?.dispose();
                      betterPlayerController = null;
                    } catch (_) {}

                    if (Get.isRegistered<DetailsController>()) {
                      Get.delete<DetailsController>(force: true);
                    }
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (_, __, ___) => VideoDetailScreen(
                          key: ValueKey('video_${item['videoTrailer']}'),
                          videoTrailer: item['videoTrailer']?.toString() ?? '',
                          videoMoives:
                              item['videoMovies']?.toString() ??
                              item['videoTrailer']?.toString() ??
                              '',
                          image: item['image']?.toString() ?? '',
                          subtitle: item['subtitle']?.toString() ?? '',
                          videoTitle: item['title']?.toString() ?? 'Untitled',
                          dis: item['dis']?.toString() ?? '',
                          logoImage: '',
                        ),
                        transitionsBuilder: (_, animation, __, child) =>
                            FadeTransition(opacity: animation, child: child),
                      ),
                    );
                  },
                  child: Container(
                    width: 100.w,
                    margin: EdgeInsets.only(right: 10.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: Image.asset(
                            item['image']?.toString() ?? '',
                            height: 170.h,
                            width: 100.w,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 170.h,
                                width: 100.w,
                                color: Colors.grey,
                                child: Icon(
                                  Icons.error,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }
}
