class AuthRequestModel {
  final String? name;
  final String email;
  final String password;

  const AuthRequestModel({
    this.name,
    required this.email,
    required this.password,
  });
}
