import 'package:get/get.dart';

import '../data/repositories/repositories.dart';
import '../modules/booking-price/bindings/booking_price_binding.dart';
import '../modules/booking-price/views/booking_price_view.dart';
import '../modules/Payment/bindings/Payment_binding.dart';
import '../modules/Payment/views/Payment_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/list/bindings/list_binding.dart';
import '../modules/list/views/list_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/outstanding/bindings/outstanding_binding.dart';
import '../modules/outstanding/views/outstanding_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/reset-password/bindings/reset_password_binding.dart';
import '../modules/reset-password/views/reset_password_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/successful-payment/bindings/successful_payment_binding.dart';
import '../modules/successful-payment/view/successful_payment_view.dart';
import '../modules/welcome/bindings/welcome_binding.dart';
import '../modules/welcome/views/welcome_view.dart';
import '../modules/forgot-password/bindings/forgot_password_binding.dart';
import '../modules/forgot-password/views/forgot_password_view.dart';
import '../modules/otp-code/bindings/otp_code_binding.dart';
import '../modules/otp-code/views/otp_code_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/profile/controllers/profile_controller.dart';
import '../modules/coupon/bindings/coupon_binding.dart';
import '../modules/coupon/views/coupon_view.dart';
import '../modules/coupon/views/coupon_detail_view.dart';
import '../modules/weather/bindings/weather_binding.dart';
import '../modules/weather/views/weather_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.dashboard;

  static final routes = <GetPage>[
    GetPage(
      name: _Paths.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      bindings: [
        HomeBinding(),
        ListBinding(),
        OutstandingBinding(),
        ProfileBinding(),
      ],
    ),
    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    // Commented out welcome route to skip it
    // GetPage(
    //   name: _Paths.welcome,
    //   page: () => const WelcomeView(),
    //   binding: WelcomeBinding(),
    // ),
    GetPage(
      name: _Paths.detailNotify,
      page: () => NotificationDetail(id: Get.parameters['id'] as String),
    ),
    GetPage(
      name: _Paths.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.list,
      page: () => const ListPageView(),
      binding: ListBinding(),
    ),
    GetPage(
      name: _Paths.outstanding,
      page: () => const OutstandingView(),
      binding: OutstandingBinding(),
    ),
    GetPage(
      name: _Paths.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.otpCode,
      page: () => const OtpCodeView(),
      binding: OtpCodeBinding(),
    ),
    GetPage(
      name: _Paths.resetPassword,
      page: () => const ResetPasswordView(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: _Paths.successfullPayment,
      page: () => const SuccessfulPaymentView(),
      binding: SuccessfulPaymentBinding(),
    ),
    GetPage(
      name: _Paths.bookingPrice,
      page: () => const BookingPriceView(),
      binding: BookingPriceBinding(),
    ),
    GetPage(
      name: _Paths.payment,
      page: () => const PaymentView(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: _Paths.chat,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: Routes.coupon,
      page: () => const CouponView(),
      binding: CouponBinding(),
    ),
    GetPage(
      name: Routes.couponDetail,
      page: () => const CouponDetailView(),
      binding: CouponBinding(),
    ),
    GetPage(
      name: _Paths.weather,
      page: () => const WeatherView(),
      binding: WeatherBinding(),
    ),
  ];
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserRepository>(() => UserRepository());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
