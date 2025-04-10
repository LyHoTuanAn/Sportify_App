// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/coupon.dart';
import '../../../data/repositories/repositories.dart';
import '../../../routes/app_pages.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

class BookingPriceController extends GetxController {
  final couponRepository = Repo.coupon;

  // User input controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Reactive variables
  final Rx<BookingInfo> bookingInfo = BookingInfo(
    venueName: '',
    venueAddress: '',
    date: '',
    customerType: '',
    totalHours: '',
    totalPrice: 0,
  ).obs;

  final RxBool hasSelectedVoucher = false.obs;
  final Rx<Coupon?> selectedVoucher = Rx<Coupon?>(null);
  final RxList<Coupon> availableVouchers = <Coupon>[].obs;
  final RxBool isLoadingVouchers = false.obs;

  // Computed values
  double get courtFee => bookingInfo.value.totalPrice;
  double get voucherDiscount => selectedVoucher.value?.amount.toDouble() ?? 0;
  double get finalTotal => courtFee - voucherDiscount;

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

    try {
      // Call checkout API
      final result = await Repo.yard.doCheckout(
        code: 'a5fa2a00e038d001480864b6436a2980',
        fullName: nameController.text,
        phone: phoneController.text,
        email: emailController.text,
      );

      print('Checkout response: $result');

      // Check if the response contains a URL directly
      // ignore: unnecessary_null_comparison
      if (result != null &&
          result['url'] != null &&
          result['url'].toString().isNotEmpty) {
        final paymentUrl = result['url'].toString();
        print('URL in response: $paymentUrl');

        // Navigate to WebView screen
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
                      // Check for payment completion
                      if (url.contains('/api/booking/confirm-payment') ||
                          url.contains('vnp_ResponseCode=00')) {
                        print(
                            'Payment successful, redirecting to success page');
                        Get.offAllNamed(Routes.successfullPayment, arguments: {
                          'bookingInfo': {
                            'booking_code': 'a5fa2a00e038d001480864b6436a2980',
                            'venueName': bookingInfo.value.venueName,
                            'date': bookingInfo.value.date,
                            'totalPrice': finalTotal,
                          }
                        });
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
                        print('Payment failed');
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
                    },
                    onWebResourceError: (WebResourceError error) {
                      print('WebView error: ${error.description}');
                      print(
                          'Error details: ${error.errorCode} - ${error.errorType}');
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
        throw Exception('Không nhận được URL thanh toán');
      }
    } catch (e) {
      print('Checkout error: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể tạo đơn thanh toán: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    // Check if booking info was passed
    if (Get.arguments != null && Get.arguments['bookingInfo'] != null) {
      final bookingData = Get.arguments['bookingInfo'];
      dev.log('Received booking data: $bookingData');

      bookingInfo.value = BookingInfo(
        venueName: bookingData['title'] ?? bookingData['venueName'] ?? '',
        venueAddress:
            bookingData['address'] ?? bookingData['venueAddress'] ?? '',
        date: bookingData['date'] ?? '',
        customerType: bookingData['customerType'] ?? '',
        totalHours: bookingData['totalHours'] ?? '',
        totalPrice:
            _parsePrice(bookingData['price'] ?? bookingData['totalPrice']),
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
