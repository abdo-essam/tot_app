import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tot_app/Frontend/pages/summary.dart';
import 'package:table_calendar/table_calendar.dart';

class AddTrip extends StatefulWidget {
  const AddTrip({Key? key}) : super(key: key);

  @override
  State<AddTrip> createState() => _AddTripState();
}

class _AddTripState extends State<AddTrip> {
  List<Map<String, dynamic>> places = [
    {
      'imageUrl':
          'https://www.egypt-nile-cruise.com/wp-content/uploads/2013/02/building1.jpg',
      'text': 'Nile Cruise',
    },
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/a/af/All_Gizah_Pyramids.jpg',
      'text': 'Pyramides',
    },
    {
      'imageUrl':
          'https://www.traveltoegypt.net/front/images/blog/AbuSimbel.jpg',
      'text': 'Abu Simbel Temples',
    },
    {
      'imageUrl':
          'https://images.squarespace-cdn.com/content/v1/56c13cc00442627a08632989/1585432288121-15NNGMB5XEP5CJ1YSGL3/egyptianmuseum.jpg',
      'text': 'Egyptian Museum',
    },
    {
      'imageUrl':
          'https://drifttravel.com/wp-content/uploads/2023/12/drifttravel_Khan_El_Khalili_Bazaar_in_Cairo_f5910bbd-7b61-4f7d-bad5-98d1d3500b99-copy-640x411.webp',
      'text': 'Khan el-Khalili',
    },
    {
      'imageUrl':
          'https://d3rr2gvhjw0wwy.cloudfront.net/uploads/activity_headers/322262/900x600-1-50-1724de8774e040a8cfa68917d96ccae1.jpg',
      'text': 'Luxor Temple',
    },
    // Add more items here
  ];
  List<Map<String, dynamic>> resturants = [
    {
      'imageUrl':
          "https://scenenow.com/Content/editor_api/images/272857187_2266755030155721_8790574858838293694_n-e7431554-54c8-40a5-9d85-baf5a1c7c338.jpg",
      'text': 'Oldish',
    },
    {
      'imageUrl':
          'https://www.tasteandflavors.com/wp-content/uploads/2022/05/zooba.jpg',
      'text': 'Zooba (Cairo)',
    },
    {
      'imageUrl':
          'https://eatapp.co/united-states-restaurants/images/1938-indochine-602-ala-moana-blvd-honolulu-hi-96813-united-states-restaurant-1.jpg?height=500&width=850',
      'text': 'Indochine (Cairo)',
    },
    {
      'imageUrl':
          'https://andareincentives.com/wp-content/uploads/2020/08/Khan-El-Khalili-Rest-Naguib-Mahfouz-Cafe.png',
      'text': 'Naguib Mahfouz',
    },
    {
      'imageUrl':
          'https://scontent.fcai19-3.fna.fbcdn.net/v/t1.6435-9/51499962_2184240844929794_4452112603103100928_n.jpg?_nc_cat=103&ccb=1-7&_nc_sid=127cfc&_nc_ohc=PjyNykmhAqIQ7kNvgHjAZYL&_nc_oc=AdggPexz-DGdCNTTgxGzO-yZejKww51Fy4OIH3os1xrT2jTAJeLr2cEwyp5roxfgogk&_nc_zt=23&_nc_ht=scontent.fcai19-3.fna&_nc_gid=ASAJnpJz7v14LhQGet-cTzB&oh=00_AYDNd4o2dEAE4Zvu0vB_RXHqE-2cf3OMhkUlwC5QRXSHVw&oe=67BB9A9C',
      'text': 'La Bodega Negra',
    },
    {
      'imageUrl':
          'https://fastly.4sqi.net/img/general/200x200/483182176_8jKNV8luIUOZDyPZQvrMhNW9Kb1YLY5EhVU3Q7d0MWc.jpg',
      'text': 'Felfela (Cairo)',
    },
    // Add more items here
  ];
  List<Map<String, dynamic>> tourGuide = [
    {
      'imageUrl':
          "https://img.freepik.com/premium-vector/man-avatar-profile-picture-isolated-background-avatar-profile-picture-man_1293239-4866.jpg",
      'text': 'Bassem wanis',
    },
    {
      'imageUrl':
          'https://img.freepik.com/premium-vector/man-avatar-profile-picture-isolated-background-avatar-profile-picture-man_1293239-4866.jpg',
      'text': 'Yousef Ashraf',
    },
    {
      'imageUrl':
          "https://img.freepik.com/premium-vector/man-avatar-profile-picture-isolated-background-avatar-profile-picture-man_1293239-4866.jpg",
      'text': 'Eyad emad',
    },
    {
      'imageUrl':
          'https://img.freepik.com/premium-vector/man-avatar-profile-picture-isolated-background-avatar-profile-picture-man_1293239-4866.jpg',
      'text': 'Mostafa tarek',
    },
    {
      'imageUrl':
          "https://img.freepik.com/premium-vector/man-avatar-profile-picture-isolated-background-avatar-profile-picture-man_1293239-4866.jpg",
      'text': 'Eviro Adham',
    },
  ];
  void _handleItemSelection(List<Map<String, dynamic>> list, int index) {
    setState(() {
      for (int i = 0; i < list.length; i++) {
        list[i]['isSelected'] = false; // Deselect all items
      }
      if (index >= 0 && index < list.length) {
        list[index]['isSelected'] = true; // Select the clicked item
      }

      // Update selected items based on category
      if (list == places) {
        _selectedPlace = list[index];
      } else if (list == resturants) {
        _selectedRestaurant = list[index];
      } else if (list == tourGuide) {
        _selectedTourGuide = list[index];
      }
    });
  }

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _showCalendar = false;
  int _numberOfTourists = 1;

  Map<String, dynamic>? _selectedPlace;
  Map<String, dynamic>? _selectedRestaurant;
  Map<String, dynamic>? _selectedTourGuide;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _toggleCalendarVisibility() {
    setState(() {
      _showCalendar = !_showCalendar;
    });
  }

  void _incrementTourists() {
    if (_numberOfTourists < 4) {
      setState(() {
        _numberOfTourists++;
      });
    }
  }

  void _decrementTourists() {
    if (_numberOfTourists > 1) {
      setState(() {
        _numberOfTourists--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add Trip',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        backgroundColor: Color(0xFFD28A22),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Places',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: places.asMap().entries.map((entry) {
                  int index = entry.key;
                  var item = entry.value;
                  return InkWell(
                    onTap: () => _handleItemSelection(places, index),
                    child: Container(
                      width: 150,
                      height: 150,
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 5),
                          Image.network(
                            item['imageUrl'],
                            width: 140,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 8.0),
                          Text(item['text']),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Restaurants',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: resturants.asMap().entries.map((entry) {
                  int index = entry.key;
                  var item = entry.value;
                  return InkWell(
                    onTap: () => _handleItemSelection(resturants, index),
                    child: Container(
                      width: 150,
                      height: 150,
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Image.network(
                            item['imageUrl'],
                            width: 140,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 8.0),
                          Text(item['text']),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tour Guides',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tourGuide.asMap().entries.map((entry) {
                  int index = entry.key;
                  var item = entry.value;
                  return InkWell(
                    onTap: () => _handleItemSelection(tourGuide, index),
                    child: Container(
                      width: 150,
                      height: 150,
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Image.network(
                            item['imageUrl'],
                            width: 140,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 8.0),
                          Text(item['text']),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20), // Add some spacing
            GestureDetector(
              onTap: _toggleCalendarVisibility,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Tour Date',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
            if (_showCalendar)
              TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                onDaySelected: _onDaySelected,
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  todayDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDay)}',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20), // Add some spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Number of Tourists:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _decrementTourists,
                  iconSize: 25,
                  color: Colors.black,
                ),
                Text(
                  '$_numberOfTourists',
                  style: const TextStyle(fontSize: 20.0),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _incrementTourists,
                  iconSize: 25,
                  color: Colors.black,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedPlace != null &&
                    _selectedRestaurant != null &&
                    _selectedTourGuide != null) {
                  Navigator.pushNamed(
                    context,
                    '/summary',
                    arguments: {
                      'selectedPlace': _selectedPlace!,
                      'selectedRestaurant': _selectedRestaurant!,
                      'selectedTourGuide': _selectedTourGuide!,
                      'selectedDay': _selectedDay,
                      'numberOfTourists': _numberOfTourists,
                    },
                  );
                } else {
                  // Show a message or snackbar indicating that all categories must be selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Please select one item from each category.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD28A22),
                foregroundColor: Colors.black,
              ),
              child: const Text('Proceed'),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Color(0xFFD28A22),
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle Status button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFCFDFF),
                foregroundColor: Colors.black,
              ),
              child: Icon(Icons.info),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/summary');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFCFDFF),
                foregroundColor: Colors.black,
              ),
              child: Icon(Icons.flight),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle Profile button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFCFDFF),
                foregroundColor: Colors.black,
              ),
              child: Icon(Icons.face),
            ),
          ],
        ),
      ),
    );
  }
}
