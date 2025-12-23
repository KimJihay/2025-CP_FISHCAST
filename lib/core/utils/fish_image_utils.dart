/// Utility class for mapping fish names to their image assets.
class FishImageUtils {
  /// Default fallback image when a fish image is not found
  static const String _defaultImage = 'assets/fish_images/round_scad.png';

  /// Map of normalized fish names to their image asset paths
  static const Map<String, String> _fishImageMap = {
    // Direct name matches
    'alumahan': 'assets/fish_images/alumahan.png',
    'culisi': 'assets/fish_images/culisi.png',
    'gulyasan': 'assets/fish_images/gulyasan.png',
    'lapu-lapu': 'assets/fish_images/lapu_lapu.png',
    'lapu lapu': 'assets/fish_images/lapu_lapu.png',
    'malasugi': 'assets/fish_images/malasugi.png',
    'matang baka': 'assets/fish_images/matang_baka.png',
    'matang-baka': 'assets/fish_images/matang_baka.png',
    'maya-maya': 'assets/fish_images/maya_maya.png',
    'maya maya': 'assets/fish_images/maya_maya.png',
    'mulmul': 'assets/fish_images/mulmul.png',
    'samaral': 'assets/fish_images/samaral.png',
    'stingray': 'assets/fish_images/sting_ray.png',
    'sting ray': 'assets/fish_images/sting_ray.png',
    'talakitok': 'assets/fish_images/talakitok.png',
    'tamban': 'assets/fish_images/tamban.png',
    'tangigue': 'assets/fish_images/tangigue.png',
    'tulingan': 'assets/fish_images/tulingan.png',
    
    // Full display name matches
    'bangus (milkfish)': 'assets/fish_images/milkfish.png',
    'bangus': 'assets/fish_images/milkfish.png',
    'milkfish': 'assets/fish_images/milkfish.png',
    'galunggong (round scad)': 'assets/fish_images/round_scad.png',
    'galunggong': 'assets/fish_images/round_scad.png',
    'round scad': 'assets/fish_images/round_scad.png',
    'yellowfin tuna': 'assets/fish_images/yellowfin_tuna.png',
    'tuna': 'assets/fish_images/yellowfin_tuna.png',
  };

  /// Get the image asset path for a given fish name.
  /// Returns the default image if no match is found.
  static String getImagePath(String fishName) {
    final normalized = fishName.toLowerCase().trim();
    
    // Try direct lookup first
    if (_fishImageMap.containsKey(normalized)) {
      return _fishImageMap[normalized]!;
    }
    
    // Try partial matching for display names with parentheses
    for (final entry in _fishImageMap.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return entry.value;
      }
    }
    
    return _defaultImage;
  }

  /// Check if an image exists for the given fish name.
  static bool hasImage(String fishName) {
    final normalized = fishName.toLowerCase().trim();
    
    if (_fishImageMap.containsKey(normalized)) {
      return true;
    }
    
    for (final key in _fishImageMap.keys) {
      if (normalized.contains(key) || key.contains(normalized)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Get all available fish image paths.
  static List<String> getAllImagePaths() {
    return _fishImageMap.values.toSet().toList();
  }
}
