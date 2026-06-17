import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  Future<String?> getCityDistrictLabel({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        return null;
      }
      return formatCityDistrict(placemarks.first);
    } catch (_) {
      return null;
    }
  }

  String formatCityDistrict(Placemark placemark) {
    final district = _firstNonEmpty([
      placemark.subLocality,
      placemark.subAdministrativeArea,
      placemark.thoroughfare,
      placemark.name,
    ]);
    final city = _firstNonEmpty([
      placemark.locality,
      placemark.administrativeArea,
    ]);

    if (district != null && city != null && district != city) {
      return '$district, $city';
    }

    return district ?? city ?? '';
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }
}
