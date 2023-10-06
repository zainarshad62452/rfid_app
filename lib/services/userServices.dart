import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Controllers/loading.dart';
import '../models/userModel.dart';
import '../screens/widgets/snackbar.dart';
import '../services/Reception.dart';

class UserServices {
  final auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.ref();

  void registerUser({
    required String name,
    required User user,
    required String rfidNumber,
    required String parentName,
    required String className,
    required int rollNo,
  }) async {
    loading(true);
    var x = Student(
      name: name,
      email: user.email,
      uid: user.uid,
      rfidNumber: rfidNumber,
      rollNo: rollNo,
      parentName: parentName,
      className: className,
    );

    try {
      await _databaseReference.child("students").child(user.uid).set(x.toJson());
      loading(false);
      Reception().userReception();
    } catch (e) {
      loading(false);
      alertSnackbar("Can't register user");
    }
  }

  Stream<Student>? streamUser() {
    try {
      return _databaseReference
          .child("students")
          .child(auth.currentUser!.uid)
          .onValue
          .map((event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map;
          return Student.fromJson(data);
        } else {
          return Student();
        }
      });
    } catch (e) {
      return null;
    }
  }
  dynamic getStudentByRFID(String rfidNumber) async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

    try {
      DatabaseEvent snapshot = await databaseReference
          .child('students')
          .orderByChild('rfidNumber')
          .equalTo(rfidNumber)
          .limitToFirst(1)
          .once();

      if (snapshot.snapshot.value != null) {
        // Student found, return the student
        return snapshot.snapshot.children.first.value;
      } else {
        // No student found with the given RFID number
        return "No user found";
      }
    } catch (error) {
      // Handle any errors that occur during the database query
      print("Error fetching student: $error");
      return "No user found";
    }
  }

  Stream<Student>? streamSpecificUser(String id) {
    try {
      return _databaseReference
          .child("students")
          .child(id)
          .onValue
          .map((event) {
        if (event.snapshot.value != null) {
          return Student.fromJson(event.snapshot.value as Map<String,dynamic>);
        } else {
          return Student();
        }
      });
    } catch (e) {
      return null;
    }
  }

  Stream<List<Student>>? streamAllStudents() {
    try {
      return _databaseReference.child("students").onValue.map((event) {
        loading(false);
        List<Student> list = [];
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> data = event.snapshot.value as Map;
          data.forEach((key, value) {
            final student = Student.fromJson(value);
            list.add(student);
          });
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
