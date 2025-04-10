// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/calendar_availability.dart';
import '../../../data/repositories/repositories.dart';
import '../../../routes/app_pages.dart';

class BookingInfo {
  final String venueName;
  final String venueAddress;
  final String date;
  final String customerType;
  final String totalHours;
  final double totalPrice;

  BookingInfo({
    required this.venueName,
    required this.venueAddress,
    required this.date,
    required this.customerType,
    required this.totalHours,
    required this.totalPrice,
  });
}

class Voucher {
  final String id;
  final String code;
  final String title;
  final double discount;
  final double minimumPurchase;
  final DateTime expiryDate;
  final String description;

  Voucher({
    required this.id,
    required this.code,
    required this.title,
    required this.discount,
    required this.minimumPurchase,
    required this.expiryDate,
    required this.description,
  });
}

class InterfaceBookingController extends GetxController {
  final YardRepository yardRepository = Repo.yard;

  // URL parameters - Get the yard_id from arguments
  final int yardId = Get.arguments != null && Get.arguments is Map
      ? Get.arguments['yard_id'] ?? 15
      : (Get.arguments is int
          ? Get.arguments
          : 15); // Default yard ID if none provided

  // Booking data
  final selectedDate = DateTime.now().obs;
  final selectedTimeSlots = <String>[].obs;
  final isLoading = true.obs;
  final yardAvailabilities = <YardAvailability>[].obs;
  final timeSlots = <String>[].obs;

  // New for booking flow
  final isAddingToCart = false.obs;
  final bookingError = ''.obs;

  // UI settings
  final cellWidth = 50.0.obs;
  final cellHeight = 40.0.obs;
  final headerFontSize = 12.0.obs;
  final cellFontSize = 12.0.obs;

  // Input fields controllers for booking form
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  RxMap<int, dynamic> yardPricingData = RxMap<int, dynamic>();

  @override
  void onInit() {
    super.onInit();
    _initTimeSlots();
    loadAvailabilityData();

    // If yard data is passed in arguments, cache it
    if (Get.arguments is Map && Get.arguments['yard_data'] != null) {
      final yardData = Get.arguments['yard_data'];
      if (yardData['id'] != null) {
        yardPricingData[yardData['id']] = yardData;
      }
    }
  }

  void _initTimeSlots() {
    // Generate time slots for the 24-hour period
    List<String> slots = [];
    for (int i = 0; i < 24; i++) {
      slots.add('${i.toString().padLeft(2, '0')}:00');
    }
    timeSlots.value = slots;
  }

