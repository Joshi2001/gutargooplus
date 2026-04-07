import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:better_player_enhanced/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chrome_cast/_session_manager/cast_session_manager.dart';
import 'package:flutter_chrome_cast/entities/cast_session.dart';
import 'package:flutter_chrome_cast/enums/connection_state.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/cast/cast.dart';
import 'package:gutrgoopro/home/screen/details_screen.dart';
import 'package:http/http.dart' as http;
import 'package:pip/pip.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:startapp_sdk/startapp.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoScreen extends StatefulWidget {
  final String url;
  final String title;
  final String image;
  final List<Map<String, String>> similarVideos;
  final String? vastTagUrl;

  const VideoScreen({
    super.key,
    required this.url,
    required this.title,
    this.similarVideos = const [],
    required this.image,
    this.vastTagUrl,
  });

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with RouteAware, WidgetsBindingObserver {
  late BetterPlayerController _controller;
  final _pip = Pip();
  bool _isDisposed = false;
  Timer? _hideTimer;
  Timer? _unlockHideTimer;
  double brightness = 0.5;
  double volume = 0.5;
  bool _isInFullscreen = false;
  bool showBrightnessUI = false;
  bool showVolumeUI = false;
  bool _showControls = true;
  bool _isDragging = false;
  bool _isLocked = false;
  bool _showUnlockButton = false;
  double _speed = 1.0;
  Timer? brightnessTimer;
  Timer? volumeTimer;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _showSeekLeft = false;
  bool _showSeekRight = false;
  bool _isBuffering = true;
  bool _isSeeking = false;
  bool _isVideoReady = false;
  bool _controllerDisposed = false;
  bool _isBackPressed = false;
  final _startAppSdk = StartAppSdk();
StartAppRewardedVideoAd? _rewardedAd;
bool _rewardEarned = false;
  // late final VastAdController _adCtrl;
  List<HlsQuality> _qualities = [];
  HlsQuality? _selectedQuality;
  late final HomeController _homeController;
  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _homeController = Get.find<HomeController>();
    // _adCtrl = Get.isRegistered<VastAdController>()
    //     ? Get.find<VastAdController>()
    //     : Get.put(VastAdController(), permanent: true);
    // _adCtrl.reset();

    _initPlayer();
    Future.microtask(() async {
      if (_isDisposed) return;
      brightness = await ScreenBrightness().current;
      volume = await VolumeController().getVolume();
    });
    _startHideTimer();
    _loadQualities();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      if (widget.vastTagUrl != null && widget.vastTagUrl!.isNotEmpty) {
        try {
          _controller.pause();
        } catch (_) {}
        try {
          _controller.setVolume(0);
        } catch (_) {}

        Future.delayed(const Duration(milliseconds: 300), () async {
          if (_isDisposed) return;
          // await _adCtrl.loadAndPlay(widget.vastTagUrl!);
          _waitForAdToFinish();
        });
      } else {
        _controller.play();
      }
    });
  }

  Future<void> _enterPipMode() async {
    if (!(_controller.isPlaying() ?? false)) return;

    try {
      final supported = await _pip.isSupported();
      if (!supported) {
        try {
          _controller.pause();
        } catch (_) {}
        return;
      }

      // Step 1: setup with options
      await _pip.setup(
        PipOptions(autoEnterEnabled: false, aspectRatioX: 16, aspectRatioY: 9),
      );

      // Step 2: start PiP
      await _pip.start();
    } catch (e) {
      debugPrint("PiP error: $e");
      try {
        _controller.pause();
      } catch (_) {}
    }
  }

  void _waitForAdToFinish() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      // final state = _adCtrl.adState.value;
      // if (state == VastAdState.finished || state == VastAdState.error) {
      //   timer.cancel();
      //   if (!_isDisposed && mounted) {
      //     WidgetsBinding.instance.addPostFrameCallback((_) {
      //       if (!_isDisposed && mounted) {
      //         _controller.setVolume(1.0);
      //         _controller.play();
      //       }
      //     });
      //   }
      // }
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
    super.didPushNext();
    if (!_controllerDisposed && !_isInFullscreen) {
      try {
        _controller.pause();
      } catch (_) {}
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    if (!_controllerDisposed && !_isDisposed) {
      setState(() {
        _showControls = true;
      });
      _startHideTimer();
    }
  }

  // void _initPlayer() {
  //   final config = BetterPlayerConfiguration(
  //     autoPlay: true,
  //     fit: BoxFit.contain,
  //     looping: true,
  //     allowedScreenSleep: false,
  //     handleLifecycle: false,
  //     autoDispose: false,
  //     controlsConfiguration: const BetterPlayerControlsConfiguration(
  //       showControls: false,
  //     ),
  //   );

  //   final dataSource = BetterPlayerDataSource(
  //     BetterPlayerDataSourceType.network,
  //     widget.url,
  //     videoFormat: BetterPlayerVideoFormat.hls,
  //     cacheConfiguration: const BetterPlayerCacheConfiguration(useCache: false),
  //   );

  //   _controller = BetterPlayerController(config);
  //   _controller.setupDataSource(dataSource);
  //   _controller.addEventsListener(_onPlayerEvent);
  //   _controllerDisposed = false;
  // }

  // void _initPlayer() {
  //   final config = BetterPlayerConfiguration(
  //     autoPlay: true,
  //     fit: BoxFit.contain,
  //     looping: true,
  //     allowedScreenSleep: false,
  //     handleLifecycle: false,
  //     autoDispose: false,
  //     controlsConfiguration: const BetterPlayerControlsConfiguration(
  //       showControls: false,
  //     ),
  //   );

  //   final dataSource = BetterPlayerDataSource(
  //     BetterPlayerDataSourceType.network,
  //     widget.url,
  //     videoFormat: BetterPlayerVideoFormat.hls,
  //     cacheConfiguration: const BetterPlayerCacheConfiguration(useCache: false),
  //   );

  //   _controller = BetterPlayerController(config);
  //   _controller.setupDataSource(dataSource).then((_) {
  //     _controller.setVolume(1.0);
  //   });
  //   _controller.addEventsListener(_onPlayerEvent);
  //   _controllerDisposed = false;
  // }
  void _initPlayer() {
  final config = BetterPlayerConfiguration(
    autoPlay: true,
    fit: BoxFit.contain,
    looping: true,
    allowedScreenSleep: false,
    handleLifecycle: false,
    autoDispose: false,
    controlsConfiguration: const BetterPlayerControlsConfiguration(
      showControls: false,
    ),
  );

  late BetterPlayerDataSource dataSource;
  if (widget.url.startsWith("http")) {
  
    dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.url,
      videoFormat: BetterPlayerVideoFormat.hls,
      cacheConfiguration:
          const BetterPlayerCacheConfiguration(useCache: false),
    );
  } else {
    // 📁 OFFLINE FILE
    dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      widget.url,
    );
  }

  _controller = BetterPlayerController(config);
  _controller.setupDataSource(dataSource).then((_) {
    _controller.setVolume(1.0);
  });

  _controller.addEventsListener(_onPlayerEvent);
  _controllerDisposed = false;
}

  void _onPlayerEvent(BetterPlayerEvent event) {
     if (!mounted) return;

  /// 🔥 SAFE setState (after build)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    setState(() {
      // your UI updates
    });
  });
    if (_isDisposed) return;
    //    _controller.setVolume(1.0);
    // _controller.play();

    if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
      try {
        _controller.seekTo(Duration.zero);
        _controller.pause();
        if (mounted && !_isDisposed) {
          setState(() {
            _position = Duration.zero;
            _showControls = true;
          });
          _hideTimer?.cancel();
        }
      } catch (_) {}
      return;
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
      try {
        if (_controller.isVideoInitialized() == true) _controller.pause();
      } catch (_) {}
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      if (mounted && !_isDisposed) {
        setState(() => _isVideoReady = true);
        _controller.setVolume(1.0);
      }
    }

    final v = _controller.videoPlayerController?.value;
    if (v == null) return;
    if (!mounted || _isDisposed) return;

    setState(() {
      _position = v.position;
      _duration = v.duration ?? Duration.zero;
      _isBuffering = v.isBuffering;
      if (v.isPlaying && !v.isBuffering) {
        _isSeeking = false;
      }
    });
  }

  void _disposeController() {
    if (_controllerDisposed) return;
    _controllerDisposed = true;

    try {
      _controller.removeEventsListener(_onPlayerEvent);
    } catch (_) {}
    try {
      _controller.pause();
    } catch (_) {}
    try {
      _controller.dispose();
    } catch (e) {
      debugPrint("Controller dispose error: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive && !_isBackPressed) {
      _enterPipMode();
    }
  }

  Future<bool> _handleBackPress() async {
    _isBackPressed = true;
    // _isDisposed = true;

    _hideTimer?.cancel();
    brightnessTimer?.cancel();
    volumeTimer?.cancel();
    _unlockHideTimer?.cancel();
    // _disposeController();
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) Navigator.pop(context);
    return true;
  }

  Future<void> _loadQualities() async {
      if (!widget.url.startsWith("http")) return;
    try {
      final res = await http.get(Uri.parse(widget.url));
      if (_isDisposed || !mounted) return;
      if (res.statusCode != 200) return;

      final masterText = utf8.decode(res.bodyBytes);
      final qualities = _parseMasterPlaylist(masterText, widget.url);

      if (mounted && !_isDisposed) {
        setState(() {
          _qualities = qualities;
          if (_qualities.isNotEmpty) {
            _selectedQuality = _qualities.firstWhere(
              (q) => q.label.toLowerCase().contains("auto"),
              orElse: () => _qualities.first,
            );
          }
        });
      }
    } catch (e) {
      debugPrint("Quality load error: $e");
    }
  }

  List<HlsQuality> _parseMasterPlaylist(String content, String baseUrl) {
    final lines = content.split("\n");
    List<HlsQuality> qualities = [];
    qualities.add(HlsQuality(label: "Auto", url: baseUrl, bitrate: 0));

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith("#EXT-X-STREAM-INF")) {
        final bitrateMatch = RegExp(r"BANDWIDTH=(\d+)").firstMatch(line);
        final resolutionMatch = RegExp(
          r"RESOLUTION=(\d+x\d+)",
        ).firstMatch(line);
        final bitrate = bitrateMatch != null
            ? int.parse(bitrateMatch.group(1)!)
            : 0;
        final resolution = resolutionMatch != null
            ? resolutionMatch.group(1)!
            : "";

        if (i + 1 < lines.length) {
          final urlLine = lines[i + 1].trim();
          final absoluteUrl = _makeAbsoluteUrl(baseUrl, urlLine);
          String label = resolution.isNotEmpty
              ? _resolutionToLabel(resolution)
              : "${(bitrate / 1000).round()} kbps";
          qualities.add(
            HlsQuality(label: label, url: absoluteUrl, bitrate: bitrate),
          );
        }
      }
    }

    qualities.sort((a, b) => a.bitrate.compareTo(b.bitrate));
    return qualities;
  }

  String _makeAbsoluteUrl(String base, String path) {
    if (path.startsWith("http")) return path;
    final uri = Uri.parse(base);
    final basePath = uri.path.substring(0, uri.path.lastIndexOf("/") + 1);
    return "${uri.scheme}://${uri.host}$basePath$path";
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_isDragging && !_isLocked && !_isDisposed) {
        setState(() => _showControls = false);
      }
    });
  }

  void _startUnlockHideTimer() {
    _unlockHideTimer?.cancel();
    _unlockHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isLocked && !_isDisposed) {
        setState(() => _showUnlockButton = false);
      }
    });
  }

  void _toggleControls() {
    if (_isLocked) {
      setState(() => _showUnlockButton = true);
      _startUnlockHideTimer();
      return;
    }
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _togglePlayPause() {
    if (_isLocked) return;
    final isPlaying = _controller.isPlaying() ?? false;
    if (isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {});
    _startHideTimer();
  }

  void _openCastDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CastDeviceSheet(
        videoUrl: _selectedQuality?.url ?? widget.url,
        title: widget.title,
      ),
    );
  }

  Future<void> _seekBy(int seconds) async {
    if (_isLocked || _isDisposed) return;
    final v = _controller.videoPlayerController?.value;
    if (v == null) return;

    setState(() => _isSeeking = true);

    final current = v.position;
    final total = v.duration ?? Duration.zero;
    Duration target = current + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (target > total) target = total;

    await _controller.seekTo(target);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!_isDisposed) _startHideTimer();
  }

  void _showSeekEffect(bool right) {
    if (_isLocked) return;
    if (right) {
      setState(() => _showSeekRight = true);
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted && !_isDisposed) setState(() => _showSeekRight = false);
      });
    } else {
      setState(() => _showSeekLeft = true);
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted && !_isDisposed) setState(() => _showSeekLeft = false);
      });
    }
  }

  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
      if (_isLocked) {
        _showControls = false;
        _showUnlockButton = true;
        _startUnlockHideTimer();
      } else {
        _showControls = true;
        _showUnlockButton = false;
        _startHideTimer();
      }
    });
  }

  String _resolutionToLabel(String resolution) {
    try {
      final parts = resolution.split("x");
      if (parts.length != 2) return resolution;
      final height = int.parse(parts[1]);
      if (height >= 2160) return "2160p";
      if (height >= 1440) return "1440p";
      if (height >= 1080) return "1080p";
      if (height >= 720) return "720p";
      if (height >= 480) return "480p";
      if (height >= 360) return "360p";
      if (height >= 240) return "240p";
      return "${height}p";
    } catch (e) {
      return resolution;
    }
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, "0");
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return "${two(h)}:${two(m)}:${two(s)}";
    return "${two(m)}:${two(s)}";
  }

  Future<void> _applyQuality(HlsQuality quality) async {
      if (!widget.url.startsWith("http")) return;
    if (_isDisposed) return;
    final wasPlaying = _controller.isPlaying() ?? false;
    final currentPos =
        _controller.videoPlayerController?.value.position ?? _position;

    setState(() => _selectedQuality = quality);

    final newDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      quality.url,
      videoFormat: BetterPlayerVideoFormat.hls,
      cacheConfiguration: const BetterPlayerCacheConfiguration(useCache: false),
    );

    await _controller.setupDataSource(newDataSource);
    if (_isDisposed) return;
    await _controller.seekTo(currentPos);
    if (wasPlaying && !_isDisposed) _controller.play();
  }

  void _openSettingsDialog() {
    if (_isLocked) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => HotstarSettingsDialog(
        qualities: _qualities,
        selectedQuality: _selectedQuality,
        speed: _speed,
        onQualitySelected: (q) async {
          Navigator.pop(context);
          await _applyQuality(q);
        },
        onSpeedSelected: (s) {
          setState(() => _speed = s);
          _controller.setSpeed(s);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _openFullscreen() async {
    if (_isLocked || _isDisposed) return;

    final videoValue = _controller.videoPlayerController?.value;
    final aspectRatio = videoValue?.aspectRatio ?? (16 / 9);
    final isPortraitVideo = aspectRatio < 1.0;

    _isInFullscreen = true;

    if (isPortraitVideo) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final livePos =
        _controller.videoPlayerController?.value.position ?? _position;

    final Duration? result = await Navigator.push<Duration>(
      context,
      MaterialPageRoute(
        builder: (_) => HotstarFullscreenPage(
          controller: _controller,
          title: widget.title,
          speed: _speed,
          qualities: _qualities,
          selectedQuality: _selectedQuality,
          isPortraitVideo: isPortraitVideo,
          initialPosition: livePos,
          onQualityChanged: (q) async => await _applyQuality(q),
          onSpeedChanged: (s) {
            if (!_isDisposed) setState(() => _speed = s);
            _controller.setSpeed(s);
          },
        ),
      ),
    );

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _isInFullscreen = false;

    if (!mounted || _isDisposed) return;

    final targetPos = result ?? livePos;

    // if (isPortraitVideo) {
    //   await Future.delayed(const Duration(milliseconds: 300));
    //   if (!mounted || _isDisposed) return;
    //   try {
    //     await _controller.seekTo(targetPos);
    //   } catch (_) {}
    //   await Future.delayed(const Duration(milliseconds: 200));
    //   if (!mounted || _isDisposed) return;
    //   try {
    //     _controller.play();
    //   } catch (_) {}
    //   setState(() => _showControls = true);
    //   _startHideTimer();
    //   return;
    // }
    if (isPortraitVideo) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted || _isDisposed) return; // ✅ already checked
      try {
        await _controller.seekTo(targetPos);
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted || _isDisposed) return;
      try {
        _controller.play();
      } catch (_) {}
      setState(() => _showControls = true);
      _startHideTimer();
      return;
    }

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted || _isDisposed) return;

    final reattachUrl = _selectedQuality?.url ?? widget.url;

    try {
      await _controller.setupDataSource(
        BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          reattachUrl,
          videoFormat: BetterPlayerVideoFormat.hls,
          cacheConfiguration: const BetterPlayerCacheConfiguration(
            useCache: false,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Reattach error: $e");
      return;
    }

    if (!mounted || _isDisposed) return;

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted || _isDisposed) return;

    try {
      await _controller.seekTo(targetPos);
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted || _isDisposed) return;

    try {
      _controller.play();
    } catch (_) {}

    setState(() => _showControls = true);
    _startHideTimer();
  }

  Widget _seekOverlay(bool right) {
    final show = right ? _showSeekRight : _showSeekLeft;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedScale(
          scale: show ? 1 : 0.9,
          duration: const Duration(milliseconds: 120),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  right ? Icons.fast_forward : Icons.fast_rewind,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 6),
                const Text(
                  "10 sec",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        if (_isLocked || _isDisposed) return;
        onTap();
        _startHideTimer();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  void _navigateToDetail({
    required String videoTrailer,
    required String videoMovies,
    required String imageUrl,
    required String subtitle,
    required String title,
    required String dis,
  }) async {
    if (!_controllerDisposed) {
      try {
        _controller.pause();
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 80));

    Get.to(
      () => VideoDetailScreen(
        key: ValueKey('video_$videoTrailer'),
        videoTrailer: videoTrailer,
        videoMoives: videoMovies,
        image: imageUrl,
        subtitle: subtitle,
        videoTitle: title,
        dis: dis,
        logoImage: '',
      ),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _similarVideosSection() {
    if (widget.similarVideos.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14, top: 14, bottom: 8),
            child: Text(
              "Similar Videos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          SizedBox(
            height: 175,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 14),
              itemCount: widget.similarVideos.length,
              itemBuilder: (context, index) {
                final item = widget.similarVideos[index];
                final title = item['title'] ?? '';
                final imageUrl = item['image'] ?? '';
                final videoTrailer = item['url'] ?? '';

                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => VideoScreen(
                          key: ValueKey('video_$videoTrailer'),
                          url: videoTrailer,
                          title: title,
                          similarVideos: widget.similarVideos,
                          image: widget.image,
                        ),
                        transitionsBuilder: (_, animation, __, child) =>
                            FadeTransition(opacity: animation, child: child),
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              height: 130,
                              width: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 130,
                                width: 110,
                                color: Colors.grey[850],
                                child: const Icon(
                                  Icons.movie,
                                  color: Colors.white54,
                                  size: 32,
                                ),
                              ),
                            )
                          : Image.asset(
                              imageUrl,
                              height: 130,
                              width: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 130,
                                width: 110,
                                color: Colors.grey[850],
                                child: const Icon(
                                  Icons.movie,
                                  color: Colors.white54,
                                  size: 32,
                                ),
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return Obx(() {
      final trendingList = _homeController.trendingList;

      if (trendingList.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "No videos available",
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14, top: 14, bottom: 8),
            child: Text(
              "Trending Videos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          SizedBox(
            height: 175,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 14),
              itemCount: trendingList.length,
              itemBuilder: (context, index) {
                final item = trendingList[index];
                final title = item['title']?.toString() ?? '';
                final imageUrl = item['image']?.toString() ?? '';
                final videoTrailer = item['videoTrailer']?.toString() ?? '';
                final videoMovies =
                    item['videoMovies']?.toString() ?? videoTrailer;
                final subtitle = item['subtitle']?.toString() ?? '';
                final dis = item['dis']?.toString() ?? '';

                return GestureDetector(
                  onTap: () => _navigateToDetail(
                    videoTrailer: videoTrailer,
                    videoMovies: videoMovies,
                    imageUrl: imageUrl,
                    subtitle: subtitle,
                    title: title,
                    dis: dis,
                  ),
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageUrl.startsWith('http')
                              ? Image.network(
                                  imageUrl,
                                  height: 130,
                                  width: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 130,
                                    width: 110,
                                    color: Colors.grey[850],
                                    child: const Icon(
                                      Icons.movie,
                                      color: Colors.white54,
                                      size: 32,
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  imageUrl,
                                  height: 130,
                                  width: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 130,
                                    width: 110,
                                    color: Colors.grey[850],
                                    child: const Icon(
                                      Icons.movie,
                                      color: Colors.white54,
                                      size: 32,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    // _adCtrl.reset();
    WakelockPlus.disable();
    routeObserver.unsubscribe(this);
    _hideTimer?.cancel();
    brightnessTimer?.cancel();
    volumeTimer?.cancel();
    _unlockHideTimer?.cancel();
    if (!_isInFullscreen) _disposeController();
    VolumeController().showSystemUI = true;
    super.dispose();
  }

  @override
  void deactivate() {
    if (!_controllerDisposed && !_isInFullscreen) {
      try {
        _controller.pause();
      } catch (e) {
        debugPrint('Error pausing on deactivate: $e');
      }
    }
    try {
    if (!_controllerDisposed) {
      _controller.removeEventsListener(_onPlayerEvent);
    }
  } catch (e) {
    print("Deactivation error: $e");
  }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _controller.isPlaying() ?? false;

    return WillPopScope(
      onWillPop: () async {
        await _handleBackPress();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    BetterPlayer(controller: _controller),
                    // const AdOverlayWidget(),
                    if (!_isVideoReady)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),

                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _toggleControls,
                        child: Container(color: Colors.transparent),
                      ),
                    ),

                    if (!_isLocked)
                      Positioned.fill(
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onDoubleTap: () async {
                                  _showSeekEffect(false);
                                  await _seekBy(-10);
                                },
                                child: const SizedBox.expand(),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onDoubleTap: () async {
                                  _showSeekEffect(true);
                                  await _seekBy(10);
                                },
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Positioned.fill(
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onVerticalDragUpdate: (details) async {
                                if (!_isVideoReady) return;
                                double delta = details.primaryDelta! / 300;
                                brightness = (brightness - delta)
                                    .clamp(0.0, 1.0)
                                    .toDouble();
                                await ScreenBrightness().setScreenBrightness(
                                  brightness,
                                );
                                if (!_isDisposed)
                                  setState(() => showBrightnessUI = true);
                                brightnessTimer?.cancel();
                                brightnessTimer = Timer(
                                  const Duration(milliseconds: 800),
                                  () {
                                    if (mounted && !_isDisposed)
                                      setState(() => showBrightnessUI = false);
                                  },
                                );
                              },
                              child: const SizedBox.expand(),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onVerticalDragUpdate: (details) async {
                                if (!_isVideoReady) return;
                                double delta = details.primaryDelta! / 300;
                                volume = (volume - delta)
                                    .clamp(0.0, 1.0)
                                    .toDouble();
                                VolumeController().setVolume(volume);
                                if (!_isDisposed)
                                  setState(() => showVolumeUI = true);
                                volumeTimer?.cancel();
                                volumeTimer = Timer(
                                  const Duration(milliseconds: 800),
                                  () {
                                    if (mounted && !_isDisposed)
                                      setState(() => showVolumeUI = false);
                                  },
                                );
                              },
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      left: 20,
                      top: 0,
                      bottom: 0,
                      child: Center(child: _seekOverlay(false)),
                    ),
                    Positioned(
                      right: 20,
                      top: 0,
                      bottom: 0,
                      child: Center(child: _seekOverlay(true)),
                    ),

                    if (_isVideoReady && (_isBuffering || _isSeeking))
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),

                    if (_showControls && !_isLocked && _isVideoReady)
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _circleButton(
                              Icons.fast_rewind,
                              onTap: () => _seekBy(-10),
                            ),
                            const SizedBox(width: 28),
                            _circleButton(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              onTap: _togglePlayPause,
                            ),
                            const SizedBox(width: 28),
                            _circleButton(
                              Icons.fast_forward,
                              onTap: () => _seekBy(10),
                            ),
                          ],
                        ),
                      ),

                    if (_showControls && !_isLocked)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: _handleBackPress,
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // IconButton(
                                //   onPressed: () => debugPrint("CAST CLICKED"),
                                //   icon: const Icon(
                                //     Icons.cast,
                                //     color: Colors.white,
                                //   ),
                                // ),
                                // VideoScreen top bar cast button:
                                StreamBuilder<GoogleCastSession?>(
                                  stream: GoogleCastSessionManager
                                      .instance
                                      .currentSessionStream,
                                  builder: (context, snapshot) {
                                    final connected =
                                        GoogleCastSessionManager
                                            .instance
                                            .connectionState ==
                                        GoogleCastConnectState.connected;
                                    return IconButton(
                                      onPressed: connected
                                          ? GoogleCastSessionManager
                                                .instance
                                                .endSessionAndStopCasting
                                          : _openCastDialog,
                                      icon: Icon(
                                        connected
                                            ? Icons.cast_connected
                                            : Icons.cast,
                                        color: connected
                                            ? Colors.blue
                                            : Colors.white,
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  onPressed: _toggleLock,
                                  icon: const Icon(
                                    Icons.lock_open,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _openSettingsDialog,
                                  icon: const Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _openFullscreen,
                                  icon: const Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    if (_showControls && !_isLocked && _isVideoReady)
                      Positioned(
                        bottom: 8,
                        left: 14,
                        right: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Slider(
                              activeColor: Colors.red,
                              inactiveColor: Colors.white24,
                              value: min(
                                _position.inSeconds.toDouble(),
                                _duration.inSeconds.toDouble() == 0
                                    ? 1
                                    : _duration.inSeconds.toDouble(),
                              ),
                              max: _duration.inSeconds.toDouble() == 0
                                  ? 1
                                  : _duration.inSeconds.toDouble(),
                              onChangeStart: (_) =>
                                  setState(() => _isDragging = true),
                              onChanged: (value) {
                                setState(
                                  () => _position = Duration(
                                    seconds: value.toInt(),
                                  ),
                                );
                              },
                              onChangeEnd: (value) async {
                                setState(() => _isDragging = false);
                                await _controller.seekTo(
                                  Duration(seconds: value.toInt()),
                                );
                                _startHideTimer();
                              },
                            ),
                            Text(
                              "${_format(_position)} / ${_format(_duration)}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_isLocked && _showUnlockButton)
                      Positioned(
                        right: 18,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: _toggleLock,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_open,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (showBrightnessUI)
                      Positioned(
                        left: 20,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _sideIndicator(Icons.brightness_6, brightness),
                        ),
                      ),

                    if (showVolumeUI)
                      Positioned(
                        right: 20,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _sideIndicator(Icons.volume_up, volume),
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.black,
                  child: SingleChildScrollView(child: _similarVideosSection()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HotstarFullscreenPage extends StatefulWidget {
  final BetterPlayerController controller;
  final String title;
  final double speed;
  final List<HlsQuality> qualities;
  final HlsQuality? selectedQuality;
  final bool isPortraitVideo;
  final Duration initialPosition;
  final Function(HlsQuality) onQualityChanged;
  final Function(double) onSpeedChanged;

  const HotstarFullscreenPage({
    super.key,
    required this.controller,
    required this.title,
    required this.speed,
    required this.qualities,
    required this.selectedQuality,
    required this.isPortraitVideo,
    required this.initialPosition,
    required this.onQualityChanged,
    required this.onSpeedChanged,
  });

  @override
  State<HotstarFullscreenPage> createState() => _HotstarFullscreenPageState();
}

class _HotstarFullscreenPageState extends State<HotstarFullscreenPage> {
  Timer? _hideTimer;
  Timer? _unlockHideTimer;
  Timer? brightnessTimer;
  Timer? volumeTimer;
  bool _showControls = true;
  bool _isDragging = false;
  double _brightness = 0.5;
  double _volume = 0.5;
  bool showBrightnessUI = false;
  bool showVolumeUI = false;
  bool _isLocked = false;
  bool _showUnlockButton = false;
  bool _isFillMode = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isBuffering = true;
  bool _isSeeking = false;
  bool _showSeekLeft = false;
  bool _showSeekRight = false;
  bool _isDisposed = false;
  HlsQuality? _localSelectedQuality;

  DeviceOrientation _currentOrientation = DeviceOrientation.landscapeLeft;

  double _scale = 1.0;
  double _previousScale = 1.0;
  static const double _minScale = 1.0;
  static const double _maxScale = 3.0;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _localSelectedQuality = widget.selectedQuality;
    VolumeController().showSystemUI = false;
    WakelockPlus.enable();
    Future.microtask(() async {
      if (_isDisposed) return;
      _brightness = await ScreenBrightness().current;
      _volume = await VolumeController().getVolume();
    });

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    widget.controller.addEventsListener(_playerListener);
    _startHideTimer();
  }

  void _playerListener(BetterPlayerEvent event) {
    if (_isDisposed) return;
    if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
      try {
        widget.controller.seekTo(Duration.zero);
        widget.controller.pause();
        if (mounted && !_isDisposed) {
          setState(() {
            _position = Duration.zero;
            _showControls = true;
          });
          _hideTimer?.cancel();
        }
      } catch (_) {}
      return;
    }
    final v = widget.controller.videoPlayerController?.value;
    if (v == null) return;
    if (!mounted) return;
    setState(() {
      _position = v.position;
      _duration = v.duration ?? Duration.zero;
      _isBuffering = v.isBuffering;
      if (v.isPlaying && !v.isBuffering) {
        _isSeeking = false;
      }
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_isDragging && !_isLocked && !_isDisposed)
        setState(() => _showControls = false);
    });
  }

  void _startUnlockHideTimer() {
    _unlockHideTimer?.cancel();
    _unlockHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isLocked && !_isDisposed)
        setState(() => _showUnlockButton = false);
    });
  }

  void _toggleControls() {
    if (_isLocked) {
      setState(() => _showUnlockButton = true);
      _startUnlockHideTimer();
      return;
    }
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
      if (_isLocked) {
        _showControls = false;
        _showUnlockButton = true;
        _startUnlockHideTimer();
      } else {
        _showControls = true;
        _showUnlockButton = false;
        _startHideTimer();
      }
    });
  }

  Future<void> _toggleRotation() async {
    final next = _currentOrientation == DeviceOrientation.landscapeLeft
        ? DeviceOrientation.landscapeRight
        : DeviceOrientation.landscapeLeft;

    setState(() => _currentOrientation = next);
    await SystemChrome.setPreferredOrientations([next]);
    _startHideTimer();
  }

  Future<void> _seekBy(int seconds) async {
    if (_isLocked || _isDisposed) return;
    final v = widget.controller.videoPlayerController?.value;
    if (v == null) return;
    final current = v.position;
    final total = v.duration ?? Duration.zero;
    Duration target = current + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (target > total) target = total;
    setState(() => _isSeeking = true);
    await widget.controller.seekTo(target);
    if (!_isDisposed) _startHideTimer();
  }

  void _showSeekEffect(bool right) {
    if (_isLocked) return;
    if (right) {
      setState(() => _showSeekRight = true);
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted && !_isDisposed) setState(() => _showSeekRight = false);
      });
    } else {
      setState(() => _showSeekLeft = true);
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted && !_isDisposed) setState(() => _showSeekLeft = false);
      });
    }
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, "0");
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return "${two(h)}:${two(m)}:${two(s)}";
    return "${two(m)}:${two(s)}";
  }

  Widget _seekOverlay(bool right) {
    final show = right ? _showSeekRight : _showSeekLeft;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedScale(
          scale: show ? 1 : 0.9,
          duration: const Duration(milliseconds: 120),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  right ? Icons.fast_forward : Icons.fast_rewind,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 6),
                const Text(
                  "10 sec",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        if (_isLocked || _isDisposed) return;
        onTap();
        _startHideTimer();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  void _openSettingsDialog() {
    if (_isLocked) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => HotstarSettingsDialog(
        qualities: widget.qualities,
        selectedQuality: _localSelectedQuality, // ✅ local use karo
        speed: widget.speed,
        onQualitySelected: (q) {
          Navigator.pop(context);
          setState(() => _localSelectedQuality = q); // ✅ local update
          widget.onQualityChanged(q);
        },
        onSpeedSelected: (s) {
          widget.onSpeedChanged(s);
          widget.controller.setSpeed(s);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _toggleFillMode() {
    setState(() {
      _isFillMode = !_isFillMode;
      _scale = _isFillMode ? 1.5 : 1.0;
    });
    _startHideTimer();
  }

  void _handleBack() {
    if (_isDisposed) return;
    _isDisposed = true;

    _hideTimer?.cancel();
    _unlockHideTimer?.cancel();
    brightnessTimer?.cancel();
    volumeTimer?.cancel();

    try {
      widget.controller.removeEventsListener(_playerListener);
    } catch (_) {}

    try {
      // widget.controller.pause();
    } catch (_) {}

    final livePos =
        widget.controller.videoPlayerController?.value.position ?? _position;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, livePos);
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _hideTimer?.cancel();
    WakelockPlus.disable();
    _unlockHideTimer?.cancel();
    brightnessTimer?.cancel();
    volumeTimer?.cancel();
    VolumeController().showSystemUI = true;
    try {
      widget.controller.removeEventsListener(_playerListener);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = widget.controller.isPlaying() ?? false;

    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: (details) => _previousScale = _scale,
                onScaleUpdate: (details) {
                  if (details.pointerCount >= 2) {
                    setState(() {
                      _scale = (_previousScale * details.scale).clamp(
                        _minScale,
                        _maxScale,
                      );
                    });
                  }
                },
                child: IgnorePointer(
                  ignoring: true,
                  child: RepaintBoundary(
                    child: Transform.scale(
                      scale: _scale,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio:
                              widget
                                  .controller
                                  .videoPlayerController
                                  ?.value
                                  .aspectRatio ??
                              (16 / 9),
                          child: BetterPlayer(controller: widget.controller),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (_isBuffering || _isSeeking)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),

            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _toggleControls,
                  onDoubleTap: _isLocked
                      ? null
                      : () async {
                          _showSeekEffect(false);
                          await _seekBy(-10);
                        },
                  onVerticalDragUpdate: (details) async {
                    if (_isLocked || _isDisposed) return;
                    double delta = details.primaryDelta! / 300;
                    _brightness = (_brightness - delta)
                        .clamp(0.0, 1.0)
                        .toDouble();
                    await ScreenBrightness().setScreenBrightness(_brightness);
                    if (!_isDisposed) setState(() => showBrightnessUI = true);
                    brightnessTimer?.cancel();
                    brightnessTimer = Timer(
                      const Duration(milliseconds: 800),
                      () {
                        if (mounted && !_isDisposed)
                          setState(() => showBrightnessUI = false);
                      },
                    );
                  },
                  child: const SizedBox.expand(),
                ),
              ),
            ),

            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _toggleControls,
                  onDoubleTap: _isLocked
                      ? null
                      : () async {
                          _showSeekEffect(true);
                          await _seekBy(10);
                        },
                  onVerticalDragUpdate: (details) async {
                    if (_isLocked || _isDisposed) return;
                    double delta = details.primaryDelta! / 300;
                    _volume = (_volume - delta).clamp(0.0, 1.0).toDouble();
                    VolumeController().setVolume(_volume);
                    if (!_isDisposed) setState(() => showVolumeUI = true);
                    volumeTimer?.cancel();
                    volumeTimer = Timer(const Duration(milliseconds: 800), () {
                      if (mounted && !_isDisposed)
                        setState(() => showVolumeUI = false);
                    });
                  },
                  child: const SizedBox.expand(),
                ),
              ),
            ),

            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Center(child: _seekOverlay(false)),
            ),
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Center(child: _seekOverlay(true)),
            ),

            if (_showControls && !_isLocked)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circleButton(Icons.fast_rewind, onTap: () => _seekBy(-10)),
                    const SizedBox(width: 28),
                    _circleButton(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      onTap: () {
                        if (isPlaying) {
                          widget.controller.pause();
                        } else {
                          widget.controller.play();
                        }
                        setState(() {});
                        _startHideTimer();
                      },
                    ),
                    const SizedBox(width: 28),
                    _circleButton(Icons.fast_forward, onTap: () => _seekBy(10)),
                  ],
                ),
              ),

            if (_showControls && !_isLocked)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _handleBack,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: _toggleFillMode,
                          icon: Icon(
                            _isFillMode ? Icons.fit_screen : Icons.crop_free,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // StreamBuilder<GoogleCastSession?>(
                        //   stream: GoogleCastSessionManager.instance.currentSessionStream,
                        //   builder: (context, snapshot) {
                        //     final connected = GoogleCastSessionManager.instance.connectionState ==
                        //         GoogleCastConnectState.connected;
                        //     return IconButton(
                        //       onPressed: connected
                        //           ? GoogleCastSessionManager.instance.endSessionAndStopCasting
                        //           : _openCastDialog,
                        //       icon: Icon(
                        //         connected ? Icons.cast_connected : Icons.cast,
                        //         color: connected ? Colors.blue : Colors.white,
                        //       ),
                        //     );
                        //   },
                        // ),
                        IconButton(
                          onPressed: _toggleLock,
                          icon: const Icon(
                            Icons.lock_open,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: _openSettingsDialog,
                          icon: const Icon(Icons.settings, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (_showControls && !_isLocked)
              Positioned(
                bottom: 10,
                left: 14,
                right: 14,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slider(
                        activeColor: Colors.red,
                        inactiveColor: Colors.white24,
                        value: min(
                          _position.inSeconds.toDouble(),
                          _duration.inSeconds.toDouble() == 0
                              ? 1
                              : _duration.inSeconds.toDouble(),
                        ),
                        max: _duration.inSeconds.toDouble() == 0
                            ? 1
                            : _duration.inSeconds.toDouble(),
                        onChangeStart: (_) =>
                            setState(() => _isDragging = true),
                        onChanged: (value) {
                          setState(
                            () => _position = Duration(seconds: value.toInt()),
                          );
                        },
                        onChangeEnd: (value) async {
                          setState(() => _isDragging = false);
                          await widget.controller.seekTo(
                            Duration(seconds: value.toInt()),
                          );
                          _startHideTimer();
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_format(_position)} / ${_format(_duration)}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: _toggleRotation,
                            child: Icon(
                              _currentOrientation ==
                                      DeviceOrientation.landscapeLeft
                                  ? Icons.screen_rotation_alt
                                  : Icons.screen_rotation,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            if (_isLocked && _showUnlockButton)
              Positioned(
                right: 18,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _toggleLock,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_open,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),

            if (showBrightnessUI)
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _sideIndicator(Icons.brightness_6, _brightness),
                ),
              ),

            if (showVolumeUI)
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Center(child: _sideIndicator(Icons.volume_up, _volume)),
              ),
          ],
        ),
      ),
    );
  }
}

