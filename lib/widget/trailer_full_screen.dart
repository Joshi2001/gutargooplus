import 'dart:async';
import 'package:better_player_enhanced/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/getx/details_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TrailerFullScreen extends StatefulWidget {
  final String url;
  final String title;

  const TrailerFullScreen({
    super.key,
    required this.url,
    this.title = 'Trailer',
  });

  @override
  State<TrailerFullScreen> createState() => _TrailerFullScreenState();
}

class _TrailerFullScreenState extends State<TrailerFullScreen> {
  BetterPlayerController? _controller;

  bool _isDisposed = false;
  bool _controllerDisposed = false;
  bool _isHandlingBack = false;

  Timer? _hideTimer;
  Timer? _unlockHideTimer;
  Timer? _brightnessTimer;
  Timer? _volumeTimer;

  double _brightness = 0.5;
  double _volume = 0.5;

  bool _showControls = true;
  bool _isDragging = false;
  bool _isLocked = false;
  bool _showUnlockButton = false;
  bool _isFillMode = false;
  bool _isBuffering = true;
  bool _isSeeking = false;
  bool _isVideoReady = false;

  bool _showBrightnessUI = false;
  bool _showVolumeUI = false;
  bool _showSeekLeft = false;
  bool _showSeekRight = false;

  double _speed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  DeviceOrientation _currentOrientation = DeviceOrientation.landscapeLeft;

