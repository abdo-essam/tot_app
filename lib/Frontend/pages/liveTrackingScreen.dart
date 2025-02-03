import 'dart:async';
import 'package:flutter/foundation.dart';
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
    super.key,
    required this.touristId,
    required this.tourGuideId,
    required this.tripId,
  });

  @override
  _LiveTrackingScreenState createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final Location _location = Location();
  final Dio _dio = Dio();
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  LatLng? _otherUserPosition;
  bool _isLoading = true;
  Set<Marker> _markers = {};
  StreamSubscription<LocationData>? _locationSubscription;
  Timer? _locationUpdateTimer;
  Timer? _fetchLocationTimer;
  bool _isTourGuide = true;
  Polyline? _navigationLine;
  String _currentUserRole = '';
  String _otherUserRole = '';

  @override
  void initState() {
    super.initState();
    _isTourGuide = globals.userId.toString() != widget.touristId;
    _setupRoles();
    _initializeLocation();
  }

  void _setupRoles() {
    if (_isTourGuide) {
      _currentUserRole = 'Tour Guide';
      _otherUserRole = 'Tourist';
    } else {
      _currentUserRole = 'Tourist';
      _otherUserRole = 'Tour Guide';
    }
  }

  Future<void> _initializeLocation() async {
    try {
      // Check and request permissions
      PermissionStatus permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          _showError('Location permission denied');
          return;
        }
      }

      // Check location service
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          _showError('Location service is disabled');
          return;
        }
      }

      // Configure location settings
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000,
        distanceFilter: 10,
      );

      // Get initial location
      setState(() => _isLoading = true);

      final LocationData locationData = await _location.getLocation();

      if (locationData.latitude != null && locationData.longitude != null) {
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(
              locationData.latitude!,
              locationData.longitude!,
            );
            _updateMarkers();
            _isLoading = false;
          });
        }
      } else {
        _showError('Could not get current location');
        return;
      }

      // Start location tracking
      _startLocationTracking();
      _startOtherUserLocationFetching();

    } catch (e) {
      _handleError('Error initializing location', e);
      setState(() => _isLoading = false);
    }
  }

  void _startLocationTracking() {
    _locationSubscription = _location.onLocationChanged.listen(
          (LocationData locationData) {
        if (mounted && locationData.latitude != null && locationData.longitude != null) {
          setState(() {
            _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
            _updateMarkers();
          });
        }
      },
      onError: (e) => _handleError('Location subscription error', e),
    );

    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _updateServerLocation(),
    );
  }

  void _startOtherUserLocationFetching() {
    String userIdToTrack = _isTourGuide ? widget.touristId : widget.tourGuideId;
    _fetchLocationTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _fetchOtherUserLocation(userIdToTrack),
    );
  }

  Future<void> _updateServerLocation() async {
    if (_currentPosition == null) return;

    try {
      await _dio.post(
        '${globals.apiUrl}/api/update-location',
        data: {
          'userId': globals.userId,
          'isTourGuide': _isTourGuide,
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'tripId': widget.tripId,
          'timestamp': DateTime.now().toIso8601String(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${globals.authToken}',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      _handleError('Error updating server location', e);
    }
  }

  Future<void> _fetchOtherUserLocation(String userId) async {
    try {
      final response = await _dio.get(
        '${globals.apiUrl}/api/get-location/$userId',
        options: Options(headers: {'Authorization': 'Bearer ${globals.authToken}'}),
      );

      if (response.statusCode == 200 && response.data['success']) {
        final locationData = response.data['data'];
        final otherPosition = LatLng(
          double.parse(locationData['latitude'].toString()),
          double.parse(locationData['longitude'].toString()),
        );

        setState(() {
          _otherUserPosition = otherPosition;
          _updateMarkers();
          if (_currentPosition != null) {
            _updateNavigationLine(_currentPosition!, otherPosition);
          }
        });
      }
    } catch (e) {
      _handleError('Error fetching other user location', e);
    }
  }

  void _updateMarkers() {
    if (_currentPosition == null) return;

    _markers = {
      Marker(
        markerId: const MarkerId('currentUser'),
        position: _currentPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _isTourGuide ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueBlue,
        ),
        infoWindow: InfoWindow(
          title: '$_currentUserRole (You)',
          snippet: 'Current Location',
        ),
      ),
    };

    if (_otherUserPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('otherUser'),
          position: _otherUserPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _isTourGuide ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: _otherUserRole,
            snippet: 'Tap to navigate',
          ),
        ),
      );
    }
  }

  void _updateNavigationLine(LatLng start, LatLng end) {
    _navigationLine = Polyline(
      polylineId: const PolylineId('navigation'),
      points: [start, end],
      color: Colors.blue,
      width: 4,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
    );
  }

  Widget _buildLegend() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: _isTourGuide ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_currentUserRole (You)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: _isTourGuide ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  _otherUserRole,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Tracking - $_currentUserRole'),
        backgroundColor: const Color(0xFFD28A22),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? const LatLng(0, 0), // Default position while loading
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              // Center on current location once available
              if (_currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLng(_currentPosition!),
                );
              }
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
          Positioned(
            top: 16,
            right: 16,
            child: _buildLegend(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (_currentPosition != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(_currentPosition!),
                );
              }
            },
            backgroundColor: const Color(0xFFD28A22),
            child: const Icon(Icons.my_location),
          ),
          if (_otherUserPosition != null) ...[
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(_otherUserPosition!),
                );
              },
              backgroundColor: const Color(0xFFD28A22),
              child: Icon(
                Icons.person_pin_circle,
                color: _isTourGuide ? Colors.blue : Colors.green,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleError(String message, dynamic error) {
    if (kDebugMode) {
      print('$message: $error');
      if (error is DioException) {
        print('DioError details: ${error.response?.data}');
      }
    }
    _showError('$message. Please try again.');
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    _fetchLocationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}