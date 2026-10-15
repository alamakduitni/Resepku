class UploaderModel {
  final String id;
  final String name;

  /// URL atau path asset foto; kosong jika pengguna belum punya foto.
  final String profileImage;

  const UploaderModel({
    this.id = '',
    required this.name,
    required this.profileImage,
  });

  factory UploaderModel.fromJson(Map<String, dynamic> json) {
    return UploaderModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String,
      profileImage: json['profileImage'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
    };
  }
}
