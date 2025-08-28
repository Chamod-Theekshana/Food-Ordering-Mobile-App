import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/food_item.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'food_detail_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';
import 'order_history_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<FoodItem> _foodItems = [];
  List<Category> _categories = [];
  List<FoodItem> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  Category? _selectedCategory;
  late TabController _tabController;
  final int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await ApiService.getCategories();
    final items = await ApiService.getFoodItems();
    setState(() {
      _categories = categories;
      _foodItems = items;
      _filteredItems = items;
    });
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _selectedCategory != null
            ? _foodItems.where((item) => item.category?.id == _selectedCategory!.id).toList()
            : _foodItems;
      } else {
        _filteredItems = _foodItems
            .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _filterByCategory(Category? category) {
    setState(() {
      _selectedCategory = category;
      _filteredItems = category != null
          ? _foodItems.where((item) => item.category?.id == category.id).toList()
          : _foodItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${widget.user.name}'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) => IconButton(
              icon: Badge(
                label: Text('${cart.itemCount}'),
                child: const Icon(Icons.shopping_cart),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartScreen(user: widget.user)),
              ),
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [Icon(Icons.person), SizedBox(width: 8), Text('Profile')],
                ),
              ),
              const PopupMenuItem(
                value: 'orders',
                child: Row(
                  children: [Icon(Icons.history), SizedBox(width: 8), Text('Order History')],
                ),
              ),
              const PopupMenuItem(
                value: 'wishlist',
                child: Row(
                  children: [Icon(Icons.favorite), SizedBox(width: 8), Text('Wishlist')],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [Icon(Icons.logout), SizedBox(width: 8), Text('Logout')],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(user: widget.user)));
                  break;
                case 'orders':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => OrderHistoryScreen(user: widget.user)));
                  break;
                case 'wishlist':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => WishlistScreen(user: widget.user)));
                  break;
                case 'logout':
                  Navigator.pushReplacementNamed(context, '/');
                  break;
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search food items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filterItems,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Categories
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 16),
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (_) => _filterByCategory(null),
                ),
                const SizedBox(width: 8),
                ..._categories.map((category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: _selectedCategory?.id == category.id,
                    onSelected: (_) => _filterByCategory(category),
                  ),
                )),
              ],
            ),
          ),
          // Food Items
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FoodDetailScreen(foodItem: item, user: widget.user),
                    ),
                  ),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              image: item.imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(item.imageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: item.imageUrl == null
                                ? const Center(child: Icon(Icons.fastfood, size: 50, color: Colors.grey))
                                : null,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 16),
                                    Text('${item.averageRating.toStringAsFixed(1)} (${item.ratingCount})', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                    ),
                                    Consumer<CartProvider>(
                                      builder: (context, cart, child) => IconButton(
                                        icon: const Icon(Icons.add_shopping_cart, size: 20),
                                        onPressed: () {
                                          cart.addItem(item);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('${item.name} added to cart')),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
