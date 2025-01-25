import 'dart:convert'; // Import for base64
import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/styles/app_colors.dart';

class CustomDrawerHeader extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String userType;

  const CustomDrawerHeader({
    required this.name,
    required this.imageUrl,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: AppColors.primary, // Adjust this color to match your theme
      ),
      accountName: Text(
        name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(
        userType,
        style: TextStyle(color: Colors.white70),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundImage: imageUrl.startsWith('data:image/')
            ? MemoryImage(base64Decode(imageUrl.split(',')[1])) // Decode base64 to Uint8List
            : AssetImage(imageUrl), // Use AssetImage for local images
      ),
    );
  }
}
