class WishlistResponse {
  final int status;
  final List<WishlistItem> data;

  WishlistResponse({
    required this.status,
    required this.data,
  });

  factory WishlistResponse.fromMap(Map<String, dynamic> json) {
    return WishlistResponse(
      status: json["status"] ?? 0,
      data: json["data"] == null
          ? []
          : List<WishlistItem>.from(
              json["data"].map((x) => WishlistItem.fromMap(x))),
    );
  }
}

class WishlistItem {
  final int id;
  final int objectId;
  final String objectModel;

  WishlistItem({
    required this.id,
    required this.objectId,
    required this.objectModel,
  });

  factory WishlistItem.fromMap(Map<String, dynamic> json) {
    // Handle service field when present in response
    int objectId = json["object_id"] ?? 0;

    // If service field is present, extract object_id from there
    if (json.containsKey("service") && json["service"] is Map) {
      objectId = json["service"]["id"] ?? objectId;
    }

    return WishlistItem(
      id: json["id"] ?? 0,
      objectId: objectId,
      objectModel:
          json["object_model"] ?? "boat", // Default to "boat" if not specified
    );
  }
}

class WishlistToggleResponse {
  final int status;
  final String message;
  final String toggleClass;

  WishlistToggleResponse({
    required this.status,
    required this.message,
    required this.toggleClass,
  });

  factory WishlistToggleResponse.fromMap(Map<String, dynamic> json) {
    return WishlistToggleResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      toggleClass: json["class"] ?? "",
    );
  }

  // Check if item is active based only on toggleClass
  // The server returns class="active" when favorited and class="" when unfavorited
  // status is always 1 for both operations, so we can't rely on it
  bool get isActive => toggleClass == "active";
}
