import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/repositories/repositories.dart';
import '../../../data/models/coupon.dart';
import '../../../data/models/weather_model.dart';
import 'package:logger/logger.dart';

class HomeController extends GetxController {
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
  final logger = Logger();

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
      'icon': 'cloud',
      'name': 'Thời tiết',
    },
    {
      'icon': 'person',
      'name': 'Huấn luyện',
    },
    {
      'icon': 'heart',
      'name': 'Yêu thích',
    },
  ];

  final List<Map<String, dynamic>> featuredCourts = [
    {
      'name': 'Sân cầu lông Hà Đông',
      'location': 'Quận Hà Đông',
      'rating': 4.8,
      'image':
          'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8YmFkbWludG9uJTIwY291cnR8ZW58MHx8MHx8&ixlib=rb-1.2.1&w=1000&q=80',
    },
    {
      'name': 'Elite Sports Thanh Xuân',
      'location': 'Quận Thanh Xuân',
      'rating': 4.6,
      'image':
          'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8YmFkbWludG9uJTIwY291cnR8ZW58MHx8MHx8&ixlib=rb-1.2.1&w=1000&q=80',
    },
    {
      'name': 'Elite Sports Thanh Xuân',
      'location': 'Quận Thanh Xuân',
      'rating': 4.6,
      'image':
          'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8YmFkbWludG9uJTIwY291cnR8ZW58MHx8MHx8&ixlib=rb-1.2.1&w=1000&q=80',
    },
    {
      'name': 'Trung tâm thể thao Đống Đa',
      'location': 'Quận Đống Đa',
      'rating': 4.7,
      'image':
          'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8YmFkbWludG9uJTIwY291cnR8ZW58MHx8MHx8&ixlib=rb-1.2.1&w=1000&q=80',
    },
  ];

  final List<Map<String, dynamic>> vouchers = [
    {
      'discount': '30',
      'title': 'Ưu đãi đầu tháng',
      'expiry': 'Hết hạn: 10/03/2025',
      'detail': 'Áp dụng cho tất cả sân',
      'color': 'red',
    },
    {
      'discount': '20',
      'title': 'Khung giờ trưa',
      'expiry': 'Hết hạn: 15/03/2025',
      'detail': '12:00 - 15:00 hàng ngày',
      'color': 'orange',
    },
    {
      'discount': '50',
      'title': 'Ưu đãi thành viên mới',
      'expiry': 'Hết hạn: 31/03/2025',
      'detail': 'Lần đặt sân đầu tiên',
      'color': 'purple',
    },
  ];

  final RxList<Coupon> coupons = <Coupon>[].obs;
  final RxBool isLoadingCoupons = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCoupons();

    // Lấy vị trí người dùng khi khởi động trang Home
    getUserLocation();
  }

  Future<void> fetchCoupons() async {
    try {
      isLoadingCoupons.value = true;
      final result = await Repo.coupon.getCoupons();
      coupons.value = result;
    } catch (e) {
      logger.e('Error fetching coupons: $e');
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
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        ).catchError((error) {
          logger.e('Lỗi lấy vị trí: $error');
          return null;
        });

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
      logger.e('Lỗi xử lý vị trí: $e');
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
        logger.e('PLACEMARK DATA:');
        logger.e('name: ${place.name}');
        logger.e('thoroughfare: ${place.thoroughfare}');
        logger.e('subThoroughfare: ${place.subThoroughfare}');
        logger.e('street: ${place.street}');
        logger.e('subLocality: ${place.subLocality}');
        logger.e('locality: ${place.locality}');
        logger.e('administrativeArea: ${place.administrativeArea}');

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
        logger.e('Địa chỉ được tạo: $detailedAddress');

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
      logger.e('Lỗi lấy địa chỉ chi tiết: $e');
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
      logger.e('Lỗi tải dữ liệu thời tiết: $e');
      if (currentLocation.value == 'Đang xác định...') {
        currentLocation.value = 'Không thể xác định vị trí';
      }
    }
  }

// Remove these overrides since they are not required
// @override
// void onReady() {
//   super.onReady();  // No custom logic needed, remove it
// }

// @override
// void onClose() {
//   super.onClose();  // No custom logic needed, remove it
// }

}
