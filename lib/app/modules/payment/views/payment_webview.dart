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
    // ignore: avoid_print
    print('PaymentWebView - Initializing with URL: ${widget.paymentUrl}');
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      // ignore: avoid_print
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
              // ignore: avoid_print
              print('WebView - Loading started: $url');
              setState(() {
                isLoading = true;
                currentUrl = url;
                hasError = false;
                errorMessage = '';
              });

              // Optimize performance by reducing UI updates during page load
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) setState(() => isLoading = true);
              });

              // Check for payment completion
              if (url.contains('/api/booking/confirm-payment') ||
                  url.contains('vnp_ResponseCode=00')) {
                // ignore: avoid_print
                print('Payment successful, redirecting to success page');
                Get.offAllNamed(Routes.successfullPayment);
              }
              // Check for payment cancellation
              else if (url.contains('vnp_ResponseCode=24')) {
                // ignore: avoid_print
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
                // ignore: avoid_print
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
              // ignore: avoid_print
              print('WebView - Loading finished: $url');
              setState(() {
                isLoading = false;
              });

              // Execute JavaScript to optimize VNPay page for mobile viewing
              webViewController.runJavaScript('''
                // Remove unnecessary elements
                document.querySelectorAll('.vnpay-desktop-only').forEach(el => {
                  el.style.display = 'none';
                });
                
                // Make sure payment info is clearly visible
                document.querySelectorAll('.payment-amount').forEach(el => {
                  el.style.fontSize = '1.2em';
                  el.style.fontWeight = 'bold';
                });
              ''').catchError((e) {
                // Silently ignore JS errors
                print('JS optimization error: $e');
              });
            },
            onWebResourceError: (WebResourceError error) {
              // ignore: avoid_print
              print('WebView error: ${error.description}');
              // ignore: avoid_print
              print('Error details: ${error.errorCode} - ${error.errorType}');
              setState(() {
                hasError = true;
                errorMessage =
                    'Không thể tải trang thanh toán: ${error.description}';
                isLoading = false;
              });
            },
            onNavigationRequest: (NavigationRequest request) {
              // ignore: avoid_print
              print('WebView - Navigation request to: ${request.url}');
              return NavigationDecision.navigate;
            },
          ),
        );

      // ignore: avoid_print
      print('Loading payment URL: ${widget.paymentUrl}');
      webViewController.loadRequest(Uri.parse(widget.paymentUrl));
    } catch (e) {
      // ignore: avoid_print
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
