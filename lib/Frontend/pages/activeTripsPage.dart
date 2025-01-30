// lib/Frontend/pages/activeTripsPage.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;
import 'liveTrackingScreen.dart';

class ActiveTripsPage extends StatefulWidget {
  final List<Map<String, dynamic>> activeTrips;

  const ActiveTripsPage({super.key, required this.activeTrips});

  @override
  _ActiveTripsPageState createState() => _ActiveTripsPageState();
}

class _ActiveTripsPageState extends State<ActiveTripsPage> {
  List<Map<String, dynamic>> activeTrips = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    activeTrips = widget.activeTrips;
    isLoading = false; // Data is already fetched in the Dashboard
  }

  Future<void> _fetchActiveTrips() async {
    try {
      final response = await Dio().get(
        '${globals.apiUrl}/api/active-trips/${globals.userId}',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${globals.authToken}',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Trips'),
        backgroundColor: const Color(0xFFD28A22),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchActiveTrips,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
            ? Center(
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
        )
            : activeTrips.isEmpty
            ? const Center(child: Text('No active trips'))
            : ListView.builder(
          itemCount: activeTrips.length,
          itemBuilder: (context, index) {
            final trip = activeTrips[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFD28A22),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text('Tourist: ${trip['tourist_name']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${trip['date']}'),
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
                trailing: IconButton(
                  icon: const Icon(Icons.location_on),
                  color: const Color(0xFFD28A22),
                  onPressed: () {
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
          },
        ),
      ),
    );
  }
}