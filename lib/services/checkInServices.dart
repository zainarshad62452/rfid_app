import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:rfid_app/models/checkInModel.dart';
import '../Controllers/loading.dart';
import '../screens/widgets/snackbar.dart';

class CheckInServices {
  final auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.ref();

  void addCheck({
    required String name,
    required DateTime checkInTime,
    required bool checkInOrOut,
    required String rfidNumber,
    required String uid,
  }) async {
    loading(true);
    var x = CheckIn(
      studentName: name,
      checkInTime: checkInTime,
      checkInOrOut: checkInOrOut,
      rfidNumber: rfidNumber,
    );

    try {
      final userRef = _databaseReference.child("checks").push();
      x.uid = userRef.key!;
      await userRef.set(x.toJson()).then((value){
        _databaseReference.child("students").child(uid).update({
          "check": checkInOrOut
        }).then((value) => snackbar("Success", "Attendance is Updated Successfully"));
      });
      loading(false);
    } catch (e) {
      loading(false);
      // Handle error
    }
  }

  Stream<List<CheckIn>>? streamAllItems() {
    try {
      return _databaseReference.child("checks").onValue.map((event) {
        loading(false);
        List<CheckIn> list = [];
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> data = event.snapshot.value as Map;

          // Extract values and sort by check-in time in descending order
          List<CheckIn> sortedList = data.values
              .map((value) => CheckIn.fromJson(value))
              .toList()
            ..sort((a, b) => b.checkInTime!.compareTo(a.checkInTime!));

          list.addAll(sortedList);
        }
        loading(false);
        return list;
      });
    } catch (e) {
      loading(false);
      return null;
    }
  }

}
