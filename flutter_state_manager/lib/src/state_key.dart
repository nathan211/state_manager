/// Utility class for working with hierarchical state keys
class StateKey {
  /// Separator used in hierarchical keys
  static const String separator = '.';
  
  /// Create a hierarchical key from parts
  static String create(List<String> parts) {
    return parts.join(separator);
  }
  
  /// Get the parent key of a hierarchical key
  static String? parent(String key) {
    final parts = key.split(separator);
    if (parts.length <= 1) {
      return null;
    }
    return parts.sublist(0, parts.length - 1).join(separator);
  }
  
  /// Get the name part of a hierarchical key
  static String name(String key) {
    final parts = key.split(separator);
    return parts.last;
  }
  
  /// Check if a key is a child of another key
  static bool isChildOf(String childKey, String parentKey) {
    return childKey.startsWith('$parentKey$separator');
  }
  
  /// Get all parts of a hierarchical key
  static List<String> parts(String key) {
    return key.split(separator);
  }
  
  /// Create a feature-specific key
  static String forFeature(String feature, String name) {
    return create([feature, name]);
  }
  
  /// Create a subfeature-specific key
  static String forSubfeature(String feature, String subfeature, String name) {
    return create([feature, subfeature, name]);
  }
}
