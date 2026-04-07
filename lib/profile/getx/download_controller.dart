import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gutrgoopro/profile/model/download_model.dart';
import 'package:gutrgoopro/profile/service/download_Service.dart';

class DownloadsController extends GetxController {
  final DownloadService _service = DownloadService();
  static const String _storageKey = 'saved_downloads';

  RxList<DownloadItem> downloads = <DownloadItem>[].obs;
  RxMap<String, RxDouble> downloadProgress = <String, RxDouble>{}.obs;
  RxMap<String, RxBool> downloadingItems = <String, RxBool>{}.obs;
  RxMap<String, RxBool> downloadedItems = <String, RxBool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedDownloads(); // ✅ App open hone par load karo
  }

  // ✅ SharedPreferences se load karo
  Future<void> _loadSavedDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_storageKey) ?? [];
      final loaded = jsonList
          .map((s) => DownloadItem.fromJson(jsonDecode(s)))
          .toList();

      downloads.assignAll(loaded);

      // ✅ Har item ke liye downloadedItems mark karo
      for (final item in loaded) {
        downloadedItems[item.videoTrailer] = true.obs;
      }

      print("✅ Loaded ${loaded.length} downloads from storage");
    } catch (e) {
      print("❌ Load error: $e");
    }
  }

  // ✅ SharedPreferences mein save karo
  Future<void> _persistDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList =
          downloads.map((d) => jsonEncode(d.toJson())).toList();
      await prefs.setStringList(_storageKey, jsonList);
    } catch (e) {
      print("❌ Persist error: $e");
    }
  }

  // ✅ Download start karo
  Future<void> downloadVideo({
    required String videoId,
    required String videoTitle,
    required String subtitle,
    required String image,
    required String videoTrailer,
    required String token,
  }) async {
    try {
      if (token.isEmpty) {
        print("❌ TOKEN IS EMPTY");
        return;
      }

      downloadProgress[videoId] = 0.0.obs;
      downloadingItems[videoId] = true.obs;
      downloadedItems[videoId] = false.obs;

      final downloadUrl = await _service.getDownloadUrl(videoId, token);
      if (downloadUrl == null) {
        print("❌ Failed to get download URL");
        downloadingItems[videoId]?.value = false;
        return;
      }

      final filePath = await _service.downloadFile(
        downloadUrl: downloadUrl,
        videoId: videoId,
        onProgress: (progress) {
          downloadProgress[videoId]?.value = progress;
        },
      );

      downloadingItems[videoId]?.value = false;

      if (filePath != null) {
        downloadedItems[videoId]?.value = true;
        downloadProgress[videoId]?.value = 1.0;

        _addDownload(DownloadItem(
          title: videoTitle,
          subtitle: subtitle,
          image: image,
          videoTrailer: videoTrailer,
          downloadedPath: filePath,  // ✅ local file path saved
          downloadedAt: DateTime.now(),
        ));
      } else {
        downloadedItems[videoId]?.value = false;
        downloadProgress[videoId]?.value = 0.0;
      }
    } catch (e) {
      print("❌ Download error: $e");
      downloadingItems[videoId]?.value = false;
    }
  }

  void _addDownload(DownloadItem item) {
    if (!downloads.any((d) => d.videoTrailer == item.videoTrailer)) {
      downloads.add(item);
      _persistDownloads(); // ✅ Save to disk
    }
  }

  Future<void> deleteItem(int index) async {
    if (index < 0 || index >= downloads.length) return;
    final item = downloads[index];
    await _service.deleteFile(item.downloadedPath);
    downloads.removeAt(index);
    downloadedItems.remove(item.videoTrailer);
    downloadProgress.remove(item.videoTrailer);
    downloadingItems.remove(item.videoTrailer);
    await _persistDownloads(); // ✅ Update disk
  }

  double getProgress(String videoId) =>
      downloadProgress[videoId]?.value ?? 0.0;

  bool isDownloading(String videoId) =>
      downloadingItems[videoId]?.value ?? false;

  bool isItemDownloaded(String videoId) =>
      downloadedItems[videoId]?.value ?? false;

  bool isDownloaded(String videoTrailer) =>
      downloads.any((e) => e.videoTrailer == videoTrailer);
}