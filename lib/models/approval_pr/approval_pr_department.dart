class Department {
  final String deptId;
  final String descr;
  final String namaPic;
  final String loginUsername;

  Department({
    required this.deptId,
    required this.descr,
    required this.namaPic,
    required this.loginUsername,
  });

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      deptId: map["dept_id"] ?? "",
      descr: map["descr"] ?? "",
      namaPic: map["nama_pic"] ?? "",
      loginUsername: map["loginusername"] ?? "",
    );
  }

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department.fromMap(json);
  }

  Map<String, dynamic> toMap() {
    return {
      "dept_id": deptId,
      "descr": descr,
      "nama_pic": namaPic,
      "loginusername": loginUsername,
    };
  }
}
