import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/styles/app_colors.dart';
import 'dart:convert'; // Import this for base64 decoding
import 'dart:typed_data'; // Import for Uint8List

class FeedbackCard extends StatelessWidget {
  final String userName;
  final String feedbackText;
  final String userProfilePic; // This will be the base64 string
  final String date;
  final int rating; // Assuming rating is between 1 and 5

  const FeedbackCard({
    Key? key,
    required this.userName,
    required this.feedbackText,
    required this.userProfilePic,
    required this.date,
    required this.rating,
  }) : super(key: key);

  // Function to generate stars based on the rating
  List<Widget> _buildRatingStars(int rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      stars.add(
        Icon(
          i <= rating ? Icons.star : Icons.star_border,
          color: AppColors.white,
          size: 16,
        ),
      );
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    // Check if the image string starts with 'data:image/png;base64,' and remove it
    String base64String = userProfilePic.startsWith('data:image/png;base64,')
        ? userProfilePic.replaceFirst('data:image/png;base64,', '')
        : userProfilePic;

    // Remove newline characters from the base64 string
    base64String = base64String.replaceAll('\n', '');

    // Decode the base64 image string
    Uint8List bytes = base64Decode(base64String);

    return Card(
      color: AppColors.primary,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // User Profile Picture
            CircleAvatar(
              backgroundImage: MemoryImage(bytes), // Use MemoryImage here
              radius: 30,
            ),
            const SizedBox(width: 12),
            // Feedback details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User name and date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Feedback text
                  Text(
                    feedbackText,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Rating stars
                  Row(
                    children: _buildRatingStars(rating),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
