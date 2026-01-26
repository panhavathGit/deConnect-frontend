class AuthModel {
    AuthModel({this.email, this.password, this.isLoggedIn, this.rememberMe}) {
    email = email ?? "";
    password = password ?? "";
    isLoggedIn = isLoggedIn ?? false;
    rememberMe = rememberMe ?? false;
  }

  String? email;
  String? password;
  bool? isLoggedIn;
  bool? rememberMe;
}