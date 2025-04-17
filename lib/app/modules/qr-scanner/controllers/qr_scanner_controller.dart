import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart' hide Barcode;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as scanner;
import '../../../routes/app_pages.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../utils/bank_mapping.dart';
import '../utils/viet_qr_parser.dart';

class QrScannerController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController();
  final RxBool flashOn = false.obs;
  final RxBool isScanComplete = false.obs;
  final RxString scannedCode = ''.obs;
  final RxBool cameraPermissionGranted = true.obs;
  final RxBool isProcessing = false.obs;

  // Lưu trữ lịch sử quét
  final RxList<Map<String, dynamic>> scanHistory = <Map<String, dynamic>>[].obs;
  final storage = GetStorage();
  final ImagePicker _imagePicker = ImagePicker();

  // Thông tin người dùng cho mã QR cá nhân
  final RxString myQrData = 'sportify.app/user/'.obs;

  void onDetect(BarcodeCapture capture) {
    if (isScanComplete.value) return;

    final List<scanner.Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final scanner.Barcode barcode = barcodes.first;
    isScanComplete.value = true;
    scannedCode.value = barcode.rawValue ?? '';

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    if (scannedCode.value.isEmpty) {
      _showInvalidQRDialog('Không thể đọc nội dung mã QR.');
      return;
    }

    // Lưu vào lịch sử quét
    saveScanToHistory(scannedCode.value, _getQRCodeType(scannedCode.value));

    // Xử lý mã QR
    _processQRCode(scannedCode.value);
  }

  void _processQRCode(String code) {
    // Phân tích và xử lý mã QR để quyết định hướng chuyển tiếp

    // 1. Kiểm tra nếu là mã QR thanh toán (VietQR, VNPay, MoMo, ZaloPay, v.v.)
    if (_isPaymentQR(code)) {
      _handlePaymentQR(code);
      return;
    }

    // 2. Kiểm tra nếu là link booking
    if (code.contains('sportify.com/booking/') ||
        code.contains('sportify.app/booking/')) {
      // Trích xuất ID đặt sân từ URL
      final bookingId = _extractBookingId(code);

      // Thông báo và chuyển hướng đến trang chi tiết đặt sân
      Get.snackbar(
        'Mã đặt sân',
        'Đang mở thông tin đặt sân...',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF2B7A78),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Delay một chút trước khi chuyển hướng để người dùng thấy snackbar
      Future.delayed(const Duration(seconds: 1), () {
        // Nếu có booking ID, chuyển đến màn hình chi tiết đặt sân
        if (bookingId != null) {
          Get.back(); // Đóng màn hình quét QR
          Get.toNamed(Routes.bookingPrice, arguments: {'id': bookingId});
        } else {
          // Reset để quét tiếp
          resetScan();
        }
      });
      return;
    }

    // 3. Kiểm tra nếu là liên kết đến sân cụ thể
    if (code.contains('sportify.com/yard/') ||
        code.contains('sportify.app/yard/')) {
      // Trích xuất yard ID
      final yardId = _extractYardId(code);

      Get.snackbar(
        'Mã sân',
        'Đang mở thông tin sân...',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF2B7A78),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      Future.delayed(const Duration(seconds: 1), () {
        // Nếu có yard ID, chuyển đến màn hình chi tiết sân
        if (yardId != null) {
          Get.back(); // Đóng màn hình quét QR
          Get.toNamed(Routes.interfaceBooking,
              arguments: {'yard_id': int.parse(yardId)});
        } else {
          // Reset để quét tiếp
          resetScan();
        }
      });
      return;
    }

    // 4. Kiểm tra nếu là URL thông thường
    if (code.startsWith('http://') || code.startsWith('https://')) {
      Get.dialog(
        Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Mở liên kết',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17252A),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          resetScan();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          _openURL(code);
                          resetScan();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B7A78),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                        child: const Text('Mở'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    Get.back();
                    Clipboard.setData(ClipboardData(text: code));
                    Get.snackbar(
                      'Đã sao chép',
                      'Đã sao chép liên kết vào bộ nhớ tạm',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                    resetScan();
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Sao chép liên kết'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    // 5. Trường hợp khác - có thể là văn bản hoặc thông tin khác
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.text_fields_rounded,
                  color: Colors.purple,
                  size: 40,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Nội dung QR',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17252A),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        resetScan();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Đóng'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        Clipboard.setData(ClipboardData(text: code));
                        Get.snackbar(
                          'Đã sao chép',
                          'Nội dung đã được sao chép vào bộ nhớ tạm',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        resetScan();
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Sao chép'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B7A78),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hiển thị dialog thông báo mã QR không hợp lệ
  void _showInvalidQRDialog(String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Mã QR không hợp lệ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17252A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  resetScan();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B7A78),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 45),
                  elevation: 2,
                ),
                child: const Text(
                  'Quét lại',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Trích xuất ID booking từ URL
  String? _extractBookingId(String url) {
    final Uri uri = Uri.parse(url);
    final List<String> segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'booking') {
      return segments[1];
    }
    return null;
  }

  // Trích xuất ID sân từ URL
  String? _extractYardId(String url) {
    final Uri uri = Uri.parse(url);
    final List<String> segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'yard') {
      return segments[1];
    }
    return null;
  }

  // Reset scanner để quét lại
  void resetScan() {
    isScanComplete.value = false;
    scannedCode.value = '';
    // Đảm bảo scanner đang chạy
    scannerController.start();
  }

  // Phương thức mở URL
  void _openURL(String url) async {
    // Sử dụng DashboardController để chuyển đến tab Home nếu cần
    try {
      final dashboardController = Get.find<DashboardController>();
      dashboardController.changePage(0); // Chuyển về tab Home
    } catch (e) {
      // Ignore if DashboardController is not available
    }

    // Mở URL bằng url_launcher
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Lỗi',
        'Không thể mở liên kết: $url',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void toggleFlash() async {
    await scannerController.toggleTorch();
    flashOn.value = !flashOn.value;
  }

  void resumeScanning() {
    isScanComplete.value = false;
    scannerController.start();
  }

  @override
  void onInit() {
    super.onInit();
    // Tải lịch sử quét từ bộ nhớ cục bộ
    loadScanHistory();
    // Tải thông tin người dùng cho mã QR cá nhân
    loadUserQRData();
  }

  void loadScanHistory() {
    final List<dynamic>? history = storage.read<List>('scan_history');
    if (history != null) {
      scanHistory.value = List<Map<String, dynamic>>.from(history);
    }
  }

  void loadUserQRData() {
    // Lấy ID người dùng từ bộ nhớ cục bộ hoặc từ API
    final String? userId = storage.read<String>('user_id');
    if (userId != null && userId.isNotEmpty) {
      myQrData.value = 'sportify.app/user/$userId';
    }
  }

  void saveScanToHistory(String code, String type) {
    // Thêm vào đầu danh sách để hiển thị mục mới nhất trước
    scanHistory.insert(0, {
      'code': code,
      'type': type,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Giới hạn lịch sử quét ở 50 mục
    if (scanHistory.length > 50) {
      scanHistory.removeLast();
    }

    // Lưu vào bộ nhớ cục bộ
    storage.write('scan_history', scanHistory.toList());
  }

  // Chọn ảnh từ thư viện để quét mã QR
  Future<void> pickImageFromGallery() async {
    final XFile? pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      try {
        // Hiển thị loading
        Get.dialog(
          const Center(
            child: CircularProgressIndicator(),
          ),
          barrierDismissible: false,
        );

        // Quét mã QR từ ảnh
        try {
          final BarcodeCapture? result =
              await scannerController.analyzeImage(pickedImage.path);

          // Đóng dialog loading
          Get.back();

          if (result != null && result.barcodes.isNotEmpty) {
            final scanner.Barcode barcode = result.barcodes.first;
            final String? code = barcode.rawValue;
            if (code != null && code.isNotEmpty) {
              // Xử lý mã QR tìm thấy
              scannedCode.value = code;
              _processQRCode(code);
              saveScanToHistory(code, _getQRCodeType(code));
            } else {
              _showErrorDialog('Không tìm thấy mã QR trong ảnh');
            }
          } else {
            _showErrorDialog('Không tìm thấy mã QR trong ảnh');
          }
        } catch (e) {
          // Đóng dialog loading nếu có lỗi
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
          _showErrorDialog('Lỗi khi quét ảnh: $e');
        }
      } catch (e) {
        // Đóng dialog loading nếu có lỗi
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        _showErrorDialog('Lỗi khi quét ảnh: $e');
      }
    }
  }

  // Hiển thị mã QR cá nhân
  void showMyQRCode() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Mã QR của tôi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 250,
                height: 250,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: myQrData.value,
                  width: 230,
                  height: 230,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Chia sẻ mã QR này để kết nối',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B7A78),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text(
                  'Đóng',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hiển thị lịch sử quét
  void showScanHistory() {
    if (scanHistory.isEmpty) {
      Get.snackbar(
        'Lịch sử trống',
        'Bạn chưa quét mã QR nào',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
        animationDuration: const Duration(milliseconds: 500),
        icon: const Icon(Icons.history, color: Colors.white),
      );
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 15),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B7A78).withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          color: Color(0xFF2B7A78),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Lịch sử quét',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF17252A),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Get.dialog(
                        Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(20),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withAlpha(30),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                const Text(
                                  'Xóa lịch sử',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF17252A),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Bạn có chắc muốn xóa toàn bộ lịch sử quét?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => Get.back(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[200],
                                          foregroundColor: Colors.black87,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text('Hủy'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          scanHistory.clear();
                                          storage.remove('scan_history');
                                          Get.back(); // Đóng dialog
                                          Get.back(); // Đóng bottom sheet
                                          Get.snackbar(
                                            'Đã xóa',
                                            'Lịch sử quét đã được xóa',
                                            snackPosition: SnackPosition.TOP,
                                            backgroundColor: Colors.green,
                                            colorText: Colors.white,
                                            borderRadius: 10,
                                            margin: const EdgeInsets.all(10),
                                            duration:
                                                const Duration(seconds: 2),
                                            icon: const Icon(Icons.check_circle,
                                                color: Colors.white),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text('Xóa'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withAlpha(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(Get.context!).size.height * 0.5,
              ),
              child: Obx(() => ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    itemCount: scanHistory.length,
                    itemBuilder: (context, index) {
                      final item = scanHistory[index];
                      final DateTime date = DateTime.fromMillisecondsSinceEpoch(
                          item['timestamp']);
                      final String formattedDate =
                          '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute < 10 ? '0${date.minute}' : date.minute}';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              Get.back(); // Đóng bottom sheet
                              _processQRCode(item['code']);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  _getIconForQRType(item['type']),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['code'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF17252A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 12,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              formattedDate,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Clipboard.setData(
                                          ClipboardData(text: item['code']));
                                      Get.snackbar(
                                        'Đã sao chép',
                                        'Nội dung đã được sao chép vào bộ nhớ tạm',
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                        borderRadius: 10,
                                        margin: const EdgeInsets.all(10),
                                        duration: const Duration(seconds: 2),
                                        icon: const Icon(Icons.copy,
                                            color: Colors.white),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.copy_rounded,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    style: IconButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(30, 30),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  // Lấy icon dựa trên loại mã QR
  Widget _getIconForQRType(String type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'payment':
        iconData = Icons.payment_rounded;
        iconColor = Colors.purple;
        break;
      case 'url':
        iconData = Icons.link_rounded;
        iconColor = Colors.blue;
        break;
      case 'booking':
        iconData = Icons.calendar_today_rounded;
        iconColor = const Color(0xFF2B7A78);
        break;
      case 'yard':
        iconData = Icons.sports_soccer_rounded;
        iconColor = Colors.green;
        break;
      case 'text':
        iconData = Icons.text_fields_rounded;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.qr_code_rounded;
        iconColor = Colors.grey;
    }

    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: iconColor.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: iconColor, size: 22),
    );
  }

  // Xác định loại mã QR
  String _getQRCodeType(String code) {
    if (_isPaymentQR(code)) {
      return 'payment';
    } else if (code.startsWith('http://') || code.startsWith('https://')) {
      if (code.contains('/booking/')) {
        return 'booking';
      } else if (code.contains('/yard/')) {
        return 'yard';
      } else {
        return 'url';
      }
    } else {
      return 'text';
    }
  }

  // Kiểm tra xem có phải là mã QR thanh toán không
  bool _isPaymentQR(String code) {
    // Kiểm tra nếu là VietQR (EMV QR Code format)
    if (code.startsWith('00020101')) {
      // Sử dụng VietQRParser để kiểm tra
      final vietQRParser = VietQRParser(code);
      return vietQRParser.isVietQR();
    }

    // VietQR format URL
    if (code.startsWith('https://vietqr.io/') ||
        code.contains('bankplus.vn/') ||
        code.contains('vietqr.vn/')) {
      return true;
    }

    // VNPAY format
    if (code.startsWith('vnpay://') ||
        code.contains('vnpayqr.vn/') ||
        code.contains('pay.vnpay.vn/')) {
      return true;
    }

    // MoMo format
    if (code.startsWith('momo://') ||
        code.contains('nhantien.momo.vn/') ||
        code.contains('payment.momo.vn/') ||
        (code.contains('MM') && code.contains('MOMO'))) {
      return true;
    }

    // ZaloPay format
    if (code.startsWith('zalopay://') ||
        code.contains('qr.zalopay.vn/') ||
        code.contains('sbpay.zalopay.vn/')) {
      return true;
    }

    // ViettelPay format
    if (code.startsWith('viettelmoney://') ||
        code.contains('viettelmoney.vn/') ||
        code.contains('viettel.vn/')) {
      return true;
    }

    return false;
  }

  // Xử lý mã QR thanh toán
  void _handlePaymentQR(String code) {
    // Luôn sử dụng MoMo cho mọi mã QR thanh toán
    String appName = 'MoMo';
    String appPackage = 'com.mservice.momotransfer';
    String appScheme = 'momo://';
    String appIntent =
        'intent://scan/#Intent;scheme=momo;package=com.mservice.momotransfer;end';
    Map<String, dynamic> paymentInfo = {};

    // Xử lý mã VietQR (EMV QR - 00020101...)
    if (code.startsWith('00020101')) {
      // Sử dụng VietQRParser để phân tích mã QR
      final vietQRParser = VietQRParser(code);
      vietQRParser.parse();
      paymentInfo = Map<String, dynamic>.from(vietQRParser.extractedInfo);
    }

    // Tạo nội dung hiển thị thông tin thanh toán
    String paymentDetails = '';

    if (paymentInfo.isNotEmpty) {
      // Hiển thị thông tin người nhận
      if (paymentInfo.containsKey('beneficiaryName')) {
        paymentDetails += 'Người nhận: ${paymentInfo['beneficiaryName']}\n';
      }

      // Hiển thị số tài khoản
      if (paymentInfo.containsKey('accountNumber')) {
        paymentDetails += 'Số tài khoản: ${paymentInfo['accountNumber']}\n';
      }

      // Hiển thị ngân hàng
      if (paymentInfo.containsKey('bankName')) {
        paymentDetails += 'Ngân hàng: ${paymentInfo['bankName']}\n';
      }

      // Hiển thị số tiền
      if (paymentInfo.containsKey('amount')) {
        final amount = paymentInfo['amount'];
        // Format số tiền nếu có thể
        try {
          final amountValue = double.parse(amount);
          final formattedAmount = '${amountValue
                  .toStringAsFixed(0)
                  .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},')} VND';
          paymentDetails += 'Số tiền: $formattedAmount\n';
        } catch (e) {
          paymentDetails += 'Số tiền: $amount\n';
        }
      }

      // Hiển thị nội dung chuyển khoản
      if (paymentInfo.containsKey('description')) {
        paymentDetails += 'Nội dung: ${paymentInfo['description']}\n';
      }
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Mã thanh toán $appName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17252A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (paymentDetails.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Text(
                    paymentDetails,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
              Text(
                'Bạn có muốn mở $appName để thực hiện thanh toán không?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        resetScan();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _openPaymentApp(code, appScheme, appPackage, appIntent);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B7A78),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      child: const Text('Mở'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mở ứng dụng thanh toán
  Future<void> _openPaymentApp(String code, String appScheme, String appPackage,
      String appIntent) async {
    try {
      // Phân tích mã QR nếu là VietQR
      if (code.startsWith('00020101')) {
        // Sử dụng VietQRParser để phân tích mã QR
        final vietQRParser = VietQRParser(code);
        vietQRParser.parse();

        // Lấy thông tin từ mã QR
        String accountNumber =
            vietQRParser.extractedInfo['accountNumber'] ?? '';
        String bankName = vietQRParser.extractedInfo['bankName'] ?? '';
        String bankId = vietQRParser.extractedInfo['bankId'] ?? '';
        String amount = vietQRParser.extractedInfo['amount'] ?? '';

        // Xử lý thông tin ngân hàng
        if (bankName.isEmpty && bankId.isNotEmpty) {
          // Sử dụng BankMapping để chuyển đổi mã ngân hàng sang tên ngân hàng
          bankName = BankMapping.getMomoBankCodeFromBankId(bankId);
        }

        // Tạo deeplink theo cú pháp mới
        // momo://app?action=transferToBank&bankCode=VietCapitalBank&accountNumber=99MM2335M50641697&amount=70000
        String directDeeplink = 'momo://app?action=transferToBank';

        // Thêm thông tin ngân hàng
        if (bankName.isNotEmpty) {
          directDeeplink += '&bankCode=${Uri.encodeComponent(bankName)}';
        }

        // Thêm số tài khoản
        if (accountNumber.isNotEmpty) {
          directDeeplink +=
              '&accountNumber=${Uri.encodeComponent(accountNumber)}';
        }

        // Thêm số tiền nếu có
        if (amount.isNotEmpty) {
          directDeeplink += '&amount=${Uri.encodeComponent(amount)}';
        }

        try {
          final Uri uri = Uri.parse(directDeeplink);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          resetScan();
          return;
        } catch (e) {
          // Thử mở MoMo trực tiếp nếu không mở được với deeplink
          try {
            final Uri uri = Uri.parse('momo://');
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            resetScan();
            return;
          } catch (e2) {
            _showErrorDialog(
                'Không thể mở ứng dụng MoMo. Vui lòng kiểm tra xem ứng dụng đã được cài đặt chưa.');
          }
        }
      } else {
        // Nếu không phải mã VietQR, thử mở MoMo trực tiếp
        try {
          final Uri uri = Uri.parse('momo://');
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          resetScan();
          return;
        } catch (e) {
          _showErrorDialog(
              'Không thể mở ứng dụng MoMo. Vui lòng kiểm tra xem ứng dụng đã được cài đặt chưa.');
        }
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể mở ứng dụng thanh toán. Vui lòng mở thủ công.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
      );
      resetScan();
    }
  }

  // Hiển thị dialog lỗi
  void _showErrorDialog(String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 40,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Lỗi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17252A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B7A78),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 45),
                  elevation: 2,
                ),
                child: const Text(
                  'Đóng',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    // Đảm bảo giải phóng tài nguyên
    super.onClose();
  }
}
