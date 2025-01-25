import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class SummaryPage extends StatelessWidget {
  final Map<String, dynamic> selectedPlace;
  final Map<String, dynamic> selectedRestaurant;
  final Map<String, dynamic> selectedTourGuide;
  final DateTime selectedDay;
  final int numberOfTourists;

  const SummaryPage({
    Key? key,
    required this.selectedPlace,
    required this.selectedRestaurant,
    required this.selectedTourGuide,
    required this.selectedDay,
    required this.numberOfTourists,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Trip Summary'),
        backgroundColor: Color(0xFFD28A22),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Place
            const Text(
              'Selected Place:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5.0),
            Text('${selectedPlace['text']}'),

            const SizedBox(height: 15.0),

            // Restaurant
            const Text(
              'Selected Restaurant:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5.0),
            Text('${selectedRestaurant['text']}'),

            const SizedBox(height: 15.0),

            // Tour Guide
            const Text(
              'Selected Tour Guide:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5.0),
            Text('${selectedTourGuide['text']}'),

            const SizedBox(height: 15.0),

            // Details section
            const Text(
              'Trip Details:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Date:',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  DateFormat('yyyy-MM-dd').format(selectedDay),
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Number of Tourists:',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  '$numberOfTourists',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the Payment page
                  Navigator.of(context).pushReplacementNamed('/payment');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD28A22),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}