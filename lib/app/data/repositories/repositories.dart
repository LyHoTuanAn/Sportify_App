// ignore_for_file: unnecessary_import

library repositories;

// ignore: library_prefixes
import 'dart:developer' as AppUtils;
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../models/dashboard_model.dart';
import '../models/models.dart';
import '../models/weather_model.dart';
import '../models/yard_featured.dart';
import '../models/yard_search.dart';
import '../models/wishlist.dart';
import '../models/calendar_availability.dart';
import '../providers/providers.dart';
import '../http_client/http_client.dart';
import '../../core/utilities/api_string.dart';
import 'weather_repository.dart';

part 'auth_repository.dart';
part 'user_repository.dart';
part 'notification_repository.dart';
part 'chat_repository.dart';
part 'coupon_repository.dart';
part 'affiliate_repository.dart';
part 'yard_repository.dart';

class Repo {
  factory Repo() => _instance;
  Repo._internal();
  static final Repo _instance = Repo._internal();

  static AuthRepository get auth => AuthRepository();

  static UserRepository get user => UserRepository();
  static NotificationRepository get notify => NotificationRepository();

  static ChatRepository get chat => ChatRepository();
  static CouponRepository get coupon => CouponRepository();
  static WeatherRepository get weather => WeatherRepository();
  static AffiliateRepository get affiliate => AffiliateRepository();
  static YardRepository get yard => YardRepository();
}
