import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Dio package for API requests
import 'package:tot_app/Frontend/styles/app_colors.dart';
import 'package:tot_app/Frontend/styles/drawer_header.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;

const baseUrl = 'http://192.168.1.5:8080';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String name = 'Loading...'; // Default loading text
  String imageUrl = 'assets/images/avatar.png'; // Default avatar
  String userType = 'Loading...'; // Default loading text

  @override
  void initState() {
    super.initState();
    fetchGuideData(); // Fetch the guide data when the widget is initialized
  }

  Future<void> fetchGuideData() async {
    try {
      Dio dio = Dio();
      String token = globals.authToken; // Get the JWT token from globals

      // Make the GET request to fetch guide data
      Response response = await dio.get(
        '$baseUrl/api/tourGuide',  // Ensure this matches the API endpoint
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Pass the JWT token
          },
        ),
      );

      // Update the state with the fetched guide data
      setState(() {
        name = response.data['name']; // Set the guide's name
        imageUrl = 'data:image/png;base64,' + response.data['img'].replaceAll('\n', ''); // Decode the base64 image
        userType = response.data['user_type']; // Set the user type
      });
    } catch (e) {
      print('Error fetching guide data: $e');
      // Handle error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Custom Drawer Header
          CustomDrawerHeader(
            name: name,
            imageUrl: imageUrl,
            userType: userType,
          ),
          // Drawer items
          ListTile(
            textColor: AppColors.white,
            iconColor: AppColors.white,
            title: const Text('Overview'),
            leading: Icon(Icons.border_all_rounded),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/dashboard');
              // Navigate to Overview page
            },
          ),
          ListTile(
            textColor: AppColors.white,
            iconColor: AppColors.white,
            title: const Text('Requests'),
            leading: Icon(Icons.hail_outlined),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/requests');
              // Navigate to Requests page
            },
          ),
          ListTile(
            textColor: AppColors.white,
            iconColor: AppColors.white,
            title: const Text('Trips History'),
            leading: Icon(Icons.history_rounded),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/history');
              // Navigate to Trips History page
            },
          ),
          ListTile(
            textColor: AppColors.white,
            iconColor: AppColors.white,
            title: const Text('Feedbacks'),
            leading: Icon(Icons.feedback),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/guideFeedback');
            },
          ),
          ListTile(
            textColor: AppColors.white,
            iconColor: AppColors.white,
            title: const Text('Reports'),
            leading: Icon(Icons.report),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Reports page
            },
          ),
          ListTile(
            textColor: AppColors.white,
            iconColor: AppColors.white,
            title: const Text('Set Schedule'),
            leading: Icon(Icons.calendar_month),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/schedule');
              // Navigate to Set Schedule page
            },
          ),
          ListTile(
            textColor: AppColors.white,
            iconColor: AppColors.white,
            title: const Text('Logout'),
            leading: Icon(Icons.logout),
            onTap: () {
              Navigator.pop(context);
              // Handle logout logic here
            },
          ),
        ],
      ),
    );
  }
}
