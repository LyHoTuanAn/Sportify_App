import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

class BookingPriceController extends GetxController {
  // User input controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  
  // Reactive variables
  final Rx<BookingInfo> bookingInfo = BookingInfo(
    venueName: 'Badminton Ngọc Anh',
    venueAddress: 'B27 Tô Ký, Phường Trung Mỹ Tây, Quận 12, TP HCM',
    date: '26/02/2025',
    customerType: 'Khách hàng',
    totalHours: '1 giờ',
    totalPrice: 100000,
  ).obs;
  
  final RxBool hasSelectedVoucher = false.obs;
  final Rx<Voucher?> selectedVoucher = Rx<Voucher?>(null);
  final RxList<Voucher> availableVouchers = <Voucher>[
    Voucher(
      id: '1',
      code: 'WELCOME10K',
      title: 'WELCOME10K',
      discount: 10000,
      minimumPurchase: 0,
      expiryDate: DateTime(2025, 12, 31),
      description: 'Áp dụng cho người mới đăng ký',
    ),
    Voucher(
      id: '2',
      code: 'SPORT20K',
      title: 'SPORT20K',
      discount: 20000,
      minimumPurchase: 0,
      expiryDate: DateTime(2025, 12, 31),
      description: 'Đặt lịch trong tháng 2',
    ),
    Voucher(
      id: '3',
      code: 'WEEKEND15',
      title: 'WEEKEND15',
      discount: 15000,
      minimumPurchase: 0,
      expiryDate: DateTime(2025, 12, 31),
      description: 'Áp dụng cho đặt lịch cuối tuần',
    ),
  ].obs;
  
  // Computed values
  double get courtFee => bookingInfo.value.totalPrice;
  double get voucherDiscount => selectedVoucher.value?.discount ?? 0;
  double get finalTotal => courtFee - voucherDiscount;
  
  String formatCurrency(double amount) {
    // Convert to thousands format with dot separator
    String priceString = amount.toInt().toString();
    final pattern = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    priceString = priceString.replaceAllMapped(pattern, (Match m) => '${m[1]}.');
    return '$priceStringđ';
  }
  
  void selectVoucher(Voucher voucher) {
    selectedVoucher.value = voucher;
    hasSelectedVoucher.value = true;
    update();
  }
  
  void removeVoucher() {
    selectedVoucher.value = null;
    hasSelectedVoucher.value = false;
    update();
  }

  void showVoucherSelectionModal() {
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ...availableVouchers.map((voucher) => GestureDetector(
                      onTap: () {
                        selectVoucher(voucher);
                        Get.back();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedVoucher.value?.id == voucher.id 
                                ? const Color(0xFF2B7A78) 
                                : const Color(0xFFE0E0E0),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: selectedVoucher.value?.id == voucher.id 
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
                                  color: selectedVoucher.value?.id == voucher.id 
                                      ? const Color(0xFF2B7A78)
                                      : const Color(0xFFE0E0E0),
                                  width: 2,
                                ),
                              ),
                              child: selectedVoucher.value?.id == voucher.id
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    'Giảm ${formatCurrency(voucher.discount)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      color: Color(0xFFE74C3C),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    voucher.description,
                                    style: const TextStyle(
                                      fontSize: 12,
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
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
  
  void confirmAndPay() {
    // Validate inputs
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      Get.snackbar(
        'Thông báo', 
        'Vui lòng nhập đầy đủ thông tin',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFCDD2), 
        colorText: const Color(0xFF333333),
      );
      return;
    }
    
    // Process payment
    Get.snackbar(
      'Thành công', 
      'Đặt lịch thành công',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
  
  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
