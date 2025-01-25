import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/styles/app_colors.dart';
import 'package:tot_app/Frontend/styles/custom_card.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;
import 'package:tot_app/Frontend/styles/drawer.dart'; // Import your custom drawer header
import 'package:dio/dio.dart'; // Import Dio package

const baseUrl = 'http://192.168.1.5:8080';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int completedTrips = 0;
  double totalRating = 0.0;
  double totalIncome = 0.0;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
  try {
    Dio dio = Dio();
    String token = globals.authToken;

    // Make a GET request to your dashboard API
    Response response = await dio.get(
      '$baseUrl/api/dashboard',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    // Ensure the response has data and the expected fields
    if (response.data != null) {
      setState(() {
        // Update state with null safety and correct data types
        completedTrips = response.data['total_orders'] ?? 0;
        totalRating = double.tryParse(response.data['average_rating'].toString()) ?? 0.0;
        totalIncome = double.tryParse(response.data['total_payments'].toString()) ?? 0.0;
      });
    } else {
      // Handle case where no data is returned
      print('No data returned from API');
    }
  } catch (e) {
    print('Error fetching dashboard data: $e');
  }
}

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Dashboard"),
        actions: [
          Icon(Icons.notifications),
        ],
      ),
      
      // Drawer with custom header
      drawer: CustomDrawer(),
      
      body: Column(
        children: [
          // Adding padding for some space around the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Your Trip Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          
          // Wrap ListView with Expanded to give it constraints
          Expanded(
            child: ListView(
              children: [
                // First card with dynamic data
                CustomCard(
                  icon: Icons.check,
                  title: 'Completed Trips',
                  number: completedTrips.toString(),
                  description: 'Last 90 days',
                ),
                
                // Second card with dynamic data
                CustomCard(
                  icon: Icons.star,
                  title: 'Rating',
                  number: totalRating.toStringAsFixed(1), // Show rating as one decimal
                  description: 'Last 90 days',
                ),
                
                // Another card with dynamic data
                CustomCard(
                  icon: Icons.monetization_on,
                  title: 'Total Income',
                  number: r'$' + totalIncome.toStringAsFixed(2), // Show income with two decimals
                  description: 'Last 90 days',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
