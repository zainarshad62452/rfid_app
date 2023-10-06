import 'package:get/get.dart';
import 'package:rfid_app/models/checkInModel.dart';
import 'package:rfid_app/services/checkInServices.dart';


final checksCntr = Get.find<CheckInController>();

class CheckInController extends GetxController {
  RxList<CheckIn>? allItems = <CheckIn>[].obs;
  @override
  void onReady() {
    initAdminStream();
  }

  initAdminStream() async {
    allItems!.bindStream(CheckInServices().streamAllItems()!);
  }
}
