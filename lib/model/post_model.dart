// ziesocial/flutter/ziesocial/lib/model/post_model.dart
import 'package:ziesocial/core/constants.dart';

class PostModel {
  final int id;
  final int userId;
  final String username;
  final String userAvatar;
  final String location;
  String imageUrl;
  int likesCount;
  int commentsCount;
  String caption;
  final String timeAgo;
  bool isLiked;
  bool isBookmarked;
  bool isAuthorFollowed;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.location,
    required this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.caption,
    required this.timeAgo,
    this.isLiked = false,
    this.isBookmarked = false,
    this.isAuthorFollowed = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? {};
    final authorId = author['id'] is int
        ? author['id']
        : int.tryParse(author['id']?.toString() ?? '0') ?? 0;

    return PostModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] != null
          ? (json['user_id'] is int
                ? json['user_id']
                : int.parse(json['user_id'].toString()))
          : authorId,
      username: author['username'] ?? 'User',
      userAvatar: ApiConstants.getImageUrl(author['avatar']),
      location: author['name'] ?? '',
      imageUrl: ApiConstants.getImageUrl(json['image']),
      likesCount: json['like_count'] ?? 0,
      commentsCount: json['comment_count'] ?? 0,
      caption: json['caption'] ?? '',
      timeAgo: _formatDate(json['create_date']),
      isLiked: (json['is_liked'] is bool)
          ? json['is_liked']
          : (json['is_liked'] == 1 || json['is_liked'] == '1'),
      isBookmarked: false,
      isAuthorFollowed: (author['is_followed'] is bool)
          ? author['is_followed'] as bool
          : (author['is_followed'] == 1 || author['is_followed'] == '1'),
    );
  }

  static String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'RECENT';
    try {
      final date = DateTime.parse(rawDate);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes == 0 ? 1 : diff.inMinutes} MINUTES AGO';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} HOURS AGO';
      } else {
        return '${diff.inDays} DAYS AGO';
      }
    } catch (_) {
      return 'RECENT';
    }
  }
}
