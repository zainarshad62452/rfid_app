import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rfid_app/controllers/checksController.dart';
import 'package:rfid_app/screens/admin/homePage.dart';
import 'package:rfid_app/screens/auth/signIn.dart';
import 'package:rfid_app/screens/user/homePage.dart';
import '../controllers/userController.dart';

class Reception {
  final auth = FirebaseAuth.instance;
  userReception() async {
    if(FirebaseAuth.instance.currentUser!=null){
      final type =  auth.currentUser!.email;
      if (type == "admin@attendanceapp.com") {
        Get.put(CheckInController());
        Get.put(UserController());
        Get.offAll(() => HomePage());

      }else{
          Get.put(UserController());
          Get.put(CheckInController());
        Get.offAll(() => ParentHomePage());

      }
    }else{
      Get.offAll(() => SignIn());
    }
  }
}
