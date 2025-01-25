import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Dio package for API requests
import 'package:tot_app/Frontend/styles/feedback_card.dart'; // Custom FeedbackCard
import 'package:tot_app/Frontend/styles/drawer.dart'; // Custom Drawer
import 'package:tot_app/Frontend/styles/app_colors.dart'; // App colors
import 'package:tot_app/Frontend/styles/globals.dart' as globals; // Globals for JWT token

const baseUrl = 'http://192.168.1.5:8080';

class FeedbackSection extends StatefulWidget {
  @override
  _FeedbackSectionState createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<FeedbackSection> {
  List<dynamic> feedbacks = []; // To store feedbacks from the API
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchFeedbacks(); // Fetch feedbacks when the page is initialized
  }

  // Method to fetch feedbacks from the API
  Future<void> fetchFeedbacks() async {
    try {
      Dio dio = Dio();
      String token = globals.authToken; // Get the JWT token from globals

      // Make the GET request to fetch feedbacks
      Response response = await dio.get(
        '$baseUrl/api/feedback',  // Your API endpoint
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Pass the JWT token
          },
        ),
      );

      // Print the response to debug
      print('API Response: ${response.data}');

      // Update the state with the fetched feedbacks
      setState(() {
        feedbacks = response.data; // Assign fetched data to feedbacks
        isLoading = false; // Stop loading
      });
    } catch (e) {
      print('Error fetching feedbacks: $e');
      setState(() {
        isLoading = false; // Stop loading in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Feedbacks'),
      ),
      drawer: CustomDrawer(),
      // Display a loading spinner while data is being fetched
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                final feedback = feedbacks[index];

                // Debugging prints to see each feedback item
                print('Feedback Item $index: $feedback');

                return FeedbackCard(
                  userName: feedback['name'], // Use 'name' from API response
                  feedbackText: feedback['Feedback'], // Feedback text
                  // Use Base64 image string; add the prefix for image display
                  userProfilePic: feedback['user_profile_pic'] != null
                      ? 'data:image/png;base64,${feedback['user_profile_pic']}'
                      : 'assets/images/avatar.png', // Default if no image
                  date: feedback['date'], // Date from the response
                  rating: feedback['Rate'], // Rating from the response
                );
              },
            ),
    );
  }
}
