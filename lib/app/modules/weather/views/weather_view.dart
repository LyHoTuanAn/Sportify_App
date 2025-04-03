import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/weather_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WeatherView extends GetView<WeatherController> {
  const WeatherView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2B7A78),
              const Color(0xFF3AAFA9),
              const Color(0xFF3AAFA9).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Đang tải dữ liệu thời tiết...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            final weather = controller.weatherData.value;
            if (weather == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 64,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Không thể lấy dữ liệu thời tiết',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Có thể API thời tiết đang gặp sự cố hoặc bị giới hạn lượt truy cập. Vui lòng thử lại sau.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: controller.fetchWeatherForDefaultCity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF2B7A78),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // Kiểm tra xem có đang dùng vị trí hiện tại không
                      if (controller.hasLocationPermission.value) {
                        await controller.getWeatherByCurrentLocation();
                      } else {
                        await controller.fetchWeatherForDefaultCity();
                      }
                    },
                    color: Colors.white,
                    backgroundColor: Color(0xFF2B7A78),
                    displacement: 40,
                    strokeWidth: 3,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            _buildSearchBar(),
                            SizedBox(height: 20),
                            _buildCurrentWeather(weather),
                            SizedBox(height: 20),
                            _buildWeatherDetails(weather),
                            SizedBox(height: 30),
                            _buildForecastLabel(),
                            SizedBox(height: 15),
                            _buildForecast(weather),
                            SizedBox(height: 20),
                            _buildDailySummary(),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Text(
            'Dự báo thời tiết',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Obx(() => GestureDetector(
                onTap: controller.getWeatherByCurrentLocation,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    controller.hasLocationPermission.value
                        ? Icons.my_location
                        : Icons.location_disabled,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final TextEditingController searchController = TextEditingController();

    return Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: searchController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          hintText: 'Tìm kiếm thành phố...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 10, right: 5),
            child: Icon(Icons.search, color: Colors.white),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 40),
          alignLabelWithHint: true,
          isDense: false,
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
            onPressed: () => searchController.clear(),
          ),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            controller.searchWeatherByCity(value);
          }
        },
      ),
    );
  }

  Widget _buildCurrentWeather(final weather) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 5),
              Obx(() {
                String displayLocation = controller.getDisplayLocation();
                return Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(Get.context!).size.width * 0.7),
                  child: Text(
                    displayLocation,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 5),
          Text(
            DateFormat('EEEE, dd MMMM yyyy', 'vi_VN').format(DateTime.now()),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 20),
          CachedNetworkImage(
            imageUrl: controller.getWeatherIconUrl(weather.icon),
            width: 120,
            height: 120,
            placeholder: (context, url) => CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
            errorWidget: (context, url, error) => Icon(
              Icons.cloud,
              size: 120,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '${weather.temperature.round()}°C',
            style: TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _capitalizeFirst(weather.description),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Cảm giác như ${weather.feelsLike.round()}°C',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails(final weather) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailItem(
                icon: Icons.water_drop_outlined,
                value: '${weather.humidity}%',
                label: 'Độ ẩm',
              ),
              _buildDetailItem(
                icon: Icons.air,
                value: '${weather.windSpeed} km/h',
                label: 'Tốc độ gió',
              ),
              _buildDetailItem(
                icon: Icons.compress,
                value: '${weather.pressure} hPa',
                label: 'Áp suất',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastLabel() {
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 12),
        Text(
          'Dự báo 5 ngày tới',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildForecast(final weather) {
    if (weather.dailyForecast.isEmpty) {
      return Center(
        child: Text(
          'Không có dữ liệu dự báo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    return Container(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weather.dailyForecast.length,
        itemBuilder: (context, index) {
          final forecast = weather.dailyForecast[index];
          return Container(
            width: 120,
            margin: EdgeInsets.only(right: 15),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.formatDate(forecast.dt),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                CachedNetworkImage(
                  imageUrl: controller.getWeatherIconUrl(forecast.icon),
                  width: 50,
                  height: 50,
                  placeholder: (context, url) => CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.cloud,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${forecast.tempDay.round()}°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${forecast.tempNight.round()}°',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailySummary() {
    return Obx(() {
      if (controller.isLoadingDailySummary.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        );
      }

      if (controller.dailySummary.isEmpty) {
        return Container(
          margin: EdgeInsets.only(top: 20, bottom: 10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Thông tin bổ sung',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Thông tin chi tiết hơn về dự báo thời tiết cần API cao cấp hơn. Các thông tin hiện tại đã được cung cấp từ OpenWeatherMap API miễn phí.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 16),
              _buildWeatherApiCredit(),
            ],
          ),
        );
      }

      // Handle potential missing data with default values
      final summary = controller.dailySummary;
      final String overviewText =
          summary['overview'] ?? 'Không có thông tin tổng quan';

      return Container(
        margin: EdgeInsets.only(top: 20, bottom: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Tóm tắt thời tiết',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              overviewText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            // Show additional statistics if available
            if (summary.containsKey('statistics')) ...[
              SizedBox(height: 20),
              _buildSummaryStatistics(summary['statistics']),
            ],

            SizedBox(height: 16),
            _buildWeatherApiCredit(),
          ],
        ),
      );
    });
  }

  Widget _buildWeatherApiCredit() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // You could add a link to OpenWeatherMap website here
        },
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
            children: [
              TextSpan(text: 'Dữ liệu được cung cấp bởi '),
              TextSpan(
                text: 'OpenWeatherMap',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStatistics(Map<String, dynamic> statistics) {
    List<Widget> statWidgets = [];

    if (statistics.containsKey('temperature')) {
      final temp = statistics['temperature'];
      statWidgets.add(
        _buildStatItem(
          'Nhiệt độ',
          'Cao: ${temp['max']?.toStringAsFixed(1)}°C, Thấp: ${temp['min']?.toStringAsFixed(1)}°C',
          Icons.thermostat,
        ),
      );
    }

    if (statistics.containsKey('precipitation')) {
      final precip = statistics['precipitation'];
      statWidgets.add(
        _buildStatItem(
          'Lượng mưa',
          '${precip['total'] ?? 0} mm',
          Icons.water_drop,
        ),
      );
    }

    if (statistics.containsKey('humidity')) {
      final humidity = statistics['humidity'];
      statWidgets.add(
        _buildStatItem(
          'Độ ẩm',
          'Trung bình: ${humidity['mean'] ?? 0}%',
          Icons.water,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: statWidgets,
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.9),
            size: 20,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}
