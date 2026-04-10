class MyApi {
  static const String _baseUrl = 'https://admin.gutargooplus.com/api';
  // static const String _baseUrl = 'https://81.17.100.176/api/api';

  // static const String _baseUrl = 'http://192.168.1.7:3001/api';

  static const String sendOtp = '$_baseUrl/otp/send';
  static const String verifyOtp = '$_baseUrl/otp/verify';
  static const String banner = '$_baseUrl/banners';
  static const String movies = '$_baseUrl/movies';
  static const String sections = '$_baseUrl/admin/sections';
  // static const String sections = '$_baseUrl/admin/sections/allList';
  static const String search = '$_baseUrl/search';
  static const String redeemGet = '$_baseUrl/redeem/list';
  static const String redeemPost = '$_baseUrl/redeem';
  static const String download = '$_baseUrl/download';
  static const String like = '$_baseUrl/movie-likes';
  static const String category = '$_baseUrl/category';

  static String dynamicUrl(String endpoint) => '$_baseUrl/$endpoint';
}
