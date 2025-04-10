class YardFeatured {
  final int id;
  final String title;
  final String price;
  final String image;
  final LocationModel location;
  final int isFeatured;
  final ReviewScore reviewScore;

  YardFeatured({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.location,
    required this.isFeatured,
    required this.reviewScore,
  });

  factory YardFeatured.fromMap(Map<String, dynamic> json) => YardFeatured(
        id: json["id"] is String ? int.tryParse(json["id"]) ?? 0 : json["id"] ?? 0,
        title: json["title"] ?? '',
        price: json["price"] ?? '0',
        image: json["image"] ?? '',
        location: LocationModel.fromMap(json["location"] ?? {}),
        isFeatured: json["is_featured"] is String 
            ? int.tryParse(json["is_featured"]) ?? 0 
            : json["is_featured"] ?? 0,
        reviewScore: ReviewScore.fromMap(json["review_score"] ?? {}),
      );

  String get formattedPrice {
    if (price.isNotEmpty) {
      // Format price as currency with comma separators and add đ symbol
      try {
        final priceDouble = double.parse(price);
        return '${priceDouble.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
      } catch (e) {
        // ignore: unnecessary_brace_in_string_interps
        return '${price}đ';
      }
    }
    return '';
  }
}

class LocationModel {
  final String name;

  LocationModel({
    required this.name,
  });

  factory LocationModel.fromMap(Map<String, dynamic> json) => LocationModel(
        name: json["name"] ?? '',
      );
}

class ReviewScore {
  final String reviewText;

  ReviewScore({
    required this.reviewText,
  });

  factory ReviewScore.fromMap(Map<String, dynamic> json) => ReviewScore(
        reviewText: json["review_text"] ?? 'Not rated',
      );
}

class YardFeaturedResponse {
  final int total;
  final int totalPages;
  final List<YardFeatured> data;
  final int status;

  YardFeaturedResponse({
    required this.total,
    required this.totalPages,
    required this.data,
    required this.status,
  });

  factory YardFeaturedResponse.fromMap(Map<String, dynamic> json) {
    return YardFeaturedResponse(
      total: json["total"] ?? 0,
      totalPages: json["total_pages"] ?? 0,
      data: json["data"] == null
          ? []
          : List<YardFeatured>.from(
              json["data"].map((x) => YardFeatured.fromMap(x))),
      status: json["status"] ?? 0,
    );
  }
}
