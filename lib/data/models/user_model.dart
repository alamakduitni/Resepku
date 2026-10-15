class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final DateTime? birthDate;
  final String? profileImage;
  final int avatarIndex;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.birthDate,
    this.profileImage,
    this.avatarIndex = 0,
  });

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      birthDate: DateTime.tryParse(json['birthDate'] as String? ?? ''),
      profileImage: json['profileImage'] as String?,
      avatarIndex: (json['avatarIndex'] as num?)?.toInt() ?? 0,
    );
  }

  UserModel copyWith({int? avatarIndex}) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      birthDate: birthDate,
      profileImage: profileImage,
      avatarIndex: avatarIndex ?? this.avatarIndex,
    );
  }
}
