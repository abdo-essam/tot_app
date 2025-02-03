import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/styles/app_colors.dart';
import 'package:tot_app/Frontend/styles/custom_card.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;
import 'package:tot_app/Frontend/styles/drawer.dart';
import 'package:dio/dio.dart';
import 'activeTripsPage.dart';

/// Dashboard widget to display tour guide statistics and active trips
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Statistics variables
  int completedTrips = 0;      // Number of completed trips
  double totalRating = 0.0;    // Average rating
  double totalIncome = 0.0;    // Total earnings
  List<Map<String, dynamic>> activeTrips = []; // List of current active trips

  // State management variables
  bool isLoading = true;  // Loading state indicator
  bool hasError = false;  // Error state indicator

  @override
  void initState() {
    super.initState();
    print('Dashboard: initState called');
    // Fetch initial data
    fetchDashboardData();
    fetchActiveTrips();
  }

  /// Fetches dashboard statistics from the server
  Future<void> fetchDashboardData() async {
    print('Dashboard: fetchDashboardData called');
    try {
      Dio dio = Dio();
      String token = globals.authToken;

      // Debug logging
      print('Dashboard: Auth Token = $token');
      print('Dashboard: Making GET request to $baseUrl/api/dashboard');

      // Make API request
      Response response = await dio.get(
        '$baseUrl/api/dashboard',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Debug logging
      print('Dashboard: API Response Status Code = ${response.statusCode}');
      print('Dashboard: API Response Data = ${response.data}');

      // Process response data
      if (response.data != null) {
        print('Dashboard: Data received successfully');
        setState(() {
          // Update statistics
          completedTrips = response.data['total_orders'] ?? 0;
          totalRating = double.tryParse(response.data['average_rating'].toString()) ?? 0.0;
          totalIncome = double.tryParse(response.data['total_payments'].toString()) ?? 0.0;
        });
        print('Dashboard: Updated state with data');
      } else {
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

  /// Fetches active trips from the server
  Future<void> fetchActiveTrips() async {
    print('Dashboard: fetchActiveTrips called');
    try {
      Dio dio = Dio();
      String token = globals.authToken;

      // Debug logging
      print('Dashboard: Auth Token = $token');
      print('Dashboard: Making GET request to $baseUrl/api/active-trips/${globals.userId}');

      // Make API request
      Response response = await dio.get(
        '$baseUrl/api/active-trips/${globals.userId}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Debug logging
      print('Dashboard: Active Trips API Response Status Code = ${response.statusCode}');
      print('Dashboard: Active Trips API Response Data = ${response.data}');

      // Process response data
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

  /// Builds the active trips card widget
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

  /// Builds the statistics cards
  List<Widget> _buildStatisticsCards() {
    return [
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
    ];
  }

  /// Builds the error widget
  Widget _buildErrorWidget() {
    return Center(
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
          ? _buildErrorWidget()
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
              children: _buildStatisticsCards(),
            ),
          ),
          _buildActiveTripsCard(),
        ],
      ),
    );
  }
}