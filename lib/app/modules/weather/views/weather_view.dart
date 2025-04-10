import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/weather_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WeatherView extends GetView<WeatherController> {
  const WeatherView({super.key});

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
              // ignore: deprecated_member_use
              const Color(0xFF3AAFA9).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
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
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Không thể lấy dữ liệu thời tiết',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Có thể API thời tiết đang gặp sự cố hoặc bị giới hạn lượt truy cập. Vui lòng thử lại sau.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: controller.fetchWeatherForDefaultCity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2B7A78),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Thử lại'),
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
                    backgroundColor: const Color(0xFF2B7A78),
                    displacement: 40,
                    strokeWidth: 3,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            _buildSearchBar(),
                            const SizedBox(height: 20),
                            _buildCurrentWeather(weather),
                            const SizedBox(height: 20),
                            _buildWeatherDetails(weather),
                            const SizedBox(height: 30),
                            _buildForecastLabel(),
                            const SizedBox(height: 15),
                            _buildForecast(weather),
                            const SizedBox(height: 20),
                            _buildDailySummary(),
                            const SizedBox(height: 10),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const Text(
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
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
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          hintText: 'Tìm kiếm thành phố...',
          // ignore: deprecated_member_use
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 10, right: 5),
            child: Icon(Icons.search, color: Colors.white),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          alignLabelWithHint: true,
          isDense: false,
          border: InputBorder.none,
          suffixIcon: IconButton(
            // ignore: deprecated_member_use
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
    return Obx(() {
      // Kiểm tra xem có forecast đang được chọn không
      final selectedForecast = controller.selectedForecast.value;

      // Dùng dữ liệu từ forecast nếu được chọn
      final String iconToShow =
          selectedForecast != null ? selectedForecast.icon : weather.icon;

      final String descriptionToShow = selectedForecast != null
          ? selectedForecast.description
          : weather.description;

      final double tempToShow = selectedForecast != null
          ? selectedForecast.tempDay
          : weather.temperature;

      final double feelsLikeToShow = selectedForecast != null
          ? selectedForecast.tempNight // Dùng tempNight nếu không có feelsLike
          : weather.feelsLike;

      return Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 5),
                Obx(() {
                  String displayLocation = controller.getDisplayLocation();
                  return Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(Get.context!).size.width * 0.7),
                    child: Text(
                      displayLocation,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              DateFormat('EEEE, dd MMMM yyyy', 'vi_VN').format(DateTime.now()),
              style: TextStyle(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            CachedNetworkImage(
              imageUrl: controller.getWeatherIconUrl(iconToShow),
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              placeholder: (context, url) => const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.cloud,
                size: 120,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${tempToShow.round()}°C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 60,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _capitalizeFirst(descriptionToShow),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              selectedForecast != null
                  ? 'Nhiệt độ ban đêm ${feelsLikeToShow.round()}°C'
                  : 'Cảm giác như ${feelsLikeToShow.round()}°C',
              style: TextStyle(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWeatherDetails(final weather) {
    return Obx(() {
      // Kiểm tra xem có forecast đang được chọn không
      final selectedForecast = controller.selectedForecast.value;

      // Chỉ hiển thị dữ liệu hiện tại từ weather vì DailyForecast không có các thuộc tính này
      final int humidity = weather.humidity;
      final double windSpeed = weather.windSpeed;
      final int pressure = weather.pressure;

      // Hiển thị một thông báo nếu đang xem dự báo
      final String infoText = selectedForecast != null
          ? '(Dữ liệu chi tiết chỉ có cho thời tiết hiện tại)'
          : '';

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            if (selectedForecast != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  infoText,
                  style: TextStyle(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(
                  icon: Icons.water_drop_outlined,
                  value: '$humidity%',
                  label: 'Độ ẩm',
                ),
                _buildDetailItem(
                  icon: Icons.air,
                  value: '$windSpeed km/h',
                  label: 'Tốc độ gió',
                ),
                _buildDetailItem(
                  icon: Icons.compress,
                  value: '$pressure hPa',
                  label: 'Áp suất',
                ),
              ],
            ),
          ],
        ),
      );
    });
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
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            // ignore: deprecated_member_use
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
        const SizedBox(width: 12),
        const Text(
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
      return const Center(
        child: Text(
          'Không có dữ liệu dự báo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weather.dailyForecast.length,
        itemBuilder: (context, index) {
          final forecast = weather.dailyForecast[index];

          return Obx(() {
            // Kiểm tra xem forecast này có đang được chọn không
            bool isSelected =
                controller.selectedForecast.value?.dt == forecast.dt;

            return GestureDetector(
              onTap: () {
                // Nếu đã chọn, bỏ chọn; nếu chưa, chọn nó
                if (isSelected) {
                  controller.clearSelectedForecast();
                } else {
                  controller.selectForecast(forecast);
                }
              },
              child: Container(
                width: 120,
                margin: const EdgeInsets.only(right: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isSelected
                      // ignore: deprecated_member_use
                      ? Colors.white.withOpacity(0.3) // Màu nền khi được chọn
                      // ignore: deprecated_member_use
                      : Colors.white.withOpacity(0.2), // Màu nền mặc định
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(
                          color: Colors.white, width: 2) // Viền khi được chọn
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.formatDate(forecast.dt),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    CachedNetworkImage(
                      imageUrl: controller.getWeatherIconUrl(forecast.icon),
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                      errorWidget: (context, url, error) => const Icon(
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${forecast.tempNight.round()}°',
                          style: TextStyle(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildDailySummary() {
    return Obx(() {
      if (controller.isLoadingDailySummary.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        );
      }

      // Thay đổi ở đây: Dùng summary tự tạo thay vì từ API
      final String summaryText = controller.generateWeatherSummary();

      return Container(
        margin: const EdgeInsets.only(top: 20, bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
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
                const SizedBox(width: 12),
                const Text(
                  'Tóm tắt thời tiết',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              summaryText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            // Hiển thị thêm các thống kê weather
            const SizedBox(height: 20),
            _buildAdditionalInfo(controller.weatherData.value!),

            const SizedBox(height: 16),
            _buildWeatherApiCredit(),
          ],
        ),
      );
    });
  }

  // Thêm widget mới để hiển thị thông tin bổ sung
  Widget _buildAdditionalInfo(final weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatItem(
          'Thời tiết hiện tại',
          _capitalizeFirst(weather.description),
          Icons.wb_twilight,
        ),
        _buildStatItem(
          'Nhiệt độ',
          '${weather.temperature.round()}°C (cảm giác ${weather.feelsLike.round()}°C)',
          Icons.thermostat_outlined,
        ),
        _buildStatItem(
          'Độ ẩm',
          '${weather.humidity}%',
          Icons.water_drop_outlined,
        ),
        _buildStatItem(
          'Áp suất',
          '${weather.pressure} hPa',
          Icons.compress,
        ),
        _buildStatItem(
          'Tốc độ gió',
          '${weather.windSpeed} km/h',
          Icons.air,
        ),
      ],
    );
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
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.7),
            ),
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const TextSpan(text: 'Dữ liệu được cung cấp bởi '),
              const TextSpan(
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

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.9),
            size: 20,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
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
