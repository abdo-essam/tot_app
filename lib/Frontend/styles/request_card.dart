import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/styles/app_colors.dart';

class RequestCard extends StatelessWidget {
  final String touristName;
  final String hotelName;
  final int daysLeft;
  final int numberOfTourists;
  final String tripStatus;
  final VoidCallback onDetailsPressed;

  const RequestCard({
    Key? key,
    required this.touristName,
    required this.hotelName,
    required this.daysLeft,
    required this.numberOfTourists,
    required this.tripStatus,
    required this.onDetailsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              touristName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.hotel, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Hotel: $hotelName'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Days Left: $daysLeft'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Number of Tourists: $numberOfTourists'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  tripStatus == 'Pending' ? Icons.hourglass_bottom : Icons.check_circle,
                  color: tripStatus == 'Pending' ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text('Status: $tripStatus'),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onDetailsPressed,
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
