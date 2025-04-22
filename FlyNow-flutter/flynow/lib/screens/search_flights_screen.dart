import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Добавено за sharedPreferences
import '../services/api_service.dart';

class SearchFlightsScreen extends StatefulWidget {
  const SearchFlightsScreen({super.key});

  @override
  State<SearchFlightsScreen> createState() => _SearchFlightsScreenState();
}

class _SearchFlightsScreenState extends State<SearchFlightsScreen> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<dynamic> _flights = [];
  bool _isLoading = false;

  bool _isOriginFocused = false;
  bool _isDestinationFocused = false;

  final FocusNode _originFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _originFocusNode.addListener(() {
      setState(() {
        _isOriginFocused = _originFocusNode.hasFocus;
      });
    });
    _destinationFocusNode.addListener(() {
      setState(() {
        _isDestinationFocused = _destinationFocusNode.hasFocus;
      });
    });
  }

  Future<void> _searchFlights() async {
    setState(() => _isLoading = true);
    try {
      var response = await _apiService.searchFlights(
        _originController.text.trim(),
        _destinationController.text.trim(),
      );
      setState(() {
        _flights = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to fetch flights')));
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('HH:mm\ndd.MM.yyyy').format(dateTime);
    } catch (_) {
      return isoDate;
    }
  }

  void _showFlightDetails(dynamic flight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    ListView(
                      controller: scrollController,
                      children: [
                        const SizedBox(height: 30),
                        Center(
                          child: Lottie.asset(
                            'assets/animations/plane.json',
                            height: 120,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            '${flight['origin']} → ${flight['destination']}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _infoRow(
                          Icons.access_time,
                          _formatDate(flight['departureTime']),
                        ),
                        _infoRow(
                          Icons.schedule,
                          'Duration: ${flight['duration']} mins',
                        ),
                        _infoRow(
                          FontAwesomeIcons.moneyBill,
                          '\$${flight['price']}',
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed:
                                () => _purchaseTicket(
                                  flight,
                                ), // Извикваме метода за покупка
                            icon: const Icon(
                              Icons.shopping_cart_checkout,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Buy Ticket',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Метод за извличане на имейла от sharedPreferences
  Future<String> _getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') ??
        ''; // Връща имейла или празен низ ако няма
  }

  // Метод за покупка на билет
  Future<void> _purchaseTicket(dynamic flight) async {
    final String email =
        await _getUserEmail(); // Извличаме имейла от sharedPreferences
    final int flightId = flight['id']; // ID на полета

    try {
      // Изпращаме заявка към бекенда за покупка на билет
      final response = await _apiService.purchaseTicket(email, flightId);
      // Ако всичко е наред, показваме съобщение за успех
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ticket Purchased')));
      Navigator.pop(context); // Затваряме модалния прозорец
    } catch (e) {
      // Ако възникне грешка, показваме съобщение за неуспех
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to purchase ticket')),
      );
      Navigator.pop(context); // Затваряме модалния прозорец
    }
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required bool isFocused,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: isFocused ? '' : label,
      prefixIcon: Icon(icon, color: Colors.indigo),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Search Flights',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
            colors: [Colors.indigoAccent, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 30),
                TextField(
                  controller: _originController,
                  focusNode: _originFocusNode,
                  decoration: _inputDecoration(
                    label: 'From',
                    isFocused: _isOriginFocused,
                    icon: Icons.flight_takeoff,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _destinationController,
                  focusNode: _destinationFocusNode,
                  decoration: _inputDecoration(
                    label: 'To',
                    isFocused: _isDestinationFocused,
                    icon: Icons.flight_land,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _searchFlights,
                    icon: const Icon(Icons.search, color: Colors.white),
                    label: const Text(
                      'Search Flights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.indigo),
                  ),
                if (!_isLoading && _flights.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _flights.length,
                      itemBuilder: (context, index) {
                        final flight = _flights[index];
                        return GestureDetector(
                          onTap: () => _showFlightDetails(flight),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            color: Colors.white.withOpacity(0.9),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${flight['origin']} → ${flight['destination']}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatDate(flight['departureTime']),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Price: \$${flight['price']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