  Future<void> loadAvailabilityData() async {
    isLoading.value = true;

    try {
      // Get all yard IDs with the same author as the selected yard
      final yardIds = await yardRepository.getYardIdsBySelectedYard(yardId);

      if (yardIds.isEmpty) {
        throw Exception('No related yards found');
      }

      // Get availability data for these yards
      final availabilities = await yardRepository.getYardAvailability(
        date: selectedDate.value,
        yardIds: yardIds,
      );

      // Update the availability data
      yardAvailabilities.clear();
      yardAvailabilities.addAll(availabilities);

      // Force UI refresh
      update();
    } catch (e) {
      Get.snackbar(
        'Lỗi tải dữ liệu',
        'Không thể tải dữ liệu lịch đặt sân. Vui lòng thử lại.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
      update();
    }
  }

  bool isSlotAvailable(String courtName, String timeSlot) {
    // Extract time hour (e.g., "09:00" -> 9)
    final hourToCheck = int.tryParse(timeSlot.split(':')[0]) ?? 0;

    // Find the yard availability for this court
    final yardAvailability = yardAvailabilities.firstWhereOrNull(
      (yard) => yard.boatTitle == courtName,
    );

    if (yardAvailability == null) {
      return false;
    }

    // Find the specific slot that matches this hour
    final matchingSlot = yardAvailability.availableSlots.firstWhereOrNull(
        (slot) => int.tryParse(slot.start.split(':')[0]) == hourToCheck);

    // If there's no slot data for this hour or the slot is explicitly unavailable
    if (matchingSlot == null) {
      return false; // Slot not in the API response, mark as unavailable (red)
    } else {
      // Return exactly what the API says about this slot
      return matchingSlot.isAvailable;
    }
  }

  void selectTimeSlot(String courtTime) {
    // Split the court-time string to get the parts
    final parts = courtTime.split('-');
    final court = parts[0];
    // ignore: unused_local_variable
    final time = parts[1];

    // Check if we're toggling a previously selected slot
    if (selectedTimeSlots.contains(courtTime)) {
      selectedTimeSlots.remove(courtTime);
      bookingError.value = ''; // Clear any error when removing
      return;
    }

    // If this is the first selection, just add it
    if (selectedTimeSlots.isEmpty) {
      selectedTimeSlots.add(courtTime);
      bookingError.value = '';
      return;
    }

    // Check that we're selecting slots for the same court
    final firstSlotParts = selectedTimeSlots.first.split('-');
    final firstCourt = firstSlotParts[0];

    if (court != firstCourt) {
      bookingError.value =
          'You can only select time slots for one court at a time.';
      return;
    }

    // Check if the selection is consecutive with existing selections
    if (isConsecutiveSelection(courtTime)) {
      selectedTimeSlots.add(courtTime);
      // Sort selections by time
      selectedTimeSlots.sort((a, b) {
        final timeA = int.parse(a.split('-')[1].split(':')[0]);
        final timeB = int.parse(b.split('-')[1].split(':')[0]);
        return timeA.compareTo(timeB);
      });
      bookingError.value = '';
    } else {
      bookingError.value =
          'You can only select consecutive time slots to book the yard.';
    }
  }

  bool isConsecutiveSelection(String newSlot) {
    // Extract the time parts from all selected slots
    List<int> selectedHours = selectedTimeSlots.map((slot) {
      return int.parse(slot.split('-')[1].split(':')[0]);
    }).toList();

    // Extract the hour from the new slot
    int newHour = int.parse(newSlot.split('-')[1].split(':')[0]);

    // Check if adding this hour would create a consecutive sequence
    if (selectedHours.contains(newHour - 1) ||
        selectedHours.contains(newHour + 1)) {
      return true;
    }

    return false;
  }

  void zoomIn() {
    if (cellWidth.value < 100) {
      cellWidth.value += 10;
      cellHeight.value += 8;
      headerFontSize.value += 1;
      cellFontSize.value += 1;
    }
  }

  void zoomOut() {
    if (cellWidth.value > 30) {
      cellWidth.value -= 10;
      cellHeight.value -= 8;
      headerFontSize.value = (headerFontSize.value - 1).clamp(8.0, 16.0);
      cellFontSize.value = (cellFontSize.value - 1).clamp(8.0, 16.0);
    }
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(selectedDate.value);
  }

  void openDatePicker() {
    DateTime now = DateTime.now();
    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chọn ngày',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              CalendarDatePicker(
                initialDate: selectedDate.value,
                firstDate: now,
                lastDate: DateTime(now.year + 1, now.month, now.day),
                onDateChanged: (date) {
                  selectedDate.value = date;
                  Get.back();
                  // Clear data before loading to prevent stale data
                  yardAvailabilities.clear();
                  // Reset isLoading explicitly
                  isLoading.value = true;
                  // Add a small delay to ensure UI updates before starting the load
                  Future.delayed(const Duration(milliseconds: 100), () {
                    loadAvailabilityData(); // Reload data when date changes
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchYardPricing(int yardId) async {
    if (yardPricingData.containsKey(yardId)) return; // Already cached

    try {
      final searchResponse = await yardRepository.searchYards();
      for (var yard in searchResponse) {
        if (yard.id == yardId) {
          yardPricingData[yardId] = {
            'id': yard.id,
            'price': yard.price,
            'sale_price_per_hour': yard.salePricePerHour,
            'discount': yard.discount,
          };
          break;
        }
      }
    } catch (e) {
      // Silent fail, will use default pricing
    }
  }

  double get totalPrice {
    if (selectedTimeSlots.isEmpty) return 0;

    // Get the court name from the first selected slot
    final courtName = selectedTimeSlots.first.split('-')[0];

    // Find the yard availability for the selected court
    final yardAvailability = yardAvailabilities.firstWhereOrNull(
      (yard) => yard.boatTitle == courtName,
    );

    if (yardAvailability == null) return 0;

    int courtId = yardAvailability.boatId;
    double hourlyRate = 100000.0; // Default fallback price

    // Get yard pricing data from cache or arguments
    final yardData = yardPricingData[courtId] ??
        (Get.arguments is Map &&
                Get.arguments['yard_data'] != null &&
                Get.arguments['yard_data']['id'] == courtId
            ? Get.arguments['yard_data']
            : null);

    if (yardData != null) {
      // If yard has a sale price per hour, use that
      if (yardData['sale_price_per_hour'] != null) {
        final salePrice = yardData['sale_price_per_hour'];
        hourlyRate = salePrice is num
            ? salePrice.toDouble()
            : double.tryParse(salePrice.toString()) ?? hourlyRate;
      }
      // Otherwise use the regular price
      else if (yardData['price'] != null) {
        final price = yardData['price'];
        hourlyRate = price is num
            ? price.toDouble()
            : double.tryParse(price.toString()) ?? hourlyRate;
      }
    }
    // Try to fetch pricing data if not available
    else {
      // Schedule a pricing data fetch for next time
      fetchYardPricing(courtId);
    }

    return hourlyRate * selectedTimeSlots.length;
  }

  String get formattedTotalPrice {
    // Format with comma separators in Vietnamese style
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(totalPrice);
  }

  String get bookingDuration {
    return '${selectedTimeSlots.length} giờ';
  }

  String get startTime {
    if (selectedTimeSlots.isEmpty) return '';

    // Sort slots by time
    selectedTimeSlots.sort((a, b) {
      final timeA = int.parse(a.split('-')[1].split(':')[0]);
      final timeB = int.parse(b.split('-')[1].split(':')[0]);
      return timeA.compareTo(timeB);
    });

    // Return the first time slot
    return selectedTimeSlots.first.split('-')[1];
  }

  int get selectedCourtId {
    if (selectedTimeSlots.isEmpty) return yardId;

    final courtName = selectedTimeSlots.first.split('-')[0];
    final courtData = yardAvailabilities.firstWhereOrNull(
      (yard) => yard.boatTitle == courtName,
    );

    return courtData?.boatId ?? yardId;
  }

  Future<void> addToCart() async {
    if (selectedTimeSlots.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn thời gian đặt sân',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    isAddingToCart.value = true;
    bookingError.value = '';

    try {
      // Get the court name from the first selected slot
      final courtName = selectedTimeSlots.first.split('-')[0];

      // Find the yard availability for the selected court
      final yardAvailability = yardAvailabilities.firstWhereOrNull(
        (yard) => yard.boatTitle == courtName,
      );

      if (yardAvailability == null) {
        throw Exception('Không tìm thấy thông tin sân');
      }

      // Fetch full yard data to get complete location info
      final fullYardData = await yardRepository.searchYards();
      final yard =
          fullYardData.firstWhereOrNull((y) => y.id == yardAvailability.boatId);

      // Get the venue address
      String venueAddress = '';
      // ignore: unnecessary_null_comparison
      if (yard != null && yard.location != null) {
        // Try to get real address text from the location
        if (yard.location.realAddressText.isNotEmpty) {
          venueAddress = yard.location.realAddressText;
        } else if (yard.location.name.isNotEmpty) {
          venueAddress = yard.location.name;
        }
      }

      print('Yard Full Data: $yard'); // Debug log
      print('Venue Address: $venueAddress'); // Debug log

      // Add booking to cart
      final response = await yardRepository.addBookingToCart(
        yardId: yardAvailability.boatId,
        bookingDate: selectedDate.value,
        durationHours: selectedTimeSlots.length,
        startTime: selectedTimeSlots.first.split('-')[1],
      );

      print('Cart Response: $response'); // Debug log

      // Check if response is successful (either status is 'success' or 1)
      if (response['status'] == 'success' || response['status'] == 1) {
        // Format the booking date
        final formattedDate =
            DateFormat('dd/MM/yyyy').format(selectedDate.value);

        // Create booking info object
        final bookingInfo = {
          'venueName': courtName,
          'venueAddress': venueAddress,
          'date': formattedDate,
          'customerType': 'Khách hàng',
          'totalHours': '${selectedTimeSlots.length} giờ',
          'totalPrice': totalPrice,
          'startTime': startTime,
          'booking_code': response['booking_code'],
          'yard_id': yardAvailability.boatId,
          'time_slots': selectedTimeSlots,
        };

        // Navigate to booking price screen with booking info
        Get.toNamed(
          Routes.bookingPrice,
          arguments: {
            'bookingInfo': bookingInfo,
          },
        );
      } else {
        // Handle error with more detailed message
        final errorMessage =
            response['message']?.toString() ?? 'Không thể thêm vào giỏ hàng';
        print('Cart Error: $errorMessage'); // Debug log
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Cart Exception: $e'); // Debug log
      bookingError.value = e.toString();
      Get.snackbar(
        'Lỗi',
        'Không thể thêm vào giỏ hàng: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isAddingToCart.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
