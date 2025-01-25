import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/styles/app_colors.dart';
import 'package:tot_app/Frontend/styles/request_card.dart';
import 'package:tot_app/Frontend/styles/drawer.dart';
import 'package:tot_app/Frontend/pages/request_details.dart';
import 'package:dio/dio.dart'; // Import Dio package
import 'package:tot_app/Frontend/styles/globals.dart' as globals;

const baseUrl = 'http://192.168.1.5:8080';

class RequestsPage extends StatefulWidget {
  const RequestsPage({Key? key}) : super(key: key);

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  List<dynamic> requests = []; // Store the requests data
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchRequests(); // Fetch requests on initialization
  }

  Future<void> fetchRequests() async {
  try {
    // Create a Dio instance
    Dio dio = Dio();
    String token = globals.authToken; // Get the JWT token from globals

    // Make a GET request to your requests API
    Response response = await dio.get(
      '$baseUrl/api/requests',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token', // Include the JWT token in the header
        },
      ),
    );

    setState(() {
      requests = response.data.map((request) {
        // Map the status to a readable string
        request['status'] = request['status'] == 1 ? 'Confirmed' : 'Pending';
        return request;
      }).toList(); // Update requests with the response data
      isLoading = false; // Set loading to false
    });
  } catch (e) {
    print('Error fetching requests: $e');
    // Handle error (you can show a Snackbar, alert, etc.)
    setState(() {
      isLoading = false; // Stop loading on error
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Requests'),
      ),
      drawer: CustomDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return RequestCard(
                    touristName: request['tourist_name'], // Adjust according to your response
                    hotelName: request['Hotel'],
                    daysLeft: request['days_until_trip'],
                    numberOfTourists: request['tourists_num'],
                    tripStatus: request['status'],
                    onDetailsPressed: () {
                      // Navigate to RequestDetailsPage with dynamic data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestDetailsPage(
                            touristName: request['tourist_name'],
                            hotelName: request['Hotel'],
                            date: request['date'],
                            daysLeft: request['days_until_trip'],
                            numberOfTourists: request['tourists_num'],
                            tripStatus: request['status'],
                            locations: ["Pyramids of Giza", "Egyptian Museum", "Nile River Cruise"], // Replace with actual locations if available
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
