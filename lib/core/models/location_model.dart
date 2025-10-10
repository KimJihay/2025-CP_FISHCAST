class LocationData {
  final double latitude;
  final double longitude;
  final String? city;
  final String? country;
  final String? administrativeArea;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.city,
    this.country,
    this.administrativeArea,
  });

  String get displayName {
    if (city != null && country != null) {
      return '$city, $country';
    } else if (city != null) {
      return city!;
    } else if (administrativeArea != null && country != null) {
      return '$administrativeArea, $country';
    } else {
      return 'Unknown Location';
    }
  }

  LocationData copyWith({
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    String? administrativeArea,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
      administrativeArea: administrativeArea ?? this.administrativeArea,
    );
  }
}
