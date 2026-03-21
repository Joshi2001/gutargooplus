// // lib/ad/controller/ad_controller.dart

// import 'dart:async';
// import 'package:better_player_enhanced/better_player.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gutrgoopro/ad/model/ad_model.dart';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';

// enum VastAdState { idle, loading, playing, finished, error }

// class VastAdController extends GetxController {
//   // ── Rx State ──────────────────────────────────────────────────────
//   final adState     = VastAdState.idle.obs;
//   final isAdVisible = false.obs;
//   final countdown   = 0.obs;
//   final canSkip     = false.obs;
//   final adProgress  = 0.0.obs;
//   final adModel     = Rxn<VastModel>();
//   final isMuted     = false.obs;

//   // ✅ Private controller — concurrent modification se bachne ke liye
//   BetterPlayerController? _adPlayerController;
//   BetterPlayerController? get adPlayerController => _adPlayerController;

//   Timer? _countdownTimer;
//   Timer? _skipTimer;
//   bool _firedStart = false;
//   bool _firedQ1    = false;
//   bool _firedMid   = false;
//   bool _firedQ3    = false;
//   bool _isDisposed = false;
//   final _fired     = <String>{};
//   final _parser    = VastParserService();

//   // ─────────────────────────────────────────────────────────────────
//   @override
//   void onInit() {
//     super.onInit();
//     _isDisposed = false;
//     _resetState();
//   }

//   // ─────────────────────────────────────────────────────────────────
//   // PUBLIC RESET — VideoScreen initState mein call karo
//   // ─────────────────────────────────────────────────────────────────
//   void reset() {
//     _countdownTimer?.cancel();
//     _skipTimer?.cancel();
//     _disposePlayer();
//     _resetState();
//   }

//   // ─────────────────────────────────────────────────────────────────
//   // LOAD & PLAY
//   // ─────────────────────────────────────────────────────────────────
//  Future<void> loadAndPlay(String vastUrl) async {
//   if (vastUrl.isEmpty || _isDisposed) return;

//   reset();

//   // ✅ Thoda delay do — content decoder release hone ke liye
//   await Future.delayed(const Duration(milliseconds: 500));
//   if (_isDisposed) return;

//   isAdVisible.value = true;
//   adState.value     = VastAdState.loading;

//     try {
//       final res = await http
//           .get(Uri.parse(vastUrl))
//           .timeout(const Duration(seconds: 8));

//       if (_isDisposed) return;
//       if (res.statusCode != 200) { _onError(); return; }

//       final model = _parser.parse(res.body);
//       if (model == null) { _onError(); return; }

//       adModel.value = model;
//       _fireUrls(model.impressionUrls);
//       await _initBetterPlayer(model);

//     } catch (e) {
//       debugPrint('VAST load error: $e');
//       if (!_isDisposed) _onError();
//     }
//   }

//   Future<void> _initBetterPlayer(VastModel model) async {
//   if (_isDisposed) return;

//   _adPlayerController = BetterPlayerController(
//     const BetterPlayerConfiguration(
//       autoPlay: true,
//       looping: false,
//       fit: BoxFit.contain,
//       allowedScreenSleep: false,
//       handleLifecycle: false,
//       autoDispose: false,
//       controlsConfiguration: BetterPlayerControlsConfiguration(
//         showControls: false,
//       ),
//     ),
//   );

//   await _adPlayerController!.setupDataSource(
//     BetterPlayerDataSource(
//       BetterPlayerDataSourceType.network,
//       model.mediaUrl,
//       // ✅ Cache off rakho — decoder conflict se bachne ke liye
//       cacheConfiguration: const BetterPlayerCacheConfiguration(useCache: false),
//       // ✅ Format explicitly set mat karo — auto detect karne do
//       bufferingConfiguration: const BetterPlayerBufferingConfiguration(
//         minBufferMs: 2000,
//         maxBufferMs: 5000,
//         bufferForPlaybackMs: 1000,
//         bufferForPlaybackAfterRebufferMs: 2000,
//       ),
//     ),
//   );

//     if (_isDisposed) {
//       try { _adPlayerController?.dispose(); } catch (_) {}
//       _adPlayerController = null;
//       return;
//     }

//     _adPlayerController!.addEventsListener(_onPlayerEvent);

//     countdown.value = model.duration;
//     adState.value   = VastAdState.playing;
//     _startCountdown();

//     // Skip timer — sirf skippable ads
//     _skipTimer?.cancel();
//     final skipOffset = model.skipOffset;
//     if (skipOffset >= 0) {
//       final skipAfter = skipOffset > 0 ? skipOffset : 30;
//       _skipTimer = Timer(Duration(seconds: skipAfter), () {
//         if (!_isDisposed && adState.value == VastAdState.playing) {
//           canSkip.value = true;
//         }
//       });
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────
//   // PLAYER EVENT
//   // ─────────────────────────────────────────────────────────────────
//   void _onPlayerEvent(BetterPlayerEvent event) {
//     // ✅ Double guard
//     if (_isDisposed) return;
//     if (_adPlayerController == null) return;

