import 'package:get/get.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';

class ViewAllController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  RxList<dynamic> items = <dynamic>[].obs;
  @override
  void onInit() {
    super.onInit();
    items.assignAll(homeController.trendingList);
  }
  @override
void onClose() {
  print("ViewAllController disposed");
  super.onClose();
}
}
