import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_model.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current location with address details
  Future<LocationData> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable location services.');
    }

    // Check permission
    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied. Please grant location access.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable them in settings.',
      );
    }

    // Get position
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    // Get address from coordinates
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String? city = place.locality ?? place.subAdministrativeArea;
        String? country = place.country;
        
        // If city is null or empty, use Zamboanga City as fallback
        if (city == null || city.isEmpty) {
          return LocationData(
            latitude: 6.9214,
            longitude: 122.0790,
            city: "Zamboanga City",
            country: "Philippines",
            administrativeArea: "Zamboanga Peninsula",
          );
        }
        
        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          city: city,
          country: country,
          administrativeArea: place.administrativeArea,
        );
      }
    } catch (e) {
      // If geocoding fails, return Zamboanga City as fallback
      return LocationData(
        latitude: 6.9214,
        longitude: 122.0790,
        city: "Zamboanga City",
        country: "Philippines",
        administrativeArea: "Zamboanga Peninsula",
      );
    }

    // If no placemarks found, return Zamboanga City as fallback
    return LocationData(
      latitude: 6.9214,
      longitude: 122.0790,
      city: "Zamboanga City",
      country: "Philippines",
      administrativeArea: "Zamboanga Peninsula",
    );
  }

  /// Get location with cached option for better performance
  Future<LocationData> getLocationWithCache({Duration maxAge = const Duration(minutes: 5)}) async {
    try {
      // Try to get last known position first
      Position? lastPosition = await Geolocator.getLastKnownPosition();
      
      if (lastPosition != null) {
        final age = DateTime.now().difference(lastPosition.timestamp);
        if (age < maxAge) {
          // Use cached location
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(
              lastPosition.latitude,
              lastPosition.longitude,
            );
            
            if (placemarks.isNotEmpty) {
              Placemark place = placemarks.first;
              String? city = place.locality ?? place.subAdministrativeArea;
              
              // If city is null or empty, use Zamboanga City as fallback
              if (city == null || city.isEmpty) {
                return LocationData(
                  latitude: 6.9214,
                  longitude: 122.0790,
                  city: "Zamboanga City",
                  country: "Philippines",
                  administrativeArea: "Zamboanga Peninsula",
                );
              }
              
              return LocationData(
                latitude: lastPosition.latitude,
                longitude: lastPosition.longitude,
                city: city,
                country: place.country,
                administrativeArea: place.administrativeArea,
              );
            }
          } catch (e) {
            // Geocoding failed, return Zamboanga City as fallback
            return LocationData(
              latitude: 6.9214,
              longitude: 122.0790,
              city: "Zamboanga City",
              country: "Philippines",
              administrativeArea: "Zamboanga Peninsula",
            );
          }
        }
      }
    } catch (e) {
      // Last known position not available, continue to get current
    }

    // Get fresh location
    return await getCurrentLocation();
  }
}
