import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/food_item.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  final User user;

  const AdminScreen({super.key, required this.user});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<FoodItem> _foodItems = [];
  List<Category> _categories = [];
  List<dynamic> _orders = [];
  Map<String, dynamic> _dashboardStats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await ApiService.getFoodItems();
    final categories = await ApiService.getCategories();
    final orders = await ApiService.getAllOrders();
    final stats = await ApiService.getDashboardStats();

    setState(() {
      _foodItems = items;
      _categories = categories;
      _orders = orders;
      _dashboardStats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel - ${widget.user.name}'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Menu'),
            Tab(icon: Icon(Icons.category), text: 'Categories'),
            Tab(icon: Icon(Icons.receipt), text: 'Orders'),
            Tab(icon: Icon(Icons.people), text: 'Customers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboard(),
          _buildMenuManagement(),
          _buildCategoryManagement(),
          _buildOrderManagement(),
          _buildCustomerManagement(),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Total Orders',
                '${_dashboardStats['totalOrders'] ?? 0}',
                Icons.receipt,
                Colors.blue,
              ),
              _buildStatCard(
                'Total Users',
                '${_dashboardStats['totalUsers'] ?? 0}',
                Icons.people,
                Colors.green,
              ),
              _buildStatCard(
                'Menu Items',
                '${_dashboardStats['totalFoodItems'] ?? 0}',
                Icons.restaurant,
                Colors.orange,
              ),
              _buildStatCard(
                'Today Orders',
                '${_dashboardStats['todayOrders'] ?? 0}',
                Icons.today,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Orders
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Orders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._orders
                      .take(5)
                      .map(
                        (order) => ListTile(
                          title: Text('Order #${order['id']}'),
                          subtitle: Text(
                            '${order['user']['name']} - \$${order['totalAmount'].toStringAsFixed(2)}',
                          ),
                          trailing: Chip(
                            label: Text(order['status']),
                            backgroundColor: _getStatusColor(order['status']),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuManagement() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Menu Items (${_foodItems.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditFoodDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _foodItems.length,
            itemBuilder: (context, index) {
              final item = _foodItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image:
                          item.imageUrl != null
                              ? DecorationImage(
                                image: NetworkImage(item.imageUrl!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        item.imageUrl == null
                            ? const Icon(Icons.fastfood)
                            : null,
                  ),
                  title: Text(item.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.category?.name ?? 'No Category'} - \$${item.price.toStringAsFixed(2)}',
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(
                            '${item.averageRating.toStringAsFixed(1)} (${item.ratingCount})',
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.inventory, size: 16, color: Colors.grey),
                          Text('Stock: ${item.stockQuantity}'),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: item.available,
                        onChanged:
                            (value) => _toggleItemAvailability(item, value),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAddEditFoodDialog(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFoodItem(item),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryManagement() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Categories (${_categories.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditCategoryDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.orange.shade100,
                    ),
                    child: const Icon(Icons.category, color: Colors.orange),
                  ),
                  title: Text(category.name),
                  subtitle: Text(category.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: category.active,
                        onChanged:
                            (value) => _toggleCategoryStatus(category, value),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAddEditCategoryDialog(category),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderManagement() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Orders (${_orders.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _orders.length,
            itemBuilder: (context, index) {
              final order = _orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ExpansionTile(
                  title: Text('Order #${order['id']}'),
                  subtitle: Text(
                    '${order['user']['name']} - \$${order['totalAmount'].toStringAsFixed(2)}',
                  ),
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(order['status']),
                    child: Text('${order['id']}'),
                  ),
                  trailing: DropdownButton<String>(
                    value: order['status'],
                    items:
                        [
                              'PENDING',
                              'CONFIRMED',
                              'PREPARING',
                              'READY',
                              'DELIVERED',
                              'CANCELLED',
                            ]
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (newStatus) =>
                            _updateOrderStatus(order['id'], newStatus!),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer: ${order['user']['name']}'),
                          Text('Email: ${order['user']['email']}'),
                          Text(
                            'Order Type: ${order['orderType'] ?? 'DELIVERY'}',
                          ),
                          Text('Payment: ${order['paymentMethod'] ?? 'COD'}'),
                          if (order['deliveryAddress'] != null)
                            Text('Address: ${order['deliveryAddress']}'),
                          const SizedBox(height: 8),
                          const Text(
                            'Items:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...List.generate(order['items'].length, (itemIndex) {
                            final item = order['items'][itemIndex];
                            return Text(
                              '• ${item['foodItem']['name']} x${item['quantity']} - \$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerManagement() {
    return const Center(
      child: Text(
        'Customer Management\n(Feature coming soon)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  void _showAddEditFoodDialog([FoodItem? item]) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final priceController = TextEditingController(
      text: item?.price.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: item?.stockQuantity.toString() ?? '0',
    );
    Category? selectedCategory = item?.category;
    String? imageUrl = item?.imageUrl;
    bool available = item?.available ?? true;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    item == null ? 'Add Food Item' : 'Edit Food Item',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          maxLines: 3,
                        ),
                        TextField(
                          controller: priceController,
                          decoration: const InputDecoration(labelText: 'Price'),
                          keyboardType: TextInputType.number,
                        ),
                        TextField(
                          controller: stockController,
                          decoration: const InputDecoration(
                            labelText: 'Stock Quantity',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Category>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items:
                              _categories
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (category) =>
                                  setState(() => selectedCategory = category),
                        ),
                        const SizedBox(height: 16),
                        if (imageUrl != null) ...[
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => const Icon(Icons.error),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final urlController = TextEditingController(
                                  text: imageUrl,
                                );
                                return AlertDialog(
                                  title: const Text('Image URL'),
                                  content: TextField(
                                    controller: urlController,
                                    decoration: const InputDecoration(
                                      labelText: 'Enter image URL',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(
                                          () =>
                                              imageUrl =
                                                  urlController.text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : urlController.text
                                                          .trim(),
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.image),
                          label: Text(
                            imageUrl == null ? 'Add Image' : 'Change Image',
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Available'),
                          value: available,
                          onChanged:
                              (value) => setState(() => available = value),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final success = await _saveFoodItem(
                          item?.id,
                          nameController.text,
                          descController.text,
                          priceController.text,
                          stockController.text,
                          selectedCategory,
                          imageUrl,
                          available,
                        );
                        if (success) {
                          Navigator.pop(context);
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Food item ${item == null ? 'created' : 'updated'} successfully',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<bool> _saveFoodItem(
    int? id,
    String name,
    String description,
    String price,
    String stock,
    Category? category,
    String? imageUrl,
    bool available,
  ) async {
    if (name.trim().isEmpty || price.trim().isEmpty || category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, price, and category are required')),
      );
      return false;
    }

    final data = {
      'name': name.trim(),
      'description': description.trim(),
      'price': double.tryParse(price) ?? 0.0,
      'stockQuantity': int.tryParse(stock) ?? 0,
      'categoryId': category.id,
      'imageUrl': imageUrl,
      'available': available,
    };

    try {
      final url = id == null ? 'food' : 'food/$id';
      final method = id == null ? 'POST' : 'PUT';

      final response =
          http.Request(method, Uri.parse('${ApiService.baseUrl}/$url'))
            ..headers['Content-Type'] = 'application/json'
            ..body = jsonEncode(data);

      final streamedResponse = await response.send();
      return streamedResponse.statusCode == 200;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      return false;
    }
  }

  void _showAddEditCategoryDialog([Category? category]) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(
      text: category?.description ?? '',
    );
    String? imageUrl = category?.imageUrl;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    category == null ? 'Add Category' : 'Edit Category',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (imageUrl != null) ...[
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => const Icon(Icons.error),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        ElevatedButton.icon(
                          onPressed: () {
                            // For now, just allow URL input
                            showDialog(
                              context: context,
                              builder: (context) {
                                final urlController = TextEditingController(
                                  text: imageUrl,
                                );
                                return AlertDialog(
                                  title: const Text('Image URL'),
                                  content: TextField(
                                    controller: urlController,
                                    decoration: const InputDecoration(
                                      labelText: 'Enter image URL',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(
                                          () =>
                                              imageUrl =
                                                  urlController.text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : urlController.text
                                                          .trim(),
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.image),
                          label: Text(
                            imageUrl == null ? 'Add Image' : 'Change Image',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final success = await _saveCategory(
                          category?.id,
                          nameController.text,
                          descController.text,
                          imageUrl,
                        );
                        if (success) {
                          Navigator.pop(context);
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Category ${category == null ? 'created' : 'updated'} successfully',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<bool> _saveCategory(
    int? id,
    String name,
    String description,
    String? imageUrl,
  ) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required')));
      return false;
    }

    final data = {
      'name': name.trim(),
      'description': description.trim(),
      'imageUrl': imageUrl,
    };

    try {
      final url = id == null ? 'categories' : 'categories/$id';
      final method = id == null ? 'POST' : 'PUT';

      final response =
          http.Request(method, Uri.parse('${ApiService.baseUrl}/$url'))
            ..headers['Content-Type'] = 'application/json'
            ..body = jsonEncode(data);

      final streamedResponse = await response.send();
      return streamedResponse.statusCode == 200;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      return false;
    }
  }

  void _toggleItemAvailability(FoodItem item, bool available) async {
    // TODO: Implement toggle availability
    _loadData();
  }

  void _toggleCategoryStatus(Category category, bool active) async {
    // TODO: Implement toggle category status
    _loadData();
  }

  void _deleteFoodItem(FoodItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Item'),
            content: Text('Are you sure you want to delete ${item.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final success = await ApiService.deleteFoodItem(item.id);
      if (success) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
      }
    }
  }

  void _updateOrderStatus(int orderId, String newStatus) async {
    final success = await ApiService.updateOrderStatus(orderId, newStatus);
    if (success) {
      _loadData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order status updated')));
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.blue;
      case 'PREPARING':
        return Colors.purple;
      case 'READY':
        return Colors.green;
      case 'DELIVERED':
        return Colors.teal;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
