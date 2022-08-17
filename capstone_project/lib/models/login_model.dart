class LoginResponseModel {
  //String token;
  String error;

  LoginResponseModel({/*required this.token,*/ required this.error});
  
  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(/*token: json["token"] != null ? json["token"]: "",*/ error: json["error"] != null ? json["error"]: "",);
  }
  //print(error);
}
class LoginRequestModel{
  String account;
  String password;

  LoginRequestModel({
    required this.account,
    required this.password,
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'account': account.trim(),
      'password': password.trim(),
    };

    return map;
  }
}