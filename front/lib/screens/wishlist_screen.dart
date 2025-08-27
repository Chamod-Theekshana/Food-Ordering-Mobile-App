import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';

class WishlistScreen extends StatefulWidget {
  final User user;

  const WishlistScreen({super.key, required this.user});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<dynamic> _wishlistItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final items = await ApiService.getUserWishlist(widget.user.id);
    setState(() {
      _wishlistItems = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wishlistItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 100, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Your wishlist is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Add items you love to see them here', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _wishlistItems.length,
                  itemBuilder: (context, index) {
                    final wishlistItem = _wishlistItems[index];
                    final foodItem = FoodItem.fromJson(wishlistItem['foodItem']);
                    
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: foodItem.imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(foodItem.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: foodItem.imageUrl == null
                              ? const Icon(Icons.fastfood, color: Colors.grey)
                              : null,
                        ),
                        title: Text(foodItem.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('\$${foodItem.price.toStringAsFixed(2)}'),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                Text('${foodItem.averageRating.toStringAsFixed(1)} (${foodItem.ratingCount})'),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Consumer<CartProvider>(
                              builder: (context, cart, child) => IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                onPressed: () {
                                  cart.addItem(foodItem);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${foodItem.name} added to cart')),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeFromWishlist(foodItem.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _removeFromWishlist(int foodItemId) async {
    final success = await ApiService.removeFromWishlist(widget.user.id, foodItemId);
    if (success) {
      _loadWishlist();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from wishlist')),
      );
    }
  }
}