class CheckIn {
  String? studentName;
  DateTime? checkInTime;
  bool? checkInOrOut;
  String? rfidNumber;
  String? uid;

  CheckIn({
     this.studentName,
     this.checkInTime,
     this.checkInOrOut,
     this.rfidNumber,
     this.uid,
  });

  factory CheckIn.fromJson(Map json) {
    return CheckIn(
      studentName: json['studentName'],
      checkInTime: DateTime.parse(json['checkInTime']),
      checkInOrOut: json['checkInOrOut'],
      rfidNumber: json['rfidNumber'],
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'checkInTime': checkInTime?.toIso8601String(),
      'checkInOrOut': checkInOrOut,
      'rfidNumber': rfidNumber,
      'uid': uid,
    };
  }
}