import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/models/weather_model.dart';
import '../../../data/repositories/repositories.dart';
import '../../../data/repositories/weather_repository.dart';
import '../../../core/utilities/api_string.dart';

class WeatherController extends GetxController {
  final WeatherRepository _weatherRepository = Repo.weather;
  final locationPrefs = GetStorage();

  // Observable variables
  final Rx<WeatherModel?> weatherData = Rx<WeatherModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString searchCity = 'Ho Chi Minh'.obs; // Default city for Vietnam
  final RxBool isSearching = false.obs;

  // Biến mới để lưu địa chỉ chi tiết
  final RxString detailedLocation = RxString('');

  // For daily summary
  final RxMap<String, dynamic> dailySummary = RxMap<String, dynamic>({});
  final RxBool isLoadingDailySummary = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // For location permission
  final RxBool hasLocationPermission = false.obs;
  final RxBool isFirstLaunch = true.obs;

  @override
  void onInit() {
    super.onInit();
    initializeDateFormatting('vi_VN', null);

    // Kiểm tra nếu đã có dữ liệu vị trí từ HomeController
    if (checkSavedLocation()) {
      // Đã có dữ liệu vị trí từ HomeController, sử dụng trực tiếp
      loadWeatherFromSavedLocation();
    } else {
      // Nếu không có dữ liệu vị trí, tiến hành kiểm tra quyền và yêu cầu
      checkAndRequestLocationPermission();
    }
  }

  // Phương thức mới để kiểm tra dữ liệu vị trí đã lưu
  bool checkSavedLocation() {
    double? lastLat = locationPrefs.read<double>('last_latitude');
    double? lastLon = locationPrefs.read<double>('last_longitude');
    int? lastLocationTime = locationPrefs.read<int>('location_timestamp');

    if (lastLat != null && lastLon != null && lastLocationTime != null) {
      final lastUpdateTime =
          DateTime.fromMillisecondsSinceEpoch(lastLocationTime);
      final now = DateTime.now();
      // Dữ liệu vị trí hợp lệ nếu được cập nhật trong vòng 30 phút
      return now.difference(lastUpdateTime).inMinutes < 30;
    }

    return false;
  }

  // Tải dữ liệu thời tiết từ vị trí đã lưu
  Future<void> loadWeatherFromSavedLocation() async {
    isLoading.value = true;
    try {
      double? lastLat = locationPrefs.read<double>('last_latitude');
      double? lastLon = locationPrefs.read<double>('last_longitude');

      if (lastLat != null && lastLon != null) {
        // Lấy địa chỉ chi tiết từ storage nếu có
        String? savedDetailedAddress =
            locationPrefs.read<String>('last_detailed_address');
        if (savedDetailedAddress != null && savedDetailedAddress.isNotEmpty) {
          detailedLocation.value = savedDetailedAddress;
        }

        final weather =
            await _weatherRepository.getWeatherByLocation(lastLat, lastLon);

        if (weather != null) {
          weatherData.value = weather;
          searchCity.value = weather.cityName;
          hasLocationPermission.value = true;

          // Lấy thông tin tóm tắt hàng ngày
          getDailySummary(DateTime.now());
        } else {
          // Nếu không lấy được dữ liệu, dùng thành phố mặc định
          fetchWeatherForDefaultCity();
        }
      } else {
        fetchWeatherForDefaultCity();
      }
    } catch (e) {
      printError(info: 'Error loading weather from saved location: $e');
      fetchWeatherForDefaultCity();
    } finally {
      isLoading.value = false;
    }
  }

  // Phương thức mới để kiểm tra và yêu cầu quyền vị trí ngay lập tức
  Future<void> checkAndRequestLocationPermission() async {
    // Kiểm tra nếu dịch vụ vị trí được bật
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Nếu dịch vụ vị trí không được bật, dùng thành phố mặc định
      hasLocationPermission.value = false;
      fetchWeatherForDefaultCity();
      return;
    }

