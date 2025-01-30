import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Allowtracking extends StatefulWidget {
  final String? tourGuideId;
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
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng? _currentPosition;
  LatLng? _guidePosition;
  Polyline? _navigationLine;
  String _status = "Initializing...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('InitState called');
    _setupLocation();
  }

  Future<void> _setupLocation() async {
    print('Setting up location...');
    try {
      // Check location service
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        print('Location service not enabled, requesting...');
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          setState(() {
            _status = "Location service not enabled";
            _isLoading = false;
          });
          return;
        }
      }

      // Check permissions
      print('Checking location permission...');
      var permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) {
          setState(() {
            _status = "Location permission denied";
            _isLoading = false;
          });
          return;
        }
      }

      print('Getting initial location...');
      // Get initial location
      LocationData locationData = await _location.getLocation();
      print('Initial location: ${locationData.latitude}, ${locationData.longitude}');

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(
            locationData.latitude ?? 30.0444,
            locationData.longitude ?? 31.2357,
          );
          _isLoading = false;
          _markers.add(
            Marker(
              markerId: const MarkerId('tourist'),
              position: _currentPosition!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: const InfoWindow(title: 'You'),
            ),
          );
        });
      }

      // Start location updates
      _startLocationUpdates();

      // Start fetching guide location
      if (widget.tourGuideId != null) {
        _fetchGuideLocation();
        // Periodic guide location updates
        Timer.periodic(const Duration(seconds: 3), (timer) {
          if (mounted) _fetchGuideLocation();
        });
      }

    } catch (e) {
      print('Error in setup: $e');
      setState(() {
        _status = "Error: $e";
        _isLoading = false;
      });
    }
  }

  void _startLocationUpdates() {
    print('Starting location updates...');
    _location.onLocationChanged.listen(
          (LocationData locationData) {
        print('Location update received: ${locationData.latitude}, ${locationData.longitude}');
        if (mounted && locationData.latitude != null && locationData.longitude != null) {
          setState(() {
            _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
            _updateMarkers();
          });
          _updateServerLocation(locationData);
        }
      },
      onError: (e) {
        print('Location update error: $e');
      },
    );
  }

  Future<void> _fetchGuideLocation() async {
    if (widget.tourGuideId == null) return;

    try {
      print('Fetching guide location...');
      final response = await _dio.get(
        '${globals.apiUrl}/api/get-location/${widget.tourGuideId}',
        options: Options(
          headers: {'Authorization': 'Bearer ${globals.authToken}'},
        ),
      );

      print('Guide location response: ${response.data}');
      if (response.statusCode == 200 && response.data['success']) {
        final locationData = response.data['data'];
        if (mounted) {
          setState(() {
            _guidePosition = LatLng(
              double.parse(locationData['latitude'].toString()),
              double.parse(locationData['longitude'].toString()),
            );
            _updateMarkers();
          });
        }
      }
    } catch (e) {
      print('Error fetching guide location: $e');
    }
  }

  void _updateMarkers() {
    _markers = {};

    // Add tourist marker
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('tourist'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'You'),
        ),
      );
    }

    // Add guide marker
    if (_guidePosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('guide'),
          position: _guidePosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Tour Guide'),
        ),
      );

      // Update navigation line
      _navigationLine = Polyline(
        polylineId: const PolylineId('nav'),
        points: [_currentPosition!, _guidePosition!],
        color: Colors.blue,
        width: 3,
      );
    }
  }

  Future<void> _updateServerLocation(LocationData locationData) async {
    try {
      print('Updating server with location: ${locationData.latitude}, ${locationData.longitude}');
      await _dio.post(
        '${globals.apiUrl}/api/update-location',
        data: {
          'userId': globals.userId,
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
          'tripId': widget.tripId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${globals.authToken}',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error updating server location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location'),
        backgroundColor: const Color(0xFFD28A22),
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(_status),
          ],
        ),
      )
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? const LatLng(30.0444, 31.2357),
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            polylines: _navigationLine != null ? {_navigationLine!} : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            compassEnabled: true,
          ),
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
                        Icon(Icons.location_on, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('You'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Tour Guide'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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
    );
  }
}