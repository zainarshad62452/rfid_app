import 'package:get/get.dart';
import 'package:rfid_app/models/userModel.dart';
import 'package:rfid_app/services/userServices.dart';



final userCntr = Get.find<UserController>();

class UserController extends GetxController {
  Rx<Student>? user = Student().obs;
  RxList<Student>? allUsers = <Student>[].obs;
  @override
  void onReady() {
    initAdminStream();
  }



  initAdminStream() async {
    user!.bindStream(UserServices().streamUser()!);
    allUsers!.bindStream(UserServices().streamAllStudents()!);
  }
}
