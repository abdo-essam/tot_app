import 'package:flutter/material.dart';
import 'payment.dart';  // Ensure this is the correct import path

class TourGuidePage extends StatefulWidget {
  final List<String> selectedPlaces;
  final String selectedRestaurant; // Add this parameter

  // Updated constructor to accept both selectedPlaces and selectedRestaurant
  TourGuidePage({required this.selectedPlaces, required this.selectedRestaurant});

  @override
  _TourGuidePageState createState() => _TourGuidePageState();
}

class _TourGuidePageState extends State<TourGuidePage> {
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> tourGuides = [];
  String selectedTourGuide = "";
  String selectedAge = "non";
  String selectedLanguage = "non";
  String selectedNationality = "non";

  // Simulating fetching tour guides (replace with real data fetching logic)
  Future<void> retrieveTourGuides() async {
    try {
      await Future.delayed(Duration(seconds: 2)); // Simulate network delay
      setState(() {
        tourGuides = [
          {
            "name": "John Doe",
            "age": 30,
            "language": "English",
            "nationality": "American",
            "rating": 4.5,
            "image": "assets/images/john_doe.png",
          },
          {
            "name": "Maria Gomez",
            "age": 25,
            "language": "Spanish",
            "nationality": "Spanish",
            "rating": 4.7,
            "image": "assets/images/maria_gomez.png",
          },
          {
            "name": "Ahmed Hassan",
            "age": 35,
            "language": "Arabic",
            "nationality": "Egyptian",
            "rating": 4.8,
            "image": "assets/images/ahmed_hassan.png",
          },
        ];
      });
    } catch (e) {
      print("Error fetching tour guides: $e");
      // Optionally, show a Snackbar or other UI element to inform the user
    }
  }

  @override
  void initState() {
    super.initState();
    retrieveTourGuides();
  }

  List<Map<String, dynamic>> getFilteredTourGuides() {
    return tourGuides.where((guide) {
      return (selectedAge == "non" || guide["age"] == int.tryParse(selectedAge)) &&
             (selectedLanguage == "non" || guide["language"] == selectedLanguage) &&
             (selectedNationality == "non" || guide["nationality"] == selectedNationality);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Your Suitable Tour Guide for ${widget.selectedRestaurant}'),
      ),
      body: Container(
        color: const Color(0xFFD28A22),
        child: Column(
          children: [
            // Filters Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterDropdown(
                    title: "Age",
                    options: ["non", "25", "30", "35"],
                    selectedOption: selectedAge,
                    onOptionSelect: (value) {
                      setState(() {
                        selectedAge = value;
                      });
                    },
                  ),
                  FilterDropdown(
                    title: "Language",
                    options: ["non", "English", "Spanish", "Arabic"],
                    selectedOption: selectedLanguage,
                    onOptionSelect: (value) {
                      setState(() {
                        selectedLanguage = value;
                      });
                    },
                  ),
                  FilterDropdown(
                    title: "Nationality",
                    options: ["non", "American", "Spanish", "Egyptian"],
                    selectedOption: selectedNationality,
                    onOptionSelect: (value) {
                      setState(() {
                        selectedNationality = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Tour Guide Cards
            Expanded(
              child: tourGuides.isEmpty
                  ? Center(child: CircularProgressIndicator()) // Show loading spinner while data is being fetched
                  : getFilteredTourGuides().isEmpty
                      ? Center(child: Text("No tour guides match the filters."))
                      : ListView.builder(
                          itemCount: getFilteredTourGuides().length,
                          itemBuilder: (context, index) {
                            var guide = getFilteredTourGuides()[index];
                            return TourGuideCard(
                              guide: guide,
                              onCardTap: () {
                                setState(() {
                                  selectedTourGuide = guide["name"];
                                });
                              },
                            );
                          },
                        ),
            ),
            // 'Next' Button for navigation
            ElevatedButton(
              onPressed: () {
                if (selectedTourGuide.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select a tour guide.")),
                  );
                  return;
                }
                // Check if any selected places are empty
                if (widget.selectedRestaurant.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select a restaurant.")),
                  );
                  return;
                }

                // Navigate to PaymentPage and pass the data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(
                      selectedPlaces: widget.selectedPlaces,
                      tourGuide: selectedTourGuide,
                      selectedRestaurants: [widget.selectedRestaurant],
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

class FilterDropdown extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selectedOption;
  final Function(String) onOptionSelect;

  FilterDropdown({
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            value: selectedOption,
            underline: SizedBox(),
            items: options
                .map((option) => DropdownMenuItem<String>(value: option, child: Text(option)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onOptionSelect(value);
              }
            },
          ),
        ],
      ),
    );
  }
}

class TourGuideCard extends StatelessWidget {
  final Map<String, dynamic> guide;
  final VoidCallback onCardTap;

  TourGuideCard({required this.guide, required this.onCardTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onCardTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: guide["image"] != null
                    ? AssetImage(guide["image"])
                    : AssetImage('assets/images/default_avatar.png'), // Fallback to default image
                child: guide["image"] == null ? Icon(Icons.person, size: 40) : null,
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide["name"],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("Age: ${guide['age']}"),
                  Text("Language: ${guide['language']}"),
                  Text("Nationality: ${guide['nationality']}"),
                  Text("Rating: ${guide['rating']}"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
