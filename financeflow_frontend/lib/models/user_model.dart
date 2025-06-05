class UserModel {
  final bool isPremium;
  final String userId;
  final String name;

  UserModel({
    required this.userId,
    required this.name,
    this.isPremium = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'isPremium': isPremium,
    };
  }

  UserModel copyWith({
    String? userId,
    String? name,
    bool? isPremium,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
