
import 'package:get/get.dart';
import 'package:gutrgoopro/profile/model/history_model.dart';

class HistoryController extends GetxController {
  final RxList<HistoryModel> history = <HistoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    history.addAll([
     
    ]);
  }

  void deleteItem(int index) {
    history.removeAt(index);
  }

  void clearAllHistory() {
    history.clear();
  }

  void addToHistory(HistoryModel item) {
    history.insert(0, item);
  }
}
