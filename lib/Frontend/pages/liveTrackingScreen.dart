import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:dio/dio.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;

/// LiveTrackingScreen widget for real-time location tracking between tourist and tour guide
class LiveTrackingScreen extends StatefulWidget {
  // Required parameters for tracking
  final String touristId;    // ID of the tourist
  final String tripId;       // ID of the current trip
  final String tourGuideId;  // ID of the tour guide

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
  // Core services
  final Location _location = Location();  // Location service instance
  final Dio _dio = Dio();                // HTTP client for API calls

  // Map and location related variables
  GoogleMapController? _mapController;    // Controller for Google Map
  LatLng? _currentPosition;              // Current user's position
  LatLng? _otherUserPosition;            // Other user's position
  Set<Marker> _markers = {};             // Set of markers on the map
  Polyline? _navigationLine;             // Line connecting both users

  // State variables
  bool _isLoading = true;                // Loading state indicator
  bool _isTourGuide = true;              // Role indicator
  String _currentUserRole = '';          // Current user's role (Tourist/Guide)
  String _otherUserRole = '';            // Other user's role

  // Subscriptions and timers for real-time updates
  StreamSubscription<LocationData>? _locationSubscription;  // Location updates subscription
  Timer? _locationUpdateTimer;    // Timer for updating server with location
  Timer? _fetchLocationTimer;     // Timer for fetching other user's location

  @override
  void initState() {
    super.initState();
    // Initialize roles and location tracking
    _isTourGuide = globals.userId.toString() != widget.touristId;
    _setupRoles();
    _initializeLocation();
  }

  /// Sets up user roles based on _isTourGuide flag
  void _setupRoles() {
    if (_isTourGuide) {
      _currentUserRole = 'Tour Guide';
      _otherUserRole = 'Tourist';
    } else {
      _currentUserRole = 'Tourist';
      _otherUserRole = 'Tour Guide';
    }
  }

  /// Initializes location services and starts tracking
  Future<void> _initializeLocation() async {
    try {
      // Check and request location permissions
      PermissionStatus permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          _showError('Location permission denied');
          return;
        }
      }

      // Verify location services are enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          _showError('Location service is disabled');
          return;
        }
      }

      // Configure location settings for high precision tracking
      await _location.changeSettings(
        accuracy: LocationAccuracy.navigation,  // Highest accuracy
        interval: 1000,                        // Update every second
        distanceFilter: 5,                     // Update every 5 meters movement
      );

      // Get initial location
      setState(() => _isLoading = true);
      final LocationData locationData = await _location.getLocation();

      // Update current position if location data is valid
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

      // Start continuous location tracking
      _startLocationTracking();
      _startOtherUserLocationFetching();

    } catch (e) {
      _handleError('Error initializing location', e);
      setState(() => _isLoading = false);
    }
  }

  /// Starts continuous location tracking and updates
  void _startLocationTracking() {
    // Listen to location changes
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

    // Start periodic server updates
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _updateServerLocation(),
    );
  }

  /// Starts fetching other user's location periodically
  void _startOtherUserLocationFetching() {
    String userIdToTrack = _isTourGuide ? widget.touristId : widget.tourGuideId;
    _fetchLocationTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _fetchOtherUserLocation(userIdToTrack),
    );
  }

  /// Updates server with current location
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

  /// Fetches other user's location from server
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

  /// Updates map markers for both users
  void _updateMarkers() {
    if (_currentPosition == null) return;

    _markers = {
      // Current user marker
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

    // Add other user's marker if available
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

  /// Updates the navigation line between users
  void _updateNavigationLine(LatLng start, LatLng end) {
    _navigationLine = Polyline(
      polylineId: const PolylineId('navigation'),
      points: [start, end],
      color: Colors.blue,
      width: 4,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
    );
  }

  /// Builds the legend widget showing user roles
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
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? const LatLng(0, 0),
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              // Center map on current location
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
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          // Legend
          Positioned(
            top: 16,
            right: 16,
            child: _buildLegend(),
          ),
        ],
      ),
      // Floating action buttons for location centering
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

  /// Handles and logs errors
  void _handleError(String message, dynamic error) {
    if (kDebugMode) {
      print('$message: $error');
      if (error is DioException) {
        print('DioError details: ${error.response?.data}');
      }
    }
    _showError('$message. Please try again.');
  }

  /// Shows error message to user
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// Cleanup resources on dispose
  @override
  void dispose() {
    _locationSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    _fetchLocationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}