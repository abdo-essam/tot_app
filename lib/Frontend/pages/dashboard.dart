import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/styles/app_colors.dart';
import 'package:tot_app/Frontend/styles/custom_card.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;
import 'package:tot_app/Frontend/styles/drawer.dart';
import 'package:dio/dio.dart';
import 'activeTripsPage.dart';

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
  List<Map<String, dynamic>> activeTrips = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    print('Dashboard: initState called');
    fetchDashboardData();
    fetchActiveTrips();
  }

  Future<void> fetchDashboardData() async {
    print('Dashboard: fetchDashboardData called');
    try {
      Dio dio = Dio();
      String token = globals.authToken;

      // Log the token for debugging
      print('Dashboard: Auth Token = $token');

      // Make a GET request to your dashboard API
      print('Dashboard: Making GET request to $baseUrl/api/dashboard');
      Response response = await dio.get(
        '$baseUrl/api/dashboard',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Log the response for debugging
      print('Dashboard: API Response Status Code = ${response.statusCode}');
      print('Dashboard: API Response Data = ${response.data}');

      // Ensure the response has data and the expected fields
      if (response.data != null) {
        print('Dashboard: Data received successfully');
        setState(() {
          completedTrips = response.data['total_orders'] ?? 0;
          totalRating = double.tryParse(response.data['average_rating'].toString()) ?? 0.0;
          totalIncome = double.tryParse(response.data['total_payments'].toString()) ?? 0.0;
        });
        print('Dashboard: Updated state with data');
      } else {
        // Handle case where no data is returned
        print('Dashboard: No data returned from API');
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      print('Dashboard: Error fetching dashboard data: $e');
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      print('Dashboard: fetchDashboardData completed');
    }
  }

  Future<void> fetchActiveTrips() async {
    print('Dashboard: fetchActiveTrips called');
    try {
      Dio dio = Dio();
      String token = globals.authToken;

      // Log the token for debugging
      print('Dashboard: Auth Token = $token');

      // Make a GET request to fetch active trips
      print('Dashboard: Making GET request to $baseUrl/api/active-trips/${globals.guideId}');
      Response response = await dio.get(
        '$baseUrl/api/active-trips/${globals.userId}', // Assuming you have a global userId
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Log the response for debugging
      print('Dashboard: Active Trips API Response Status Code = ${response.statusCode}');
      print('Dashboard: Active Trips API Response Data = ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        print('Dashboard: Active trips data received successfully');
        setState(() {
          activeTrips = List<Map<String, dynamic>>.from(response.data);
        });
        print('Dashboard: Updated state with active trips');
      } else {
        print('Dashboard: No active trips data returned from API');
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      print('Dashboard: Error fetching active trips: $e');
      setState(() {
        hasError = true;
      });
    } finally {
      print('Dashboard: fetchActiveTrips completed');
    }
  }

  Widget _buildActiveTripsCard() {
    print('Dashboard: Building Active Trips Card');
    return CustomCard(
      icon: Icons.location_on,
      title: 'Active Trips',
      number: activeTrips.length.toString(),
      description: 'Track tourist location',
      onTap: () {
        print('Dashboard: Active Trips Card tapped');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActiveTripsPage(activeTrips: activeTrips),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Dashboard: Building UI');
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Dashboard"),
        actions: const [
          Icon(Icons.notifications),
        ],
      ),
      drawer: CustomDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Failed to load data. Please try again later.'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                print('Dashboard: Retry button pressed');
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
                fetchDashboardData();
                fetchActiveTrips();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Your Trip Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                CustomCard(
                  icon: Icons.check,
                  title: 'Completed Trips',
                  number: completedTrips.toString(),
                  description: 'Last 90 days',
                ),
                CustomCard(
                  icon: Icons.star,
                  title: 'Rating',
                  number: totalRating.toStringAsFixed(1),
                  description: 'Last 90 days',
                ),
                CustomCard(
                  icon: Icons.monetization_on,
                  title: 'Total Income',
                  number: r'$' + totalIncome.toStringAsFixed(2),
                  description: 'Last 90 days',
                ),
              ],
            ),
          ),
          _buildActiveTripsCard(),
        ],
      ),
    );
  }
}