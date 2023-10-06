import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Import for date formatting
import 'package:rfid_app/controllers/userController.dart';
import 'package:rfid_app/models/checkInModel.dart';
import 'package:rfid_app/models/userModel.dart';
import 'package:rfid_app/services/checkInServices.dart';

class AllChecksInOuts extends StatelessWidget {
  AllChecksInOuts({Key? key});
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.tealAccent.shade700,
        title: const Text("All Checks In & Outs"),
      ),
      body: StreamBuilder(
        stream: _databaseReference.child("checks").onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return Center(child: Text('No data available.'));
          }

          // Process and display your data based on the snapshot
          final data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>;

          // Sort the data based on date
          List<MapEntry<dynamic, dynamic>> sortedData = data.entries.toList()
            ..sort((a, b) {
              var dateA = DateTime.parse(a.value['checkInTime']);
              var dateB = DateTime.parse(b.value['checkInTime']);
              return dateB.compareTo(dateA);
            });

          // Display a list of students for today only
          List<Widget> checkInOutWidgets = [];
          DateTime currentDate = DateTime.now();
          for (var entry in sortedData) {
            final students = CheckIn.fromJson(entry.value);

            // Check if the check-in date is today
            if (students.checkInTime!.year == currentDate.year &&
                students.checkInTime!.month == currentDate.month &&
                students.checkInTime!.day == currentDate.day) {
              String formattedDate = DateFormat('dd MMMM yyyy hh:mm:ss a').format(students.checkInTime!);

              checkInOutWidgets.add(
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(students.studentName!),
                      subtitle: Text(formattedDate),
                      trailing: students.checkInOrOut!
                          ? Text(
                        "Check In",
                        style: TextStyle(color: Colors.green),
                      )
                          : Text(
                        "Check Out",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ),
              );
            }
          }

          // Use the data to update your UI accordingly
          return ListView(
            children: checkInOutWidgets,
          );
        },
      ),
    );
  }
}
