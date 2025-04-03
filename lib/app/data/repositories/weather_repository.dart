import 'package:dio/dio.dart';
import '../models/weather_model.dart';
import '../../core/utilities/utilities.dart';
import 'package:intl/intl.dart';

class WeatherRepository {
  final Dio _dio = Dio();

  Future<WeatherModel?> getCurrentWeather(String city) async {
    try {
      // First, get coordinates from city name using geocoding API
      final geoResponse = await _dio.get(
          'https://api.openweathermap.org/geo/1.0/direct?q=$city&limit=1&appid=${ApiUrl.weatherApiKey}');

      if (geoResponse.statusCode == 200 &&
          geoResponse.data is List &&
          geoResponse.data.isNotEmpty) {
        final double lat = geoResponse.data[0]['lat'];
        final double lon = geoResponse.data[0]['lon'];

        // Use the One Call API 3.0 to get all weather data at once
        return getWeatherByLocation(lat, lon);
      }

      AppUtils.log('City not found: $city');
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        AppUtils.log('API Key authentication error: ${e.message}');
      } else {
        AppUtils.log('Error fetching weather: ${e.message}');
      }
      return null;
    } catch (e) {
      AppUtils.log('Error fetching weather: $e');
      return null;
    }
  }

  Future<WeatherModel?> getWeatherByLocation(double lat, double lon) async {
    try {
      // Get all weather data from One Call API 3.0
      final response = await _dio.get(ApiUrl.weatherOnecall(lat, lon));

      if (response.statusCode == 200) {
        // Extract the city name using reverse geocoding
        final cityName = await _getCityNameFromCoordinates(lat, lon);

        // Add city name to response data
        final Map<String, dynamic> weatherData = {
          ...response.data,
          'name': cityName,
        };

        return WeatherModel.fromMap(weatherData);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        AppUtils.log('API Key authentication error: ${e.message}');
      } else {
        AppUtils.log('Error fetching weather by location: ${e.message}');
      }
      return null;
    } catch (e) {
      AppUtils.log('Error fetching weather by location: $e');
      return null;
    }
  }

  Future<String> _getCityNameFromCoordinates(double lat, double lon) async {
    try {
      final response = await _dio.get(
          'https://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=${ApiUrl.weatherApiKey}');

      if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        final String name = response.data[0]['name'] ?? 'Unknown';
        final String country = response.data[0]['country'] ?? '';
        return country.isEmpty ? name : '$name, $country';
      }
      return 'Vị trí hiện tại';
    } catch (e) {
      AppUtils.log('Error getting city name: $e');
      return 'Vị trí hiện tại';
    }
  }

  // Get daily summary directly from One Call API 3.0
  Future<Map<String, dynamic>?> getDailySummary(
      double lat, double lon, DateTime date) async {
    try {
      // Format date for API
      final String dateStr = DateFormat('yyyy-MM-dd').format(date);

      // Get daily summary from One Call API 3.0
      final response = await _dio.get(
          '${ApiUrl.weatherBaseUrl}/3.0/onecall/day_summary?lat=$lat&lon=$lon&date=$dateStr&units=metric&appid=${ApiUrl.weatherApiKey}&lang=vi');

      if (response.statusCode == 200) {
        // The API already returns the summary in the format we need
        return response.data;
      }

      return {
        'overview':
            'Không có dữ liệu dự báo chi tiết cho ngày ${DateFormat('dd/MM/yyyy').format(date)}.'
      };
    } catch (e) {
      AppUtils.log('Error fetching daily summary: $e');
      return null;
    }
  }
}
