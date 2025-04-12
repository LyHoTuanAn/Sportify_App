import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  const PaymentWebView({super.key, required this.paymentUrl});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController webViewController;
  bool isLoading = true;
  String currentUrl = '';
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // ignore
    print('PaymentWebView - Initializing with URL: ${widget.paymentUrl}');
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      // ignore
      print('Initializing WebView controller...');
      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..enableZoom(true)
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setUserAgent('Mozilla/5.0 (Flutter; Mobile) WebView')
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              // ignore
              print('WebView - Loading started: $url');
              setState(() {
                isLoading = true;
                currentUrl = url;
                hasError = false;
                errorMessage = '';
              });

              // Check for VNPay success parameters
              if (url.contains('vnp_ResponseCode=00') ||
                  url.contains('vnp_TransactionStatus=00')) {
                // Extract booking info from URL if possible
                String? extractedBookingCode;
                try {
                  Uri uri = Uri.parse(url);
                  extractedBookingCode = uri.queryParameters['c'];
                } catch (e) {
                  // ignore
                  print('Error parsing URL parameters: $e');
                }

                // If there's a connection refused error for localhost callbacks, this will ensure we still complete payment
                // ignore
                print('Payment successful based on VNPay response parameters');
                Get.offAllNamed(Routes.successfullPayment,
                    arguments: extractedBookingCode != null
                        ? {'booking_code': extractedBookingCode}
                        : null);
                return;
              }

              // Check for payment completion
              if (url.contains('/api/booking/confirm-payment')) {
                // ignore
                print('Payment successful, redirecting to success page');
                Get.offAllNamed(Routes.successfullPayment);
              }
              // Check for payment cancellation
              else if (url.contains('vnp_ResponseCode=24')) {
                // ignore
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
                // ignore
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
              // ignore
              print('WebView - Loading finished: $url');
              setState(() {
                isLoading = false;
              });

              // Check again for VNPay success in case it wasn't caught in onPageStarted
              if (url.contains('vnp_ResponseCode=00') ||
                  url.contains('vnp_TransactionStatus=00')) {
                // ignore
                print(
                    'Payment successful based on VNPay response parameters (detected in onPageFinished)');
                Get.offAllNamed(Routes.successfullPayment);
              }
            },
            onWebResourceError: (WebResourceError error) {
              // ignore
              print('WebView error: ${error.description}');
              // ignore
              print('Error details: ${error.errorCode} - ${error.errorType}');

              // If the error is connection refused but we have a VNPay success URL,
              // this likely means the callback URL is for a local server not accessible from the app
              if (error.errorType == WebResourceErrorType.connect &&
                  currentUrl != null &&
                  currentUrl.contains('vnp_ResponseCode=00')) {
                // ignore
                print(
                    'Detected connection error after successful VNPay response, completing payment');
                Get.offAllNamed(Routes.successfullPayment);
                return;
              }

              setState(() {
                hasError = true;
                errorMessage =
                    'Không thể tải trang thanh toán: ${error.description}';
                isLoading = false;
              });
            },
            onNavigationRequest: (NavigationRequest request) {
              // ignore
              print('WebView - Navigation request to: ${request.url}');
              return NavigationDecision.navigate;
            },
          ),
        );

      // ignore
      print('Loading payment URL: ${widget.paymentUrl}');
      webViewController.loadRequest(Uri.parse(widget.paymentUrl));
    } catch (e) {
      // ignore
      print('Error initializing WebView: $e');
      setState(() {
        hasError = true;
        errorMessage = 'Không thể khởi tạo trang thanh toán: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
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
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toán'),
          backgroundColor: const Color(0xFF2B7A78),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldClose = await showDialog<bool>(
                context: context,
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
        body: Stack(
          children: [
            if (hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          hasError = false;
                          isLoading = true;
                        });
                        _initializeWebView();
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              )
            else
              WebViewWidget(controller: webViewController),
            if (isLoading)
              const LinearProgressIndicator(
                color: Color(0xFF2B7A78),
                backgroundColor: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}
