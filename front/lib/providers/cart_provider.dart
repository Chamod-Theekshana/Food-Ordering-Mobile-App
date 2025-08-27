import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';
import '../models/coupon.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  Coupon? _appliedCoupon;

  List<CartItem> get items => _items;
  Coupon? get appliedCoupon => _appliedCoupon;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get discountAmount {
    if (_appliedCoupon == null) return 0;
    
    if (_appliedCoupon!.discountAmount != null) {
      return _appliedCoupon!.discountAmount!;
    } else if (_appliedCoupon!.discountPercentage != null) {
      return subtotal * (_appliedCoupon!.discountPercentage! / 100);
    }
    return 0;
  }

  double get total => subtotal - discountAmount;

  void addItem(FoodItem foodItem) {
    final existingIndex = _items.indexWhere((item) => item.foodItem.id == foodItem.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex].incrementQuantity();
    } else {
      _items.add(CartItem(foodItem: foodItem));
    }
    notifyListeners();
  }

  void removeItem(int foodItemId) {
    _items.removeWhere((item) => item.foodItem.id == foodItemId);
    notifyListeners();
  }

  void updateQuantity(int foodItemId, int quantity) {
    final index = _items.indexWhere((item) => item.foodItem.id == foodItemId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void applyCoupon(Coupon coupon) {
    _appliedCoupon = coupon;
    notifyListeners();
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _appliedCoupon = null;
    notifyListeners();
  }
}