part of 'providers.dart';

class YardProvider {
  static Future<Map<String, dynamic>> searchYards({
    double? userLat,
    double? userLng,
    int? authorId,
    bool? isFeatured,
  }) async {
    try {
      Map<String, dynamic> query = {};

      // Add location parameters if available
      if (userLat != null && userLng != null) {
        query["user_lat"] = userLat.toString();
        query["user_lng"] = userLng.toString();
      }

      // Add author_id filter if provided
      if (authorId != null) {
        query["author_id"] = authorId.toString();
      }

      // Add is_featured filter if provided
      if (isFeatured != null) {
        query["is_featured"] = isFeatured ? "1" : "0";
      }

      final res = await ApiClient.connect(
        ApiUrl.yardSearch,
        query: query,
      );

      if (res.statusCode == 200) {
        return res.data;
      }
      return {"status": 0, "data": []};
    } catch (e) {
      AppUtils.log('Error searching yards: $e');
      return {"status": 0, "data": []};
    }
  }

  static Future<Map<String, dynamic>> getAvailabilityCalendar({
    required String date,
    required List<int> yardIds,
  }) async {
    try {
      final query = {
        "start_date": date,
        "yard_ids": yardIds.join(','),
      };

      final res = await ApiClient.connect(
        ApiUrl.availabilityCalendar,
        query: query,
      );

      if (res.statusCode == 200) {
        return res.data;
      }
      return {"status": "error", "data": []};
    } catch (e) {
      AppUtils.log('Error getting availability calendar: $e');
      return {"status": "error", "data": []};
    }
  }
}
