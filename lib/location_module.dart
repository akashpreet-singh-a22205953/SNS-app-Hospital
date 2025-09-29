import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class LocationModule  {
  final Location _location = Location();



  Future<LocationData?>getCurrentLocation() async {

    throw UnimplementedError('getCurrentLocation() has not been implemented yet.');

  }

  Stream<LocationData> onLocationChanged() {
    return _location.onLocationChanged;
  }

  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
  }
}