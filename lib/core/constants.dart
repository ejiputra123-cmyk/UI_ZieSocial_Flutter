class ApiConstants {
  static String get baseUrl {
    return "https://giver-suds-identity.ngrok-free.dev/ziesocial";
  }

  static String get apiBaseUrl => '$baseUrl/api';

  static String get login => '$apiBaseUrl/auth/login.php';
  static String get register => '$apiBaseUrl/register.php';
  static String get createPost => '$apiBaseUrl/posts/create.php';
  static String get readPosts => '$apiBaseUrl/posts/read.php';
  static String get toggleLike => '$apiBaseUrl/likes/toggle.php';

  // Helper untuk mendapatkan full URL dari path gambar di server
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
