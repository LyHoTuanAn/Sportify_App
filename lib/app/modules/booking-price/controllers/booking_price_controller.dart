// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/coupon.dart';
import '../../../data/repositories/repositories.dart';
import '../../../routes/app_pages.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';

class BookingInfo {
  final String venueName;
  final String venueAddress;
  final String date;
  final String totalHours;
  final double totalBeforeFees;
  final double commission;
  final String? commissionType;
  final double totalPrice;

  BookingInfo({
    required this.venueName,
    required this.venueAddress,
    required this.date,
    required this.totalHours,
    required this.totalBeforeFees,
    required this.commission,
    this.commissionType,
    required this.totalPrice,
  });
}

class BookingPriceController extends GetxController {
  final couponRepository = Repo.coupon;

  // User input controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Add persistent booking data storage
  final Rx<Map<String, dynamic>> bookingRawData = Rx<Map<String, dynamic>>({});

  // Add variable to store current WebView URL
  String? currentUrl;

  // Add property to store the current booking code
  String? bookingCode;

  // Reactive variables
  final Rx<BookingInfo> bookingInfo = BookingInfo(
    venueName: '',
    venueAddress: '',
    date: '',
    totalHours: '',
    totalBeforeFees: 0,
    commission: 0,
    commissionType: '',
    totalPrice: 0,
  ).obs;

  final RxBool hasSelectedVoucher = false.obs;
  final Rx<Coupon?> selectedVoucher = Rx<Coupon?>(null);
  final RxList<Coupon> availableVouchers = <Coupon>[].obs;
  final RxBool isLoadingVouchers = false.obs;

  // Computed values
  double get courtFee => bookingInfo.value.totalBeforeFees;
  double get serviceFee => bookingInfo.value.commission;
  double get voucherDiscount => selectedVoucher.value?.amount.toDouble() ?? 0;
  double get finalTotal => (courtFee + serviceFee) - voucherDiscount;

  String formatCurrency(double amount) {
    // Convert to thousands format with dot separator
    String priceString = amount.toInt().toString();
    final pattern = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    priceString =
        priceString.replaceAllMapped(pattern, (Match m) => '${m[1]}.');
    return '$priceStringđ';
  }

  void selectVoucher(Coupon voucher) {
    selectedVoucher.value = voucher;
    hasSelectedVoucher.value = true;
    update();
  }

  void removeVoucher() {
    selectedVoucher.value = null;
    hasSelectedVoucher.value = false;
    update();
  }

