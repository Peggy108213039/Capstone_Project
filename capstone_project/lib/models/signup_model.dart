// let sql="INSERT INTO `member`(`name`, `account`, `password`, `email`, `phone`) VALUES (?,?,?,?,?)";
// let param=[req.body.name,req.body.account,req.body.password,req.body.email,req.body.phone];
class SignUpResponseModel {
  int uID;
  String account;
  String name;
  String password;
  String email;
  int phone;
  int totalDiatance;
  int totalTime;
  int totalActivity;
  int totalTrack;
  String result;

  SignUpResponseModel({
    required this.uID,
    required this.account,
    required this.name,
    required this.password,
    required this.email,
    required this.phone,
    required this.totalDiatance,
    required this.totalTime,
    required this.totalActivity,
    required this.totalTrack,
    required this.result});

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) {
    return SignUpResponseModel(
      uID: json["uID"] ?? "", // if null then return ""
      account: json["account"] ?? "",
      name: json["name"] ?? "",
      password: json["password"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      totalDiatance: json["total_distance"],
      totalTime: json["total_time"],
      totalActivity: json["total_activity"],
      totalTrack: json["total_track"],
      result: json["result"] ?? "",
    );
  }
}
class SignUpRequestModel{
  String name;
  String account;
  String password;
  String email;
  String phone;

  SignUpRequestModel({
    required this.name,
    required this.account,
    required this.password,
    required this.email,
    required this.phone,
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': name.trim(),
      'account': account.trim(),
      'password': password.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
    };

    return map;
  }
}