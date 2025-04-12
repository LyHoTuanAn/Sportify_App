part of 'repositories.dart';

class AffiliateRepository {
  Future<String?> getCategoryLink(int categoryId) async {
    try {
      // ignore
      print('Fetching affiliate link for category ID: $categoryId');
      final res = await ApiClient.connect(ApiUrl.affiliateLinks(categoryId),
          options: Options(
              sendTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3)));
      // ignore
      print('API response: ${res.data}');

      if (res.statusCode == 200 &&
          res.data['data'] != null &&
          res.data['data'] is List &&
          res.data['data'].isNotEmpty) {
        final url = res.data['data'][0]['url'];
        // ignore
        print('Found URL: $url');
        return url;
      }
      return null;
    } catch (e) {
      // ignore
      print('Error in getCategoryLink: $e');
      return null;
    }
  }
}
