import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flynow/screens/search_flights_screen.dart';
import 'package:flynow/screens/my_tickets_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userFirstName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
              // Добавяме SingleChildScrollView тук
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
                  const SizedBox(height: 210),
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
