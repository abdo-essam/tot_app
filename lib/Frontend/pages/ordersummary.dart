import 'package:flutter/material.dart';

class OrderSummary extends StatelessWidget {
  final List<String> selectedPlaces;
  final String tourGuide;
  final List<String> restaurants;
  final String paymentMethod;

  // Constructor to accept the selections
  OrderSummary({
    required this.selectedPlaces,
    required this.tourGuide,
    required this.restaurants,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Summary'),
        backgroundColor: Color(0xFFD28A22),
      ),
      backgroundColor: Color(0xFFD28A22), // Set the background color of the page
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Matches the background color
                ),
              ),
              SizedBox(height: 20),

              // Tour Guide Section
              _buildSectionTitle('Tour Guide:'),
              Text(
                tourGuide,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
              ),
              Divider(color: Colors.white70),
              SizedBox(height: 10),

              // Restaurants Section
              _buildSectionTitle('Restaurants:'),
              Text(
                restaurants.isNotEmpty ? restaurants.join(", ") : "None selected",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
              ),
              Divider(color: Colors.white70),
              SizedBox(height: 10),

              // Places Section
              _buildSectionTitle('Places:'),
              Text(
                selectedPlaces.join(", "),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
              ),
              Divider(color: Colors.white70),
              SizedBox(height: 10),

              // Payment Method Section
              _buildSectionTitle('Payment Method:'),
              Text(
                paymentMethod,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
              ),
              Divider(color: Colors.white70),
              SizedBox(height: 40),

              // Go Back Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFFD28A22),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to the previous page
                  },
                  child: Text('Go Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for consistent section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
