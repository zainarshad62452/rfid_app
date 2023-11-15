import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rfid_app/Controllers/loading.dart';
import 'package:rfid_app/Services/Authentication.dart';
import 'package:rfid_app/controllers/userController.dart';
import 'package:rfid_app/screens/widgets/loading.dart';
import 'package:rfid_app/controllers/checksController.dart';

class ParentHomePage extends StatefulWidget {
  @override
  _ParentHomePageState createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController studentName = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  Future<void> _getUser() async {
    user = _auth.currentUser;
  }

  @override
  void initState() {
    super.initState();
    _getUser();
    studentName = new TextEditingController();
  }

  @override
  void dispose() {
    studentName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? _message;
    DateTime now = DateTime.now();
    String _currentHour = DateFormat('kk').format(now);
    int hour = int.parse(_currentHour);

    setState(
          () {
        if (hour >= 5 && hour < 12) {
          _message = 'Good Morning';
        } else if (hour >= 12 && hour <= 17) {
          _message = 'Good Afternoon';
        } else {
          _message = 'Good Evening';
        }
      },
    );
    return Obx(() => Stack(
      children: [
        !loading()?Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: <Widget>[Container()],
            backgroundColor: Colors.white,
            elevation: 0,
            title: Container(
              padding: EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    //width: MediaQuery.of(context).size.width/1.3,
                    alignment: Alignment.center,
                    child: Text(
                      _message!,
                      style: GoogleFonts.lato(
                        color: Colors.black54,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 55,
                  ),
                  IconButton(
                    splashRadius: 20,
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      Authentication().signOut();
                    },
                  ),
                ],
              ),
            ),
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
          ),
          body: SafeArea(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (OverscrollIndicatorNotification overscroll) {
                overscroll.disallowGlow();
                return true;
              },
              child: ListView(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                children: <Widget>[
                  Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 20, bottom: 10),
                        child: Text(
                          "Welcome Parents!",
                          // "Hello " + user!.displayName!,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 20, bottom: 25),
                        child: Text(
                          "Let's Monitor Students",
                          style: GoogleFonts.lato(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 20),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "All CheckIn & Out",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            // color: Colors.blue[800],
                              color: Colors.tealAccent.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      Obx(() => Container(
                        height: 400,
                        padding: EdgeInsets.only(top: 14),
                        child: ListView.builder(
                          physics: ClampingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: checksCntr.allItems?.value.length,
                          itemBuilder: (context, index) {
                            var students = checksCntr.allItems?.value[index];
                            DateTime currentDate = DateTime.now();
                            DateTime checkInDate = students!.checkInTime!;
                            print(checkInDate.year == currentDate.year &&
                                checkInDate.month == currentDate.month &&
                                checkInDate.day == currentDate.day);
                            // Check if the check-in date is today
                            if (checkInDate.year == currentDate.year &&
                                checkInDate.month == currentDate.month &&
                                checkInDate.day == currentDate.day) {
                              // Format date to day, month, year, hour, minute, second, AM/PM
                              String formattedDate = DateFormat('dd MMMM yyyy hh:mm:ss a').format(checkInDate);

                              if(students.rfidNumber == userCntr.user!.value.rfidNumber) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: ListTile(
                                      title: Text(students.studentName!),
                                      subtitle: Text(formattedDate),  // Use the formatted date
                                      trailing: students.checkInOrOut!
                                          ? Text("Check In", style: TextStyle(color: Colors.green))
                                          : Text("Check Out", style: TextStyle(color: Colors.red)),
                                    ),
                                  ),
                                );
                              }
                            }

                            // If it's not today's data or not the current user, return an empty SizedBox
                            return SizedBox.shrink();
                          },
                        ),
                      )),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ):LoadingWidget(),
        LoadingWidget()
      ],
    ));
  }
}

