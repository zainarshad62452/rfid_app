import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rfid_app/Services/Authentication.dart';
import 'package:rfid_app/controllers/userController.dart';
import 'package:rfid_app/screens/admin/allCheckIn&Out.dart';
import 'package:rfid_app/screens/admin/allStudents.dart';
import 'package:rfid_app/screens/admin/rfidReaderConnector.dart';
import 'package:rfid_app/screens/auth/register.dart';
import 'package:rfid_app/screens/widgets/loading.dart';
import '../../Controllers/loading.dart';
import '../../models/cardModel.dart';
import '../widgets/carouselSlider.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController studentName = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  List<CardModel> cards = [
    CardModel("Scan RFID Cards", 0xFFec489a, Icons.search),
    CardModel("Add Students", 0xFFec407a, Icons.add),
    CardModel("All Students", 0xFF5c6bc0, Icons.person),
    CardModel("Check In & Outs", 0xFFfbc02d, Icons.timeline_rounded),
  ];

  Future<void> _getUser() async {
    user = _auth.currentUser;
  }

  Future _signOut() async {
    await _auth.signOut();
  }

  @override
  void initState() {
    super.initState();
    _getUser();
    studentName =  TextEditingController();
    Get.put(UserController());
  }

  @override
  void dispose() {
    studentName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? message;
    DateTime now = DateTime.now();
    String currentHour = DateFormat('kk').format(now);
    int hour = int.parse(currentHour);

    setState(
          () {
        if (hour >= 5 && hour < 12) {
          message = 'Good Morning';
        } else if (hour >= 12 && hour <= 17) {
          message = 'Good Afternoon';
        } else {
          message = 'Good Evening';
        }
      },
    );
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,
          appBar: AppBar(
            leading: IconButton(onPressed: (){
              Authentication().signOut();
            }, icon: const Icon(Icons.logout,color: Colors.black,)),
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
                      message!,
                      style: GoogleFonts.lato(
                        color: Colors.black54,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 55,
                  ),
                  IconButton(
                    splashRadius: 20,
                    icon: const Icon(Icons.notifications_active),
                    onPressed: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (contex) => NotificationList()));
                    },
                  ),
                ],
              ),
            ),
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20, bottom: 10),
                    child: Text(
                      "Welcome Admin",
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
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 25),
                    child: TextFormField(
                      textInputAction: TextInputAction.search,
                      controller: studentName,
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.only(left: 20, top: 10, bottom: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'Search Student',
                        hintStyle: GoogleFonts.lato(
                          color: Colors.black26,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        suffixIcon: Container(
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.shade700!.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            iconSize: 20,
                            splashRadius: 20,
                            color: Colors.white,
                            icon: Icon(CupertinoIcons.search),
                            onPressed: () {},
                          ),
                        ),
                      ),
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      onFieldSubmitted: (String value) {
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 23, bottom: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "We care for you",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        // color: Colors.blue[800],
                          color: Colors.tealAccent.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Carouselslider(),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Our Functions",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        // color: Colors.blue[800],
                          color: Colors.tealAccent.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  Container(
                    height: 150,
                    padding: EdgeInsets.only(top: 14),
                    child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        //print("images path: ${cards[index].cardImage.toString()}");
                        return Container(
                          margin: EdgeInsets.only(right: 14),
                          height: 150,
                          width: 140,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(cards[index].cardBackground),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[400]!,
                                  blurRadius: 4.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(3, 3),
                                ),
                              ]
                            // image: DecorationImage(
                            //   image: AssetImage(cards[index].cardImage),
                            //   fit: BoxFit.fill,
                            // ),
                          ),
                          // ignore: deprecated_member_use
                          child: MaterialButton(
                            onPressed: () {
                              if (cards[index].title == "Add Students") {
                                Get.to(() => Register());
                              } else if (cards[index].title == "All Students") {
                                Get.to(() => AllStudents());
                              } else if (cards[index].title == "Check In & Outs") {
                                Get.to(() => AllChecksInOuts());
                              } else if (cards[index].title == "Scan RFID Cards") {
                                Get.to(() =>  RfidScanner());
                              }
                            },
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(20)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16,
                                ),
                                Container(
                                  child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 29,
                                      child: Icon(
                                        cards[index].cardIcon,
                                        size: 26,
                                        color:
                                        Color(cards[index].cardBackground),
                                      )),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  child: Text(
                                    cards[index].title,
                                    style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
        !loading()?
        SizedBox():LoadingWidget(),
      ],
    );
  }
}