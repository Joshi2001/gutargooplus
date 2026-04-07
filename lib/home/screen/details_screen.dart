import 'package:better_player_enhanced/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:gutrgoopro/home/screen/cast.dart';
import 'package:gutrgoopro/profile/getx/download_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:gutrgoopro/home/getx/details_controller.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/home/screen/video_screen.dart';
import 'package:gutrgoopro/navigation/route_observer.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/profile/model/favorite_model.dart';
import 'package:gutrgoopro/widget/trailer_full_screen.dart';
import 'package:gutrgoopro/home/model/banner_model.dart';

class VideoDetailScreen extends StatefulWidget {
  final String videoTrailer;
  final String videoMoives;
  final String image;
  final String? videoId;
  final String subtitle;
  final String videoTitle;
  final String dis;
  final String logoImage;
  final double imdbRating;
  final String ageRating;
  final String directorInfo;
  final String castInfo;
  final String tagline;
  final String fullStoryline;
  final List<String> genres;
  final List<String> tags;
  final String language;
  final int duration;
  final int releaseYear;
  final String budget;
  final String awardsAndNominations;
  final String videoQuality;
  final String audioFormat;
  final bool publishStatus;
  final bool subscriptionRequired;
  final bool enableAds;
  final bool allowDownloads;
  final bool featuredMovie;
  final String contentVendor;
  final int viewCount;
  final String mp4Url;
  final String trailerMp4Url;
  final String thumbnailUrl;
  final String trailerThumbnailUrl;
  final String horizontalBannerUrl;
  final String verticalPosterUrl;
  final String customVideoUrl;
  final String customTrailerUrl;
  final String? downloadedPath; // ✅ NEW - local file path
  final DateTime? downloadedAt;
  final MovieModel? movieModel;

  const VideoDetailScreen({
    Key? key,
    required this.videoTrailer,
    required this.videoMoives,
    required this.image,
    required this.subtitle,
    required this.videoTitle,
    required this.dis,
    required this.logoImage,
    this.imdbRating = 0.0,
    this.ageRating = 'U/A',
    this.directorInfo = '',
    this.castInfo = '',
    this.tagline = '',
    this.fullStoryline = '',
    this.genres = const [],
    this.tags = const [],
    this.language = '',
    this.duration = 0,
    this.releaseYear = 0,
    this.budget = '',
    this.awardsAndNominations = '',
    this.videoQuality = '',
    this.audioFormat = '',
    this.publishStatus = true,
    this.subscriptionRequired = false,
    this.enableAds = false,
    this.allowDownloads = false,
    this.featuredMovie = false,
    this.contentVendor = '',
    this.viewCount = 0,
    this.mp4Url = '',
    this.trailerMp4Url = '',
    this.thumbnailUrl = '',
    this.trailerThumbnailUrl = '',
    this.horizontalBannerUrl = '',
    this.verticalPosterUrl = '',
    this.customVideoUrl = '',
    this.customTrailerUrl = '',
    this.movieModel,
    this.downloadedPath, // ✅ optional
    this.downloadedAt,
    this.videoId,
  }) : super(key: key);

  factory VideoDetailScreen.fromArgument(MovieArgument arg) =>
      VideoDetailScreen(
        key: ValueKey('video_${arg.id}'),
        videoId: arg.id,
        videoTrailer: arg.hlsUrl,
        videoMoives: arg.hlsUrl,
        image: arg.horizontalBannerUrl,
        subtitle: arg.subtitle,
        videoTitle: arg.title,
        dis: arg.description,
        logoImage: arg.logoUrl,
        imdbRating: arg.imdbRating,
        ageRating: arg.ageRating,
        directorInfo: arg.directorString,
        castInfo: arg.castString,
      );

