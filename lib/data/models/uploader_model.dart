class UploaderModel {
  final String name;
  final String profileImage;

  const UploaderModel({
    required this.name,
    required this.profileImage,
  });

  factory UploaderModel.fromJson(Map<String, dynamic> json) {
    return UploaderModel(
      name: json['name'] as String,
      profileImage: json['profileImage'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profileImage': profileImage,
    };
  }
}
