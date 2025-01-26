import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tot_app/Frontend/pages/activeTripsPage.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;

import 'AllowTrack.dart';
import 'liveTrackingScreen.dart';


class SummaryPage extends StatefulWidget {
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
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  bool _tripPaid = false;
  String? _tripId;
  String? _tourGuideId;
  @override
  void initState() {
    super.initState();
    _tourGuideId = widget.selectedTourGuide['id']?.toString();
    if (kDebugMode) {
      print('Received Tour Guide Data: ${widget.selectedTourGuide}');
      print('Tour Guide ID: $_tourGuideId');
    }
  }



  Future<bool> _createTrip() async {
    try {
      if (_tourGuideId == null) {
        print('Error: Tour guide ID is null');
        return false;
      }

      final response = await Dio().post(
        '${globals.apiUrl}/api/create-trip',
        data: {
          'tourist_id': globals.userId,
          'guide_id': _tourGuideId,
          'tourists_num': widget.numberOfTourists,
          'date': DateFormat('yyyy-MM-dd').format(widget.selectedDay),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${globals.authToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (kDebugMode) {
        print('Create trip response: ${response.data}');
      }

      if (response.statusCode == 201) {
        setState(() {
          _tripId = response.data['data']['trip_id'].toString();
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating trip: $e');
      if (e is DioException) {
        print('DioError details: ${e.response?.data}');
      }
      return false;
    }
  }


  void _handlePayment() async {
    try {
      // First create the trip
      bool tripCreated = await _createTrip();

      if (!tripCreated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create trip'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Simulate payment success
      setState(() {
        _tripPaid = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Payment error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  void _enableLocationTracking() {
    if (_tripId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip ID not found')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Allowtracking(tourGuideId:globals.guideId.toString() ,
          tripId: _tripId!,
        ),
      ),
    );
  }

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
            Text('${widget.selectedPlace['text']}'),

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
            Text('${widget.selectedRestaurant['text']}'),

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
            Text('${widget.selectedTourGuide['name']}'),

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
                  DateFormat('yyyy-MM-dd').format(widget.selectedDay),
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
                  '${widget.numberOfTourists}',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            Column(
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: _tripPaid ? null : _handlePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD28A22),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_tripPaid ? 'Payment Complete' : 'Proceed to Payment'),
                  ),
                ),
                if (_tripPaid) // Add a variable to check if trip is paid
                  ElevatedButton(
                    onPressed: _enableLocationTracking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD28A22),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Enable Location Tracking'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}