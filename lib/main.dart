import 'dart:async';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/core/styles/style.dart';
import 'app/core/utilities/encry_data.dart';
import 'app/core/utilities/utilities.dart';
import 'app/data/http_client/http_client.dart';
import 'app/data/providers/notification_provider.dart';
import 'app/modules/profile/controllers/profile_controller.dart';
import 'app/services/favorite_service.dart';
import 'app/services/service_initializer.dart';
import 'app/widgets/restart_widget.dart';
import 'root.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> initServices() async {
  Get.log('starting services ...');
  await Firebase.initializeApp();
  await Preferences.setPreferences();
  await NotificationProvider.initialize();

  EncryptData.init();

  // Khởi tạo các service cần thiết cho ứng dụng
  await ServiceInitializer.init();

  if (Preferences.isAuth()) {
    await Get.putAsync(
      () => ProfileController().getUserDetail(),
      permanent: true,
    );
  }

  Get.log('All services started...');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Thêm dòng này để khởi tạo dữ liệu ngôn ngữ tiếng Việt
  await initializeDateFormatting('vi_VN', null);

  await GetStorage.init();

  // Setup Firebase và Preferences before running the app
  await Firebase.initializeApp();
  await Preferences.setPreferences();

  final flavor = await getFlavorSettings();
  switch (flavor) {
    case 'dev':
      ApiClient.setBaseUrl('https://vnsportify.space');
      break;
    default:
      ApiClient.setBaseUrl('https://vnsportify.space');
  }

  // Khởi tạo các service với ServiceInitializer
  await ServiceInitializer.init();

  // Run the app after setting up Preferences
  runApp(
    RestartWidget(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('vi')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('vi'),
        useOnlyLangCode: true,
        saveLocale: true,
        useFallbackTranslations: true,
        child: const RootApp(),
      ),
    ),
  );

  // Complete initialization of other services
  EncryptData.init();
  await NotificationProvider.initialize();

  if (Preferences.isAuth()) {
    await Get.putAsync(
      () => ProfileController().getUserDetail(),
      permanent: true,
    );
  }

  // Setup error handling for Firebase Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // Setup error handling for unhandled errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  Get.log('All services started...');
}

Future<String?> getFlavorSettings() async {
  const methodChannel = MethodChannel('flavor');
  final flavor = await methodChannel.invokeMethod('flavor');
  return flavor;
}
