import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/food_item.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import '../widgets/animated_food_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'cart_screen.dart';
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

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Loading categories...');
      final categories = await ApiService.getCategories();
      print('Categories loaded: ${categories.length}');
      
      print('Loading food items...');
      final items = await ApiService.getFoodItems();
      print('Food items loaded: ${items.length}');
      
      setState(() {
        _categories = categories;
        _foodItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
      
      if (categories.isEmpty && items.isEmpty) {
        setState(() {
          _error = 'No data found. Please check if the backend server is running.';
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems =
            _selectedCategory != null
                ? _foodItems
                    .where((item) => item.category?.id == _selectedCategory!.id)
                    .toList()
                : _foodItems;
      } else {
        _filteredItems =
            _foodItems
                .where(
                  (item) =>
                      item.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  void _filterByCategory(Category? category) {
    setState(() {
      _selectedCategory = category;
      _filteredItems =
          category != null
              ? _foodItems
                  .where((item) => item.category?.id == category.id)
                  .toList()
              : _foodItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading delicious food...'),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: CustomErrorWidget(message: _error!, onRetry: _loadData),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF4757), Color(0xFFFF6B7A)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Text(
                                widget.user.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFFFF4757),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Consumer<CartProvider>(
                                  builder:
                                      (context, cart, child) => GestureDetector(
                                        onTap:
                                            () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => CartScreen(
                                                      user: widget.user,
                                                    ),
                                              ),
                                            ),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Badge(
                                            label: Text('${cart.itemCount}'),
                                            child: const Icon(
                                              Icons.shopping_cart,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                ),
                                const SizedBox(width: 8),
                                PopupMenuButton(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                  ),
                                  itemBuilder:
                                      (context) => [
                                        const PopupMenuItem(
                                          value: 'profile',
                                          child: Row(
                                            children: [
                                              Icon(Icons.person),
                                              SizedBox(width: 8),
                                              Text('Profile'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'orders',
                                          child: Row(
                                            children: [
                                              Icon(Icons.history),
                                              SizedBox(width: 8),
                                              Text('Order History'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'wishlist',
                                          child: Row(
                                            children: [
                                              Icon(Icons.favorite),
                                              SizedBox(width: 8),
                                              Text('Wishlist'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'logout',
                                          child: Row(
                                            children: [
                                              Icon(Icons.logout),
                                              SizedBox(width: 8),
                                              Text('Logout'),
                                            ],
                                          ),
                                        ),
                                      ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'profile':
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => ProfileScreen(
                                                  user: widget.user,
                                                ),
                                          ),
                                        );
                                        break;
                                      case 'orders':
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => OrderHistoryScreen(
                                                  user: widget.user,
                                                ),
                                          ),
                                        );
                                        break;
                                      case 'wishlist':
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => WishlistScreen(
                                                  user: widget.user,
                                                ),
                                          ),
                                        );
                                        break;
                                      case 'logout':
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/',
                                        );
                                        break;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'FoodGo',
                          style: TextStyle(
                            fontSize: size.width * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Order your favourite food!',
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF7F8C8D),
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4757),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.tune,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    onChanged: _filterItems,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Categories
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildCategoryChip('All', _selectedCategory == null),
                      ..._categories.map(
                        (category) => _buildCategoryChip(
                          category.name,
                          _selectedCategory?.id == category.id,
                          onTap: () => _filterByCategory(category),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Food Items Grid
          _filteredItems.isEmpty
              ? SliverToBoxAdapter(
                  child: Container(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No food items available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please check if the backend server is running\nand has data in the database',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: size.width > 600 ? 3 : 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = _filteredItems[index];
                      return AnimatedFoodCard(item: item, user: widget.user);
                    }, childCount: _filteredItems.length),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    String label,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => _filterByCategory(null),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4757) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4757) : Colors.grey.shade300,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFFFF4757).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF7F8C8D),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
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
