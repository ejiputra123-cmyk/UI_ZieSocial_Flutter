// ziesocial/flutter/ziesocial/lib/model/user_model.dart
class UserModel {
  final String id;
  final String username;
  final String email;
  final String name;
  final String avatar;
  final String bio;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isFollowed;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.avatar,
    required this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.isFollowed = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      bio: json['bio'] ?? '',
      followersCount: json['followers_count'] is int
          ? json['followers_count'] as int
          : int.tryParse(json['followers_count']?.toString() ?? '0') ?? 0,
      followingCount: json['following_count'] is int
          ? json['following_count'] as int
          : int.tryParse(json['following_count']?.toString() ?? '0') ?? 0,
      postsCount: json['posts_count'] is int
          ? json['posts_count'] as int
          : int.tryParse(json['posts_count']?.toString() ?? '0') ?? 0,
      isFollowed: json['is_followed'] is bool
          ? json['is_followed'] as bool
          : (json['is_followed'] == 1 || json['is_followed'] == '1'),
    );
  }

  UserModel copyWith({
    String? username,
    String? email,
    String? name,
    String? avatar,
    String? bio,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isFollowed,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}
