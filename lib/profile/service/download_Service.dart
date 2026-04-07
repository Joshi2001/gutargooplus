import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadService {
  static const String baseUrl = "http://81.17.100.176/api";

  Future<String?> getDownloadUrl(String videoId, String token) async {
    try {
      final url = "$baseUrl/download/$videoId";
      print("📡 URL: $url");
      print("🔑 Token: $token");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("📥 Status: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['url'];
        }
      } else {
        print("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ API error: $e");
    }
    return null;
  }
  
  Future<String?> downloadFile({
    required String downloadUrl,
    required String videoId,
    required void Function(double progress) onProgress,
  }) async {
    try {
      // ❌ HLS block karo
      if (downloadUrl.contains(".m3u8")) {
        print("❌ HLS stream detected → skip download");
        return null;
      }

      final response = await http.Client().send(
        http.Request('GET', Uri.parse(downloadUrl)),
      );

      if (response.statusCode != 200) {
        print("❌ Download failed: ${response.statusCode}");
        return null;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final filePath =
          "${appDir.path}/${videoId}_${DateTime.now().millisecondsSinceEpoch}.mp4";

      final file = File(filePath);
      final sink = file.openWrite();

      int received = 0;
      final total = response.contentLength ?? 0;

      await for (var chunk in response.stream) {
        received += chunk.length;
        if (total != 0) {
          onProgress(received / total);
        }
        sink.add(chunk);
      }

      await sink.close();

      // ✅ File size check
      final fileSize = await file.length();
      print("📁 FILE SIZE: $fileSize");

      if (fileSize < 500000) {
        print("❌ Invalid video → deleting");
        await file.delete();
        return null;
      }

      print("✅ VALID VIDEO SAVED: $filePath");
      return filePath;
    } catch (e) {
      print("❌ File download error: $e");
      return null;
    }
  }

  // ✅ File delete karo
  Future<void> deleteFile(String? filePath) async {
    if (filePath == null) return;
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print("🗑 Deleted: $filePath");
      }
    } catch (e) {
      print("❌ Delete error: $e");
    }
  }
}