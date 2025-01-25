import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tot_app/Frontend/styles/app_colors.dart';
import 'package:tot_app/Frontend/styles/drawer.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals; // For the token and guide ID
import 'package:dio/dio.dart'; // Import Dio for HTTP requests

const baseUrl = 'http://192.168.1.5:8080';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  Map<DateTime, List> selectedDays = {};
  DateTime selectedDate = DateTime.now();
  bool isAvailable = true; // Track availability status
  final Dio dio = Dio(); // Initialize Dio

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Set Schedule'),
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary, // Color for selected day
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blueGrey, // Color for today's date
                  shape: BoxShape.circle,
                ),
              ),
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: selectedDate,
              selectedDayPredicate: (day) {
                return selectedDays.containsKey(day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = focusedDay;
                  if (selectedDays.containsKey(selectedDay)) {
                    selectedDays.remove(selectedDay);
                  } else {
                    selectedDays[selectedDay] = [];
                  }
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronVisible: true,
                rightChevronVisible: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (selectedDays.isNotEmpty) {
                  // Convert selectedDays to an array of unavailability dates
                  List<String> unavailabilityDates = selectedDays.keys
                      .map((date) => date.toIso8601String().split('T')[0]) // Format to YYYY-MM-DD
                      .toList();

                  try {
                    // Print debug logs
                    print('Unavailability Dates: $unavailabilityDates');
                    print('Guide ID: ${globals.guideId}');
                    print('Token: ${globals.authToken}');

                    // Call the API to save unavailable days
                    final response = await dio.post(
                      '$baseUrl/api/guideAvailability',
                      data: {
                        'guide_id': globals.guideId, // Pass the guide ID here
                        'unavailability_date': unavailabilityDates,
                      },
                      options: Options(
                        headers: {
                          'Authorization': 'Bearer ${globals.authToken}', // Pass JWT token from globals
                        },
                      ),
                    );

                    if (response.statusCode == 201) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Unavailable days saved!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      throw Exception('Failed with status code ${response.statusCode}');
                    }
                  } catch (error) {
                    print('Error saving unavailable days: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save unavailable days.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save Unavailable Days'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                foregroundColor: AppColors.white,
                backgroundColor: AppColors.primary,
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isAvailable = !isAvailable; // Toggle availability
                });

                String message = isAvailable
                    ? 'You are now available to receive requests.'
                    : 'You are now unavailable to receive requests.';

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: isAvailable ? Colors.green : Colors.red,
                  ),
                );
              },
              child: Text(isAvailable ? 'Stop Receiving Requests' : 'Start Receiving Requests'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                foregroundColor: AppColors.white,
                backgroundColor: isAvailable ? Colors.red : Colors.green, // Color based on availability
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
