import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;
import 'liveTrackingScreen.dart';

class SummaryPage extends StatefulWidget {
  final Map<String, dynamic> selectedPlace;
  final Map<String, dynamic> selectedRestaurant;
  final Map<String, dynamic> selectedTourGuide;
  final DateTime selectedDay;
  final int numberOfTourists;

  const SummaryPage({
    super.key,
    required this.selectedPlace,
    required this.selectedRestaurant,
    required this.selectedTourGuide,
    required this.selectedDay,
    required this.numberOfTourists,
  });

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  bool _tripPaid = false;
  String? _tripId;
  String? _tourGuideId;
  final Dio _dio = Dio();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeTourGuideId();
  }

  void _initializeTourGuideId() {
    _tourGuideId = widget.selectedTourGuide['id']?.toString();
    if (kDebugMode) {
      print('Tour Guide Data: ${widget.selectedTourGuide}');
      print('Tour Guide ID: $_tourGuideId');
    }
  }

  Future<bool> _createTrip() async {
    if (_tourGuideId == null) {
      _showErrorSnackBar('Tour guide ID is missing');
      return false;
    }

    try {
      setState(() => _isLoading = true);

      final response = await _dio.post(
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

      if (response.statusCode == 201) {
        setState(() => _tripId = response.data['data']['trip_id'].toString());
        return true;
      }

      _showErrorSnackBar('Failed to create trip');
      return false;

    } catch (e) {
      _handleError('Error creating trip', e);
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePayment() async {
    if (_isLoading) return;

    try {
      bool tripCreated = await _createTrip();
      if (!tripCreated) return;

      // Simulate payment process here
      setState(() => _tripPaid = true);
      _showSuccessSnackBar('Payment successful');

    } catch (e) {
      _handleError('Payment failed', e);
    }
  }

  void _enableLocationTracking() {
    if (_tripId == null) {
      _showErrorSnackBar('Trip ID not found');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveTrackingScreen(
          touristId: globals.userId.toString(), // Current user's ID
          tourGuideId: _tourGuideId ?? '', // Tour guide's ID
          tripId: _tripId!, // Trip ID
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleError(String message, dynamic error) {
    if (kDebugMode) {
      print('$message: $error');
      if (error is DioException) {
        print('DioError details: ${error.response?.data}');
      }
    }
    _showErrorSnackBar('$message. Please try again.');
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16.0),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5.0),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_isLoading)
          const CircularProgressIndicator()
        else ...[
          ElevatedButton(
            onPressed: _tripPaid ? null : _handlePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD28A22),
              foregroundColor: Colors.white,
            ),
            child: Text(_tripPaid ? 'Payment Complete' : 'Proceed to Payment'),
          ),
          if (_tripPaid)
            ElevatedButton(
              onPressed: _enableLocationTracking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD28A22),
                foregroundColor: Colors.white,
              ),
              child: const Text('Enable Location Tracking'),
            ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Trip Summary'),
        backgroundColor: const Color(0xFFD28A22),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Selected Place:'),
            Text('${widget.selectedPlace['text']}'),
            const SizedBox(height: 15.0),

            _buildSectionTitle('Selected Restaurant:'),
            Text('${widget.selectedRestaurant['text']}'),
            const SizedBox(height: 15.0),

            _buildSectionTitle('Selected Tour Guide:'),
            Text('${widget.selectedTourGuide['name']}'),
            const SizedBox(height: 15.0),

            _buildSectionTitle('Trip Details:'),
            _buildDetailRow(
              'Date:',
              DateFormat('yyyy-MM-dd').format(widget.selectedDay),
            ),
            const SizedBox(height: 10.0),
            _buildDetailRow(
              'Number of Tourists:',
              widget.numberOfTourists.toString(),
            ),
            const SizedBox(height: 20.0),

            Center(child: _buildActionButtons()),
          ],
        ),
      ),
    );
  }
}