class HotstarSettingsDialog extends StatefulWidget {
  final List<HlsQuality> qualities;
  final HlsQuality? selectedQuality;
  final double speed;
  final Function(HlsQuality) onQualitySelected;
  final Function(double) onSpeedSelected;

  const HotstarSettingsDialog({
    super.key,
    required this.qualities,
    required this.selectedQuality,
    required this.speed,
    required this.onQualitySelected,
    required this.onSpeedSelected,
  });

  @override
  State<HotstarSettingsDialog> createState() => _HotstarSettingsDialogState();
}

class _HotstarSettingsDialogState extends State<HotstarSettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _selectedSpeed = 1.0;
  HlsQuality? _selectedQuality;

  @override
  void initState() {
    super.initState();
    //  VolumeController().showSystemUI = false;
    _selectedSpeed = widget.speed;
    _selectedQuality = widget.selectedQuality;
    _tabController = TabController(length: 3, vsync: this);
  }

  Widget _rowItem(String title, {bool selected = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white60,
          fontSize: 17,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      leading: selected
          ? const Icon(Icons.check, color: Colors.blueAccent)
          : const SizedBox(width: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: "Quality"),
                      Tab(text: "Audio"),
                      Tab(text: "Speed"),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView(
                    children: widget.qualities.map((q) {
                      final selected = _selectedQuality?.url == q.url;
                      return _rowItem(
                        q.label,
                        selected: selected,
                        onTap: () {
                          setState(() => _selectedQuality = q);
                          widget.onQualitySelected(q);
                        },
                      );
                    }).toList(),
                  ),
                  ListView(
                    children: [
                      _rowItem("Hindi (Default)", selected: true),
                      _rowItem("English", selected: false),
                    ],
                  ),
                  ListView(
                    children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((s) {
                      final selected = _selectedSpeed == s;
                      return _rowItem(
                        s == 1.0 ? "1x  Normal" : "${s}x",
                        selected: selected,
                        onTap: () {
                          setState(() => _selectedSpeed = s);
                          widget.onSpeedSelected(s);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _sideIndicator(IconData icon, double value) {
  return Container(
    width: 65,
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.75),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color.fromARGB(255, 155, 138, 138), size: 26),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: RotatedBox(
            quarterTurns: -1,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.red),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "${(value * 100).toInt()}%",
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    ),
  );
}

class HlsQuality {
  final String label;
  final String url;
  final int bitrate;

  HlsQuality({required this.label, required this.url, required this.bitrate});
}
