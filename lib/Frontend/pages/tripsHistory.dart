import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/styles/app_colors.dart';
import 'package:tot_app/Frontend/styles/trip_card.dart';
import 'package:tot_app/Frontend/styles/drawer.dart';
import 'package:dio/dio.dart'; // Import Dio package
import 'package:tot_app/Frontend/styles/globals.dart' as globals;

const baseUrl = 'http://192.168.1.5:8080';

class TripsHistory extends StatefulWidget {
  const TripsHistory({super.key});

  @override
  _TripsHistoryState createState() => _TripsHistoryState();
}

class _TripsHistoryState extends State<TripsHistory> {
  List<dynamic> trips = []; // Store the trips data
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchTrips(); // Fetch trips on initialization
  }

  Future<void> fetchTrips() async {
    try {
      // Create a Dio instance
      Dio dio = Dio();
      String token = globals.authToken; // Get the JWT token from globals

      // Make a GET request to your trips history API
      Response response = await dio.get(
        '$baseUrl/api/trips-history', // Adjust endpoint as needed
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Include the JWT token in the header
          },
        ),
      );

      setState(() {
        trips = response.data; // Update trips with the response data
        isLoading = false; // Set loading to false
      });
    } catch (e) {
      print('Error fetching trips: $e');
      // Handle error (you can show a Snackbar, alert, etc.)
      setState(() {
        isLoading = false; // Stop loading on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Trips History'),
        backgroundColor: AppColors.primary,
      ),
      drawer: CustomDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return TripCard(
                  touristName: trip['tourist_name'], // Update according to your response structure
                  tripDate: trip['date'], // Ensure format is suitable for display
                  tripId: trip['trip_id'],
                  numberOfTourists: trip['tourists_num'],
                  places: [], // Adjust if you have places data
                );
              },
            ),
    );
  }
}
