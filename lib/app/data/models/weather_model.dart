class WeatherModel {
  final String cityName;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final double feelsLike;
  final int pressure;
  final List<DailyForecast> dailyForecast;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.feelsLike,
    required this.pressure,
    required this.dailyForecast,
  });

  factory WeatherModel.fromMap(Map<String, dynamic> map) {
    // Extract city name
    final String cityName = map['name'] ?? 'Unknown location';

    // Extract current weather data
    final current = map['current'] ?? {};

    // Temperature
    final double temp = current['temp']?.toDouble() ?? 0.0;

    // Feels like
    final double feelsLike = current['feels_like']?.toDouble() ?? 0.0;

    // Humidity
    final int humidity = current['humidity'] ?? 0;

    // Pressure
    final int pressure = current['pressure'] ?? 0;

    // Wind speed
    final double windSpeed = current['wind_speed']?.toDouble() ?? 0.0;

    // Weather description and icon
    String description = 'No description';
    String icon = '01d';
    if (current['weather'] != null &&
        current['weather'] is List &&
        current['weather'].isNotEmpty) {
      description = current['weather'][0]['description'] ?? 'No description';
      icon = current['weather'][0]['icon'] ?? '01d';
    }

    // Create daily forecasts
    List<DailyForecast> forecasts = [];
    if (map['daily'] != null && map['daily'] is List) {
      forecasts = (map['daily'] as List)
          .take(7) // Get 7 days forecast
          .map((day) => DailyForecast.fromMap(day))
          .toList();
    }

    return WeatherModel(
      cityName: cityName,
      temperature: temp,
      humidity: humidity,
      windSpeed: windSpeed,
      description: description,
      icon: icon,
      feelsLike: feelsLike,
      pressure: pressure,
      dailyForecast: forecasts,
    );
  }
}

class DailyForecast {
  final int dt;
  final double tempDay;
  final double tempNight;
  final String description;
  final String icon;

  DailyForecast({
    required this.dt,
    required this.tempDay,
    required this.tempNight,
    required this.description,
    required this.icon,
  });

  factory DailyForecast.fromMap(Map<String, dynamic> map) {
    // Extract temperatures - always a map in One Call API 3.0
    double tempDay = 0.0;
    double tempNight = 0.0;

    if (map['temp'] is Map) {
      tempDay = (map['temp']['day'] is int)
          ? (map['temp']['day'] as int).toDouble()
          : map['temp']['day'] ?? 0.0;

      tempNight = (map['temp']['night'] is int)
          ? (map['temp']['night'] as int).toDouble()
          : map['temp']['night'] ?? 0.0;
    }

    return DailyForecast(
      dt: map['dt'] ?? 0,
      tempDay: tempDay,
      tempNight: tempNight,
      description: map['weather']?[0]?['description'] ?? 'No description',
      icon: map['weather']?[0]?['icon'] ?? '01d',
    );
  }
}
