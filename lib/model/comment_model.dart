import 'package:ziesocial/core/constants.dart';

class CommentModel {
  final int id;
  final int userId;
  final int postId;
  String text;
  final String createDate;
  final String username;
  final String name;
  final String userAvatar;
  final String timeAgo;

  CommentModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.text,
    required this.createDate,
    required this.username,
    required this.name,
    required this.userAvatar,
    required this.timeAgo,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic> ? json['user'] : {};
    final rawDate = json['create_date']?.toString() ?? '';

    return CommentModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      postId: json['post_id'] is int
          ? json['post_id']
          : int.parse(json['post_id'].toString()),
      text: json['text']?.toString() ?? '',
      createDate: rawDate,
      username: user['username']?.toString() ?? 'User',
      name: user['name']?.toString() ?? '',
      userAvatar: ApiConstants.getImageUrl(user['avatar']?.toString()),
      timeAgo: _formatDate(rawDate),
    );
  }

  static String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Baru saja';
    try {
      final date = DateTime.parse(rawDate);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) {
        return 'Baru saja';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}j';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}h';
      } else {
        return '${(diff.inDays / 7).floor()}mg';
      }
    } catch (_) {
      return 'Baru saja';
    }
  }
}
