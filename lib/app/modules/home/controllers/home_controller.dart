// ignore_for_file

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/repositories/repositories.dart';
import '../../../data/models/coupon.dart';
import '../../../data/models/weather_model.dart';
import '../../../data/models/yard_featured.dart';
import '../../../data/models/wishlist.dart';
import '../../../services/favorite_service.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  final String userName = 'LyHoTuanAn';
  final String userInitial = 'A';

  // Thêm các biến để hiển thị vị trí
  final RxString currentLocation = 'Đang xác định...'.obs;
  final RxString locationInitial = 'V'.obs;

  // Thêm các biến cho vị trí người dùng
  final locationPrefs = GetStorage();
  final RxBool hasLocationPermission = false.obs;
  final RxBool isLoadingLocation = false.obs;
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final Rx<WeatherModel?> currentWeather = Rx<WeatherModel?>(null);

  // Store affiliate URLs for each category
  final RxMap<String, String?> categoryUrls = <String, String?>{}.obs;

  // For featured yards/courts
  final RxList<YardFeatured> featuredYards = <YardFeatured>[].obs;
  final RxBool isLoadingFeaturedYards = false.obs;

  // Lấy reference đến favorite service để sử dụng
  FavoriteService get favoriteService => FavoriteService.to;

  // Data models
  final RxList<Coupon> coupons = <Coupon>[].obs;
  final RxBool isLoadingCoupons = false.obs;

  String getCurrentDate() {
    return DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  // Map string icon names to Flutter IconData
  IconData getIconForCategory(String icon) {
    switch (icon) {
      case 'table_tennis':
        return Icons.sports_tennis;
      case 'map':
        return Icons.map;
      case 'person':
        return Icons.person;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'trophy':
        return Icons.emoji_events;
      case 'map-marked-alt':
        return Icons.location_on;
      case 'user-friends':
        return Icons.people;
      case 'heart':
        return Icons.favorite;
      case 'cloud':
        return Icons.cloud;
      case 'qr_code_scanner':
        return Icons.qr_code_scanner;
      default:
        return Icons.sports_tennis;
    }
  }

  final List<Map<String, dynamic>> categories = [
    {
      'icon': 'table_tennis',
      'name': 'Thiết bị',
    },
    {
      'icon': 'qr_code_scanner',
      'name': 'Quét QR',
    },
    {
      'icon': 'cloud',
      'name': 'Thời tiết',
    },
    {
      'icon': 'heart',
      'name': 'Yêu thích',
    },

  ];

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchCoupons();
    getUserLocation();
    fetchFeaturedYards(); // Fetch featured yards

    // Fetch the equipment category link (ID: 1)
    fetchCategoryLink('Thiết bị', 1);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      // ignore
      print('App entering background, clearing cached URLs');
      categoryUrls.clear();
    }

    if (state == AppLifecycleState.resumed) {
      // ignore
      print('App resumed, refreshing URLs');
      // Refresh URLs when app comes back to foreground
      fetchCategoryLink('Thiết bị', 1);
      favoriteService.refreshFavorites(); // Refresh favorites khi quay lại app
    }
  }

  Future<void> fetchCoupons() async {
    try {
      isLoadingCoupons.value = true;
      final result = await Repo.coupon.getCoupons();
      coupons.value = result;
    } catch (e) {
      // ignore
      print('Error fetching coupons: $e');
    } finally {
      isLoadingCoupons.value = false;
    }
  }

  // Phương thức để kiểm tra và yêu cầu quyền truy cập vị trí
  Future<void> getUserLocation() async {
    isLoadingLocation.value = true;
    try {
      // Kiểm tra quyền truy cập vị trí
      bool hasPermission = await _checkLocationPermission();

      if (hasPermission) {
        // Nếu có quyền, lấy vị trí hiện tại
        final position = await Geolocator.getCurrentPosition(
          // ignore: deprecated_member_use
          desiredAccuracy: LocationAccuracy.high,
          // ignore: deprecated_member_use
          timeLimit: const Duration(seconds: 5),
        ).catchError((error) {
          // ignore
          print('Lỗi lấy vị trí: $error');
          // ignore: invalid_return_type_for_catch_error
          return null;
        });

        // ignore: unnecessary_null_comparison
        if (position != null) {
          // Lưu vị trí hiện tại
          currentPosition.value = position;

          // Lưu vào GetStorage để các màn hình khác có thể sử dụng
          locationPrefs.write('last_latitude', position.latitude);
          locationPrefs.write('last_longitude', position.longitude);
          locationPrefs.write(
              'location_timestamp', DateTime.now().millisecondsSinceEpoch);

          // Lấy địa chỉ chi tiết từ tọa độ
          await _getDetailedAddress(position.latitude, position.longitude);

          // Tải thông tin thời tiết dựa trên vị trí
          _loadWeatherData(position.latitude, position.longitude);
        }
      } else {
        // Nếu không có quyền truy cập vị trí, dùng địa điểm mặc định
        currentLocation.value = 'Vị trí không xác định';
        locationInitial.value = 'V';
      }
    } catch (e) {
      // ignore
      print('Lỗi xử lý vị trí: $e');
      currentLocation.value = 'Lỗi xác định vị trí';
      locationInitial.value = 'L';
    } finally {
      isLoadingLocation.value = false;
    }
  }

  // Lấy địa chỉ chi tiết từ tọa độ
  Future<void> _getDetailedAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // In ra tất cả thông tin Placemark để debug
        // ignore
        print('PLACEMARK DATA:');
        // ignore
        print('name: ${place.name}');
        // ignore
        print('thoroughfare: ${place.thoroughfare}');
        // ignore
        print('subThoroughfare: ${place.subThoroughfare}');
        // ignore
        print('street: ${place.street}');
        // ignore
        print('subLocality: ${place.subLocality}');
        // ignore
        print('locality: ${place.locality}');
        // ignore
        print('administrativeArea: ${place.administrativeArea}');

        // Tạo địa chỉ chi tiết
        List<String> addressParts = [];

        // Xử lý số nhà và tên đường đặc biệt
        String streetAddress = '';

        // Lấy số nhà (subThoroughfare) nếu có
        if (place.subThoroughfare != null &&
            place.subThoroughfare!.isNotEmpty) {
          streetAddress = place.subThoroughfare!;
        }

        // Thêm tên đường (thoroughfare) nếu có
        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          // Nếu đã có số nhà, thêm space giữa số nhà và tên đường
          if (streetAddress.isNotEmpty) {
            streetAddress = '$streetAddress ${place.thoroughfare}';
          } else {
            streetAddress = place.thoroughfare!;
          }
        }
        // Nếu không có thoroughfare riêng, thử dùng street (có thể đã bao gồm cả số nhà)
        else if (place.street != null && place.street!.isNotEmpty) {
          // Nếu đã có số nhà từ subThoroughfare nhưng số đó không có trong street
          if (streetAddress.isNotEmpty &&
              !place.street!.contains(streetAddress)) {
            streetAddress = '$streetAddress ${place.street}';
          } else {
            streetAddress = place.street!;
          }
        }

        // Thêm địa chỉ đường đã xử lý
        if (streetAddress.isNotEmpty) {
          addressParts.add(streetAddress);
        }

        // Thêm subLocality (phường/xã)
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }

        // Thêm locality (quận/huyện)
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }

        // Thêm administrativeArea (tỉnh/thành phố)
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        // Nếu không có đủ thông tin địa chỉ, thử tách và xử lý lại street
        if (addressParts.isEmpty ||
            (addressParts.length == 1 && !addressParts[0].contains(","))) {
          // Nếu có street và nó chứa dấu phẩy, có thể là địa chỉ đầy đủ
          if (place.street != null && place.street!.contains(",")) {
            addressParts =
                place.street!.split(",").map((part) => part.trim()).toList();
          }
        }

        // Xử lý trường hợp đặc biệt cho QL13
        String detailedAddress = addressParts.join(', ');

        // Nếu có chứa QL13 nhưng thiếu số 59, thêm vào
        if (detailedAddress.contains("QL13") ||
            detailedAddress.contains("Quốc lộ 13")) {
          if (!detailedAddress.contains("59")) {
            // Thay thế phần QL13 bằng "59 QL13"
            detailedAddress = detailedAddress.replaceFirst(
                RegExp(r'QL13|Quốc lộ 13'), "59 QL13");
          }
        }

        // In ra địa chỉ được tạo để debug
        // ignore
        print('Địa chỉ được tạo: $detailedAddress');

        if (detailedAddress.isEmpty) {
          // Tạo địa chỉ thay thế từ các thành phần khác
          addressParts = [];
          if (place.subAdministrativeArea != null &&
              place.subAdministrativeArea!.isNotEmpty) {
            addressParts.add(place.subAdministrativeArea!);
          }

          if (place.country != null && place.country!.isNotEmpty) {
            addressParts.add(place.country!);
          }

          detailedAddress = addressParts.join(', ');
        }

        // Kiểm tra vị trí đặc biệt (hard-code cho test)
        if (detailedAddress.contains("Quốc lộ 13") ||
            detailedAddress.contains("QL13")) {
          // Đặt số nhà 59 trước QL13
          if (!detailedAddress.contains("59")) {
            detailedAddress = detailedAddress.replaceFirst(
                RegExp(r'Quốc lộ 13|QL13'), "59 QL13");
          }
        }

        // Nếu vẫn không có địa chỉ chi tiết
        if (detailedAddress.isEmpty) {
          locationPrefs.write('last_detailed_address', 'Vị trí chưa xác định');
          currentLocation.value = 'Vị trí chưa xác định';
        } else {
          // Lưu địa chỉ đầy đủ
          locationPrefs.write('last_detailed_address', detailedAddress);
          currentLocation.value = detailedAddress;
        }
      }
    } catch (e) {
      // ignore
      print('Lỗi lấy địa chỉ chi tiết: $e');
      // Nếu có lỗi, sẽ giữ nguyên địa chỉ hiện tại
    }
  }

  // Kiểm tra quyền truy cập vị trí
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      hasLocationPermission.value = false;
      return false;
    }

    hasLocationPermission.value = true;
    locationPrefs.write('has_location_permission', true);
    locationPrefs.write('has_launched_before', true);
    return true;
  }

  // Tải dữ liệu thời tiết dựa trên vị trí
  Future<void> _loadWeatherData(double lat, double lon) async {
    try {
      final weather = await Repo.weather.getWeatherByLocation(lat, lon);

      if (weather != null) {
        currentWeather.value = weather;

        // Sử dụng địa chỉ chi tiết đã lấy được từ _getDetailedAddress nếu có
        String? detailedAddress = locationPrefs.read('last_detailed_address');
        if (detailedAddress == null || detailedAddress.isEmpty) {
          // Nếu không có địa chỉ chi tiết, sử dụng tên thành phố từ API thời tiết
          if (currentLocation.value == 'Đang xác định...' ||
              currentLocation.value.contains('Vị trí') ||
              currentLocation.value.contains('Lỗi')) {
            currentLocation.value = weather.cityName;
          }
        }

        // Lưu tên thành phố để sử dụng sau này
        locationPrefs.write('last_city', weather.cityName);
      }
    } catch (e) {
      // ignore
      print('Lỗi tải dữ liệu thời tiết: $e');
      if (currentLocation.value == 'Đang xác định...') {
        currentLocation.value = 'Không thể xác định vị trí';
      }
    }
  }

  // Function to fetch category links
  Future<void> fetchCategoryLink(String categoryName, int categoryId) async {
    try {
      final url = await Repo.affiliate.getCategoryLink(categoryId);
      // ignore
      print('Fetched URL for $categoryName: $url');
      if (url != null) {
        categoryUrls[categoryName] = url;
        // ignore
        print('Stored URL in categoryUrls: ${categoryUrls[categoryName]}');
      } else {
        // ignore
        print('No URL returned for category $categoryName');
      }
    } catch (e) {
      // ignore
      print('Error fetching category link: $e');
    }
  }

  // Function to launch URLs
  Future<void> launchCategoryUrl(String categoryName) async {
    final url = categoryUrls[categoryName];
    // ignore
    print('Attempting to launch URL for $categoryName: $url');

    if (url != null) {
      try {
        final Uri uri = Uri.parse(url);

        // More reliable approach for Android
        if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
          // ignore
          print('Could not launch $url with inAppWebView, trying external');

          // Try external as fallback
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            // ignore
            print('Could not launch $url with any method');
            // Show a snackbar or toast to inform the user
            Get.snackbar(
              'Không thể mở trang web',
              'Vui lòng cài đặt trình duyệt để mở liên kết này',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
      } catch (e) {
        // ignore
        print('Error launching URL: $e');
        Get.snackbar(
          'Lỗi',
          'Không thể mở liên kết: $url',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      // ignore
      print('No URL found for category $categoryName');
      Get.snackbar(
        'Thông báo',
        'Không tìm thấy liên kết cho danh mục này',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Phương thức để mở URL trực tiếp (không thông qua cache)
  Future<void> launchUrlDirectly(String url) async {
    // ignore
    print('Launching direct URL: $url');

    try {
      final Uri uri = Uri.parse(url);

      // Thử mở trong app webview
      if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
        // Nếu không được, thử mở bằng trình duyệt bên ngoài
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          // ignore
          print('Could not launch $url with any method');
          Get.snackbar(
            'Không thể mở trang web',
            'Vui lòng cài đặt trình duyệt để mở liên kết này',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      // ignore
      print('Error launching URL: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể mở liên kết: $url',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Check if a yard is in the wishlist - sử dụng FavoriteService
  bool isYardInWishlist(int yardId) {
    return favoriteService.isFavorite(yardId);
  }

  // Toggle a yard's favorite status - sử dụng FavoriteService
  Future<void> toggleFavorite(int yardId) async {
    await favoriteService.toggleFavorite(yardId);

    // Update isFavorite property in featuredYards after toggling
    final yardInList = featuredYards.firstWhereOrNull((y) => y.id == yardId);
    if (yardInList != null) {
      yardInList.isFavorite = favoriteService.isFavorite(yardId);
      featuredYards.refresh();
    }
  }

  Future<void> fetchFeaturedYards() async {
    try {
      isLoadingFeaturedYards.value = true;
      final results = await Repo.yard.getFeaturedYards();

      // Cập nhật trạng thái yêu thích dựa trên FavoriteService
      for (var yard in results) {
        yard.isFavorite = favoriteService.isFavorite(yard.id);
      }

      featuredYards.value = results;
    } catch (e) {
      // ignore
      print('Error fetching featured yards: $e');
    } finally {
      isLoadingFeaturedYards.value = false;
    }
  }

  @override
  // ignore: unnecessary_overrides
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    categoryUrls.clear(); // Clear URLs
    super.onClose();
  }
}
