class SavedPlaceRemoteDto {
  SavedPlaceRemoteDto({
    required this.id,
    required this.label,
    required this.latitude,
    required this.longitude,
    this.addressDescription,
  });

  factory SavedPlaceRemoteDto.fromJson(Map<String, dynamic> json) {
    return SavedPlaceRemoteDto(
      id: json['id'] as String,
      label: json['label'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      addressDescription: json['address_description'] as String?,
    );
  }

  final String id;
  final String label;
  final double latitude;
  final double longitude;
  final String? addressDescription;

  Map<String, dynamic> toCreateJson({
    required String label,
    required double latitude,
    required double longitude,
    String? addressDescription,
  }) =>
      {
        'label': label,
        'latitude': latitude,
        'longitude': longitude,
        if (addressDescription != null) 'address_description': addressDescription,
      };

  Map<String, dynamic> toUpdateJson({
    String? label,
    double? latitude,
    double? longitude,
    String? addressDescription,
    bool clearAddressDescription = false,
  }) =>
      {
        if (label != null) 'label': label,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (addressDescription != null) 'address_description': addressDescription,
        if (clearAddressDescription) 'clear_address_description': true,
      };
}
