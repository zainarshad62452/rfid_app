import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rfid_app/controllers/userController.dart';
import 'package:rfid_app/models/userModel.dart';

class AllStudents extends StatelessWidget {
  AllStudents({Key? key});
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.tealAccent.shade700,
        title: Text("All Students"),
      ),
      body: StreamBuilder(
        stream: _databaseReference.child("students").onValue,
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

          // Display a list of students
          List<Widget> studentWidgets = [];
          data.forEach((key, value) {
            final student = Student.fromJson(value);
            studentWidgets.add(
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child:ExpansionTile(title: Text("Student Name: ${student.name}"),
                  children: [
                    Text('Father Name: ${student.parentName}'),
                    Text('Serial Number: ${student.rfidNumber}'),
                    Text('RolNo: ${student.rollNo}'),
                    Text('Class: ${student.className}'),
                  ],),
                ),
              ),
            );
          });

          // Use the data to update your UI accordingly
          return ListView(
            children: studentWidgets,
          );
        },
      ),
    );
  }
}

