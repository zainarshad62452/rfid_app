import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:rfid_app/screens/auth/signIn.dart';

import '../Controllers/loading.dart';
import '../screens/widgets/snackbar.dart';
import 'Reception.dart';
import 'userServices.dart';

class Authentication {
  FirebaseAuth auth = FirebaseAuth.instance;

  void createAccount({
    required String name,
    required String email,
    required String pass,
    required String? rfidNumber,
    required String? parentName,
    required String? className,
    required int? rollNo,
  }) async {
    loading(true);
    try {
      final user = await auth.createUserWithEmailAndPassword(
          email: email, password: pass);
      if (user.user != null) {
        UserServices().registerUser(
            name: name, user: user.user!,rfidNumber: rfidNumber!, parentName: parentName!, className: className!, rollNo: rollNo!);
        Get.back();
        loading(false);
      } else {
        loading(false);
        alertSnackbar(
          "Unknown Error",
        );
      }
    } catch (e) {
      loading(false);
      alertSnackbar(
          e.toString().contains(']') ? e.toString().split(']').last : e.toString());
    }
  }


  void signinWithEmail(String email, String pass) async {
    try {
      loading(true);
      await auth.signInWithEmailAndPassword(email: email, password: pass).then(
            (value) {
          if (value.user != null) {
            loading(false);
            Reception().userReception();
          } else {
            loading(false);
            alertSnackbar("Unknown error");
          }
        },
      );
    } catch (e) {
      loading(false);
      alertSnackbar(e.toString().split(']').last);
    }
  }

  void forgotPassword(String email) async {
    loading(true);

    try {
      await auth.sendPasswordResetEmail(email: email);
      loading(false);
      snackbar('Success', 'Password reset email sent to $email');
    } catch (e) {
      loading(false);
      alertSnackbar(e.toString().split(']').last);
    }
  }

  void signOut() async {
    try {
      await auth.signOut();
      Get.put(LoadingController());
      Get.offAll(() => SignIn());
    } catch (e) {
      snackbar("Error Signing Out", e.toString());
    }
  }
}
