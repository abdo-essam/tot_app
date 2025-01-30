import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:dio/dio.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:dio/dio.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;

class LiveTrackingScreen extends StatefulWidget {
  final String touristId;
  final String tripId;
  final String tourGuideId;

  const LiveTrackingScreen({
    Key? key,
    required this.touristId,
    required this.tourGuideId,
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
  bool _isTourGuide = true;
  Polyline? _navigationLine;

  @override
  void initState() {
    super.initState();
    _isTourGuide = globals.userId.toString() != widget.touristId;
    _initializeLocation();
    _startFetchingOtherUserLocation();
  }

  void _startFetchingOtherUserLocation() {
    String userIdToTrack = _isTourGuide ? widget.touristId : widget.tourGuideId;
    _fetchLocationTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _fetchOtherUserLocation(userIdToTrack),
    );
  }
  Future<void> _fetchOtherUserLocation(String userId) async {
    try {
      final response = await _dio.get(
        '${globals.apiUrl}/api/get-location/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${globals.authToken}',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success']) {
        final locationData = response.data['data'];
        final otherUserPosition = LatLng(
          double.parse(locationData['latitude'].toString()),
          double.parse(locationData['longitude'].toString()),
        );

        setState(() {
          // Update markers
          _markers = {
            // Current user marker (Tour Guide)
            Marker(
              markerId: const MarkerId('currentUser'),
              position: _currentPosition,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindow: const InfoWindow(
                title: 'Tour Guide',
                snippet: 'Current Location',
              ),
            ),
            // Tourist marker
            Marker(
              markerId: const MarkerId('otherUser'),
              position: otherUserPosition,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: const InfoWindow(
                title: 'Tourist',
                snippet: 'Tap to navigate',
              ),
              onTap: () {
                _updateNavigationLine(_currentPosition, otherUserPosition);
              },
            ),
          };

          // Update navigation line
          _updateNavigationLine(_currentPosition, otherUserPosition);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching other user location: $e');
      }
    }
  }
  void _startFetchingTouristLocation() {
    // Fetch tourist location every 1 seconds
    _fetchLocationTimer = Timer.periodic(
      const Duration(seconds: 1),
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
      if (kDebugMode) {
        print('Error fetching tourist location: $e');
      }
    }
  }

  Future<void> _initializeLocation() async {
    try {
      if (kDebugMode) {
        print('Requesting location permission...');
      }
      PermissionStatus permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          _showError('Location permission denied');
          return;
        }
      }

      if (kDebugMode) {
        print('Checking if location service is enabled...');
      }
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
        interval: 1000,
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
      if (kDebugMode) {
        print('Error initializing location: $e');
      }
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

            // Update current user marker
            _markers.removeWhere((m) => m.markerId.value == 'currentUser');
            _markers.add(
              Marker(
                markerId: const MarkerId('currentUser'),
                position: _currentPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    _isTourGuide ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueBlue
                ),
                infoWindow: InfoWindow(
                  title: _isTourGuide ? 'Tour Guide (You)' : 'Tourist (You)',
                  snippet: 'Current location',
                ),
              ),
            );
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
          'userId': globals.userId, // Add userId to request
          'isTourGuide': _isTourGuide,
          'latitude': _currentPosition.latitude,
          'longitude': _currentPosition.longitude,
          'tripId': widget.tripId, // Add tripId for reference
          'timestamp': DateTime.now().toIso8601String(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${globals.authToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Location updated successfully');
      } else {
        print('Failed to update location on server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating server location: $e');
      if (e is DioException) {
        print('DioError details: ${e.response?.data}');
      }
    }
  }
  void _updateNavigationLine(LatLng start, LatLng end) {
    setState(() {
      _navigationLine = Polyline(
        polylineId: const PolylineId('navigation'),
        points: [start, end],
        color: Colors.blue,
        width: 4,
        patterns: [
          PatternItem.dash(20),
          PatternItem.gap(10),
        ],
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Navigation'),
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
            polylines: _navigationLine != null ? {_navigationLine!} : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            compassEnabled: true,
          ),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          // Simplified legend
          Positioned(
            top: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Tour Guide'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Tourist'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _mapController?.animateCamera(
              CameraUpdate.newLatLng(_currentPosition),
            ),
            backgroundColor: const Color(0xFFD28A22),
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