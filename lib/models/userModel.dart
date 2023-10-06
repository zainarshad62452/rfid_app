class Student {
  String? uid;
  String? rfidNumber;
  String? name;
  String? parentName;
  String? email;
  String? className;
  int? rollNo;
  bool? check;

  Student({
     this.uid,
     this.rfidNumber,
     this.name,
     this.parentName,
     this.email,
     this.className,
     this.rollNo,
     this.check,
  });

  factory Student.fromJson(Map json) {
    return Student(
      uid: json['uid'],
      rfidNumber: json['rfidNumber'],
      name: json['name'],
      parentName: json['parentName'],
      email: json['email'],
      className: json['className'],
      rollNo: json['rollNo'],
      check: json['check'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'rfidNumber': rfidNumber,
      'name': name,
      'parentName': parentName,
      'email': email,
      'className': className,
      'rollNo': rollNo,
      'check': check,
    };
  }
}