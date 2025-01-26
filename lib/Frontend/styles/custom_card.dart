// lib/custom_card.dart

import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/styles/app_colors.dart';

class CustomCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String number;
  final String description;
  final VoidCallback? onTap;

  // Constructor to accept values for the card
  CustomCard({
    required this.icon,
    required this.title,
    required this.number,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: AppColors.white,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.all(16.0),
        shadowColor: AppColors.black,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: AppColors.secondary),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                number,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
