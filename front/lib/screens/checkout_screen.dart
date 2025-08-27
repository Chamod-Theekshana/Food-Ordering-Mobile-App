import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  final User user;

  const CheckoutScreen({super.key, required this.user});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _orderType = 'DELIVERY';
  String _paymentMethod = 'COD';
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Type
                const Text('Order Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Delivery'),
                        value: 'DELIVERY',
                        groupValue: _orderType,
                        onChanged: (value) => setState(() => _orderType = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Takeaway'),
                        value: 'TAKEAWAY',
                        groupValue: _orderType,
                        onChanged: (value) => setState(() => _orderType = value!),
                      ),
                    ),
                  ],
                ),
                
                // Delivery Address (if delivery)
                if (_orderType == 'DELIVERY') ...[
                  const SizedBox(height: 16),
                  const Text('Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your delivery address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
                
                const SizedBox(height: 16),
                // Payment Method
                const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Cash on Delivery'),
                      subtitle: const Text('Pay when your order arrives'),
                      value: 'COD',
                      groupValue: _paymentMethod,
                      onChanged: (value) => setState(() => _paymentMethod = value!),
                    ),
                    RadioListTile<String>(
                      title: const Text('Online Payment'),
                      subtitle: const Text('Pay now with card/wallet'),
                      value: 'ONLINE',
                      groupValue: _paymentMethod,
                      onChanged: (value) => setState(() => _paymentMethod = value!),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                // Special Notes
                const Text('Special Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    hintText: 'Any special instructions for your order...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                
                const SizedBox(height: 24),
                // Order Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...cart.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text('${item.foodItem.name} x${item.quantity}')),
                              Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                            ],
                          ),
                        )),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:'),
                            Text('\$${cart.subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        if (cart.discountAmount > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Discount:', style: TextStyle(color: Colors.green)),
                              Text('-\$${cart.discountAmount.toStringAsFixed(2)}', 
                                   style: const TextStyle(color: Colors.green)),
                            ],
                          ),
                        ],
                        if (_orderType == 'DELIVERY') ...[
                          const SizedBox(height: 4),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Delivery Fee:'),
                              Text('\$2.99'),
                            ],
                          ),
                        ],
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                              '\$${(_orderType == 'DELIVERY' ? cart.total + 2.99 : cart.total).toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _placeOrder,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Place Order'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _placeOrder() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    
    if (_orderType == 'DELIVERY' && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final items = cart.items.map((item) => {
      'foodItem': {'id': item.foodItem.id},
      'quantity': item.quantity,
      'price': item.foodItem.price,
    }).toList();

    final success = await ApiService.createOrder(
      widget.user.id,
      items,
      orderType: _orderType,
      paymentMethod: _paymentMethod,
      address: _orderType == 'DELIVERY' ? _addressController.text.trim() : null,
    );

    setState(() => _isLoading = false);

    if (success) {
      cart.clear();
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}