library repositories;

import 'dart:developer' as app_utils;
import 'dart:typed_data';

import '../models/dashboard_model.dart';
import '../models/models.dart';
// Remove this line because it's redundant
// import '../models/coupon.dart';

import '../providers/providers.dart';
import 'weather_repository.dart';

part 'auth_repository.dart';
part 'user_repository.dart';
part 'notification_repository.dart';
part 'chat_repository.dart';
part 'coupon_repository.dart';

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
}
