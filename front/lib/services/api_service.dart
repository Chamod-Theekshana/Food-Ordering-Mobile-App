import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/food_item.dart';
import '../models/category.dart';
import '../models/coupon.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  // Auth APIs
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

  static Future<User?> register(String email, String password, String name) async {
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

  // Category APIs
  static Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Category.fromJson(item)).toList();
    }
    return [];
  }

  static Future<List<Category>> getAllCategoriesForAdmin() async {
    try {
      print('API: Fetching admin categories from $baseUrl/categories/admin');
      final response = await http.get(Uri.parse('$baseUrl/categories/admin'));
      print('API: Categories response status: ${response.statusCode}');
      print('API: Categories response body: ${response.body}');
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        final categories = data.map((item) => Category.fromJson(item)).toList();
        print('API: Parsed ${categories.length} categories');
        return categories;
      }
      print('API: Categories request failed with status ${response.statusCode}');
    } catch (e) {
      print('API: Error fetching admin categories: $e');
    }
    return [];
  }

  // Food APIs
  static Future<List<FoodItem>> getFoodItems() async {
    final response = await http.get(Uri.parse('$baseUrl/food'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => FoodItem.fromJson(item)).toList();
    }
    return [];
  }

  static Future<List<FoodItem>> getAllFoodItemsForAdmin() async {
    try {
      print('API: Fetching admin food items from $baseUrl/food/admin');
      final response = await http.get(Uri.parse('$baseUrl/food/admin'));
      print('API: Food items response status: ${response.statusCode}');
      print('API: Food items response body: ${response.body}');
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        final items = data.map((item) => FoodItem.fromJson(item)).toList();
        print('API: Parsed ${items.length} food items');
        return items;
      }
      print('API: Food items request failed with status ${response.statusCode}');
    } catch (e) {
      print('API: Error fetching admin food items: $e');
    }
    return [];
  }

  static Future<List<FoodItem>> searchFoodItems(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/food/search?query=$query'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => FoodItem.fromJson(item)).toList();
    }
    return [];
  }

  static Future<List<FoodItem>> getFoodByCategory(int categoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/food/category/$categoryId'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => FoodItem.fromJson(item)).toList();
    }
    return [];
  }

  static Future<List<FoodItem>> getTopRatedFood() async {
    final response = await http.get(Uri.parse('$baseUrl/food/top-rated'));
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

  // Coupon APIs
  static Future<Coupon?> validateCoupon(String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/coupons/validate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}),
    );
    if (response.statusCode == 200) {
      return Coupon.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // Wishlist APIs
  static Future<List<dynamic>> getUserWishlist(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/wishlist/user/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<bool> addToWishlist(int userId, int foodItemId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/wishlist'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'foodItemId': foodItemId}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> removeFromWishlist(int userId, int foodItemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/wishlist/user/$userId/item/$foodItemId'),
    );
    return response.statusCode == 200;
  }

  // Rating APIs
  static Future<bool> addRating(int userId, int foodItemId, int rating, String comment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ratings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'foodItemId': foodItemId,
        'rating': rating,
        'comment': comment,
      }),
    );
    return response.statusCode == 200;
  }

  // Order APIs
  static Future<bool> createOrder(int userId, List<Map<String, dynamic>> items, 
      {String orderType = 'DELIVERY', String paymentMethod = 'COD', String? address}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'items': items,
        'orderType': orderType,
        'paymentMethod': paymentMethod,
        'deliveryAddress': address,
      }),
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
    try {
      print('API: Fetching all orders from $baseUrl/orders');
      final response = await http.get(Uri.parse('$baseUrl/orders'));
      print('API: Orders response status: ${response.statusCode}');
      print('API: Orders response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final orders = jsonDecode(response.body);
        print('API: Parsed ${orders.length} orders');
        return orders;
      }
      print('API: Orders request failed with status ${response.statusCode}');
    } catch (e) {
      print('API: Error fetching orders: $e');
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

  // Reports APIs
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      print('API: Fetching dashboard stats from $baseUrl/reports/dashboard');
      final response = await http.get(Uri.parse('$baseUrl/reports/dashboard'));
      print('API: Dashboard stats response status: ${response.statusCode}');
      print('API: Dashboard stats response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final stats = jsonDecode(response.body);
        print('API: Parsed dashboard stats: $stats');
        return stats;
      }
      print('API: Dashboard stats request failed with status ${response.statusCode}');
    } catch (e) {
      print('API: Error fetching dashboard stats: $e');
    }
    return {};
  }

  // User Profile APIs
  static Future<bool> updateUserProfile(int userId, String name, String phone, String address) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'address': address,
      }),
    );
    return response.statusCode == 200;
  }

  // Admin APIs
  static Future<bool> createFirstAdmin(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/create-first-admin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );
    return response.statusCode == 200;
  }
}
