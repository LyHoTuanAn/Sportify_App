class SlotAvailability {
  final String start;
  final String end;
  final bool isAvailable;

  SlotAvailability(
      {required this.start, required this.end, required this.isAvailable});

  factory SlotAvailability.fromMap(Map<String, dynamic> map) {
    // Make sure to handle different formats of is_available from the API
    final isAvailableRaw = map['is_available'];
    bool parsedIsAvailable;

    if (isAvailableRaw is bool) {
      parsedIsAvailable = isAvailableRaw;
    } else if (isAvailableRaw is int) {
      parsedIsAvailable = isAvailableRaw == 1;
    } else if (isAvailableRaw is String) {
      parsedIsAvailable =
          isAvailableRaw.toLowerCase() == 'true' || isAvailableRaw == '1';
    } else {
      // Default to false if format is unknown
      parsedIsAvailable = false;
    }

    return SlotAvailability(
      start: map['start'] ?? '',
      end: map['end'] ?? '',
      isAvailable: parsedIsAvailable,
    );
  }

  @override
  String toString() => '$start-$end: ${isAvailable ? 'available' : 'booked'}';
}

class YardAvailability {
  final int boatId;
  final String boatTitle;
  final bool available;
  final List<SlotAvailability> availableSlots;

  YardAvailability({
    required this.boatId,
    required this.boatTitle,
    required this.available,
    required this.availableSlots,
  });

  factory YardAvailability.fromMap(Map<String, dynamic> map) {
    return YardAvailability(
      boatId: map['boat_id'] ?? 0,
      boatTitle: map['boat_title'] ?? '',
      available: map['available'] ?? false,
      availableSlots: (map['available_slots'] as List?)
              ?.map((e) => SlotAvailability.fromMap(e))
              .toList() ??
          [],
    );
  }

  @override
  String toString() =>
      'YardAvailability($boatId: $boatTitle, ${availableSlots.length} slots)';
}

class CalendarAvailabilityResponse {
  final String status;
  final List<YardAvailability> data;

  CalendarAvailabilityResponse({
    required this.status,
    required this.data,
  });

  factory CalendarAvailabilityResponse.fromMap(Map<String, dynamic> map) {
    return CalendarAvailabilityResponse(
      status: map['status'] ?? '',
      data: (map['data'] as List?)
              ?.map((e) => YardAvailability.fromMap(e))
              .toList() ??
          [],
    );
  }

  @override
  String toString() =>
      'CalendarResponse(status: $status, ${data.length} yards)';
}
