class PostModel {
  final String username;
  final String userAvatar;
  final String location;
  final String imageUrl;
  final int likesCount;
  final int commentsCount;
  final String caption;
  final String timeAgo;
  bool isLiked;
  bool isBookmarked;

  PostModel({
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
}