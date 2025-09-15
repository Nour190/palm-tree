class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime? createdAt;
  final String? refreshToken;
  final String? accessToken;
  final bool isOAuthRedirect;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.createdAt,
    this.refreshToken,
    this.accessToken,
    this.isOAuthRedirect = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'avatar_url': avatarUrl};
  }
}
