import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  Dio _dio = Dio();
  List<Map<String, dynamic>> _locations = [];
  bool _isLoading = true;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  // Fetch user locations from the API
  Future<void> _fetchLocations() async {
    try {
      final response = await _dio.get('http://192.168.1.5:8080/api/get-locations');
      setState(() {
        _locations = List<Map<String, dynamic>>.from(response.data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching locations: $e");
    }
  }

  // Set initial position dynamically
  LatLng _getInitialPosition() {
    if (_locations.isNotEmpty) {
      double avgLat = _locations.map((loc) => loc['latitude']).reduce((a, b) => a + b) / _locations.length;
      double avgLng = _locations.map((loc) => loc['longitude']).reduce((a, b) => a + b) / _locations.length;
      return LatLng(avgLat, avgLng);
    }
    return LatLng(30.0444, 31.2357); // Default to Cairo
  }

  // Set markers on the map
  Set<Marker> _createMarkers() {
    return _locations.map((location) {
      return Marker(
        markerId: MarkerId(location['user_id'].toString()),
        position: LatLng(location['latitude'], location['longitude']),
        infoWindow: InfoWindow(
          title: location['user_name'],
          snippet: 'Updated at: ${location['updated_at']}',
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin - User Locations Map"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _getInitialPosition(),
                zoom: 10.0,
              ),
              markers: _createMarkers(),
            ),
    );
  }
}