  // Quality
  List<_HlsQuality> _qualities = [];
  _HlsQuality? _selectedQuality;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initPlayer();
    Future.microtask(() async {
      if (_isDisposed) return;
      _brightness = await ScreenBrightness().current;
      _volume = await VolumeController().getVolume();
    });
    _startHideTimer();
  }

  // ─────────────────────────────────────────────
  // PLAYER INIT
  // ─────────────────────────────────────────────
  void _initPlayer() {
    final config = BetterPlayerConfiguration(
      autoPlay: true,
      fit: BoxFit.contain,
      looping: false,
      allowedScreenSleep: false,
      handleLifecycle: false,
      autoDispose: false,
      controlsConfiguration: const BetterPlayerControlsConfiguration(
        showControls: false,
      ),
    );

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.url,
      videoFormat: BetterPlayerVideoFormat.hls,
      useAsmsTracks: true,
      cacheConfiguration: const BetterPlayerCacheConfiguration(useCache: false),
    );

    _controller = BetterPlayerController(config);
    _controller!.setupDataSource(dataSource);
    _controller!.addEventsListener(_onPlayerEvent);
    _controllerDisposed = false;
    setState(() {});
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    if (_isDisposed) return;

    if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
      try {
        _controller?.seekTo(Duration.zero);
        _controller?.pause();
        if (mounted) {
          setState(() {
            _position = Duration.zero;
            _showControls = true;
          });
          _hideTimer?.cancel();
        }
      } catch (_) {}
      return;
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      if (mounted) setState(() => _isVideoReady = true);
      // Load quality tracks after init
      _loadQualitiesFromTracks();
    }

    final v = _controller?.videoPlayerController?.value;
    if (v == null || !mounted) return;

    setState(() {
      _position = v.position;
      _duration = v.duration ?? Duration.zero;
      _isBuffering = v.isBuffering;
      if (v.isPlaying && !v.isBuffering) _isSeeking = false;
    });
  }

  // ─────────────────────────────────────────────
  // QUALITY — uses BetterPlayer ASMS tracks
  // ─────────────────────────────────────────────
  void _loadQualitiesFromTracks() {
    final tracks = _controller?.betterPlayerAsmsTracks ?? [];
    final qualities = <_HlsQuality>[
      _HlsQuality(label: 'Auto', height: 0),
    ];
    for (final t in tracks) {
      if (t.height != null && t.height! > 0) {
        qualities.add(_HlsQuality(label: '${t.height}p', height: t.height!, track: t));
      }
    }
    // Sort ascending
    qualities.sort((a, b) => a.height.compareTo(b.height));
    if (mounted) {
      setState(() {
        _qualities = qualities;
        _selectedQuality = qualities.first;
      });
    }
  }

  void _applyQuality(_HlsQuality quality) {
    setState(() => _selectedQuality = quality);
    if (quality.track != null) {
      _controller?.setTrack(quality.track!);
    }
  }

  // ─────────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────────
  void _disposeController() {
    if (_controllerDisposed) return;
    _controllerDisposed = true;
    try { _controller?.removeEventsListener(_onPlayerEvent); } catch (_) {}
    try { _controller?.pause(); } catch (_) {}
    try { _controller?.clearCache(); } catch (_) {}
    try { _controller?.dispose(); } catch (_) {}
    _controller = null;
  }

  // ─────────────────────────────────────────────
  // BACK / NAVIGATE
  // ─────────────────────────────────────────────
  Future<void> _handleBack() async {
    if (_isHandlingBack || _isDisposed) return;
    _isHandlingBack = true;
    _isDisposed = true;

    _hideTimer?.cancel();
    _unlockHideTimer?.cancel();
    _brightnessTimer?.cancel();
    _volumeTimer?.cancel();

    _disposeController();

    try { WakelockPlus.disable(); } catch (_) {}

    if (Get.isRegistered<DetailsController>()) {
      Get.delete<DetailsController>(force: true);
    }

    // Pop back — TrailerFullScreen is a single route (no BetterPlayer fullscreen push)
    if (mounted) {
      Navigator.of(context).pop();
    }

    await Future.delayed(const Duration(milliseconds: 150));
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  // ─────────────────────────────────────────────
  // CONTROLS HELPERS
  // ─────────────────────────────────────────────
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

  void _togglePlayPause() {
    if (_isLocked || _isDisposed) return;
    final isPlaying = _controller?.isPlaying() ?? false;
    isPlaying ? _controller?.pause() : _controller?.play();
    setState(() {});
    _startHideTimer();
  }

  void _toggleFillMode() {
    setState(() => _isFillMode = !_isFillMode);
    _startHideTimer();
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
    final v = _controller?.videoPlayerController?.value;
    if (v == null) return;
    final current = v.position;
    final total = v.duration ?? Duration.zero;
    final newMs = (current.inMilliseconds + seconds * 1000)
        .clamp(0, total.inMilliseconds);
    setState(() => _isSeeking = true);
    await _controller?.seekTo(Duration(milliseconds: newMs));
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

  void _openSettingsDialog() {
    if (_isLocked) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _TrailerSettingsDialog(
        qualities: _qualities,
        selectedQuality: _selectedQuality,
        speed: _speed,
        onQualitySelected: (q) {
          Navigator.pop(context);
          _applyQuality(q);
        },
        onSpeedSelected: (s) {
          setState(() => _speed = s);
          _controller?.setSpeed(s);
          Navigator.pop(context);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FORMAT
  // ─────────────────────────────────────────────
  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  // ─────────────────────────────────────────────
  // WIDGETS
  // ─────────────────────────────────────────────
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

  Widget _seekOverlay(bool right) {
    final show = right ? _showSeekRight : _showSeekLeft;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedScale(
          scale: show ? 1.0 : 0.9,
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
                Icon(right ? Icons.fast_forward : Icons.fast_rewind,
                    color: Colors.white, size: 22),
                const SizedBox(width: 6),
                const Text('10 sec',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
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
          Icon(icon, color: Colors.white, size: 26),
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
          Text('${(value * 100).toInt()}%',
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────────
  @override
  void dispose() {
    _isDisposed = true;
    WakelockPlus.disable();
    _hideTimer?.cancel();
    _unlockHideTimer?.cancel();
    _brightnessTimer?.cancel();
    _volumeTimer?.cancel();
    if (!_isHandlingBack) {
      _disposeController();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isPlaying = _controller?.isPlaying() ?? false;

    return WillPopScope(
      onWillPop: () async {
        await _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _controller == null
            ? const Center(
                child: CircularProgressIndicator(color: Colors.red))
            : Stack(
                children: [
                  // ── Video ──
                  Positioned.fill(
                    child: _isFillMode
                        ? SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: BetterPlayer(controller: _controller!),
                              ),
                            ),
                          )
                        : BetterPlayer(controller: _controller!),
                  ),

                  // ── Loading before ready ──
                  if (!_isVideoReady)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 3, color: Colors.red),
                        ),
                      ),
                    ),

                  // ── Buffering / seeking spinner ──
                  if (_isVideoReady && (_isBuffering || _isSeeking))
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        child: const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 3, color: Colors.red),
                        ),
                      ),
                    ),

                  // ── Gesture zones ──
                  // Left half: tap/double-tap/brightness
                  Positioned(
                    left: 0, top: 0, bottom: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _toggleControls,
                        onDoubleTap: _isLocked ? null : () async {
                          _showSeekEffect(false);
                          await _seekBy(-10);
                        },
                        onVerticalDragUpdate: (details) async {
                          if (_isLocked || _isDisposed) return;
                          final delta = details.primaryDelta! / 300;
                          _brightness = (_brightness - delta).clamp(0.0, 1.0);
                          await ScreenBrightness().setScreenBrightness(_brightness);
                          if (!_isDisposed) setState(() => _showBrightnessUI = true);
                          _brightnessTimer?.cancel();
                          _brightnessTimer = Timer(const Duration(milliseconds: 800), () {
                            if (mounted && !_isDisposed)
                              setState(() => _showBrightnessUI = false);
                          });
                        },
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),

                  // Right half: tap/double-tap/volume
                  Positioned(
                    right: 0, top: 0, bottom: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _toggleControls,
                        onDoubleTap: _isLocked ? null : () async {
                          _showSeekEffect(true);
                          await _seekBy(10);
                        },
                        onVerticalDragUpdate: (details) async {
                          if (_isLocked || _isDisposed) return;
                          final delta = details.primaryDelta! / 300;
                          _volume = (_volume - delta).clamp(0.0, 1.0);
                          VolumeController().setVolume(_volume);
                          if (!_isDisposed) setState(() => _showVolumeUI = true);
                          _volumeTimer?.cancel();
                          _volumeTimer = Timer(const Duration(milliseconds: 800), () {
                            if (mounted && !_isDisposed)
                              setState(() => _showVolumeUI = false);
                          });
                        },
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),

                  // ── Seek overlays ──
                  Positioned(
                      left: 20, top: 0, bottom: 0,
                      child: Center(child: _seekOverlay(false))),
                  Positioned(
                      right: 20, top: 0, bottom: 0,
                      child: Center(child: _seekOverlay(true))),

                  // ── Center play/pause/seek buttons ──
                  if (_showControls && !_isLocked && _isVideoReady)
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _circleButton(Icons.fast_rewind,
                              onTap: () => _seekBy(-10)),
                          const SizedBox(width: 28),
                          _circleButton(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            onTap: _togglePlayPause,
                          ),
                          const SizedBox(width: 28),
                          _circleButton(Icons.fast_forward,
                              onTap: () => _seekBy(10)),
                        ],
                      ),
                    ),

                  // ── Top bar ──
                  if (_showControls && !_isLocked)
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _handleBack,
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.white),
                              ),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: _toggleFillMode,
                                icon: Icon(
                                  _isFillMode
                                      ? Icons.fit_screen
                                      : Icons.crop_free,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: _toggleLock,
                                icon: const Icon(Icons.lock_open,
                                    color: Colors.white),
                              ),
                              IconButton(
                                onPressed: _openSettingsDialog,
                                icon: const Icon(Icons.settings,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ── Bottom bar: progress + rotation ──
                  if (_showControls && !_isLocked && _isVideoReady)
                    Positioned(
                      bottom: 10, left: 14, right: 14,
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Slider(
                              activeColor: Colors.red,
                              inactiveColor: Colors.white24,
                              value: _position.inSeconds
                                  .toDouble()
                                  .clamp(
                                    0,
                                    _duration.inSeconds.toDouble() == 0
                                        ? 1
                                        : _duration.inSeconds.toDouble(),
                                  ),
                              max: _duration.inSeconds.toDouble() == 0
                                  ? 1
                                  : _duration.inSeconds.toDouble(),
                              onChangeStart: (_) =>
                                  setState(() => _isDragging = true),
                              onChanged: (v) => setState(() =>
                                  _position = Duration(seconds: v.toInt())),
                              onChangeEnd: (v) async {
                                setState(() => _isDragging = false);
                                await _controller?.seekTo(
                                    Duration(seconds: v.toInt()));
                                _startHideTimer();
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_format(_position)} / ${_format(_duration)}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                                GestureDetector(
                                  onTap: _toggleRotation,
                                  child: Icon(
                                    _currentOrientation ==
                                            DeviceOrientation.landscapeLeft
                                        ? Icons.screen_rotation_alt
                                        : Icons.screen_rotation,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Lock button (when locked) ──
                  if (_isLocked && _showUnlockButton)
                    Positioned(
                      right: 18, top: 0, bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _toggleLock,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_open,
                                color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                    ),

                  // ── Brightness indicator ──
                  if (_showBrightnessUI)
                    Positioned(
                      left: 20, top: 0, bottom: 0,
                      child: Center(
                          child: _sideIndicator(
                              Icons.brightness_6, _brightness)),
                    ),

                  // ── Volume indicator ──
                  if (_showVolumeUI)
                    Positioned(
                      right: 20, top: 0, bottom: 0,
                      child:
                          Center(child: _sideIndicator(Icons.volume_up, _volume)),
                    ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _TrailerSettingsDialog extends StatefulWidget {
  final List<_HlsQuality> qualities;
  final _HlsQuality? selectedQuality;
  final double speed;
  final Function(_HlsQuality) onQualitySelected;
  final Function(double) onSpeedSelected;

  const _TrailerSettingsDialog({
    required this.qualities,
    required this.selectedQuality,
    required this.speed,
    required this.onQualitySelected,
    required this.onSpeedSelected,
  });

  @override
  State<_TrailerSettingsDialog> createState() => _TrailerSettingsDialogState();
}

class _TrailerSettingsDialogState extends State<_TrailerSettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late double _selectedSpeed;
  _HlsQuality? _selectedQuality;

  @override
  void initState() {
    super.initState();
    _selectedSpeed = widget.speed;
    _selectedQuality = widget.selectedQuality;
    _tabController = TabController(length: 2, vsync: this);
  }

  Widget _rowItem(String title,
      {bool selected = false, VoidCallback? onTap}) {
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
                        fontSize: 15, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Quality'),
                      Tab(text: 'Speed'),
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
                  // Quality tab
                  widget.qualities.isEmpty
                      ? const Center(
                          child: Text('No quality options',
                              style: TextStyle(color: Colors.white54)))
                      : ListView(
                          children: widget.qualities.map((q) {
                            final selected =
                                _selectedQuality?.label == q.label;
                            return _rowItem(q.label,
                                selected: selected,
                                onTap: () {
                                  setState(() => _selectedQuality = q);
                                  widget.onQualitySelected(q);
                                });
                          }).toList(),
                        ),

                  // Speed tab
                  ListView(
                    children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((s) {
                      final selected = _selectedSpeed == s;
                      return _rowItem(
                        s == 1.0 ? '1x  Normal' : '${s}x',
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
class _HlsQuality {
  final String label;
  final int height;
  final BetterPlayerAsmsTrack? track;

  _HlsQuality({required this.label, required this.height, this.track});
}