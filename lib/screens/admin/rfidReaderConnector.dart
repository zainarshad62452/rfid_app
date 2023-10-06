import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rfid_app/Services/userServices.dart';
import 'package:rfid_app/models/userModel.dart';
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
  bool _isLoading = true;
  int _totalEPC = 0, _invalidEPC = 0, _scannedEPC = 0;
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = (await RfidC72Plugin.platformVersion)!;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    RfidC72Plugin.connectedStatusStream
        .receiveBroadcastStream()
        .listen(updateIsConnected);
    RfidC72Plugin.tagsStatusStream.receiveBroadcastStream().listen(updateTags);
    await RfidC72Plugin.connect;
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _isLoading = false;
    });
  }

  List<TagEpc> _data = [];
  final List<String> _EPC = [];
  void updateTags(dynamic result) async {
    setState(() {
      _data = TagEpc.parseTags(result);
      _totalEPC = _data.toSet().toList().length;
    });
  }

  void updateIsConnected(dynamic isConnected) {
    setState(() {
    _isConnected = isConnected;
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(_isConnected?"Connected":"Not Connected"),
            const Card(
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
                      await RfidC72Plugin.startSingle;
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
                      bool? isStarted = _isContinuousCall == true
                          ? await RfidC72Plugin.stop
                          : await RfidC72Plugin.startContinuous;
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
                  await RfidC72Plugin.clearData;
                  setState(() {
                    _data.clear();
                    //     _logs.clear();
                  });
                }),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              color: Colors.tealAccent.shade700,
              child: Center(
                child: Text(
                  'Total Cards: $_totalEPC',
                  style: GoogleFonts.lato(
                    color: Colors.black,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            ..._data.map(
                  (TagEpc tag)  {
                _EPC.add(tag.epc.replaceAll(RegExp('EPC:'), ''));
                final data = tag.epc.replaceAll(RegExp('EPC:'), '');
                final user =  UserServices().getStudentByRFID(data);
                if(user != "No user found"){
                  final student = Student.fromJson(user);
                  CheckInServices().addCheck(name: student.name!, checkInTime: DateTime.now(), checkInOrOut: !student.check!, rfidNumber: student.rfidNumber!, uid: student.uid!,);
                  return Card(
                    color: Colors.blue.shade50,
                    child: Container(
                      width: 330,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Tag: ${tag.epc.replaceAll(RegExp('EPC:'), '')}',
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ),
                  );
                }else{
                  return Card(
                    color: Colors.blue.shade50,
                    child: Container(
                      width: 330,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Tag: ${tag.epc.replaceAll(RegExp('EPC:'), '')}\nUser Not Found',
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ),
                  );
                }

              },
            ),
          ],
        ),
      ),
    );
  }
}