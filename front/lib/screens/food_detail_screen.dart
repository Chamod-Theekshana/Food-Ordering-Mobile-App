import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../models/user.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem foodItem;
  final User user;

  const FoodDetailScreen({super.key, required this.foodItem, required this.user});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  bool _isFavorite = false;
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  void _checkIfFavorite() async {
    // Check if item is in wishlist
    final wishlist = await ApiService.getUserWishlist(widget.user.id);
    setState(() {
      _isFavorite = wishlist.any((item) => item['foodItem']['id'] == widget.foodItem.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.foodItem.imageUrl != null
                  ? Image.network(
                      widget.foodItem.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.fastfood, size: 100, color: Colors.grey),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.foodItem.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '\$${widget.foodItem.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < widget.foodItem.averageRating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text('${widget.foodItem.averageRating.toStringAsFixed(1)} (${widget.foodItem.ratingCount} reviews)'),
                    ],
                  ),
                  if (widget.foodItem.category != null) ...[
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(widget.foodItem.category!.name),
                      backgroundColor: Colors.orange.shade100,
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.foodItem.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  // Add Review Section
                  const Text(
                    'Add Your Review',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Rating: '),
                      ...List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () => setState(() => _rating = index + 1),
                        );
                      }),
                    ],
                  ),
                  TextField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      hintText: 'Write your review...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _submitReview,
                    child: const Text('Submit Review'),
                  ),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Consumer<CartProvider>(
          builder: (context, cart, child) => ElevatedButton(
            onPressed: () {
              cart.addItem(widget.foodItem);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.foodItem.name} added to cart')),
              );
            },
            child: const Text('Add to Cart'),
          ),
        ),
      ),
    );
  }

  void _toggleFavorite() async {
    if (_isFavorite) {
      final success = await ApiService.removeFromWishlist(widget.user.id, widget.foodItem.id);
      if (success) {
        setState(() => _isFavorite = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites')),
        );
      }
    } else {
      final success = await ApiService.addToWishlist(widget.user.id, widget.foodItem.id);
      if (success) {
        setState(() => _isFavorite = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites')),
        );
      }
    }
  }

  void _submitReview() async {
    final comment = _reviewController.text.trim();
    if (comment.isEmpty) return;

    final success = await ApiService.addRating(
      widget.user.id,
      widget.foodItem.id,
      _rating,
      comment,
    );

    if (success) {
      _reviewController.clear();
      setState(() => _rating = 5);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit review')),
      );
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}