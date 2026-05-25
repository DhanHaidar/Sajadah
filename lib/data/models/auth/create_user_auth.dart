class CreateUserReq {
  String? fullName;
  String? email;
  String? password;
  String? role;

  CreateUserReq({
    required this.fullName,
    required this.email,
    required this.password,
    this.role,
  });
}
