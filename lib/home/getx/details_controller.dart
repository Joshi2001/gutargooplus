import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DetailsController extends GetxController {
  var isFavorite = false.obs;
  var isShare = false.obs;
  var isDownload = false.obs;
  var currentTab = 'iptv'.obs;
  var shareTab = 'share'.obs;
  var downloadTab = 'dow'.obs;

  void toggleFavorite() => isFavorite.value = !isFavorite.value;
  void toggleShare() => isShare.value = !isShare.value;
  void toggleDownload() => isDownload.value = !isDownload.value;

  void changeTab(String tab) {
    currentTab.value = tab;  
    shareTab.value = tab;
    downloadTab.value = tab;
  }
  var castList = [
  {
    "name": "Parambrata Chattopadhyay",
    "role": "Director",
    "image": "assets/cast1.jpg"
  },
  {
    "name": "Anirban Bhattacharya",
    "role": "Actor",
    "image": "assets/cast2.jpg"
  },
  {
    "name": "Parno Mittra",
    "role": "Actor",
    "image": "assets/cast3.jpg"
  },
  {
    "name": "Rajatava Dutta",
    "role": "Actor",
    "image": "assets/cast4.jpg"
  },
  {
    "name": "Anirban Bhattacharya",
    "role": "Actor",
    "image": "assets/cast2.jpg"
  },
  {
    "name": "Parno Mittra",
    "role": "Actor",
    "image": "assets/cast3.jpg"
  },
  {
    "name": "Rajatava Dutta",
    "role": "Actor",
    "image": "assets/cast4.jpg"
  },
].obs;
}
