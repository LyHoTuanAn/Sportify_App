import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../controllers/interface_booking.dart';

class InterfaceBookingView extends GetView<InterfaceBookingController> {
  const InterfaceBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildBookingContent(),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
      color: const Color(0xFF2B7A78),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              const Spacer(), // Đẩy tiêu đề ra giữa
              const Text(
                'Đặt lịch sân',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(), // Giữ cân đối khoảng trống hai bên
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20), // Bo góc nhẹ hơn
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: Color(0xFF2B7A78),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '28/02/2025',
                        style: TextStyle(
                          color: Color(0xFF2B7A78), // Custom color to match the UI
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.2),
                    borderRadius: BorderRadius.circular(24),
                    color: const Color(0xFF2B7A78),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2B7A78),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Xem giá',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildBookingContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegend(),
            const SizedBox(height: 16),
            _buildInfoMessage(),
            const SizedBox(height: 16),
            _buildTimeSlotHeader(),
            _buildTimeGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem(
          color: Colors.white,
          border: true,
          label: 'Còn trống',
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          color: Colors.red[100]!,
          label: 'Đã đặt',
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          color: Colors.blue[100]!,
          label: 'Đang chọn',
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    bool border = false,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: border ? Border.all(color: Colors.grey[300]!) : null,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Lưu ý: Nếu bạn cần đặt lịch có đính vui lòng liên hệ: 0334043054 để được hỗ trợ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotHeader() {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          child: const Icon(
            Icons.back_hand,
            size: 16,
            color: Colors.grey,
          ),
        ),
        const Text(
          ' Vuốt sang để xem toàn bộ lịch',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeGrid() {
    // Define our time slots
    final timeSlots = ['0:00', '1:00', '2:00', '3:00', '4:00', '5:00', '6:00', '7:00', '8:00'];
    final courts = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    // Sample booking data - matches the image
    final bookedSlots = {
      'T2-0:00': true,
      'T2-1:00': true,
      'T4-4:00': true,
      'T6-6:00': true,
      'T6-7:00': true,
    };

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF2B7A78), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Header row with times
          Container(
            color: const Color(0xFF2B7A78),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      'day/h', // Changed from 'sân/h' to match the image
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[200],
                      ),
                    ),
                  ),
                ),
                ...timeSlots.map((time) => Expanded(
                  child: Center(
                    child: Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),

          // Court rows with time slots
          ...courts.map((court) => Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[300]!, // Changed to grey for grid lines
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: const Color(0xFF2B7A78),
                  child: Center(
                    child: Text(
                      court,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                ...timeSlots.map((time) {
                  final isBooked = bookedSlots['$court-$time'] == true;
                  return Expanded(
                    child: Container(
                      height: 40, // Increased height for better readability
                      decoration: BoxDecoration(
                        color: isBooked
                            ? Colors.red[100]
                            : Colors.green[50], // Light green background for unbooked slots
                        border: Border(
                          left: BorderSide(
                            color: Colors.grey[300]!, // Changed to grey for grid lines
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Thời gian: 2 giờ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tổng: 200.000đ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            // Navigate to next screen
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: const Color(0xFF2B7A78),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tiếp theo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CourtBookingController extends GetxController {
  // Controller logic would go here
  final selectedDate = DateTime.now().obs;
  final selectedTimeSlots = <String>[].obs;

  double get totalPrice => selectedTimeSlots.length * 100000.0;

  void selectTimeSlot(String courtTime) {
    if (selectedTimeSlots.contains(courtTime)) {
      selectedTimeSlots.remove(courtTime);
    } else {
      selectedTimeSlots.add(courtTime);
    }
  }
}