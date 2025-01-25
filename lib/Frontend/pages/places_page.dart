import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/pages/touguide.dart'; // Make sure this is correct
import 'package:dio/dio.dart'; // Import Dio for API calls

class PlacesPage extends StatefulWidget {
  final String selectedRestaurant; // Added a parameter for selected restaurant

  PlacesPage({required this.selectedRestaurant}); // Constructor to accept the restaurant name

  @override
  _PlacesPageState createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  TextEditingController searchController = TextEditingController();

  // Pre-populated places (your original data)
  List<Map<String, dynamic>> places = [
    {"name": "Beach", "icon": Icons.beach_access, "description": "Relax by the ocean.", "location": "California, USA", "price": "\$10 - \$20", "days": "3-5 days"},
    {"name": "Riding", "icon": Icons.bike_scooter, "description": "Exciting bike trails.", "location": "Colorado, USA", "price": "\$15 - \$30", "days": "1-2 days"},
    {"name": "Park", "icon": Icons.park, "description": "Explore the green fields.", "location": "New York, USA", "price": "\$5 - \$10", "days": "1 day"},
    {"name": "Museum", "icon": Icons.museum, "description": "Discover the art and history.", "location": "Paris, France", "price": "\$20 - \$50", "days": "2-3 days"},
    {"name": "City Tour", "icon": Icons.location_city, "description": "Explore the city sights.", "location": "Tokyo, Japan", "price": "\$30 - \$60", "days": "4-6 days"},
    {"name": "Gyms", "icon": Icons.sports, "description": "Get fit and healthy.", "location": "Los Angeles, USA", "price": "\$10 - \$25", "days": "Ongoing"},
  ];

  // Filtered places based on search query
  List<Map<String, dynamic>> filteredPlaces = [];

  Dio dio = Dio();
  List<String> selectedPlaces = [];

  // Fetch places data from the API (if necessary)
  Future<void> fetchPlaces() async {
    try {
      final response = await dio.get(
        'http://192.168.1.5:8080/api', // Replace with actual endpoint
        queryParameters: {'restaurant': widget.selectedRestaurant}, // Pass restaurant name
      );
      if (response.statusCode == 200) {
        setState(() {
          places = List<Map<String, dynamic>>.from(response.data); // Update with fetched data
          filteredPlaces = List.from(places); // Initialize filtered list with all places
        });
      }
    } catch (e) {
      print("Error fetching places: $e");
    }
  }

  // Filter places based on search input
  void filterPlaces(String query) {
    setState(() {
      filteredPlaces = places.where((place) {
        return place["name"].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPlaces(); // Fetch places when the page loads
    filteredPlaces = List.from(places); // Initialize filtered list with all places
    searchController.addListener(() {
      filterPlaces(searchController.text); // Filter places as user types
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose Place for ${widget.selectedRestaurant}')),
      body: Container(
        color: Color(0xFFD28A22),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search for a place',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredPlaces.length,
                itemBuilder: (context, index) {
                  String placeName = filteredPlaces[index]["name"];
                  IconData icon = filteredPlaces[index]["icon"];
                  String description = filteredPlaces[index]["description"];
                  String location = filteredPlaces[index]["location"];
                  String price = filteredPlaces[index]["price"];
                  String days = filteredPlaces[index]["days"];

                  return PlaceCard(
                    placeName: placeName,
                    icon: icon,
                    description: description,
                    location: location,
                    price: price,
                    days: days,
                    onCardTap: () {
                      setState(() {
                        selectedPlaces.add(placeName);
                      });
                      _showSelectedPlaceBottomSheet(placeName);
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TourGuidePage(selectedPlaces: selectedPlaces, selectedRestaurant: widget.selectedRestaurant), // Pass selectedRestaurant here
                  ),
                );
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  // Show selected place details in bottom sheet
  void _showSelectedPlaceBottomSheet(String placeName) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You selected: $placeName',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('This place is now selected, and you can proceed with the next steps.'),
            ],
          ),
        );
      },
    );
  }
}

class PlaceCard extends StatefulWidget {
  final String placeName;
  final String description;
  final String location;
  final String price;
  final String days;
  final IconData icon;
  final VoidCallback onCardTap;

  PlaceCard({
    required this.placeName,
    required this.description,
    required this.icon,
    required this.location,
    required this.price,
    required this.days,
    required this.onCardTap,
  });

  @override
  _PlaceCardState createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onCardTap,
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
        },
        child: Card(
          margin: EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(widget.icon, size: 50),
                    SizedBox(width: 20),
                    Text(
                      widget.placeName,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (_isHovered) ...[
                  SizedBox(height: 12),
                  Text(widget.description, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Location: ${widget.location}', style: TextStyle(fontSize: 14)),
                  Text('Price: ${widget.price}', style: TextStyle(fontSize: 14)),
                  Text('Days: ${widget.days}', style: TextStyle(fontSize: 14)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
