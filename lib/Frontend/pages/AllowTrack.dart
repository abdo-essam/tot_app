import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;
import 'package:dio/dio.dart';

class Allowtracking extends StatefulWidget {
  @override
  _AllowtrackingState createState() => _AllowtrackingState();
}

class _AllowtrackingState extends State<Allowtracking> {
  Dio _dio = Dio();
  Location _location = Location();
  bool _locationGranted = false;
  String _statusMessage = "Grant location access to begin.";
  bool _isUpdatingLocation = false;

  @override
  void initState() {
    super.initState();
    _requestLocationAccess();
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
        // Replace with your actual token
        String token = globals.authToken;

        final response = await _dio.post(
          'http://192.168.1.5:8080/api/update-location', // Update with your API URL
          data: {
            'latitude': latitude,
            'longitude': longitude,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );

        if (response.statusCode == 200) {
          setState(() {
            _statusMessage = "Location updated successfully!";
          });
        } else {
          setState(() {
            _statusMessage = "Failed to update location!";
          });
        }
      } catch (e) {
        setState(() {
          _statusMessage = "Error sending location: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User - Location Tracking"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isUpdatingLocation)
              CircularProgressIndicator()
            else
              Text(
                _statusMessage,
                style: TextStyle(fontSize: 18, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 20),
            if (_locationGranted)
              Text(
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
