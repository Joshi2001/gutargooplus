// // lib/app/services/vast_parser_service.dart
// import 'package:gutrgoopro/ad/model/ad_model.dart';
// import 'package:xml/xml.dart';

// class VastParserService {
//   VastModel? parse(String xmlString) {
//     try {
//       final doc = XmlDocument.parse(xmlString);

//       // ── Media file ──────────────────────────────────────────────
//       final mediaFile = doc
//           .findAllElements('MediaFile')
//           .firstWhere((e) => e.getAttribute('type') == 'video/mp4',
//               orElse: () => doc.findAllElements('MediaFile').first);
//       final mediaUrl = mediaFile.innerText.trim();

//       // ── Duration ────────────────────────────────────────────────
//       final durText = doc.findAllElements('Duration').first.innerText.trim();
//       final duration = _parseDuration(durText);

//       // ── Skip offset ─────────────────────────────────────────────
//       final linearEl = doc.findAllElements('Linear').firstOrNull;
//       int skipOffset = -1;
//       if (linearEl != null) {
//         final raw = linearEl.getAttribute('skipoffset');
//         if (raw != null) skipOffset = _parseDuration(raw);
//       }

//       // ── Impression URLs ─────────────────────────────────────────
//       final impressions = doc
//           .findAllElements('Impression')
//           .map((e) => e.innerText.trim())
//           .toList();

//       // ── Tracking events ─────────────────────────────────────────
//       final tracking = <String, List<String>>{};
//       for (final el in doc.findAllElements('Tracking')) {
//         final event = el.getAttribute('event') ?? '';
//         tracking.putIfAbsent(event, () => []).add(el.innerText.trim());
//       }

//       // ── Click-through ───────────────────────────────────────────
//       final clickThrough =
//           doc.findAllElements('ClickThrough').firstOrNull?.innerText.trim();

//       // ── Companion ───────────────────────────────────────────────
//       CompanionAd? companion;
//       final compEl = doc.findAllElements('Companion').firstOrNull;
//       if (compEl != null) {
//         final imgUrl =
//             compEl.findAllElements('StaticResource').firstOrNull?.innerText.trim();
//         final clickUrl =
//             compEl.findAllElements('CompanionClickThrough').firstOrNull?.innerText.trim();
//         final w = int.tryParse(compEl.getAttribute('width') ?? '') ?? 0;
//         final h = int.tryParse(compEl.getAttribute('height') ?? '') ?? 0;
//         if (imgUrl != null) {
//           companion = CompanionAd(imageUrl: imgUrl, clickUrl: clickUrl, width: w, height: h);
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
//       print('VAST parse error: $e');
//       return null;
//     }
//   }

//   int _parseDuration(String hms) {
//     // HH:MM:SS or HH:MM:SS.mmm
//     final parts = hms.split(':');
//     if (parts.length != 3) return 0;
//     final h = int.tryParse(parts[0]) ?? 0;
//     final m = int.tryParse(parts[1]) ?? 0;
//     final s = double.tryParse(parts[2]) ?? 0;
//     return h * 3600 + m * 60 + s.toInt();
//   }
// }