// let sql="INSERT INTO `member`(`name`, `account`, `password`, `email`, `phone`) VALUES (?,?,?,?,?)";
// let param=[req.body.name,req.body.account,req.body.password,req.body.email,req.body.phone];
class SignUpResponseModel {
  //String token;
  String error;

  SignUpResponseModel({required this.error});
  
  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) {
    return SignUpResponseModel(error: json["error"] != null ? json["error"]: "",);
  }
  //print(error);
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