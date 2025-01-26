import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;
import 'package:dio/dio.dart';

class Allowtracking extends StatefulWidget {
  final String? tourGuideId; // Make parameters optional
  final String? tripId;

  const Allowtracking({
    super.key,
    this.tourGuideId,
    this.tripId,
  });

  @override
  _AllowtrackingState createState() => _AllowtrackingState();
}

class _AllowtrackingState extends State<Allowtracking> {
  final Dio _dio = Dio();
  final Location _location = Location();
  bool _locationGranted = false;
  String _statusMessage = "Grant location access to begin.";
  bool _isUpdatingLocation = false;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _requestLocationAccess();
  }

  @override
  void dispose() {
    _locationTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

// Request permission and enable background location tracking
  Future<void> _requestLocationAccess() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
// Check if location services are enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _statusMessage = "Location services are disabled.";
        });
        return;
      }
    }

// Check and request permission
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _statusMessage = "Location permission denied.";
        });
        return;
      }
    }

    setState(() {
      _locationGranted = true;
      _statusMessage = "Location access granted!";
    });

// Configure location settings for real-time updates
    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000, // Update every 1 second
      distanceFilter: 0, // No minimum distance required for updates
    );

// Start tracking the location and update the backend
    _startLocationTracking();
  }

// Track location in real-time and send updates to the backend
  Future<void> _startLocationTracking() async {
    _location.onLocationChanged.listen((LocationData currentLocation) async {
      if (!_isUpdatingLocation) {
        setState(() {
          _isUpdatingLocation = true;
        });
        await _updateLocation(currentLocation.latitude, currentLocation.longitude);
        setState(() {
          _isUpdatingLocation = false;
        });
      }
    });
  }


// Send the location to the backend
  Future<void> _updateLocation(double? latitude, double? longitude) async {
    if (latitude != null && longitude != null) {
      try {
        if (kDebugMode) {
          print('Sending location update: lat=$latitude, lng=$longitude');
        }
        setState(() {
          _isUpdatingLocation = true;
        });

        final response = await _dio.post(
          '${globals.apiUrl}/api/update-location',
          data: {
            'latitude': latitude,
            'longitude': longitude,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer ${globals.authToken}',
              'Content-Type': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200) {
          if (kDebugMode) {
            print('Location updated successfully: ${response.data}');
          }
        } else {
          if (kDebugMode) {
            print('Failed to update location: ${response.statusCode}');
          }
        }
      } catch (e) {
        print('Error updating location: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isUpdatingLocation = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User - Location Tracking"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isUpdatingLocation)
              const CircularProgressIndicator()
            else
              Text(
                _statusMessage,
                style: const TextStyle(fontSize: 18, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            if (_locationGranted)
              const Text(
                "Your location is being tracked and sent to the server.",
                style: TextStyle(fontSize: 16, color: Colors.green),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}