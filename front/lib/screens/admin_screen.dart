import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  final User user;
  
  const AdminScreen({super.key, required this.user});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<FoodItem> _foodItems = [];

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    final items = await ApiService.getFoodItems();
    setState(() => _foodItems = items);
  }

  void _showAddEditDialog([FoodItem? item]) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final priceController = TextEditingController(text: item?.price.toString() ?? '');
    final categoryController = TextEditingController(text: item?.category ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Add Food Item' : 'Edit Food Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price')),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final newItem = FoodItem(
                id: item?.id ?? 0,
                name: nameController.text,
                description: descController.text,
                price: double.parse(priceController.text),
                category: categoryController.text,
                available: true,
              );

              bool success;
              if (item == null) {
                success = await ApiService.addFoodItem(newItem);
              } else {
                success = await ApiService.updateFoodItem(item.id, newItem);
              }

              if (success) {
                _loadFoodItems();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - ${widget.user.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _foodItems.length,
        itemBuilder: (context, index) {
          final item = _foodItems[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text('${item.category} - \$${item.price.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showAddEditDialog(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    if (await ApiService.deleteFoodItem(item.id)) {
                      _loadFoodItems();
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }
}