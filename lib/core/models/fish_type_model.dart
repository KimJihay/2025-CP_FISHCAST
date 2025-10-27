/// Model representing a fish type in the system
class FishType {
  final String id;
  final String name;
  final String? scientificName;
  final String? category;
  final bool isActive;

  FishType({
    required this.id,
    required this.name,
    this.scientificName,
    this.category,
    this.isActive = true,
  });

  /// Create FishType from JSON (for API responses)
  factory FishType.fromJson(Map<String, dynamic> json) {
    return FishType(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientific_name'],
      category: json['category'],
      isActive: json['is_active'] ?? true,
    );
  }

  /// Convert FishType to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientific_name': scientificName,
      'category': category,
      'is_active': isActive,
    };
  }

  /// Create a copy with updated fields
  FishType copyWith({
    String? id,
    String? name,
    String? scientificName,
    String? category,
    bool? isActive,
  }) {
    return FishType(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FishType && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
