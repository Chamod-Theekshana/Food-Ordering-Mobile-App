import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/food_item.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api'; // Using ADB port forwarding

  static Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      print('Login failed: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  static Future<User?> register(
    String email,
    String password,
    String name,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<List<FoodItem>> getFoodItems() async {
    final response = await http.get(Uri.parse('$baseUrl/food'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => FoodItem.fromJson(item)).toList();
    }
    return [];
  }

  static Future<bool> addFoodItem(FoodItem item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/food'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> updateFoodItem(int id, FoodItem item) async {
    final response = await http.put(
      Uri.parse('$baseUrl/food/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteFoodItem(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/food/$id'));
    return response.statusCode == 200;
  }

  static Future<bool> createOrder(int userId, List<Map<String, dynamic>> items) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'items': items}),
    );
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getUserOrders(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/orders/user/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<List<dynamic>> getAllOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/orders'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<bool> updateOrderStatus(int orderId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    return response.statusCode == 200;
  }
}