    // Kiểm tra quyền vị trí
    LocationPermission permission = await Geolocator.checkPermission();

    bool hasLaunchedBefore = locationPrefs.read('has_launched_before') ?? false;
    bool hasPermissionSaved =
        locationPrefs.read('has_location_permission') ?? false;

    // Xử lý khác nhau dựa trên trạng thái quyền
    if (permission == LocationPermission.denied) {
      // Nếu lần đầu mở app hoặc chưa có quyền được lưu
      if (!hasLaunchedBefore) {
        // Hiển thị dialog xin quyền cho lần đầu
        await Future.delayed(Duration(milliseconds: 500));
        showLocationPermissionDialog();
      } else if (hasPermissionSaved) {
        // Đã lưu quyền trước đó, yêu cầu trực tiếp
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          hasLocationPermission.value = false;
          fetchWeatherForDefaultCity();
        } else {
          hasLocationPermission.value = true;
          getWeatherByCurrentLocation();
        }
      } else {
        // Không có quyền được lưu, dùng thành phố mặc định
        fetchWeatherForDefaultCity();
      }
    } else if (permission == LocationPermission.deniedForever) {
      // Quyền bị từ chối vĩnh viễn
      hasLocationPermission.value = false;
      fetchWeatherForDefaultCity();
    } else {
      // Đã có quyền, lấy thời tiết dựa trên vị trí
      hasLocationPermission.value = true;
      locationPrefs.write('has_launched_before', true);
      locationPrefs.write('has_location_permission', true);
      getWeatherByCurrentLocation();
    }
  }

  // Phương thức cũ - giữ lại để tương thích
  void checkFirstLaunch() async {
    // Gọi phương thức mới
    checkAndRequestLocationPermission();
  }

  void showLocationPermissionDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.black.withOpacity(0.85),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white,
                size: 48,
              ),
              SizedBox(height: 20),
              Text(
                'Truy cập thông tin vị trí',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              // Các tùy chọn vị trí
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(Icons.circle, color: Colors.blue, size: 14),
                    SizedBox(width: 10),
                    Text('Vị trí chính xác',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Các nút hành động
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  // Từ chối
                  locationPrefs.write('has_launched_before', true);
                  locationPrefs.write('has_location_permission', false);
                  Get.back();
                  fetchWeatherForDefaultCity();
                },
                child: Text('Từ chối', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 10),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  // Cho phép lần này
                  locationPrefs.write('has_launched_before', true);
                  locationPrefs.write('has_location_permission', false);
                  Get.back();
                  handlePermissionRequest(onlyThisTime: true);
                },
                child: Text('Cho phép lần này',
                    style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 10),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  // Cho phép khi đang dùng
                  locationPrefs.write('has_launched_before', true);
                  locationPrefs.write('has_location_permission', true);
                  Get.back();
                  handlePermissionRequest();
                },
                child: Text('Chỉ cho phép khi đang ứng dụng',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> handlePermissionRequest({bool onlyThisTime = false}) async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Nếu bị từ chối
      hasLocationPermission.value = false;
      fetchWeatherForDefaultCity();
    } else {
      // Được cấp quyền
      hasLocationPermission.value = true;

      if (!onlyThisTime) {
        // Lưu trạng thái cho những lần sau
        locationPrefs.write('has_location_permission', true);
      }

      // Lấy thời tiết theo vị trí
      getWeatherByCurrentLocation();
    }
  }

  // Fetch weather data for the default city
  Future<void> fetchWeatherForDefaultCity() async {
    isLoading.value = true;
    try {
      final weather =
          await _weatherRepository.getCurrentWeather(searchCity.value);
      if (weather != null) {
        weatherData.value = weather;
        // Xóa địa chỉ chi tiết khi tìm kiếm thành phố khác
        detailedLocation.value = '';
        // Try to get daily summary for today
        getDailySummary(DateTime.now());

        // Hiển thị thông báo đã làm mới
        _showRefreshSuccessSnackbar(weather.cityName);
      }
    } catch (e) {
      printError(info: 'Error fetching weather: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Search for weather by city name
  Future<void> searchWeatherByCity(String city) async {
    if (city.isEmpty) return;

    searchCity.value = city;
    isLoading.value = true;

    try {
      final weather = await _weatherRepository.getCurrentWeather(city);
      if (weather != null) {
        weatherData.value = weather;
        // Xóa địa chỉ chi tiết khi tìm kiếm thành phố khác
        detailedLocation.value = '';
        // Try to get daily summary for today
        getDailySummary(DateTime.now());
      } else {
        Get.snackbar(
          'Không tìm thấy',
          'Không tìm thấy thành phố $city hoặc có lỗi xảy ra. Vui lòng thử lại.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      printError(info: 'Error searching for weather: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể tìm kiếm thời tiết. Vui lòng thử lại sau.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get weather data by current location
  Future<void> getWeatherByCurrentLocation() async {
    // Kiểm tra quyền truy cập vị trí
    if (!hasLocationPermission.value) {
      bool hasPermission = await requestLocationPermissionIfNeeded();
      if (!hasPermission) {
        // Nếu không có quyền, sử dụng thành phố mặc định
        fetchWeatherForDefaultCity();
        return;
      }
    }

    isLoading.value = true;
    try {
      // Kiểm tra xem có dữ liệu vị trí đã lưu không từ HomeController
      double? lastLat = locationPrefs.read<double>('last_latitude');
      double? lastLon = locationPrefs.read<double>('last_longitude');
      String? lastCity = locationPrefs.read<String>('last_city');
      String? savedDetailedAddress =
          locationPrefs.read<String>('last_detailed_address');

      // Nếu có dữ liệu vị trí đã lưu và chưa quá 30 phút, sử dụng ngay
      if (lastLat != null && lastLon != null) {
        // Lấy thời gian lưu gần nhất (nếu có)
        int? lastLocationTime = locationPrefs.read<int>('location_timestamp');
        bool isRecent = false;

        if (lastLocationTime != null) {
          final lastUpdateTime =
              DateTime.fromMillisecondsSinceEpoch(lastLocationTime);
          final now = DateTime.now();
          // Kiểm tra xem dữ liệu có được cập nhật trong vòng 30 phút không
          isRecent = now.difference(lastUpdateTime).inMinutes < 30;
        }

        if (isRecent) {
          // Nếu đã có dữ liệu gần đây, sử dụng ngay
          if (savedDetailedAddress != null && savedDetailedAddress.isNotEmpty) {
            detailedLocation.value = savedDetailedAddress;
          }

          final weather =
              await _weatherRepository.getWeatherByLocation(lastLat, lastLon);
          if (weather != null) {
            weatherData.value = weather;
            searchCity.value = weather.cityName;
            getDailySummary(DateTime.now());
            isLoading.value = false;

            // Hiển thị thông báo đã làm mới
            _showRefreshSuccessSnackbar(
                savedDetailedAddress ?? weather.cityName);
            return;
          }
        }
      }

      // Nếu không có dữ liệu vị trí đã lưu hoặc đã quá cũ, lấy vị trí mới
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      ).catchError((error) {
        // Xử lý lỗi timeout
        printError(info: 'Timeout getting location: $error');
        throw error;
      });

      // Lưu vị trí mới
      locationPrefs.write('last_latitude', position.latitude);
      locationPrefs.write('last_longitude', position.longitude);
      locationPrefs.write(
          'location_timestamp', DateTime.now().millisecondsSinceEpoch);

      // Lấy dữ liệu thời tiết cho vị trí hiện tại
      final weather = await _weatherRepository.getWeatherByLocation(
          position.latitude, position.longitude);

      // Kiểm tra xem sau khi lấy vị trí mới, đã lưu địa chỉ chi tiết chưa
      savedDetailedAddress =
          locationPrefs.read<String>('last_detailed_address');
      if (savedDetailedAddress != null && savedDetailedAddress.isNotEmpty) {
        detailedLocation.value = savedDetailedAddress;
      }

      if (weather != null) {
        weatherData.value = weather;
        searchCity.value = weather.cityName;
        // Lưu lại thành phố hiện tại để sử dụng sau này
        locationPrefs.write('last_city', weather.cityName);
        // Lấy tóm tắt hàng ngày
        getDailySummary(DateTime.now());

        // Hiển thị thông báo đã làm mới
        _showRefreshSuccessSnackbar(detailedLocation.value.isEmpty
            ? weather.cityName
            : detailedLocation.value);
      } else {
        // Nếu không lấy được dữ liệu thời tiết, sử dụng thành phố mặc định
        fetchWeatherForDefaultCity();
      }
    } catch (e) {
      printError(info: 'Error getting weather by location: $e');
      // Hiển thị thông báo lỗi và sử dụng thành phố mặc định
      Get.snackbar(
        'Lỗi vị trí',
        'Không thể lấy thông tin vị trí hiện tại. Đang hiển thị dữ liệu mặc định.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      fetchWeatherForDefaultCity();
    } finally {
      isLoading.value = false;
    }
  }

  // Yêu cầu quyền vị trí nếu cần
  Future<bool> requestLocationPermissionIfNeeded() async {
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
      return false;
    }

    hasLocationPermission.value = true;
    return true;
  }

  // Get daily summary for a specific date
  Future<void> getDailySummary(DateTime date) async {
    if (weatherData.value == null) return;

    // Only get summary for dates within the past week
    if (date.isAfter(DateTime.now().subtract(Duration(days: 7)))) {
      isLoadingDailySummary.value = true;
      try {
        // Extract coordinates from the current weather data
        final String cityName = weatherData.value!.cityName;
        double lat = 0, lon = 0;

        // Use geocoding to get coordinates
        final String geocodingUrl =
            'https://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=${ApiUrl.weatherApiKey}';

        final dio = Dio();
        final geocodingResponse = await dio.get(geocodingUrl);

        if (geocodingResponse.statusCode == 200 &&
            geocodingResponse.data is List &&
            geocodingResponse.data.isNotEmpty) {
          lat = geocodingResponse.data[0]['lat'];
          lon = geocodingResponse.data[0]['lon'];

          // Get the daily summary using the coordinates
          final summary =
              await _weatherRepository.getDailySummary(lat, lon, date);
          if (summary != null) {
            dailySummary.value = summary;
          }
        }
      } catch (e) {
        printError(info: 'Error getting daily summary: $e');
      } finally {
        isLoadingDailySummary.value = false;
      }
    }
  }

  // Check if we have location permission
  Future<void> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      hasLocationPermission.value = false;
      return;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        hasLocationPermission.value = false;
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      hasLocationPermission.value = false;
      return;
    }

    // We have permission
    hasLocationPermission.value = true;
  }

  // Format date for display
  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('EEEE, dd/MM', 'vi_VN').format(date);
  }

  // Get weather icon URL
  String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  // Lấy địa chỉ hiển thị - ưu tiên địa chỉ chi tiết nếu có
  String getDisplayLocation() {
    if (detailedLocation.value.isNotEmpty) {
      return detailedLocation.value;
    } else if (weatherData.value != null) {
      return weatherData.value!.cityName;
    }
    return "Không xác định";
  }

  // Hiển thị thông báo đã làm mới thành công
  void _showRefreshSuccessSnackbar(String locationName) {
    Get.snackbar(
      'Đã cập nhật',
      'Dữ liệu thời tiết $locationName đã được làm mới',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.7),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
      borderRadius: 10,
    );
  }
}
