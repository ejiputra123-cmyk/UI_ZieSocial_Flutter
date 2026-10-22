import 'package:ziesocial/core/constants.dart';

class PostModel {
  final int id;
  final String username;
  final String userAvatar;
  final String location;
  final String imageUrl;
  int likesCount;
  int commentsCount;
  final String caption;
  final String timeAgo;
  bool isLiked;
  bool isBookmarked;

  PostModel({
    required this.id,
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
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? {};

    return PostModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
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
