class AuthModel {
    AuthModel({this.email, this.password, this.username ,this.isLoggedIn}) {
    email = email ?? "";
    password = password ?? "";
    username = username ?? "";
    isLoggedIn = isLoggedIn ?? false;
  }

  String? email;
  String? password;
  String? username;
  bool? isLoggedIn;

}