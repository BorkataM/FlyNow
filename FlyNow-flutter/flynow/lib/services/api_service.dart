import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.0.2.2:5289/api';

  // Login
  Future<Map<String, dynamic>> login(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/Users?email=$email'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  // Registration
  Future<Map<String, dynamic>> register(
    String email,
    String firstName,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Users/create-user'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'firstName': firstName,
        'password': password,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to register. Error: ${response.statusCode}');
    }
  }

  // Search flights
  Future<List<dynamic>> searchFlights(String origin, String destination) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/Flights/search?origin=$origin&destination=$destination',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch flights');
    }
  }

  // View yor tickets
  Future<List<dynamic>> getTickets(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/Users?email=$email'));

    if (response.statusCode == 200) {
      final user = json.decode(response.body);
      final userId = user['id'];

      final ticketResponse = await http.get(
        Uri.parse('$baseUrl/Tickets?userId=$userId'),
      );

      if (ticketResponse.statusCode == 200) {
        return json.decode(ticketResponse.body);
      } else {
        throw Exception('Failed to fetch tickets');
      }
    } else {
      throw Exception('User not found');
    }
  }

  // Buy tickets
  Future<void> purchaseTicket(String email, int flightId) async {
    final userResponse = await http.get(
      Uri.parse('$baseUrl/Users?email=$email'),
    );

    if (userResponse.statusCode == 200) {
      final user = json.decode(userResponse.body);
      final userId = user['id'];

      // Добавяне на полето email към тялото на заявката
      final purchaseResponse = await http.post(
        Uri.parse('$baseUrl/Tickets/purchase'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'flightId': flightId,
          'email': email, // Добави email полето тук
        }),
      );

      if (purchaseResponse.statusCode == 200) {
        return;
      } else {
        throw Exception(
          'Failed to purchase ticket. Error: ${purchaseResponse.statusCode} - ${purchaseResponse.body}',
        );
      }
    } else {
      throw Exception('User not found');
    }
  }

  Future<List<dynamic>> getTicketsByUser(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Tickets/user-tickets/$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch tickets');
    }
  }
}
