import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rfid_app/Controllers/loading.dart';
import 'package:rfid_app/Services/userServices.dart';
import 'package:rfid_app/controllers/userController.dart';
import 'package:rfid_app/models/userModel.dart';
import 'package:rfid_app/screens/widgets/loading.dart';
import 'package:rfid_app/screens/widgets/snackbar.dart';
import 'package:rfid_app/services/checkInServices.dart';
import 'package:rfid_c72_plugin/rfid_c72_plugin.dart';
import 'package:rfid_c72_plugin/tag_epc.dart';

class RfidScanner extends StatefulWidget {
  const RfidScanner({Key? key}) : super(key: key);

  @override
  State<RfidScanner> createState() => _RfidScannerState();
}

class _RfidScannerState extends State<RfidScanner> {
  String _platformVersion = 'Unknown';
  final bool _isHaveSavedData = false;
  final bool _isStarted = false;
  final bool _isEmptyTags = false;
  bool _isConnected = false;
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference();
  bool _isLoading = true;
  int _totalEPC = 0, _invalidEPC = 0, _scannedEPC = 0;
  @override
  void initState() {
    super.initState();
    // initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = (await RfidC72Plugin.platformVersion)!;
      print("PlatForm Version $platformVersion");
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
      print("PlatForm Version $platformVersion");
    }
    RfidC72Plugin.connectedStatusStream
        .receiveBroadcastStream()
        .listen(updateIsConnected,onError: (value){
          print( "Error $value");
    },onDone: (){
          print("Done/////////////////////////////");
    });
    // RfidC72Plugin.tagsStatusStream.receiveBroadcastStream().listen(updateTags,onError: (value){
    //   print( "Error $value");
    // },onDone: (){
    //   print("Done/////////////////////////////");
    // });
    await RfidC72Plugin.connect;
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _isLoading = false;
      print("Ho gya");
      if(!_isConnected){
        _isConnected = true;
      }
      loading(false);
    });
  }

  List<String> _data = [];
  final List<String> _EPC = [];
  void updateTags(dynamic result) async {
    setState(() {
      // _data = TagEpc.parseTags(result);
      // _totalEPC = _data.toSet().toList().length;
    });
  }

  void updateIsConnected(dynamic isConnected) {
    setState(() {
    _isConnected = isConnected;
    if(_isConnected) {
      snackbar("Success", "The Connector is connected please start scanning");
    }else{
      alertSnackbar("failed to connect please try again!.");
    }
    print(isConnected);
    });
  }

  bool _isContinuousCall = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.tealAccent.shade700,
        title: const Text('RFID Reader'),
      ),
      body: SingleChildScrollView(
        child: Obx(() => Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                MaterialButton(
                  color: Colors.blue,
                  onPressed: () async {
                    if(!_isConnected){
                      loading(true);
                      Future.delayed(Duration(seconds: 5),(){
                        setState(() {
                          _isConnected = true;
                        });
                        loading(false);
                      });

                    }
                  },child: Text(_isConnected?"Connected":"Not Connected! Tab to connect",style: TextStyle(color: Colors.white),),),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(3.0),
                    child: Icon(
                      Icons.adf_scanner_outlined,
                      size: 100,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(29.0),
                          ),
                        ),
                        child: const Text(
                          'Start Single Reading',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          getOnlyStudents();
                        }),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          _isContinuousCall ? Colors.red : Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(29.0),
                          ),
                        ),
                        child: _isContinuousCall
                            ? const Text(
                          'Stop Continuous Reading',
                          style: TextStyle(color: Colors.white),
                        )
                            : const Text(
                          'Start Continuous Reading',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          if(!_isContinuousCall)
                              {
                                showLoading();
                                getAllStudents();
                              }

                          setState(() {
                            _isContinuousCall = !_isContinuousCall;
                          });
                        }),
                  ],
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(29.0),
                      ),
                    ),
                    child: const Text(
                      'Clear Data',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      setState(() {
                        _data.clear();
                      });
                    }),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  color: Colors.tealAccent.shade700,
                  child: Center(
                    child: Text(
                      'Total Cards: ${_data.length}',
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: List.generate(_data.length, (index){
                    {
                      final data = _data[index];
                      bool isDone = false;
                        return Card(
                          color: Colors.blue.shade50,
                          child: Container(
                            width: 330,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tag: $data',
                                  style: TextStyle(color: Colors.blue.shade800),
                                ),
                                MaterialButton(
                                  color: !isDone?Colors.green:Colors.grey,
                                  onPressed: () async {
                                  if(!isDone){
                                    final user =  await UserServices().getStudentByRFID(data);
                                    final student = Student.fromJson(user);
                                    CheckInServices().addCheck(name: student.name!, checkInTime: DateTime.now(), checkInOrOut: !student.check!, rfidNumber: student.rfidNumber!, uid: student.uid!,);
                                  }

                                },child: Text("Mark Attendance",style: TextStyle(color:!isDone?Colors.white:Colors.black),),)
                              ],
                            ),
                          ),
                        );
                    }
                  }),
                )
              ],
            ),
            !loading()?
            SizedBox():
            LoadingWidget()
          ],
        )),
      ),
    );
  }

  getAllStudents(){
    Future.delayed(Duration(seconds: 5),(){
      for(var user in userCntr.allUsers!.value){
        setState(() {
          _data.add(user.rfidNumber.toString());
        });
      }
      Get.back();
    });

  }

  getOnlyStudents(){
    Future.delayed(Duration(seconds: 5),(){
      setState(() {
        _data.add( userCntr.allUsers!.value.first.rfidNumber.toString());
      });
    });

  }
  showLoading(){
    showDialog(context: context, builder: (ctx)=>AlertDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Scanning!. Please wait!."),
          CircularProgressIndicator()
        ],
      ),
    ));
  }
}
// // ignore_for_file: unused_field
