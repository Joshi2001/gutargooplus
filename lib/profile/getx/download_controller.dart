import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:gutrgoopro/profile/model/download_model.dart';

class DownloadsController extends GetxController {
  RxList<DownloadItem> downloads = <DownloadItem>[].obs;

 void addDownload(DownloadItem item) {
  if (!downloads.any((d) => d.videoTrailer == item.videoTrailer)) {
    downloads.add(item);
  }
  print("Added: ${item.title}");          
  print("Total downloads: ${downloads.length}");
}
  void deleteItem(int index) {
    downloads.removeAt(index);
  }
  bool isDownloaded(String videoTrailer) {
  return downloads.any((e) => e.videoTrailer == videoTrailer);
}

}