  Future<void> fetchVouchers() async {
    isLoadingVouchers.value = true;
    try {
      final coupons = await couponRepository.getCoupons();
      availableVouchers.assignAll(coupons);
      dev.log('Loaded ${coupons.length} vouchers from API');
    } catch (e) {
      dev.log('Error loading vouchers: $e');
      Get.snackbar(
        'Thông báo',
        'Có lỗi khi tải danh sách voucher',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoadingVouchers.value = false;
    }
  }

  void showVoucherSelectionModal() {
    // Fetch vouchers if not already loaded
    if (availableVouchers.isEmpty && !isLoadingVouchers.value) {
      fetchVouchers();
    }

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chọn voucher',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFF17252A),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Color(0xFF777777)),
                  ),
                ],
              ),
            ),
            // Voucher List
            Container(
              constraints: BoxConstraints(
                maxHeight: Get.height * 0.6,
              ),
              child: Obx(() {
                if (isLoadingVouchers.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (availableVouchers.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Không có voucher nào khả dụng',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Color(0xFF777777),
                        ),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ...availableVouchers
                          .map((voucher) => GestureDetector(
                                onTap: () {
                                  selectVoucher(voucher);
                                  Get.back();
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: selectedVoucher.value?.id ==
                                              voucher.id
                                          ? const Color(0xFF2B7A78)
                                          : const Color(0xFFE0E0E0),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        selectedVoucher.value?.id == voucher.id
                                            ? const Color(0xFFDEF2F1)
                                            : Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: selectedVoucher.value?.id ==
                                                    voucher.id
                                                ? const Color(0xFF2B7A78)
                                                : const Color(0xFFE0E0E0),
                                            width: 2,
                                          ),
                                        ),
                                        child: selectedVoucher.value?.id ==
                                                voucher.id
                                            ? const Center(
                                                child: Icon(
                                                  Icons.circle,
                                                  size: 8,
                                                  color: Color(0xFF2B7A78),
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              voucher.code,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Poppins',
                                                color: Color(0xFF333333),
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              'Giảm ${formatCurrency(voucher.amount.toDouble())}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Poppins',
                                                color: Color(0xFFE74C3C),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              voucher.name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                                color: Color(0xFF777777),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              voucher.formattedEndDate,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontFamily: 'Poppins',
                                                color: Color(0xFF777777),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          // ignore: unnecessary_to_list_in_spreads
                          .toList(),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> confirmAndPay() async {
    // Validate inputs
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty) {
      Get.snackbar(
        'Thông báo',
        'Vui lòng nhập đầy đủ thông tin',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFCDD2),
        colorText: const Color(0xFF333333),
      );
      return;
    }

    // Show loading indicator
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2B7A78),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Use the stored booking data instead of trying to get it from arguments again
      final bookingData = bookingRawData.value;

      // Log booking data for debugging
      print('Processing booking data: $bookingData');

      if (bookingData.isEmpty) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        throw Exception('Không tìm thấy dữ liệu đặt sân. Vui lòng thử lại.');
      }

      // Kiểm tra và log tất cả các trường của bookingData
      bookingData.forEach((key, value) {
        print('BookingData field: $key = $value');
      });

      // Lấy yardId từ arguments hoặc thông tin phòng
      int yardId = 0;
      if (bookingData.containsKey('yard_id')) {
        try {
          if (bookingData['yard_id'] is int) {
            yardId = bookingData['yard_id'];
          } else {
            yardId = int.parse(bookingData['yard_id'].toString());
          }
          print('Extracted yard_id: $yardId');
        } catch (e) {
          print('Error parsing yard_id: ${bookingData['yard_id']} - $e');
        }
      }

      // Nếu không tìm thấy yard_id, thử kiểm tra các trường khác
      if (yardId <= 0 && bookingData.containsKey('yardId')) {
        try {
          if (bookingData['yardId'] is int) {
            yardId = bookingData['yardId'];
          } else {
            yardId = int.parse(bookingData['yardId'].toString());
          }
          print('Found alternate yard_id field (yardId): $yardId');
        } catch (e) {
          print(
              'Error parsing alternate yardId: ${bookingData['yardId']} - $e');
        }
      }

      // Try one more approach - look for potential service_id field
      if (yardId <= 0 && bookingData.containsKey('service_id')) {
        try {
          if (bookingData['service_id'] is int) {
            yardId = bookingData['service_id'];
          } else {
            yardId = int.parse(bookingData['service_id'].toString());
          }
          print('Found yard_id from service_id field: $yardId');
        } catch (e) {
          print('Error parsing service_id: ${bookingData['service_id']} - $e');
        }
      }

      if (yardId <= 0) {
        // Close dialog before throwing exception
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        throw Exception('Không tìm thấy thông tin sân đặt. Vui lòng thử lại.');
      }

      // Lấy startTime từ time_slots array nếu có
      String startTime = "05:00"; // Giá trị mặc định nếu không thể xác định
      if (bookingData.containsKey('startTime')) {
        // Ưu tiên sử dụng startTime từ bookingData nếu có
        startTime = bookingData['startTime'].toString();
        print('Using startTime from bookingData: $startTime');
      } else if (bookingData.containsKey('time_slots') &&
          bookingData['time_slots'] is List &&
          (bookingData['time_slots'] as List).isNotEmpty) {
        // Nếu không có startTime, lấy từ time_slots
        List timeSlots = bookingData['time_slots'] as List;
        if (timeSlots.isNotEmpty) {
          // Lấy startTime từ slot đầu tiên (format: "Sân X-HH:MM")
          String firstSlot = timeSlots.first.toString();
          if (firstSlot.contains('-')) {
            startTime = firstSlot.split('-')[1];
            print('Extracted startTime from time_slots: $startTime');
          }
        }
      }

      // Lấy số giờ từ time_slots nếu có, nếu không thì từ totalHours
      int hours = 1; // Giá trị mặc định
      if (bookingData.containsKey('time_slots') &&
          bookingData['time_slots'] is List) {
        // Số giờ là số lượng slot đã chọn
        hours = (bookingData['time_slots'] as List).length;
        print('Using hours from time_slots count: $hours');
      } else if (bookingData.containsKey('totalHours')) {
        try {
          // Nếu không có time_slots, sử dụng totalHours
          String totalHoursStr = bookingData['totalHours'].toString();
          hours = int.parse(totalHoursStr.replaceAll(RegExp(r'[^0-9]'), ''));
          print('Using hours from totalHours: $hours');
        } catch (e) {
          print(
              'Không thể phân tích số giờ: ${bookingData['totalHours']}, sử dụng giá trị mặc định: $hours');
        }
      } else if (bookingInfo.value.totalHours.isNotEmpty) {
        try {
          hours = int.parse(
              bookingInfo.value.totalHours.replaceAll(RegExp(r'[^0-9]'), ''));
          print('Using hours from bookingInfo.totalHours: $hours');
        } catch (e) {
          print(
              'Không thể phân tích số giờ từ bookingInfo: ${bookingInfo.value.totalHours}, sử dụng giá trị mặc định: $hours');
        }
      }

      // Lấy ngày đặt từ date string
      String bookingDateStr = "";
      // First try to get date from bookingData
      if (bookingData.containsKey('date') && bookingData['date'] != null) {
        bookingDateStr = bookingData['date'].toString();
      }
      // Fallback to bookingInfo if not found in bookingData
      else if (bookingInfo.value.date.isNotEmpty) {
        bookingDateStr = bookingInfo.value.date;
      }
      // If still not available, use current date
      else {
        bookingDateStr = DateFormat('dd/MM/yyyy').format(DateTime.now());
        print(
            'No date found in booking data, using current date: $bookingDateStr');
      }

      if (bookingDateStr.contains(" ")) {
        bookingDateStr = bookingDateStr.split(" ")[0];
      }

      DateTime bookingDate;
      try {
        // Chuyển đổi định dạng dd/MM/yyyy sang yyyy-MM-dd
        List<String> parts = bookingDateStr.split('/');
        if (parts.length == 3) {
          bookingDate = DateTime.parse('${parts[2]}-${parts[1]}-${parts[0]}');
          print('Parsed booking date: $bookingDate from $bookingDateStr');
        } else {
          bookingDate = DateTime.now();
          print(
              'Định dạng ngày không đúng: $bookingDateStr, sử dụng ngày hiện tại: $bookingDate');
        }
      } catch (e) {
        // Nếu không parse được, sử dụng ngày hôm nay
        bookingDate = DateTime.now();
        print(
            'Không thể phân tích ngày đặt: $bookingDateStr, sử dụng ngày hiện tại: $bookingDate');
      }

      print(
          'Tạo booking với: yardId=$yardId, ngày=$bookingDate, giờ=$hours, bắt đầu=$startTime');

      // 1. Gọi API addToCart để tạo booking - thực hiện không đồng bộ để không block UI
      final addToCartResult = await Repo.yard.addBookingToCart(
        yardId: yardId,
        bookingDate: bookingDate,
        durationHours: hours,
        startTime: startTime,
      );

      print('Kết quả AddToCart: $addToCartResult');

      if (addToCartResult['status'] != 1) {
        // Đóng dialog loading trước khi throw exception
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        throw Exception(
            addToCartResult['message'] ?? 'Không thể tạo đơn đặt sân');
      }

      // 2. Lấy booking_code từ kết quả addToCart
      bookingCode = addToCartResult['booking_code']?.toString();
      if (bookingCode == null || bookingCode!.isEmpty) {
        // Đóng dialog loading trước khi throw exception
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        throw Exception('Không nhận được mã đặt sân');
      }

      print('Created booking with code: $bookingCode');

      // 3. Gọi API doCheckout với booking_code mới
      print(
          'Checkout request data: {code: $bookingCode, full_name: ${nameController.text}, phone: ${phoneController.text}, email: ${emailController.text}}');

      final result = await Repo.yard.doCheckout(
        code: bookingCode.toString(),
        fullName: nameController.text,
        phone: phoneController.text,
        email: emailController.text,
      );

      print('Checkout response: $result');

      // Đóng dialog loading
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Xử lý response
      if (result != null &&
          result['url'] != null &&
          result['url'].toString().isNotEmpty) {
        final paymentUrl = result['url'].toString();
        print('URL in response: $paymentUrl');

        // Kiểm tra URL có phải VNPay không
        if (!paymentUrl.contains('vnpayment.vn')) {
          throw Exception('Nhận được URL không hợp lệ: $paymentUrl');
        }

        // Mở WebView thanh toán sau một khoảng thời gian ngắn
        // để cho phép UI cập nhật trước
        await Future.delayed(const Duration(milliseconds: 300));
        Get.to(
          () => Scaffold(
            appBar: AppBar(
              title: const Text('Thanh toán'),
              backgroundColor: const Color(0xFF2B7A78),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () async {
                  final shouldClose = await showDialog<bool>(
                    context: Get.context!,
                    builder: (context) => AlertDialog(
                      title: const Text('Xác nhận'),
                      content: const Text('Bạn có chắc muốn hủy thanh toán?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Không'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Có'),
                        ),
                      ],
                    ),
                  );
                  if (shouldClose == true) {
                    Get.back();
                  }
                },
              ),
            ),
            body: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setBackgroundColor(Colors.white)
                ..enableZoom(true)
                ..setNavigationDelegate(
                  NavigationDelegate(
                    onPageStarted: (String url) {
                      print('WebView - Loading started: $url');
                      currentUrl = url; // Update the current URL

                      // Check for VNPay response codes in the URL parameters
                      if (url.contains('vnp_ResponseCode=00') ||
                          url.contains('vnp_TransactionStatus=00')) {
                        print(
                            'VNPay payment successful, extracting data from URL');

                        // Parse payment details from URL parameters
                        Uri uri = Uri.parse(url);
                        Map<String, String> params = uri.queryParameters;

                        // Extract relevant information
                        String vnpBookingCode = params['c'] ?? '';
                        String amount = params['vnp_Amount'] ?? '';
                        String transactionNo =
                            params['vnp_TransactionNo'] ?? '';

                        print(
                            'Payment completed: Booking code: $vnpBookingCode, Amount: $amount, Transaction: $transactionNo');

                        // Immediately navigate to success page without loading the return URL
                        Get.offAllNamed(Routes.successfullPayment, arguments: {
                          'bookingInfo': {
                            'booking_code': vnpBookingCode.isNotEmpty
                                ? vnpBookingCode
                                : (bookingCode?.toString() ?? ''),
                            'venueName': bookingInfo.value.venueName,
                            'date': bookingInfo.value.date,
                            'totalPrice': finalTotal,
                            'totalBeforeFees':
                                bookingInfo.value.totalBeforeFees,
                            'commission': bookingInfo.value.commission,
                          }
                        });
                        return; // Stop further processing of this URL
                      }

                      // Check for other payment completion indicators
                      if (url.contains('/api/booking/confirm-payment')) {
                        print(
                            'Payment successful via confirm-payment endpoint');
                        Get.offAllNamed(Routes.successfullPayment, arguments: {
                          'bookingInfo': {
                            'booking_code': bookingCode.toString(),
                            'venueName': bookingInfo.value.venueName,
                            'date': bookingInfo.value.date,
                            'totalPrice': finalTotal,
                            'totalBeforeFees':
                                bookingInfo.value.totalBeforeFees,
                            'commission': bookingInfo.value.commission,
                          }
                        });
                        return;
                      }

                      // Check for payment cancellation
                      else if (url.contains('vnp_ResponseCode=24')) {
                        print('Payment cancelled by user');
                        Get.back();
                        Get.snackbar(
                          'Thông báo',
                          'Bạn đã hủy thanh toán',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange[100],
                          colorText: Colors.orange[900],
                        );
                      }
                      // Check for payment failure
                      else if (url.contains('vnp_ResponseCode=') &&
                          !url.contains('vnp_ResponseCode=00')) {
                        print('Payment failed with code in URL: $url');
                        Get.back();
                        Get.snackbar(
                          'Lỗi',
                          'Thanh toán không thành công. Vui lòng thử lại',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red[100],
                          colorText: Colors.red[900],
                        );
                      }
                    },
                    onPageFinished: (String url) {
                      print('WebView - Loading finished: $url');
                      currentUrl = url; // Update current URL
                    },
                    onWebResourceError: (WebResourceError error) {
                      // If we get a connection refused error when trying to load the return URL
                      // but the payment was actually successful, redirect to success page
                      print('WebView error: ${error.description}');
                      print(
                          'Error details: ${error.errorCode} - ${error.errorType}');

                      // Check if this is the localhost error after successful payment
                      if (currentUrl != null &&
                          currentUrl!.contains('vnp_ResponseCode=00') &&
                          error.errorType == WebResourceErrorType.connect) {
                        print(
                            'Detected successful payment but failed to load return URL');

                        // Try to extract booking code from currentUrl
                        String extractedBookingCode = '';
                        try {
                          Uri uri = Uri.parse(currentUrl!);
                          extractedBookingCode = uri.queryParameters['c'] ?? '';
                        } catch (e) {
                          print('Error parsing URL: $e');
                        }

                        // Navigate to success page
                        Get.offAllNamed(Routes.successfullPayment, arguments: {
                          'bookingInfo': {
                            'booking_code': extractedBookingCode.isNotEmpty
                                ? extractedBookingCode
                                : (bookingCode?.toString() ?? ''),
                            'venueName': bookingInfo.value.venueName,
                            'date': bookingInfo.value.date,
                            'totalPrice': finalTotal,
                            'totalBeforeFees':
                                bookingInfo.value.totalBeforeFees,
                            'commission': bookingInfo.value.commission,
                          }
                        });
                        return;
                      }

                      // For other errors, show error message
                      Get.snackbar(
                        'Lỗi',
                        'Không thể tải trang thanh toán: ${error.description}',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red[100],
                        colorText: Colors.red[900],
                      );
                    },
                  ),
                )
                ..loadRequest(Uri.parse(paymentUrl)),
            ),
          ),
          fullscreenDialog: true,
          preventDuplicates: true,
        );
      } else {
        throw Exception('Không nhận được URL thanh toán hợp lệ');
      }
    } catch (e) {
      print('Checkout error: $e');

      // Ensure dialog is closed
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Lỗi',
        'Không thể tạo đơn thanh toán: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();

    // Clear stored data
    bookingRawData.value = {};
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    // Add debug log for all arguments
    print('BookingPriceController.onInit - Arguments: ${Get.arguments}');

    // Check if booking info was passed
    if (Get.arguments != null && Get.arguments['bookingInfo'] != null) {
      final bookingData = Get.arguments['bookingInfo'];
      dev.log('Received booking data: $bookingData');

      // Store the raw booking data
      bookingRawData.value = Map<String, dynamic>.from(bookingData);

      // Extract the booking code if available
      if (bookingData['booking_code'] != null) {
        bookingCode = bookingData['booking_code'].toString();
      }

      // Parse commission data
      double commission = 0;
      if (bookingData['commission'] != null) {
        commission = _parsePrice(bookingData['commission']);
      }

      // Parse total_before_fees
      double totalBeforeFees = 0;
      if (bookingData['total_before_fees'] != null) {
        totalBeforeFees = _parsePrice(bookingData['total_before_fees']);
      } else if (bookingData['totalBeforeFees'] != null) {
        totalBeforeFees = _parsePrice(bookingData['totalBeforeFees']);
      } else {
        // If not found, try to use the price field
        totalBeforeFees = _parsePrice(bookingData['price'] ?? 0);
      }

      // Parse total price
      double totalPrice = 0;
      if (bookingData['total'] != null) {
        totalPrice = _parsePrice(bookingData['total']);
      } else {
        totalPrice =
            _parsePrice(bookingData['totalPrice'] ?? bookingData['price'] ?? 0);
      }

      // If total_before_fees was not present but we have total and commission, calculate it
      if (totalBeforeFees == 0 && totalPrice > 0 && commission > 0) {
        totalBeforeFees = totalPrice - commission;
      }

      // Create booking info object
      bookingInfo.value = BookingInfo(
        venueName: bookingData['title'] ?? bookingData['venueName'] ?? '',
        venueAddress:
            bookingData['address'] ?? bookingData['venueAddress'] ?? '',
        date: bookingData['date'] ?? '',
        totalHours: bookingData['totalHours'] ?? '',
        totalBeforeFees: totalBeforeFees,
        commission: commission,
        commissionType: bookingData['commission_type'] != null
            ? bookingData['commission_type']['type'] ?? ''
            : null,
        totalPrice: totalPrice,
      );
    }

    // Fetch vouchers from API
    fetchVouchers();
  }

  double _parsePrice(dynamic price) {
    if (price == null) return 0;

    if (price is double) {
      return price;
    } else if (price is int) {
      return price.toDouble();
    } else if (price is String) {
      try {
        return double.parse(price);
      } catch (e) {
        return 0;
      }
    }

    return 0;
  }
}
