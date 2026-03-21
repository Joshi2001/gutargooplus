// // lib/app/repositories/ad_repository.dart
// import 'package:get/get.dart';

// class AdRepository {
//   Future<String?> fetchVastXml(String vastUrl) async {
//     try {
//       final response = await GetConnect().get(vastUrl);
//       if (response.statusCode == 200) return response.bodyString;
//       return null;
//     } catch (_) {
//       return null;
//     }
//   }
// }