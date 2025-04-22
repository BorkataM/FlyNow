import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flynow/screens/search_flights_screen.dart';
import 'package:flynow/screens/my_tickets_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userFirstName = '';
  String _userEmail = '';

  // Позиции на самолетите
  LatLng _plane1Position = LatLng(42.6977, 23.3219); // София
  LatLng _plane2Position = LatLng(42.6977, 23.3219); // София
  LatLng _plane3Position = LatLng(42.6977, 23.3219); // София

  late Timer _timer;

  // Рутове за самолетите
  final List<LatLng> route1 = [
    LatLng(42.6977, 23.3219),
    LatLng(41.9028, 12.4964),
  ]; // София -> Рим
  final List<LatLng> route2 = [
    LatLng(42.6977, 23.3219),
    LatLng(41.3851, 2.1734),
  ]; // София -> Барселона
  final List<LatLng> route3 = [
    LatLng(42.6977, 23.3219),
    LatLng(35.6762, 139.6503),
  ]; // София -> Токио

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startPlaneAnimation();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userFirstName = prefs.getString('userFirstName') ?? 'User';
    final userEmail = prefs.getString('userEmail') ?? '';
    if (mounted) {
      setState(() {
        _userFirstName = userFirstName;
        _userEmail = userEmail;
      });
    }
  }

  void _startPlaneAnimation() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        // Премества самолетите по рутовете
        _plane1Position = _getNextPosition(_plane1Position, route1);
        _plane2Position = _getNextPosition(_plane2Position, route2);
        _plane3Position = _getNextPosition(_plane3Position, route3);
      });
    });
  }

  LatLng _getNextPosition(LatLng currentPosition, List<LatLng> route) {
    double currentLat = currentPosition.latitude;
    double currentLng = currentPosition.longitude;
    double targetLat = route.last.latitude;
    double targetLng = route.last.longitude;

    // Пресмятане на следваща позиция (необходимо за плавно движение)
    double newLat = currentLat + (targetLat - currentLat) * 0.1;
    double newLng = currentLng + (targetLng - currentLng) * 0.1;

    // Ако самолетът достигне крайната точка на маршрута, връща се към началната точка
    if ((newLat - targetLat).abs() < 0.0001 &&
        (newLng - targetLng).abs() < 0.0001) {
      return route.first; // Връща се към началната точка
    }

    return LatLng(newLat, newLng);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _navigateToSearchFlights() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchFlightsScreen()),
    );
  }

  void _navigateToMyTickets() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyTicketsScreen()),
    );
  }

  void _logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userFirstName');
    await prefs.remove('userEmail');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight = 160.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Fly Now',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Hi, $_userFirstName!\nWhere we going to?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _navigateToSearchFlights,
                        child: SizedBox(
                          width: double.infinity,
                          height: cardHeight,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            color: Colors.blueAccent.withOpacity(0.8),
                            child: const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Search Flights',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _navigateToMyTickets,
                        child: SizedBox(
                          width: double.infinity,
                          height: cardHeight,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            color: Colors.green.withOpacity(0.8),
                            child: const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.airplane_ticket,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'My Tickets',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: FlutterMap(
                        options: MapOptions(
                          center: LatLng(48.8566, 2.3522), // Център на картата
                          zoom: 4,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: ['a', 'b', 'c'],
                            userAgentPackageName: 'com.yourcompany.flynow',
                          ),
                          MarkerLayer(
                            markers: [
                              // Самолет София -> Рим
                              Marker(
                                point: _plane1Position,
                                width: 30,
                                height: 30,
                                child: Icon(
                                  Icons.airplanemode_active,
                                  size: 30,
                                  color: Colors.red,
                                ),
                              ),
                              // Самолет София -> Барселона
                              Marker(
                                point: _plane2Position,
                                width: 30,
                                height: 30,
                                child: Icon(
                                  Icons.airplanemode_active,
                                  size: 30,
                                  color: Colors.green,
                                ),
                              ),
                              Marker(
                                point: _plane3Position,
                                width: 30,
                                height: 30,
                                child: Icon(
                                  Icons.airplanemode_active,
                                  size: 30,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: ElevatedButton(
                      onPressed: _logOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.withOpacity(0.9),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
