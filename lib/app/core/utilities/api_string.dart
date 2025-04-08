class ApiUrl {
  factory ApiUrl() => _instance;
  ApiUrl._internal();
  static final ApiUrl _instance = ApiUrl._internal();
  static const String receipt = '/api';
  static const String sendOtp = '/api/auth/send-otp';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String forgotPassword = '/api/forgot-password';
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String logout = '/api/auth/logout';
  static const String changePassword = '/api/auth/change-password';

  // Weather API endpoints (OpenWeatherMap)
  static const String weatherApiKey = 'e887f1f3530ec4596bf6bf0b5a7dca8d';
  static const String weatherBaseUrl = 'https://api.openweathermap.org/data';

  // One Call API 3.0 - This requires a paid subscription
  static String weatherOnecall(double lat, double lon) =>
      '$weatherBaseUrl/3.0/onecall?lat=$lat&lon=$lon&units=metric&appid=$weatherApiKey&lang=vi';

  // Remove all other weather API methods/formats and use only One Call API 3.0
  // The following free API endpoint methods are no longer needed:
  // currentWeather, weatherForecast, weatherOverview, etc.

  static const String resetPassword = '/api/reset-password';

  // Yard (boat) API endpoint
  static const String yardSearch = '/api/boat/search';
  static const String availabilityCalendar = '/api/availability-calendar';
  static const String addToCart = '/api/booking/addToCart';

  // Wishlist endpoints
  static const String userWishlist = '/api/user/wishlist';
  static String toggleWishlist = userWishlist;

  static String detailRecipient(id) => '$receipt/recipients/$id';
  static String notifications = '$receipt/notifications';
  static String stores = '$receipt/stores';
  static String addresses = '$receipt/addresses';
  static String numberUnread = '$receipt/notifications/notifications_statistic';

  static detailNotify(String id) => '$receipt/notifications/$id';
  static enableNotify(id) => '$receipt/recipients/$id/enable_notification';
  static disableNotify(id) => '$receipt/recipients/$id/disable_notification';
  static updateAvatar(id) => '$receipt/recipients/$id/upload_avatar';
  static markRead(id) => '$receipt/notifications/$id/mark_as_read';

  static const String conversations = '$receipt/message_threads';
  static const String detailChat = '$receipt/messages/group_message';
  static const String createChat = '$receipt/message_threads';
  static const String sentMessage = '$receipt/messages/send_message';
  static String markReadAll(String id) =>
      '$receipt/message_threads/$id/mark_all_as_read';

  static const String refreshToken = '$receipt/refresh_token';

  // Firebase authentication endpoint
  static const String firebaseAuth = '$receipt/auth/firebase';

  // New endpoint for user profile
  static const String userMe = '$receipt/auth/me';
  static const String updateUserMe =
      userMe; // Same endpoint but different HTTP method (PUT/PATCH)

  //delete/restore account
  static deleteRecipient(id) => '$receipt/recipients/$id';
  static const String restoreRecipient = '$receipt/recipients/restore';
  static const String getDashboard = '$receipt/home';
  static const String coupons = '$receipt/coupon';
  static couponDetail(String id) => '$receipt/coupon/$id';

  // Add media store endpoint
  static const String mediaStore = '$receipt/media/store';

  static String affiliateLinks(int categoryId) =>
      '$receipt/affiliate/categories/$categoryId/links';
}
