class AppConfig {
  final bool searchEnabled;
  final int searchMinCharacters;
  final int searchDebounceMs;
  final String searchPlaceholder;
  final int minAppVersion;
  final bool maintenanceMode;
  final String maintenanceMessage;

  const AppConfig({
    required this.searchEnabled,
    required this.searchMinCharacters,
    required this.searchDebounceMs,
    required this.searchPlaceholder,
    required this.minAppVersion,
    required this.maintenanceMode,
    required this.maintenanceMessage,
  });

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      searchEnabled: map['search_enabled'] as bool? ?? false,
      searchMinCharacters: map['search_min_characters'] as int? ?? 3,
      searchDebounceMs: map['search_debounce_ms'] as int? ?? 500,
      searchPlaceholder: map['search_placeholder'] as String? ?? 'Buscar películas...',
      minAppVersion: map['min_app_version'] as int? ?? 1,
      maintenanceMode: map['maintenance_mode'] as bool? ?? false,
      maintenanceMessage: map['maintenance_message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'search_enabled': searchEnabled,
      'search_min_characters': searchMinCharacters,
      'search_debounce_ms': searchDebounceMs,
      'search_placeholder': searchPlaceholder,
      'min_app_version': minAppVersion,
      'maintenance_mode': maintenanceMode,
      'maintenance_message': maintenanceMessage,
    };
  }

  factory AppConfig.defaultConfig() {
    return const AppConfig(
      searchEnabled: false,
      searchMinCharacters: 3,
      searchDebounceMs: 500,
      searchPlaceholder: 'Buscar películas...',
      minAppVersion: 1,
      maintenanceMode: false,
      maintenanceMessage: '',
    );
  }
}