  factory VideoDetailScreen.fromModel(MovieModel m) => VideoDetailScreen(
    key: ValueKey('video_${m.id}'),
    videoId: m.id,
    videoTrailer: m.trailerUrl.isNotEmpty ? m.trailerUrl : m.playUrl,
    videoMoives: m.playUrl,
    image: m.horizontalBannerUrl,
    subtitle: m.genresString,
    videoTitle: m.movieTitle,
    dis: m.description,
    logoImage: m.logoUrl,
    imdbRating: m.imdbRating,
    ageRating: m.ageRating,
    directorInfo: m.directorString,
    castInfo: m.castString,
    tagline: m.tagline,
    fullStoryline: m.fullStoryline,
    genres: m.genres,
    tags: m.tags,
    language: m.language,
    duration: m.duration,
    releaseYear: m.releaseYear,
    budget: m.budget,
    awardsAndNominations: m.awardsAndNominations,
    videoQuality: m.videoQuality,
    audioFormat: m.audioFormat,
    publishStatus: m.publishStatus,
    subscriptionRequired: m.subscriptionRequired,
    enableAds: m.enableAds,
    allowDownloads: m.allowDownloads,
    featuredMovie: m.featuredMovie,
    contentVendor: m.contentVendor,
    viewCount: m.viewCount,
    mp4Url: m.movieFile?.mp4Url ?? '',
    trailerMp4Url: m.trailer?.mp4Url ?? '',
    thumbnailUrl: m.movieFile?.thumbnailUrl ?? '',
    trailerThumbnailUrl: m.trailer?.thumbnailUrl ?? '',
    horizontalBannerUrl: m.horizontalBannerUrl,
    verticalPosterUrl: m.verticalPosterUrl,
    customVideoUrl: m.customVideoUrl,
    customTrailerUrl: m.customTrailerUrl,
    movieModel: m,
  );
  factory VideoDetailScreen.fromBanner(BannerMovie b) => VideoDetailScreen(
    key: ValueKey('video_banner_${b.id}'),
    videoId: b.id,
    videoTrailer: b.trailerUrl.isNotEmpty ? b.trailerUrl : b.movieUrl,
    videoMoives: b.movieUrl.isNotEmpty ? b.movieUrl : b.trailerUrl,
    image: b.mobileImage.isNotEmpty ? b.mobileImage : b.logoImage,
    subtitle: b.genres.join(', '),
    videoTitle: b.title,
    dis: b.description,
    logoImage: b.logoImage,
    genres: b.genres,
  );

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> with RouteAware {
  late final DetailsController detailsController;

  final HomeController homeController = Get.find<HomeController>();
  final FavoritesController favoritesController =
      Get.find<FavoritesController>();
  bool _isExpanded = false;
  BetterPlayerController? betterPlayerController;
  bool isVideoInitialized = false;
  String? errorMessage;
  bool showControls = true;
  bool isPlaying = false;
  final isLiked = false.obs;
  final isShared = false.obs;
  final isShare = false.obs;

  String get _effectiveVideoUrl => widget.customVideoUrl.isNotEmpty
      ? widget.customVideoUrl
      : widget.videoMoives;

  String get _effectiveTrailerUrl => widget.customTrailerUrl.isNotEmpty
      ? widget.customTrailerUrl
      : widget.videoTrailer;

  List<Map<String, String>> _castList = [];
  @override
  @override
void initState() {
  super.initState();

  if (!Get.isRegistered<DownloadsController>()) {
    Get.put(DownloadsController());
  }

  // Initialize detailsController only once
  detailsController = Get.put(DetailsController(), permanent: false);

  WakelockPlus.enable();
  _createAndAttachController();

  if (widget.movieModel != null) {
    detailsController.loadFromModel(widget.movieModel!);
  } else {
    _fetchMovieDetailsForBanner();
  }
}
  void _initCastData() {
    if (widget.movieModel != null) {
      _castList = _buildCastList(widget.movieModel!);
      debugPrint("✅ Cast loaded from movieModel: ${_castList.length}");
    } else {
      _fetchMovieDetailsForBanner();
    }
  }

  Future<void> _fetchMovieDetailsForBanner() async {
    if (homeController.trendingMovies.isEmpty &&
        homeController.featuredMovies.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    final allMovies = [
      ...homeController.trendingMovies,
      ...homeController.featuredMovies,
    ];

    MovieModel? matched;

    try {
      matched = allMovies.firstWhereOrNull(
        (m) =>
            m.movieTitle.trim().toLowerCase() ==
            widget.videoTitle.trim().toLowerCase(),
      );
      matched ??= allMovies.firstWhereOrNull(
        (m) => m.movieTitle.toLowerCase().contains(
          widget.videoTitle.toLowerCase(),
        ),
      );

      matched ??= allMovies.firstWhereOrNull(
        (m) => widget.videoTitle.toLowerCase().contains(
          m.movieTitle.toLowerCase(),
        ),
      );

      if (matched != null && mounted) {
        detailsController.loadFromModel(matched);
        debugPrint(
          "✅ Cast matched from banner: ${detailsController.castList.length}",
        );
      } else {
        debugPrint("❌ No matching movie found for cast");
      }
    } catch (e) {
      debugPrint("❌ Cast fetch error: $e");
    }
  }

  List<Map<String, String>> _buildCastList(MovieModel movie) {
    final List<Map<String, String>> list = [];

    void addItems(List<dynamic> items, String role) {
      for (var e in items) {
        list.add({
          'name': e.name ?? '',
          'role': role,
          'character': e.character ?? '',
          'image': e.imageUrl ?? '',
        });
      }
    }

    addItems(movie.director, 'Director');
    addItems(movie.producer, 'Producer');
    addItems(movie.writer, 'Writer');
    addItems(movie.musicDirector, 'Music Director');
    addItems(movie.cinematographer, 'Cinematographer');
    addItems(movie.editor, 'Editor');
    addItems(movie.castMembers, 'Actor');

    debugPrint("🎬 Total Cast Items: ${list.length}");

    return list;
  }

  void _createAndAttachController() {
    final url = _effectiveTrailerUrl;
    if (url.isEmpty || Uri.tryParse(url)?.hasAuthority != true) {
      debugPrint('⚠️ Trailer URL is invalid or empty: "$url"');
      setState(() => errorMessage = 'Trailer not available');
      return;
    }
    try {
      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        _effectiveTrailerUrl,
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
      debugPrint('Error creating player: $e');
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
            setState(() => errorMessage = 'Video failed to load');
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
    if (route != null) routeObserver.subscribe(this, route);
  }

  @override
  void didPushNext() {
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
    } catch (_) {}
    try {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } catch (_) {}
    // ✅ Removed Get.delete<DetailsController>()
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
    } catch (_) {}
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
      if (isPlaying) setState(() => showControls = false);
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
    });
  }

  void _shareMovie() {
    Share.share(
      'Download App: https://play.google.com/store/apps/details?id=com.gutargooproo.application',
      subject: 'Movie Recommendation',
    );
  }

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
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
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
                    _buildVideoPlayer(),
                    Center(child: _buildLogoOrTitle()),
                    _buildInfoSection(),
                    SizedBox(height: 8.h),
                    _buildWatchButton(),
                    SizedBox(height: 8.h),
                Obx(() {
  final token = homeController.userToken.value;
  // Agar homeController mein empty hai toh fallback
  return FutureBuilder<String>(
    future: _getToken(),
    builder: (context, snapshot) {
      final resolvedToken = token.isNotEmpty 
          ? token 
          : (snapshot.data ?? '');
      
      debugPrint('🔑 Resolved Token: "$resolvedToken"');
      
      if (resolvedToken.isEmpty) return const SizedBox();
      
      return DownloadButton(
        videoId: widget.movieModel?.id ?? widget.videoId ?? '',
        videoTitle: widget.videoTitle,
        subtitle: widget.subtitle,
        image: widget.image,
        videoTrailer: _effectiveVideoUrl,
        token: resolvedToken,
      );
    },
  );
}),
                    SizedBox(height: 8.h),
                    _buildDescription(),
                    SizedBox(height: 10.h),
                    _buildActionButtons(),
                    SizedBox(height: 16.h),

                    Obx(() {
                      if (detailsController.castList.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Center(
                            child: Text(
                              "No Cast & Crew Available",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return CastCrewSection(
                        castList: detailsController.castList,
                      );
                    }),
                    SizedBox(height: 32.h),
                    _buildExploreMore(),
                    SizedBox(height: 10.h),
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
Widget _buildLogoOrTitle() {
  if (widget.logoImage.isNotEmpty) {
    final imageWidget = widget.logoImage.startsWith('http')
        ? Image.network(
            widget.logoImage,
            height: 50.h,
            width: 160.w,
            fit: BoxFit.contain,
            cacheWidth: 360,
            cacheHeight: 100,
            errorBuilder: (_, __, ___) => _titleText(),
          )
        : Image.asset(
            widget.logoImage,
            height: 50.h,
            width: 160.w,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _titleText(),
          );
    return imageWidget;
  }
  return _titleText();
}
  Widget _titleText() => Text(
    widget.videoTitle,
    style: TextStyle(
      fontSize: 22.sp,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );

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

  // ── Top Bar ────────────────────────────────────────────────────────────────
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
    final imdbLabel = widget.imdbRating > 0
        ? 'IMDB ${widget.imdbRating.toStringAsFixed(1)}'
        : 'IMDB 8.6';
    final ratingLabel = widget.ageRating.isNotEmpty
        ? widget.ageRating
        : 'U/A 16+';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          imdbLabel,
          style: TextStyle(
            color: const Color(0xFFFFA500),
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(width: 4.w),
        _dot(),
        SizedBox(width: 4.w),
        Text(
          widget.subtitle,
          style: TextStyle(color: Colors.grey, fontSize: 10.sp),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(width: 4.w),
        _dot(),
        SizedBox(width: 4.w),
        Text(
          ratingLabel,
          style: TextStyle(color: Colors.grey, fontSize: 10.sp),
        ),
      ],
    );
  }

  Widget _dot() => Container(
    width: 4.w,
    height: 4.h,
    decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
  );
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
              colors: [Color(0xFF9e1119), Color(0xFFdf4119), Color(0xFF9e1119)],
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

  //   Widget _buildDownloadButton() {
  //   final isDownloading = false.obs;
  //   final isDownloaded = false.obs;
  //   final downloadProgress = 0.0.obs; // 0.0 to 1.0

  //   return Obx(() {
  //     final Color bgColor = isDownloaded.value
  //         ? const Color(0xFF1a7a3a)
  //         : isDownloading.value
  //         ? Colors.grey.shade800
  //         : Colors.grey.shade900;

  //     final String label = isDownloaded.value
  //         ? 'Downloaded'
  //         : isDownloading.value
  //         ? '${(downloadProgress.value * 100).toStringAsFixed(0)}%'
  //         : 'Download';

  //     final IconData icon = isDownloaded.value
  //         ? Icons.check_circle_rounded
  //         : isDownloading.value
  //         ? Icons.hourglass_top_rounded
  //         : Icons.download_rounded;

  //     return Padding(
  //       padding: EdgeInsets.symmetric(horizontal: 20.w),
  //       child: GestureDetector(
  //         onTap: () async {
  //           if (isDownloaded.value || isDownloading.value) return;

  //           isDownloading.value = true;
  //           downloadProgress.value = 0.0;

  //           // Simulate download progress
  //           const totalDuration = Duration(seconds: 3);
  //           const stepDuration = Duration(milliseconds: 100);
  //           final steps = totalDuration.inMilliseconds ~/ stepDuration.inMilliseconds;

  //           for (int i = 0; i <= steps; i++) {
  //             downloadProgress.value = i / steps;
  //             await Future.delayed(stepDuration);
  //           }

  //           downloadProgress.value = 1.0;
  //           isDownloading.value = false;
  //           isDownloaded.value = true;
  //         },
  //         child: AnimatedContainer(
  //           duration: const Duration(milliseconds: 300),
  //           width: double.infinity,
  //           height: 40.h,
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.white24, width: 1),
  //             borderRadius: BorderRadius.circular(8),
  //             color: bgColor,
  //           ),
  //           alignment: Alignment.center,
  //           child: Stack(
  //             alignment: Alignment.center,
  //             children: [
  //               // Progress background
  //               if (isDownloading.value)
  //                 Positioned.fill(
  //                   child: ClipRRect(
  //                     borderRadius: BorderRadius.circular(7),
  //                     child: LinearProgressIndicator(
  //                       value: downloadProgress.value,
  //                       backgroundColor: Colors.transparent,
  //                       valueColor: AlwaysStoppedAnimation<Color>(
  //                         Colors.white.withOpacity(0.2),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               // Text and icon
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(icon, color: Colors.white, size: 16.sp),
  //                   SizedBox(width: 4.w),
  //                   Text(
  //                     label,
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 16.sp,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   });
  // }

  Widget _buildDescription() {
    final isLong = widget.dis.length > 100;
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
          if (isLong)
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  _isExpanded ? 'Read Less' : 'Read More',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          imagePath: 'assets/t.png',
          label: 'Trailer',
          onTap: () => Get.to(
            () => TrailerFullScreen(url: _effectiveTrailerUrl),
            transition: Transition.fadeIn,
          ),
          color: Colors.white,
        ),
        Obx(
          () => _buildActionButton(
            icon: isLiked.value ? Icons.thumb_up : Icons.thumb_up_outlined,
            label: 'Rate',
            onTap: () => isLiked.value = !isLiked.value,
            color: isLiked.value ? Colors.red : Colors.white,
          ),
        ),
        Obx(() {
          final movieId = widget.videoId ?? '';
          if (movieId.isEmpty) return const SizedBox();

          // ✅ favorites.any() directly use karo - ye reactive hai
          final isFav = favoritesController.favorites.any(
            (e) => e.id == movieId,
          );

          return _buildActionButton(
            icon: isFav ? Icons.check_circle : Icons.add_outlined,
            label: 'My List',
            onTap: () {
              if (isFav) return;
              favoritesController.addFavorite(
                FavoriteItem(
                  id: movieId,
                  title: widget.videoTitle,
                  image: widget.image,
                  videoTrailer: widget.videoTrailer,
                  subtitle: widget.subtitle,
                  videoMovies: widget.videoMoives ?? '',
                  logoImage: widget.logoImage ?? '',
                  description: widget.dis ?? '',
                  imdbRating: widget.imdbRating ?? 0.0,
                  ageRating: widget.ageRating ?? 'U/A',
                  directorInfo: widget.directorInfo ?? '',
                  castInfo: widget.castInfo ?? '',
                  tagline: widget.tagline ?? '',
                  fullStoryline: widget.fullStoryline ?? '',
                  genres: widget.genres ?? [],
                  tags: widget.tags ?? [],
                  language: widget.language ?? '',
                  duration: widget.duration ?? 0,
                  releaseYear: widget.releaseYear ?? 0,
                ),
              );
            },
            color: isFav ? Colors.red : Colors.white,
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
      ],
    );
  }

  Widget _buildActionButton({
    IconData? icon,
    String? imagePath,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
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
              Icon(icon, color: color, size: 16.sp),
            SizedBox(width: imagePath != null ? 0 : 6.w),
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

  // ── Explore More ───────────────────────────────────────────────────────────
  Widget _buildExploreMore() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Text(
        'Explore More',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ── Trending Section ───────────────────────────────────────────────────────
  Widget _trendingSection(HomeController controller) {
    return Obx(() {
      if (controller.isLoadingTrending.value) {
        return SizedBox(
          height: 170.h,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }
      if (controller.trendingList.isEmpty) {
        return SizedBox(
          height: 170.h,
          child: const Center(
            child: Text(
              'No Trending Data',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
      return SizedBox(
        height: 170.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: 15.w),
          itemCount: controller.trendingList.length,
          itemBuilder: (context, index) {
            final item = controller.trendingList[index];
            final imageUrl = item['image']?.toString() ?? '';
            final isNetwork = imageUrl.startsWith('http');

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

                final rawItem = Map<String, dynamic>.from(item);

                final MovieModel reconstructed = rawItem.containsKey('_id')
                    ? MovieModel.fromJson(rawItem)
                    : MovieModel.fromLegacyMap(rawItem);

                // ── pushReplacement is correct here: detail → detail swap ──
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (_, __, ___) =>
                        VideoDetailScreen.fromModel(reconstructed),
                    transitionsBuilder: (_, animation, __, child) =>
                        FadeTransition(opacity: animation, child: child),
                  ),
                );
              },
              child: Container(
                width: 100.w,
                margin: EdgeInsets.only(right: 10.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: imageUrl.isEmpty
                      ? _imagePlaceholder()
                      : isNetwork
                      ? Image.network(
                          imageUrl,
                          height: 170.h,
                          width: 100.w,
                          fit: BoxFit.cover,
                          cacheWidth: 200,
                          cacheHeight: 340,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 170.h,
                              width: 100.w,
                              color: Colors.grey.shade800,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white54,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        )
                      : Image.asset(
                          imageUrl,
                          height: 170.h,
                          width: 100.w,
                          fit: BoxFit.cover,
                          cacheWidth: 200,
                          cacheHeight: 340,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _imagePlaceholder() => Container(
    color: Colors.grey.shade800,
    child: Icon(Icons.movie, color: Colors.white54, size: 24.sp),
  );
}

class DownloadButton extends StatelessWidget {
  final String videoId;
  final String videoTitle;
  final String subtitle;
  final String image;
  final String videoTrailer;
  final String token;

  const DownloadButton({
    Key? key,
    required this.videoId,
    required this.videoTitle,
    required this.subtitle,
    required this.image,
    required this.videoTrailer,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DownloadsController>()) {
    Get.put(DownloadsController());
  }
  final controller = Get.find<DownloadsController>();

    return Obx(() {
      final isDownloading = controller.isDownloading(videoId);
      final isDownloaded = controller.isItemDownloaded(videoId);
      final progress = controller.getProgress(videoId) ?? 0.0;

      final Color bgColor = isDownloaded
          ? const Color(0xFF1a7a3a)
          : isDownloading
          ? Colors.grey.shade800
          : Colors.grey.shade900;

      final String label = isDownloaded
          ? 'Downloaded'
          : isDownloading
          ? '${(progress * 100).toStringAsFixed(0)}%'
          : 'Download';

      final IconData icon = isDownloaded
          ? Icons.check_circle_rounded
          : isDownloading
          ? Icons.hourglass_top_rounded
          : Icons.download_rounded;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Opacity(
          opacity: (isDownloading || isDownloaded) ? 0.7 : 1.0,
          child: Tooltip(
            message: isDownloaded
                ? 'Already Downloaded'
                : 'Download this video',
            child: GestureDetector(
              onTap: () {
                if (isDownloaded || isDownloading) return;

                controller.downloadVideo(
                  videoId: videoId,
                  videoTitle: videoTitle,
                  subtitle: subtitle,
                  image: image,
                  videoTrailer: videoTrailer,
                  token: token,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 40.h,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24, width: 1),
                  borderRadius: BorderRadius.circular(8),
                  color: bgColor,
                ),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress background
                    if (isDownloading)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, value, child) =>
                                LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.2),
                                  ),
                                ),
                          ),
                        ),
                      ),
                    // Text and icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: Colors.white, size: 16.sp),
                        SizedBox(width: 6.w),
                        Text(
                          label,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
Future<String> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  // Apna actual key daalo jo login pe save kiya tha
  return prefs.getString('token') ?? 
         prefs.getString('auth_token') ?? 
         prefs.getString('user_token') ?? '';
}