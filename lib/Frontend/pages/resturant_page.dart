import 'package:flutter/material.dart';
import 'places_page.dart'; // Ensure this is the correct import for PlacesPage

class RestaurantPage extends StatefulWidget {
  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> restaurants = [
    {"name": "Pizza", "icon": Icons.local_pizza, "description": "One of the iconic restaurants that serve pizza.", "price": "\$10 - \$20"},
    {"name": "Burger", "icon": Icons.fastfood, "description": "Delicious burger, enjoy it.", "price": "\$8 - \$15"},
    {"name": "Sushi", "icon": Icons.rice_bowl, "description": "Fresh sushi rolls.", "price": "\$12 - \$25"},
    {"name": "Pasta House", "icon": Icons.dining, "description": "Enjoy your favorite pasta.", "price": "\$15 - \$30"},
    {"name": "Coffee Corner", "icon": Icons.coffee, "description": "Coffee corner.", "price": "\$5 - \$12"},
    {"name": "Fish Land", "icon": Icons.set_meal, "description": "All types of seafood.", "price": "\$20 - \$35"},
  ];

  String selectedRestaurant = "Null"; // Track the selected restaurant

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Your Favourite Restaurant'),
        backgroundColor: Color(0xFFD28A22), 
      ),
      body: Container(
        color: Color(0xFFD28A22), 
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search for a restaurant',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                onChanged: (query) {
                  setState(() {
                    restaurants = restaurants
                        .where((item) =>
                            item["name"].toLowerCase().contains(query.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  return RestaurantCard(
                    icon: restaurants[index]["icon"],
                    name: restaurants[index]["name"],
                    description: restaurants[index]["description"],
                    price: restaurants[index]["price"],
                    onCardTap: () {
                      setState(() {
                        selectedRestaurant = restaurants[index]["name"];
                      });

                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'You selected: ${restaurants[index]["name"]}',
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedRestaurant == "Null") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select a restaurant.")),
                  );
                  return;
                }

                // Pass the selected restaurant to PlacesPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlacesPage(
                      selectedRestaurant: selectedRestaurant, // Pass selected restaurant data
                    ),
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
}

class RestaurantCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String description;
  final String price;
  final VoidCallback onCardTap;

  RestaurantCard({
    required this.icon,
    required this.name,
    required this.description,
    required this.price,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onCardTap, 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.black54),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(description),
                  ],
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
