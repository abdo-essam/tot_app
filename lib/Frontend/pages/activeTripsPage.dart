import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;
import 'liveTrackingScreen.dart';

/// Widget to display and manage active trips for tourists or tour guides
class ActiveTripsPage extends StatefulWidget {
  // List of active trips passed from the dashboard
  final List<Map<String, dynamic>> activeTrips;

  const ActiveTripsPage({super.key, required this.activeTrips});

  @override
  _ActiveTripsPageState createState() => _ActiveTripsPageState();
}

class _ActiveTripsPageState extends State<ActiveTripsPage> {
  // State variables
  List<Map<String, dynamic>> activeTrips = []; // List to store active trips
  bool isLoading = true;  // Loading state indicator
  bool hasError = false;  // Error state indicator

  @override
  void initState() {
    super.initState();
    // Initialize with trips passed from dashboard
    activeTrips = widget.activeTrips;
    isLoading = false; // Data is already fetched in the Dashboard
  }

  /// Fetches updated active trips from the server
  Future<void> _fetchActiveTrips() async {
    try {
      // Make API call to get active trips
      final response = await Dio().get(
        '${globals.apiUrl}/api/active-trips/${globals.userId}',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${globals.authToken}',
          },
        ),
      );

      // Update state based on response
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          // Convert response data to List<Map<String, dynamic>>
          activeTrips = List<Map<String, dynamic>>.from(response.data);
          hasError = false;
        });
      } else {
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      print('Error fetching active trips: $e');
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Builds a trip card for each active trip
  Widget _buildTripCard(Map<String, dynamic> trip) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        // User avatar
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFD28A22),
          child: Icon(Icons.person, color: Colors.white),
        ),
        // Tourist name
        title: Text('Tourist: ${trip['tourist_name']}'),
        // Trip details
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${trip['date']}'),
            // Show last seen time if available
            if (trip['location_updated_at'] != null)
              Text(
                'Last seen: ${DateTime.parse(trip['location_updated_at']).toLocal()}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        // Location tracking button
        trailing: IconButton(
          icon: const Icon(Icons.location_on),
          color: const Color(0xFFD28A22),
          onPressed: () {
            // Navigate to live tracking screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LiveTrackingScreen(
                  touristId: trip['Tourist_id'].toString(),
                  tourGuideId: trip['Admin_id'].toString(),
                  tripId: trip['trip_id'].toString(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the main content based on state
  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Failed to load active trips.'),
            TextButton(
              onPressed: _fetchActiveTrips,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (activeTrips.isEmpty) {
      return const Center(child: Text('No active trips'));
    }

    return ListView.builder(
      itemCount: activeTrips.length,
      itemBuilder: (context, index) => _buildTripCard(activeTrips[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar
      appBar: AppBar(
        title: const Text('Active Trips'),
        backgroundColor: const Color(0xFFD28A22),
      ),
      // Main body with refresh capability
      body: RefreshIndicator(
        onRefresh: _fetchActiveTrips,
        child: _buildContent(),
      ),
    );
  }
}