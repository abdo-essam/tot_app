import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:dio/dio.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;

class LiveTrackingScreen extends StatefulWidget {
  final String touristId;
  final String tripId;

  const LiveTrackingScreen({
    Key? key,
    required this.touristId,
    required this.tripId,
  }) : super(key: key);

  @override
  _LiveTrackingScreenState createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final Location _location = Location();
  final Dio _dio = Dio();
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(30.0444, 31.2357);
  bool _isLoading = true;
  Set<Marker> _markers = {};
  StreamSubscription<LocationData>? _locationSubscription;
  Timer? _locationTimer;
  Timer? _fetchLocationTimer;
  bool _isTourGuide = true; // Assuming the current user is the tour guide

  @override
  void initState() {
    super.initState();
    print('Initializing LiveTrackingScreen...');
    _initializeLocation();
    _startFetchingTouristLocation();
  }

  void _startFetchingTouristLocation() {
    // Fetch tourist location every 10 seconds
    _fetchLocationTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) => _fetchTouristLocation(),
    );
  }

  Future<void> _fetchTouristLocation() async {
    try {
      final response = await _dio.get(
        '${globals.apiUrl}/api/get-location/${widget.touristId}',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${globals.authToken}',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success']) {
        final locationData = response.data['data'];
        final touristPosition = LatLng(
          double.parse(locationData['latitude'].toString()),
          double.parse(locationData['longitude'].toString()),
        );

        setState(() {
          _markers = {
            ..._markers,
            Marker(
              markerId: const MarkerId('touristLocation'),
              position: touristPosition,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: const InfoWindow(title: 'Tourist Location'),
            ),
          };
        });

        // Optional: Center map on tourist location
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(touristPosition),
        );
      }
    } catch (e) {
      print('Error fetching tourist location: $e');
    }
  }

  Future<void> _initializeLocation() async {
    try {
      print('Requesting location permission...');
      PermissionStatus permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          _showError('Location permission denied');
          return;
        }
      }

      print('Checking if location service is enabled...');
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          _showError('Location service is disabled');
          return;
        }
      }

      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 10000,
        distanceFilter: 10,
      );

      final LocationData locationData = await _location.getLocation();

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(
            locationData.latitude ?? 30.0444,
            locationData.longitude ?? 31.2357,
          );
          _markers = {
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: _currentPosition,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindow: const InfoWindow(title: 'Your Location'),
            ),
          };
          _isLoading = false;
        });
      }

      _startLocationUpdates();
    } catch (e) {
      print('Error initializing location: $e');
      _showError('Failed to initialize location services');
    }
  }

  void _startLocationUpdates() {
    _locationSubscription?.cancel();
    _locationTimer?.cancel();

    _locationSubscription = _location.onLocationChanged.listen(
          (LocationData locationData) {
        if (mounted && locationData.latitude != null && locationData.longitude != null) {
          setState(() {
            _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
            _markers = {
              ..._markers.where((m) => m.markerId.value != 'currentLocation'),
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: _currentPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                infoWindow: const InfoWindow(title: 'Your Location'),
              ),
            };
          });
        }
      },
      onError: (e) {
        print('Location subscription error: $e');
      },
    );

    _locationTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _updateServerLocation(),
    );
  }

  Future<void> _updateServerLocation() async {
    try {
      final response = await _dio.post(
        '${globals.apiUrl}/api/update-location',
        data: {
          'latitude': _currentPosition.latitude,
          'longitude': _currentPosition.longitude,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${globals.authToken}',
          },
        ),
      );

      if (response.statusCode != 200) {
        print('Failed to update location on server');
      }
    } catch (e) {
      print('Error updating server location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        backgroundColor: const Color(0xFFD28A22),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                _mapController = controller;
              });
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            mapType: MapType.normal,
            compassEnabled: true,
          ),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _fetchTouristLocation,
            backgroundColor: const Color(0xFFD28A22),
            heroTag: 'refresh',
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(_currentPosition),
              );
            },
            backgroundColor: const Color(0xFFD28A22),
            heroTag: 'location',
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _locationTimer?.cancel();
    _fetchLocationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}