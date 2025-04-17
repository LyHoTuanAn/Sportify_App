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

    // Xử lý các loại mã QR khác nhau
    if (scannedCode.value.startsWith('http://') ||
        scannedCode.value.startsWith('https://')) {
      // Kiểm tra nếu là URL của ứng dụng
      final String url = scannedCode.value;

      // Kiểm tra nếu là URL booking
      final String? bookingId = _extractBookingId(url);
      if (bookingId != null) {
        Get.back();
        // Use the booking-price route instead since BOOKING_DETAIL doesn't exist
        Get.toNamed(Routes.bookingPrice, arguments: {'bookingId': bookingId});
        return;
      }

      // Kiểm tra nếu là URL yard
      final String? yardId = _extractYardId(url);
      if (yardId != null) {
        Get.back();
        // Use the interfaceBooking route instead since YARD_DETAIL doesn't exist
        Get.toNamed(Routes.interfaceBooking,
            arguments: {'yard_id': int.tryParse(yardId) ?? 0});
        return;
      }

      // Xử lý URL thông thường
      Get.dialog(
        AlertDialog(
          title: const Text('Mở liên kết'),
          content: Text('Bạn có muốn mở liên kết này không?\n\n$url'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                resetScan();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
              child: const Text('Mở'),
            ),
          ],
        ),
      );
    } else {
      // Xử lý nội dung thông thường (không phải URL)
      Clipboard.setData(ClipboardData(text: scannedCode.value));
      Get.snackbar(
        'Đã quét thành công',
        'Đã sao chép: ${scannedCode.value}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
      });
    }
  }

  void _processQRCode(String code) {
    // Phân tích và xử lý mã QR để quyết định hướng chuyển tiếp

    // 1. Kiểm tra nếu là link booking
    if (code.contains('sportify.com/booking/') ||
        code.contains('sportify.app/booking/')) {
      // Trích xuất ID đặt sân từ URL
      final bookingId = _extractBookingId(code);

      // Thông báo và chuyển hướng đến trang chi tiết đặt sân
      Get.snackbar(
        'Mã đặt sân',
        'Đang mở thông tin đặt sân...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2B7A78),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Delay một chút trước khi chuyển hướng để người dùng thấy snackbar
      Future.delayed(const Duration(seconds: 1), () {
        Get.back(); // Đóng màn hình quét QR

        // Nếu có booking ID, chuyển đến màn hình chi tiết đặt sân
        if (bookingId != null) {
          Get.toNamed(Routes.bookingPrice, arguments: {'id': bookingId});
        }
      });
    }

    // 2. Kiểm tra nếu là liên kết đến sân cụ thể
    else if (code.contains('sportify.com/yard/') ||
        code.contains('sportify.app/yard/')) {
      // Trích xuất yard ID
      final yardId = _extractYardId(code);

      Get.snackbar(
        'Mã sân',
        'Đang mở thông tin sân...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2B7A78),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Get.back(); // Đóng màn hình quét QR

        // Nếu có yard ID, chuyển đến màn hình chi tiết sân
        if (yardId != null) {
          Get.toNamed(Routes.interfaceBooking,
              arguments: {'yard_id': int.parse(yardId)});
        }
      });
    }

    // 3. Kiểm tra nếu là URL thông thường
    else if (code.startsWith('http://') || code.startsWith('https://')) {
      Get.snackbar(
        'Đường dẫn web',
        'Đã tìm thấy: $code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2B7A78),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Hiển thị hộp thoại xác nhận mở liên kết
      Future.delayed(const Duration(seconds: 1), () {
        Get.dialog(
          AlertDialog(
            title: const Text('Mở liên kết'),
            content: Text('Bạn có muốn mở liên kết này?\n$code'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Get.back(); // Đóng dialog
                  Get.back(); // Đóng màn hình QR

                  // Mở URL bằng launcher hoặc trong app
                  _openURL(code);
                },
                child: const Text('Mở'),
              ),
            ],
          ),
        );
      });
    }

    // 4. Trường hợp khác - có thể là văn bản hoặc thông tin khác
    else {
      Get.snackbar(
        'Kết quả quét',
        code,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2B7A78),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      // Hiển thị dialog với nội dung quét được
      Future.delayed(const Duration(seconds: 1), () {
        Get.dialog(
          AlertDialog(
            title: const Text('Nội dung QR'),
            content: Text(code),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Đóng dialog
                  Get.back(); // Đóng màn hình QR

                  // Sao chép vào clipboard
                  Clipboard.setData(ClipboardData(text: code));
                  Get.snackbar(
                    'Đã sao chép',
                    'Nội dung đã được sao chép vào bộ nhớ tạm',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
                child: const Text('Sao chép & Đóng'),
              ),
              TextButton(
                onPressed: () {
                  Get.back(); // Đóng dialog
                  resumeScanning(); // Tiếp tục quét mã QR khác
                },
                child: const Text('Quét tiếp'),
              ),
            ],
          ),
        );
      });
    }

    // Reset trạng thái sau khi đã xử lý
    Future.delayed(const Duration(seconds: 2), () {
      isProcessing.value = false;
      if (!isScanComplete.value) {
        resumeScanning();
      }
    });
  }

  // Hiển thị dialog thông báo mã QR không hợp lệ
  void _showInvalidQRDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Mã QR không hợp lệ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              resetScan();
            },
            child: const Text('Quét lại'),
          ),
        ],
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
        snackPosition: SnackPosition.BOTTOM,
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
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
      );
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lịch sử quét',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Xóa lịch sử'),
                          content: const Text(
                              'Bạn có chắc muốn xóa toàn bộ lịch sử quét?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                scanHistory.clear();
                                storage.remove('scan_history');
                                Get.back(); // Đóng dialog
                                Get.back(); // Đóng bottom sheet
                                Get.snackbar(
                                  'Đã xóa',
                                  'Lịch sử quét đã được xóa',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              },
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
            const Divider(),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(Get.context!).size.height * 0.5,
              ),
              child: Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: scanHistory.length,
                    itemBuilder: (context, index) {
                      final item = scanHistory[index];
                      final DateTime date = DateTime.fromMillisecondsSinceEpoch(
                          item['timestamp']);
                      final String formattedDate =
                          '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';

                      return ListTile(
                        leading: _getIconForQRType(item['type']),
                        title: Text(
                          item['code'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(formattedDate),
                        onTap: () {
                          Get.back(); // Đóng bottom sheet
                          _processQRCode(item['code']);
                        },
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // Lấy icon dựa trên loại mã QR
  Widget _getIconForQRType(String type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'url':
        iconData = Icons.link;
        iconColor = Colors.blue;
        break;
      case 'booking':
        iconData = Icons.calendar_today;
        iconColor = const Color(0xFF2B7A78);
        break;
      case 'yard':
        iconData = Icons.sports_soccer;
        iconColor = Colors.green;
        break;
      case 'text':
        iconData = Icons.text_fields;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.qr_code;
        iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withAlpha(50),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  // Xác định loại mã QR
  String _getQRCodeType(String code) {
    if (code.startsWith('http://') || code.startsWith('https://')) {
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

  // Hiển thị dialog lỗi
  void _showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
}
