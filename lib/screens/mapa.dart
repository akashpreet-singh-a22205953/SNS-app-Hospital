import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:prjectcm/data/http_sns_datasource.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/screens/detalhespage.dart';
import 'package:provider/provider.dart';

class Mapa extends StatefulWidget {
  const Mapa({Key? key}) : super(key: key);

  @override
  State<Mapa> createState() => _HospitalsMapState();
}

class _HospitalsMapState extends State<Mapa> {
  GoogleMapController? _mapController;
  StreamSubscription<LocationData>? _locationSubscription;

  Set<Marker> _hospitalMarkers = {};
  List<Hospital> _hospitals = [];
  bool _isLoading = true;

  static const CameraPosition _defaultInitialPosition = CameraPosition(
    target: LatLng(38.7223, -9.1393),
    zoom: 8.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeMapData();
  }

  Future<void> _initializeMapData() async {
     _loadHospitals();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }




  Future<void> _loadHospitals() async {
    try {
      final repository = context.read<HttpSnsDataSource>();
      _hospitals = await repository.getAllHospitals();
      _updateMarkers();
    } catch (e) {
      print("Error loading hospitals: $e");
    }
  }

  void _updateMarkers() {
    if (_hospitals.isEmpty) return;

    final Set<Marker> markers = {};
    for (final hospital in _hospitals) {
      markers.add(
        Marker(
          markerId: MarkerId(hospital.id.toString()),
          position: LatLng(hospital.latitude, hospital.longitude),
          infoWindow: InfoWindow(
            title: hospital.name,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Detalhes(
                    hospitalId: hospital.id,
                  ),
                ),
              );
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }
    if (mounted) {
      setState(() {
        _hospitalMarkers = markers;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

  }



  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _defaultInitialPosition,
        markers: _hospitalMarkers,
        mapType: MapType.normal,
        zoomControlsEnabled: true,
      ),
    );
  }





}