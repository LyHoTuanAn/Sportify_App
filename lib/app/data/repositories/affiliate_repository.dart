part of repositories;

class AffiliateRepository {
  Future<String?> getCategoryLink(int categoryId) async {
    try {
      print('Fetching affiliate link for category ID: $categoryId');
      final res = await ApiClient.connect(ApiUrl.affiliateLinks(categoryId),
          options: Options(
              sendTimeout: Duration(seconds: 3),
              receiveTimeout: Duration(seconds: 3)));
      print('API response: ${res.data}');

      if (res.statusCode == 200 &&
          res.data['data'] != null &&
          res.data['data'] is List &&
          res.data['data'].isNotEmpty) {
        final url = res.data['data'][0]['url'];
        print('Found URL: $url');
        return url;
      }
      return null;
    } catch (e) {
      print('Error in getCategoryLink: $e');
      return null;
    }
  }
}