//     final model = adModel.value;
//     if (model == null) return;

//     final v = _adPlayerController?.videoPlayerController?.value;
//     if (v == null) return;

//     final posSec = v.position.inSeconds;
//     final durSec = v.duration?.inSeconds ?? 1;

//     if (durSec > 0) {
//       adProgress.value = (posSec / durSec).clamp(0.0, 1.0);
//     }

//     if (!_firedStart && posSec > 0) {
//       _firedStart = true;
//       _fireUrls(model.trackingEvents['start']);
//     }
//     if (!_firedQ1 && durSec > 0 && posSec >= durSec * 0.25) {
//       _firedQ1 = true;
//       _fireUrls(model.trackingEvents['firstQuartile']);
//     }
//     if (!_firedMid && durSec > 0 && posSec >= durSec * 0.5) {
//       _firedMid = true;
//       _fireUrls(model.trackingEvents['midpoint']);
//     }
//     if (!_firedQ3 && durSec > 0 && posSec >= durSec * 0.75) {
//       _firedQ3 = true;
//       _fireUrls(model.trackingEvents['thirdQuartile']);
//     }

//     if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
//       _fireUrls(model.trackingEvents['complete']);
//       _finish();
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────
//   // COUNTDOWN
//   // ─────────────────────────────────────────────────────────────────
//   void _startCountdown() {
//     _countdownTimer?.cancel();
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (_isDisposed) { _countdownTimer?.cancel(); return; }
//       if (countdown.value > 0) {
//         countdown.value--;
//       } else {
//         _countdownTimer?.cancel();
//       }
//     });
//   }

//   // ─────────────────────────────────────────────────────────────────
//   // PUBLIC ACTIONS
//   // ─────────────────────────────────────────────────────────────────
//   void skipAd() {
//     if (!canSkip.value || _isDisposed) return;
//     _fireUrls(adModel.value?.trackingEvents['skip']);
//     _finish();
//   }

//   void toggleMute() {
//     if (_isDisposed) return;
//     isMuted.value = !isMuted.value;
//     _adPlayerController?.setVolume(isMuted.value ? 0 : 1);
//   }

//   void onAdTap() {
//     if (_isDisposed) return;
//     final url = adModel.value?.clickThroughUrl;
//     if (url == null || url.isEmpty) return;
//     _fireUrls(adModel.value?.trackingEvents['clickTracking']);
//     launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//   }

//   // ─────────────────────────────────────────────────────────────────
//   // INTERNAL
//   // ─────────────────────────────────────────────────────────────────
//   void _finish() {
//     if (_isDisposed) return;
//     _countdownTimer?.cancel();
//     _skipTimer?.cancel();
//     _disposePlayer();
//     _resetState(); 
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//     if (!_isDisposed) {
//       adState.value     = VastAdState.finished;
//       isAdVisible.value = false;
//     }
//   });
//   }

//   void _onError() {
//     if (_isDisposed) return;
//     _disposePlayer();
//     _resetState();
//      WidgetsBinding.instance.addPostFrameCallback((_) {
//     if (!_isDisposed) {
//       adState.value     = VastAdState.error;
//       isAdVisible.value = false;
//     }
//   });
//   }

//   // ✅ MAIN FIX: pehle null karo, phir microtask mein dispose
//   // Yeh concurrent modification error khatam karta hai
//   void _disposePlayer() {
//     final ctrl = _adPlayerController;
//     _adPlayerController = null; // ✅ Turant null — listener ab fire nahi karega

//     if (ctrl == null) return;

//     // ✅ Microtask mein dispose — current event iteration complete hone do
//     Future.microtask(() {
//       try { ctrl.removeEventsListener(_onPlayerEvent); } catch (_) {}
//       try { ctrl.pause(); } catch (_) {}
//       try { ctrl.dispose(); } catch (_) {}
//     });
//   }

//   void _resetState() {
//     _firedStart = _firedQ1 = _firedMid = _firedQ3 = false;
//     _fired.clear();
//     adState.value     = VastAdState.idle;
//     isAdVisible.value = false;
//     adModel.value     = null;
//     canSkip.value     = false;
//     adProgress.value  = 0.0;
//     isMuted.value     = false;
//     countdown.value   = 0;
//   }

//   void _fireUrls(List<String>? urls) {
//     if (urls == null || _isDisposed) return;
//     for (final url in urls) {
//       if (_fired.contains(url)) continue;
//       _fired.add(url);
//       try { http.get(Uri.parse(url)); } catch (_) {}
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────
//   @override
//   void onClose() {
//     _isDisposed = true;
//     _countdownTimer?.cancel();
//     _skipTimer?.cancel();
//     _disposePlayer();
//     super.onClose();
//   }
// }