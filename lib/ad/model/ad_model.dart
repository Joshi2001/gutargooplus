// // lib/ad/model/ad_model.dart  (ya jahan bhi yeh file hai)

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:xml/xml.dart';

// enum VastAdState { idle, loading, playing, skippable, finished, error }

// // ── CompanionAd ──────────────────────────────────────────────────
// class CompanionAd {
//   final String imageUrl;
//   final String? clickUrl;
//   final int width;
//   final int height;

//   const CompanionAd({
//     required this.imageUrl,
//     this.clickUrl,
//     required this.width,
//     required this.height,
//   });
// }

// // ── VastModel ────────────────────────────────────────────────────
// class VastModel {
//   final String mediaUrl;
//   final int duration;
//   final int skipOffset;
//   final String? clickThroughUrl;
//   final List<String> impressionUrls;
//   final Map<String, List<String>> trackingEvents;
//   final CompanionAd? companionAd;  // ← CompanionAd (not CompanionAdModel)

//   const VastModel({
//     required this.mediaUrl,
//     required this.duration,
//     this.skipOffset = -1,
//     this.clickThroughUrl,
//     this.impressionUrls = const [],
//     this.trackingEvents = const {},
//     this.companionAd,
//   });

//   bool get isSkippable => skipOffset >= 0;
// }

// // ── VastParserService ────────────────────────────────────────────
// class VastParserService {
//   VastModel? parse(String xmlString) {
//     try {
//       final doc = XmlDocument.parse(xmlString);

//       final mediaFile = doc.findAllElements('MediaFile').firstWhere(
//             (e) => e.getAttribute('type') == 'video/mp4',
//             orElse: () => doc.findAllElements('MediaFile').first,
//           );
//       final mediaUrl = mediaFile.innerText.trim();
//       if (mediaUrl.isEmpty) return null;

//       final durText = doc
//               .findAllElements('Duration')
//               .firstOrNull
//               ?.innerText
//               .trim() ??
//           '00:00:30';
//       final duration = _parseDuration(durText);

//       int skipOffset = -1;
//       final linearEl = doc.findAllElements('Linear').firstOrNull;
//       if (linearEl != null) {
//         final raw = linearEl.getAttribute('skipoffset');
//         if (raw != null) skipOffset = _parseDuration(raw);
//       }

//       final impressions = doc
//           .findAllElements('Impression')
//           .map((e) => e.innerText.trim())
//           .where((u) => u.isNotEmpty)
//           .toList();

//       final tracking = <String, List<String>>{};
//       for (final el in doc.findAllElements('Tracking')) {
//         final event = el.getAttribute('event') ?? '';
//         final url = el.innerText.trim();
//         if (event.isNotEmpty && url.isNotEmpty) {
//           tracking.putIfAbsent(event, () => []).add(url);
//         }
//       }

//       final clickThrough =
//           doc.findAllElements('ClickThrough').firstOrNull?.innerText.trim();

//       // ── Companion ──────────────────────────────────────────────
//       CompanionAd? companion;  // ← CompanionAd (not CompanionAdModel)
//       final compEl = doc.findAllElements('Companion').firstOrNull;
//       if (compEl != null) {
//         final imgUrl = compEl
//             .findAllElements('StaticResource')
//             .firstOrNull
//             ?.innerText
//             .trim();
//         final clickUrl = compEl
//             .findAllElements('CompanionClickThrough')
//             .firstOrNull
//             ?.innerText
//             .trim();
//         final w = int.tryParse(compEl.getAttribute('width') ?? '') ?? 0;
//         final h = int.tryParse(compEl.getAttribute('height') ?? '') ?? 0;
//         if (imgUrl != null && imgUrl.isNotEmpty) {
//           companion = CompanionAd(  // ← CompanionAd (not CompanionAdModel)
//               imageUrl: imgUrl, clickUrl: clickUrl, width: w, height: h);
//         }
//       }

//       return VastModel(
//         mediaUrl: mediaUrl,
//         duration: duration,
//         skipOffset: skipOffset,
//         clickThroughUrl: clickThrough,
//         impressionUrls: impressions,
//         trackingEvents: tracking,
//         companionAd: companion,
//       );
//     } catch (e) {
//       debugPrint('VAST parse error: $e');
//       return null;
//     }
//   }

//   int _parseDuration(String hms) {
//     final parts = hms.split(':');
//     if (parts.length != 3) return 0;
//     final h = int.tryParse(parts[0]) ?? 0;
//     final m = int.tryParse(parts[1]) ?? 0;
//     final s = double.tryParse(parts[2]) ?? 0;
//     return h * 3600 + m * 60 + s.toInt();
//   }
// }

// class VastTrackingService {
//   final _fired = <String>{};

//   Future<void> fire(List<String>? urls) async {
//     if (urls == null || urls.isEmpty) return;
//     for (final url in urls) {
//       if (_fired.contains(url)) continue;
//       _fired.add(url);
//       try {
//         http.get(Uri.parse(url));
//       } catch (_) {}
//     }
//   }

//   void reset() => _fired.clear();
// }