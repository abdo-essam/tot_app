import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/pages/Login.dart';
import 'package:tot_app/Frontend/pages/Admin.dart';
import 'package:tot_app/Frontend/pages/tripsHistory.dart';  
import 'package:tot_app/Frontend/styles/app_colors.dart';
import 'package:tot_app/Frontend/pages/dashboard.dart';
import 'package:tot_app/Frontend/pages/register.dart';
import 'package:tot_app/Frontend/pages/feedbacks.dart';
import 'package:tot_app/Frontend/pages/requests.dart';
import 'package:tot_app/Frontend/pages/setschedule.dart';
import 'package:tot_app/Frontend/pages/AddTrip.dart';
import 'package:tot_app/Frontend/pages/AllowTrack.dart';
import 'package:tot_app/Frontend/pages/summary.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Oswald',
        scaffoldBackgroundColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Handle dynamic route arguments
        if (settings.name == '/summary') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (context) => SummaryPage(
              selectedPlace: args['selectedPlace'],
              selectedRestaurant: args['selectedRestaurant'],
              selectedTourGuide: args['selectedTourGuide'],
              selectedDay: args['selectedDay'],
              numberOfTourists: args['numberOfTourists'],
            ),
          );
        }

        // Define other static routes
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => LoginPage());
          case '/admin':
            return MaterialPageRoute(builder: (context) => Admin());
          case '/dashboard':
            return MaterialPageRoute(builder: (context) => Dashboard());
          case '/register':
            return MaterialPageRoute(builder: (context) => SignUpPage());
          case '/guideFeedback':
            return MaterialPageRoute(builder: (context) => FeedbackSection());
          case '/history':
            return MaterialPageRoute(builder: (context) => TripsHistory());
          case '/requests':
            return MaterialPageRoute(builder: (context) => RequestsPage());
          case '/schedule':
            return MaterialPageRoute(builder: (context) => SchedulePage());
          case '/addtrip':
            return MaterialPageRoute(builder: (context) => AddTrip());
          case '/trackallow':
            return MaterialPageRoute(builder: (context) => Allowtracking());
          default:
            return null;
        }
      },
    );
  }
}
