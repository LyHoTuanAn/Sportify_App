class YardSearchResponse {
  final int total;
  final int totalPages;
  final List<Yard> data;
  final int status;

  YardSearchResponse({
    required this.total,
    required this.totalPages,
    required this.data,
    required this.status,
  });

  factory YardSearchResponse.fromMap(Map<String, dynamic> json) {
    return YardSearchResponse(
      total: json["total"] ?? 0,
      totalPages: json["total_pages"] ?? 0,
      data: json["data"] == null
          ? []
          : List<Yard>.from(json["data"].map((x) => Yard.fromMap(x))),
      status: json["status"] ?? 0,
    );
  }
}

class Yard {
  final int id;
  final String title;
  final String price;
  final String? salePricePerHour;
  final String image;
  final Location location;
  final int? isFeatured;
  final YardReviewScore reviewScore;
  final List<String> features;
  final String? discount;
  final double? distanceInKm;
  final bool isOpen;
  bool isFavorite;

  Yard({
    required this.id,
    required this.title,
    required this.price,
    this.salePricePerHour,
    required this.image,
    required this.location,
    this.isFeatured,
    required this.reviewScore,
    this.features = const [],
    this.discount,
    this.distanceInKm,
    this.isOpen = true,
    this.isFavorite = false,
  });

  factory Yard.fromMap(Map<String, dynamic> json) {
    // Extract features from meta_data if available
    List<String> extractFeatures = [];
    if (json["meta_data"] != null && json["meta_data"] is Map) {
      final metaData = json["meta_data"] as Map;
      if (metaData.containsKey("features")) {
        if (metaData["features"] is List) {
          extractFeatures = List<String>.from(metaData["features"]);
        }
      }
    }

    // Extract discount from sale_price_html if available
    String? discountText;
    if (json.containsKey("sale_price_html") &&
        json["sale_price_html"] != null &&
        json["sale_price_html"].toString().isNotEmpty) {
      discountText = json["sale_price_html"];
    }

    // Check for discount_percent
    if (json.containsKey("discount_percent") &&
        json["discount_percent"] != null &&
        json["discount_percent"].toString() != "0") {
      discountText = "-${json["discount_percent"]}%";
    }

    // Calculate distance if coordinates are provided
    double? distance;
    if (json["distance"] != null) {
      if (json["distance"] is Map && json["distance"].containsKey("value")) {
        // New format with distance object containing value and unit
        try {
          distance = double.parse(json["distance"]["value"].toString());
        } catch (e) {
          print('Error parsing distance value: $e');
        }
      } else {
        // Old format with direct distance value
        try {
          distance = double.parse(json["distance"].toString());
        } catch (e) {
          print('Error parsing distance: $e');
        }
      }
    }

    // Get the sale price per hour if available
    String? salePricePerHour;
    if (json["sale_price_per_hour"] != null) {
      salePricePerHour = json["sale_price_per_hour"].toString();
    }

    return Yard(
      id: json["id"] ?? 0,
      title: json["title"] ?? '',
      price: json["price"] ?? '0',
      salePricePerHour: salePricePerHour,
      image: json["image"] ?? '',
      location: Location.fromMap({
        "name": json["location"] != null ? json["location"]["name"] : '',
        "lat": json["location"] != null ? json["location"]["map_lat"] : null,
        "lng": json["location"] != null ? json["location"]["map_lng"] : null,
        "real_address": json["real_address"],
      }),
      isFeatured: json["is_featured"],
      reviewScore: YardReviewScore.fromMap(json["review_score"] ?? {}),
      features: extractFeatures,
      discount: discountText,
      distanceInKm: distance,
      isOpen: json["is_open"] == 1 || json["is_open"] == true,
    );
  }

  String get formattedDistance {
    if (distanceInKm == null) return '';

    if (distanceInKm! < 1.0) {
      // Convert to meters if less than 1km
      final meters = (distanceInKm! * 1000).toInt();
      return '$meters m từ bạn';
    } else {
      // Show in km with one decimal place
      return '${distanceInKm!.toStringAsFixed(1)} km từ bạn';
    }
  }

  String get formattedPrice {
    if (price.isNotEmpty) {
      try {
        final priceDouble = double.parse(price);
        return '${priceDouble.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} vnđ/h';
      } catch (e) {
        return '${price} vnđ/h';
      }
    }
    return '';
  }

  // Format the sale price per hour
  String get formattedSalePrice {
    if (salePricePerHour != null && salePricePerHour!.isNotEmpty) {
      try {
        final salePriceDouble = double.parse(salePricePerHour!);
        return '${salePriceDouble.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} vnđ/h';
      } catch (e) {
        return '${salePricePerHour} vnd/h';
      }
    }
    return '';
  }
}

class Location {
  final String name;
  final double? lat;
  final double? lng;
  final String? address;
  final Map<String, dynamic>? realAddress;

  Location({
    required this.name,
    this.lat,
    this.lng,
    this.address,
    this.realAddress,
  });

  factory Location.fromMap(Map<String, dynamic> json) {
    String? address;
    Map<String, dynamic>? realAddressMap;

    // Check for real_address
    if (json["real_address"] is Map) {
      realAddressMap = Map<String, dynamic>.from(json["real_address"]);
      address = realAddressMap["address"];
    }

    return Location(
      name: json["name"] ?? '',
      lat: json["lat"] != null ? double.tryParse(json["lat"].toString()) : null,
      lng: json["lng"] != null ? double.tryParse(json["lng"].toString()) : null,
      address: address,
      realAddress: realAddressMap,
    );
  }

  String get realAddressText =>
      realAddress != null && realAddress!.containsKey("address")
          ? realAddress!["address"]
          : "";
}

class YardReviewScore {
  final String reviewText;
  final double? score;
  final int? totalReview;

  YardReviewScore({
    required this.reviewText,
    this.score,
    this.totalReview,
  });

  factory YardReviewScore.fromMap(Map<String, dynamic> json) {
    double? parseScore;
    if (json["score"] != null) {
      try {
        parseScore = double.parse(json["score"].toString());
      } catch (e) {
        print('Error parsing review score: $e');
      }
    }

    return YardReviewScore(
      reviewText: json["review_text"] ?? 'Not rated',
      score: parseScore,
      totalReview: json["total_review"] ?? 0,
    );
  }
}
