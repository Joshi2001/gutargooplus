import 'package:get/get.dart';
import 'package:gutrgoopro/profile/getx/history_controller.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryController>(() => HistoryController());
  }
}
