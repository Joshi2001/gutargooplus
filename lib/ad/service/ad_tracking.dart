// // lib/app/services/tracking_service.dart
// import 'package:get/get.dart';

// class TrackingService {
//   final _fired = <String>{};

//   Future<void> fireUrls(List<String> urls) async {
//     for (final url in urls) {
//       if (_fired.contains(url)) continue;
//       _fired.add(url);
//       try {
//         await GetConnect().get(url); // fire-and-forget pixel
//       } catch (_) {}
//     }
//   }

//   void reset() => _fired.clear();
// }