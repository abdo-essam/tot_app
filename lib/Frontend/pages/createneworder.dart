import 'package:flutter/material.dart';
import 'ordersummary.dart'; // Import the Order Summary page

class CreateNewOrderPage extends StatefulWidget {
  @override
  _CreateNewOrderPageState createState() => _CreateNewOrderPageState();
}

class _CreateNewOrderPageState extends State<CreateNewOrderPage> {
  List<String> selectedPlaces = [];
  List<String> selectedRestaurants = [];
  String selectedTourGuide = '';
  String selectedPaymentMethod = '';

  final List<String> places = ['Beach', 'Park', 'Museum', 'City Tour'];
  final List<String> restaurants = ['Restaurant 1', 'Restaurant 2', 'Restaurant 3'];
  final List<String> tourGuides = ['Guide 1', 'Guide 2', 'Guide 3'];
  final List<String> paymentMethods = ['Credit Card', 'PayPal', 'Cash'];

  // Handle form submission
  void _submitOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSummary(
          selectedPlaces: selectedPlaces,
          tourGuide: selectedTourGuide,
          restaurants: selectedRestaurants,
          paymentMethod: selectedPaymentMethod,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Order')),
      backgroundColor: Color(0xFFD28A22), // Set the background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Create a New Order',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 20),

              // Select Tour Guide
              Text('Select a Tour Guide:', style: TextStyle(fontSize: 18, color: Colors.white)),
              DropdownButton<String>(
                value: selectedTourGuide.isEmpty ? null : selectedTourGuide,
                hint: Text('Choose a Tour Guide', style: TextStyle(color: Colors.white)),
                dropdownColor: Color(0xFFD28A22),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTourGuide = newValue!;
                  });
                },
                items: tourGuides.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),

              // Select Restaurants
              Text('Select Restaurants:', style: TextStyle(fontSize: 18, color: Colors.white)),
              ...restaurants.map((restaurant) {
                return CheckboxListTile(
                  title: Text(restaurant, style: TextStyle(color: Colors.white)),
                  value: selectedRestaurants.contains(restaurant),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedRestaurants.add(restaurant);
                      } else {
                        selectedRestaurants.remove(restaurant);
                      }
                    });
                  },
                );
              }).toList(),
              SizedBox(height: 20),

              // Select Places
              Text('Select Places:', style: TextStyle(fontSize: 18, color: Colors.white)),
              ...places.map((place) {
                return CheckboxListTile(
                  title: Text(place, style: TextStyle(color: Colors.white)),
                  value: selectedPlaces.contains(place),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedPlaces.add(place);
                      } else {
                        selectedPlaces.remove(place);
                      }
                    });
                  },
                );
              }).toList(),
              SizedBox(height: 20),

              // Select Payment Method
              Text('Select Payment Method:', style: TextStyle(fontSize: 18, color: Colors.white)),
              DropdownButton<String>(
                value: selectedPaymentMethod.isEmpty ? null : selectedPaymentMethod,
                hint: Text('Choose Payment Method', style: TextStyle(color: Colors.white)),
                dropdownColor: Color(0xFFD28A22),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPaymentMethod = newValue!;
                  });
                },
                items: paymentMethods.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
              SizedBox(height: 40),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: _submitOrder,
                  child: Text('Proceed to Order Summary'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
