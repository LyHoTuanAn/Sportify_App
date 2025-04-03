import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppCacheManager {
  static const _key = 'appCustomCache';
  static CacheManager instance = CacheManager(
    Config(
      _key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: _key),
      fileService: HttpFileService(),
    ),
  );

  // Phương thức để xóa cache của một URL cụ thể
  static Future<void> removeFile(String url) async {
    await instance.removeFile(url);
  }

  // Phương thức để xóa toàn bộ cache
  static Future<void> clearCache() async {
    await instance.emptyCache();
  }
}
