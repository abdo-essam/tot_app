import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/styles/app_colors.dart';

class TripCard extends StatefulWidget {
  final String touristName;
  final String tripDate;
  final int tripId;
  final int numberOfTourists;
  final List<String> places;

  const TripCard({
    Key? key,
    required this.touristName,
    required this.tripDate,
    required this.tripId,
    required this.numberOfTourists,
    required this.places,
  }) : super(key: key);

  @override
  _TripCardState createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 12,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.touristName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${widget.tripDate}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (_isExpanded)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text('Trip ID: ${widget.tripId}'),
                  const SizedBox(height: 4),
                  Text('Number of Tourists: ${widget.numberOfTourists}'),
                  const SizedBox(height: 4),
                  Text('Places: ${widget.places.join(', ')}'),
                ],
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(_isExpanded ? 'Show Less' : 'Show More'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
