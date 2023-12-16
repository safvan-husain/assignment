class UserModel {
  final String name;
  final String id;
  final String? avatar;
  UserModel({
    required this.name,
    required this.id,
    this.avatar,
  });
}
