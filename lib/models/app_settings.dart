/// Data Layer model. Stores non-sensitive user preferences only.
class AppSettings {
  final String languageCode; // 'en' or 'bn'
  final List<String> selectedCities; // IANA timezone names, e.g. 'Asia/Dhaka'
  final bool dndPermissionGranted;

  AppSettings({
    required this.languageCode,
    required this.selectedCities,
    required this.dndPermissionGranted,
  });

  factory AppSettings.defaults() => AppSettings(
        languageCode: 'en',
        selectedCities: [
          'Australia/Sydney', // Sydney Met (university) is based in Sydney, Australia
          'Asia/Dhaka',
          'Europe/London',
          'America/New_York',
        ],
        dndPermissionGranted: false,
      );

  Map<String, dynamic> toJson() => {
        'languageCode': languageCode,
        'selectedCities': selectedCities,
        'dndPermissionGranted': dndPermissionGranted,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        languageCode: json['languageCode'] as String? ?? 'en',
        selectedCities:
            List<String>.from(json['selectedCities'] as List? ?? []),
        dndPermissionGranted: json['dndPermissionGranted'] as bool? ?? false,
      );

  AppSettings copyWith({
    String? languageCode,
    List<String>? selectedCities,
    bool? dndPermissionGranted,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      selectedCities: selectedCities ?? this.selectedCities,
      dndPermissionGranted: dndPermissionGranted ?? this.dndPermissionGranted,
    );
  }
}
