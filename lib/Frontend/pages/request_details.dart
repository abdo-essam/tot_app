import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/styles/app_colors.dart';

class RequestDetailsPage extends StatelessWidget {
  final String touristName;
  final String hotelName;
  final String date;
  final int daysLeft;
  final int numberOfTourists;
  final String tripStatus;
  final List<String> locations; // Add locations list

  const RequestDetailsPage({
    Key? key,
    required this.touristName,
    required this.hotelName,
    required this.date,
    required this.daysLeft,
    required this.numberOfTourists,
    required this.tripStatus,
    required this.locations,  // Include locations in the constructor
  }) : super(key: key);

  // Method to handle the confirmation logic
  void _confirmRequest(BuildContext context) {
    // Add your logic here, like making an API call or showing a confirmation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request Confirmed!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Request Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // To make sure all content fits the screen
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tourist: $touristName',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.hotel, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Pickup Location: $hotelName'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Date: $date'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.timer, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Days Left: $daysLeft'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.people, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Number of Tourists: $numberOfTourists'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    tripStatus == 'Pending'
                        ? Icons.hourglass_bottom
                        : Icons.check_circle,
                    color: tripStatus == 'Pending'
                        ? Colors.orange
                        : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text('Status: $tripStatus'),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'Locations Included:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Display the list of locations
              ListView.builder(
                shrinkWrap: true, // Ensures the list fits within the column
                physics: const NeverScrollableScrollPhysics(),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading:
                        const Icon(Icons.location_on, color: AppColors.primary),
                    title: Text(locations[index]),
                  );
                },
              ),
              const SizedBox(height: 20), // Spacing before button
              
              // Show Confirm button only if status is 'Pending'
              if (tripStatus == 'Pending') 
                Center(
                  child: ElevatedButton(
                    
                    onPressed: () => _confirmRequest(context),
                    style: 
                    
                    ElevatedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      backgroundColor: AppColors.primary, // Button color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 12.0),
                    ),
                    child: const Text(
                      'Confirm Request',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
