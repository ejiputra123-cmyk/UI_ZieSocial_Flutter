class ApiConstants {
  static String get baseUrl {
    return "http://localhost/ziesocial/api";
  }

  static String get login => '$baseUrl/auth/login.php';
  static String get register => '$baseUrl/auth/register.php';
}