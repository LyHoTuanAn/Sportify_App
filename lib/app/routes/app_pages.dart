import 'package:get/get.dart';

import '../modules/booking-price/bindings/booking_price_binding.dart';
import '../modules/booking-price/views/booking_price_view.dart';
import '../modules/change-password/bindings/change_password_binding.dart';
import '../modules/change-password/views/change_password_view.dart';
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
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/user-profile/bindings/user_profile_binding.dart';
import '../modules/user-profile/views/user_profile_view.dart';
import '../modules/successful-payment/bindings/successful_payment_binding.dart';
import '../modules/successful-payment/view/successful_payment_view.dart';
import '../modules/welcome/bindings/welcome_binding.dart';
import '../modules/welcome/views/welcome_view.dart';
import '../modules/forgot-password/bindings/forgot_password_binding.dart';
import '../modules/forgot-password/views/forgot_password_view.dart';
import '../modules/otp-code/bindings/otp_code_binding.dart';
import '../modules/otp-code/views/otp_code_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = <GetPage>[
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.login,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
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
      name: _Paths.changePassword,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: _Paths.detailNotify,
      page: () => NotificationDetail(id: Get.parameters['id'] as String),
    ),
    GetPage(
      name: _Paths.profile,
      page: () => const ProfileView(),
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
      name: _Paths.userprofile,
      page: () => const UserProfileView(),
      binding: UserProfileBinding(),
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
  ];
}
