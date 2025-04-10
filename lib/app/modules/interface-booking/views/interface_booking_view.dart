import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../controllers/interface_booking_controller.dart';

class InterfaceBookingView extends GetView<InterfaceBookingController> {
  const InterfaceBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() => _buildBookingContent()),
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
              const Spacer(),
              const Text(
                'Đặt lịch sân',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.openDatePicker(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Color(0xFF2B7A78),
                        ),
                        const SizedBox(width: 8),
                        Obx(() => Text(
                              controller.formattedDate,
                              style: const TextStyle(
                                color: Color(0xFF2b7a78),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(8),
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Xem giá',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegend(),
            const SizedBox(height: 12),
            _buildInfoMessage(),
            const SizedBox(height: 12),
            _buildSwipeHint(),
            Obx(() => controller.bookingError.isNotEmpty
                ? _buildErrorMessage(controller.bookingError.value)
                : const SizedBox.shrink()),
            _buildTimeGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildLegendItem(
            color: Colors.white,
            border: true,
            label: 'Còn trống',
          ),
          const SizedBox(width: 16),
          _buildLegendItem(
            color: const Color(0xFFEF9A9A),
            border: true,
            label: 'Đã đặt',
          ),
        ],
      ),
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
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            border: border
                ? Border.all(
                    color: label == 'Còn trống'
                        ? const Color(0xFF81C784)
                        : const Color(0xFFEF9A9A))
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoMessage() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFDEF2F1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Color(0xFF2B7A78),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'Lưu ý: Nếu bạn cần đặt lịch cố định vui lòng liên hệ: 0334043054 để được hỗ trợ',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF2B7A78),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeHint() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.swipe,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                'Vuốt sang để xem toàn bộ lịch',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          _buildZoomControls(),
        ],
      ),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              controller.zoomOut();
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.remove,
                size: 16,
                color: Color(0xFF2B7A78),
              ),
            ),
          ),
          Container(
            height: 20,
            width: 1,
            color: Colors.grey[300],
          ),
          InkWell(
            onTap: () {
              controller.zoomIn();
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.add,
                size: 16,
                color: Color(0xFF2B7A78),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: Colors.red[700],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeGrid() {
    // Get all needed data first
    final timeSlots = controller.timeSlots;
    final courts =
        controller.yardAvailabilities.map((yard) => yard.boatTitle).toList();

    // Only show loading if we truly have no data
    if (courts.isEmpty && controller.isLoading.value) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF2B7A78),
            ),
            const SizedBox(height: 16),
            Text(
              'Đang tải lịch...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Show message for no data
    if (courts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Không có dữ liệu lịch cho sân này',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.loadAvailabilityData(),
                // ignore: sort_child_properties_last
                child: const Text('Tải lại dữ liệu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B7A78),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Build the calendar grid since we have data
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with times
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2B7A78),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  // First cell "Sân / Giờ"
                  Container(
                    width: 70,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    child: Text(
                      'Sân / Giờ',
                      style: TextStyle(
                        fontSize: controller.headerFontSize.value,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ...timeSlots.map((time) => Container(
                        width: controller.cellWidth.value,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.white, width: 0.5),
                          ),
                        ),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: controller.headerFontSize.value,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )),
                ],
              ),
            ),

            // Courts and time slots
            Column(
              children: courts.map((court) {
                return Row(
                  children: [
                    // Court name column
                    Container(
                      width: 70,
                      height: controller.cellHeight.value,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B7A78),
                        border: const Border(
                          top: BorderSide(color: Colors.white, width: 1),
                          right: BorderSide(color: Colors.white, width: 1),
                        ),
                        borderRadius: court == courts.last
                            ? const BorderRadius.only(
                                bottomLeft: Radius.circular(10))
                            : null,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        court,
                        style: TextStyle(
                          fontSize: controller.cellFontSize.value,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ...timeSlots.map((time) {
                      final isAvailable =
                          controller.isSlotAvailable(court, time);
                      final isSelected =
                          controller.selectedTimeSlots.contains('$court-$time');

                      return InkWell(
                        onTap: isAvailable
                            ? () => controller.selectTimeSlot('$court-$time')
                            : null,
                        child: Container(
                          width: controller.cellWidth.value,
                          height: controller.cellHeight.value,
                          decoration: BoxDecoration(
                            color: !isAvailable
                                ? const Color(
                                    0xFFFFCDD2) // Light red for unavailable
                                : isSelected
                                    ? const Color(
                                        0xFFE8F5E9) // Light green for selected
                                    : Colors.white, // White for available
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 0.5,
                            ),
                            borderRadius:
                                (court == courts.last && time == timeSlots.last)
                                    ? const BorderRadius.only(
                                        bottomRight: Radius.circular(10))
                                    : null,
                          ),
                          child: isSelected
                              ? Center(
                                  child: Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.green[700],
                                  ),
                                )
                              : null,
                        ),
                      );
                    // ignore: unnecessary_to_list_in_spreads
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Color(0xFF2B7A78),
                      ),
                      const SizedBox(width: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Thời gian: ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2B7A78),
                              ),
                            ),
                            TextSpan(
                              text: controller.selectedTimeSlots.isEmpty
                                  ? '0 giờ'
                                  : controller.bookingDuration,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF777777),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Color(0xFF2B7A78),
                      ),
                      const SizedBox(width: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Tổng: ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2B7A78),
                              ),
                            ),
                            TextSpan(
                              text: controller.selectedTimeSlots.isEmpty
                                  ? '0đ'
                                  : controller.formattedTotalPrice,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF777777),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ),
        Obx(() => InkWell(
              onTap: controller.selectedTimeSlots.isEmpty ||
                      controller.isAddingToCart.value
                  ? null
                  : () => controller.addToCart(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: controller.selectedTimeSlots.isEmpty
                        ? [Colors.grey[400]!, Colors.grey[600]!]
                        : [const Color(0xFF2B7A78), const Color(0xFF17252A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: controller.selectedTimeSlots.isEmpty
                          // ignore: deprecated_member_use
                          ? Colors.grey.withOpacity(0.2)
                          // ignore: deprecated_member_use
                          : const Color(0xFF2B7A78).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: controller.isAddingToCart.value
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.selectedTimeSlots.isEmpty
                                ? 'Vui lòng chọn thời gian'
                                : 'Tiếp theo',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            controller.selectedTimeSlots.isEmpty
                                ? Icons.access_time
                                : Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            )),
      ],
    );
  }
}
