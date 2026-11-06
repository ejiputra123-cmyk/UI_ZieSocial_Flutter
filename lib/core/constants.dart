// ziesocial/flutter/ziesocial/lib/core/constants.dart
class ApiConstants {
  static String get baseUrl {
    return "https://giver-suds-identity.ngrok-free.dev/ziesocial";
  }

  static String get apiBaseUrl => '$baseUrl/api';

  static String get login => '$apiBaseUrl/auth/login.php';
  static String get register => '$apiBaseUrl/auth/register.php';
  static String get createPost => '$apiBaseUrl/posts/create.php';
  static String get updatePost => '$apiBaseUrl/posts/update.php';
  static String get readPosts => '$apiBaseUrl/posts/read.php';
  static String get toggleLike => '$apiBaseUrl/likes/toggle.php';
  static String get readComments => '$apiBaseUrl/comments/read.php';
  static String get createComment => '$apiBaseUrl/comments/create.php';
  static String get updateComment => '$apiBaseUrl/comments/update.php';
  static String get deleteComment => '$apiBaseUrl/comments/delete.php';

  // Endpoint Profile & Follow
  static String get readProfile => '$apiBaseUrl/profile/read.php';
  static String get updateProfile => '$apiBaseUrl/profile/update.php';
  static String get toggleFollow => '$apiBaseUrl/follows/toggle.php';
  static String get readUsers => '$apiBaseUrl/users/read.php';

  static String getImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return 'https://picsum.photos/seed/placeholder/600/600';
    }
    if (relativePath.startsWith('http://') ||
        relativePath.startsWith('https://')) {
      return relativePath;
    }
    return '$baseUrl/$relativePath';
  }
}
