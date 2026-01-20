abstract class RemoteConfigService {
  /// Initialize the remote config service
  Future<void> initialize();

  /// Fetch and activate remote config values
  Future<bool> fetchAndActivate();

  /// Get a boolean value from remote config
  bool getBool(String key);

  /// Get a string value from remote config
  String getString(String key);

  /// Get an integer value from remote config
  int getInt(String key);

  /// Get a double value from remote config
  double getDouble(String key);

  /// Get all remote config values as a map
  Map<String, dynamic> getAll();

  /// Set default values for remote config
  Future<void> setDefaults(Map<String, dynamic> defaults);
}
