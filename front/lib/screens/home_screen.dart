import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FoodItem> _foodItems = [];
  final List<FoodItem> _cart = [];

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    final items = await ApiService.getFoodItems();
    setState(() => _foodItems = items);
  }

  void _addToCart(FoodItem item) {
    setState(() => _cart.add(item));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${item.name} added to cart')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${widget.user.name}'),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${_cart.length}'),
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () => _showCart(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
        ),
        itemCount: _foodItems.length,
        itemBuilder: (context, index) {
          final item = _foodItems[index];
          return Card(
            child: Column(
              children: [
                Expanded(
                  child:
                      item.imageUrl != null
                          ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.fastfood, size: 50),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('\$${item.price.toStringAsFixed(2)}'),
                      ElevatedButton(
                        onPressed: () => _addToCart(item),
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Cart',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed:
                              () => setState(() => _cart.removeAt(index)),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _cart.isNotEmpty ? () => _placeOrder() : null,
                  child: Text(
                    'Place Order (\$${_cart.fold(0.0, (sum, item) => sum + item.price).toStringAsFixed(2)})',
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _placeOrder() async {
    final items =
        _cart
            .map(
              (item) => {
                'foodItem': {'id': item.id},
                'quantity': 1,
                'price': item.price,
              },
            )
            .toList();

    final success = await ApiService.createOrder(widget.user.id, items);

    setState(() => _cart.clear());
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Order placed successfully!' : 'Failed to place order',
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }
}
