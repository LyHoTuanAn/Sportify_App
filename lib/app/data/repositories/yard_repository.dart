part of 'repositories.dart';

class YardRepository {
  Future<List<YardFeatured>> getFeaturedYards() async {
    try {
      final response = await ApiProvider.getFeaturedYards();
      final featuredResponse = YardFeaturedResponse.fromMap(response);

      if (featuredResponse.status == 1 && featuredResponse.data.isNotEmpty) {
        // Filter only featured yards (though the API should already do this)
        return featuredResponse.data
            .where((yard) => yard.isFeatured == 1)
            .toList();
      }

      return [];
    } catch (e) {
      AppUtils.log('Error in YardRepository.getFeaturedYards: $e');
      return [];
    }
  }

  // Search yards with location and filters
  Future<List<Yard>> searchYards({
    double? userLat,
    double? userLng,
    String? orderBy,
  }) async {
    try {
      final response = await ApiProvider.searchYards(
        userLat: userLat,
        userLng: userLng,
        orderBy: orderBy,
      );

      final searchResponse = YardSearchResponse.fromMap(response);
      if (searchResponse.status == 1) {
        return searchResponse.data;
      }

      return [];
    } catch (e) {
      AppUtils.log('Error in YardRepository.searchYards: $e');
      return [];
    }
  }

  // Get user's wishlist items
  Future<List<WishlistItem>> getUserWishlist() async {
    try {
      final response = await ApiProvider.getUserWishlist();
      final wishlistResponse = WishlistResponse.fromMap(response);

      if (wishlistResponse.status == 1) {
        return wishlistResponse.data;
      }

      return [];
    } catch (e) {
      AppUtils.log('Error in YardRepository.getUserWishlist: $e');
      return [];
    }
  }

  // Toggle a yard in the wishlist (add/remove)
  Future<WishlistToggleResponse> toggleWishlistItem(int yardId,
      {String objectModel = "boat"}) async {
    try {
      final response =
          await ApiProvider.toggleWishlistItem(yardId, objectModel);
      return WishlistToggleResponse.fromMap(response);
    } catch (e) {
      AppUtils.log('Error in YardRepository.toggleWishlistItem: $e');
      return WishlistToggleResponse(
        status: 0,
        message: "Error: ${e.toString()}",
        toggleClass: "",
      );
    }
  }

  Future<List<YardFeatured>> getYardsByAuthorId(int authorId) async {
    try {
      final response = await ApiProvider.searchYards(authorId: authorId);

      if (response['status'] == 1 && response['data'] != null) {
        List<YardFeatured> yards = [];
        for (var item in response['data']) {
          yards.add(YardFeatured.fromMap(item));
        }
        return yards;
      }
      return [];
    } catch (e) {
      AppUtils.log('Error getting yards by author ID: $e');
      return [];
    }
  }

  Future<List<YardAvailability>> getYardAvailability({
    required DateTime date,
    required List<int> yardIds,
  }) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await ApiProvider.getAvailabilityCalendar(
        date: formattedDate,
        yardIds: yardIds,
      );

      if (response['status'] == 'success' && response['data'] != null) {
        List<YardAvailability> availabilities = [];
        for (var item in response['data']) {
          availabilities.add(YardAvailability.fromMap(item));
        }

        return availabilities;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Utility method to get all yards by the same author as the given yard
  Future<List<int>> getYardIdsBySelectedYard(int selectedYardId) async {
    try {
      // First get selected yard to find its author_id
      final response = await ApiProvider.searchYards();

      if (response['status'] == 1 && response['data'] != null) {
        // Find the selected yard
        int? authorId;
        for (var item in response['data']) {
          if (item['id'] == selectedYardId) {
            authorId = item['author_id'];
            break;
          }
        }

        if (authorId != null) {
          // Now get all yards with same author_id
          List<int> relatedYardIds = [];
          for (var item in response['data']) {
            if (item['author_id'] == authorId) {
              relatedYardIds.add(item['id']);
            }
          }
          return relatedYardIds;
        }
      }
      // If we can't find related yards, just return the selected yard
      return [selectedYardId];
    } catch (e) {
      return [selectedYardId];
    }
  }

  // Add booking to cart
  Future<Map<String, dynamic>> addBookingToCart({
    required int yardId,
    required DateTime bookingDate,
    required int durationHours,
    required String startTime,
  }) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(bookingDate);

      final response = await ApiProvider.addBookingToCart(
        serviceId: yardId,
        startDate: formattedDate,
        hour: durationHours,
        startTime: startTime,
      );

      return response;
    } catch (e) {
      AppUtils.log('Error adding booking to cart: $e');
      return {
        "status": "error",
        "message": "Failed to add booking to cart: ${e.toString()}"
      };
    }
  }

  Future<Map<String, dynamic>> doCheckout({
    required String code,
    required String fullName,
    required String phone,
    required String email,
  }) async {
    try {
      return await ApiProvider.doCheckout(
        code: code,
        fullName: fullName,
        phone: phone,
        email: email,
      );
    } catch (e) {
      print('Error in YardRepository.doCheckout: $e');
      rethrow;
    }
  }
}
