import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  final User user;

  const OrderHistoryScreen({super.key, required this.user});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await ApiService.getUserOrders(widget.user.id);
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 100, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No orders yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Your order history will appear here', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ExpansionTile(
                          title: Text('Order #${order['id']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status: ${order['status']}'),
                              Text('Total: \$${order['totalAmount'].toStringAsFixed(2)}'),
                              Text('Date: ${_formatDate(order['createdAt'])}'),
                            ],
                          ),
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(order['status']),
                            child: Icon(
                              _getStatusIcon(order['status']),
                              color: Colors.white,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Order Items:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ...List.generate(
                                    order['items'].length,
                                    (itemIndex) {
                                      final item = order['items'][itemIndex];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${item['foodItem']['name']} x${item['quantity']}',
                                              ),
                                            ),
                                            Text('\$${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Order Type:'),
                                      Text(order['orderType'] ?? 'DELIVERY'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Payment:'),
                                      Text(order['paymentMethod'] ?? 'COD'),
                                    ],
                                  ),
                                  if (order['deliveryAddress'] != null) ...[
                                    const SizedBox(height: 8),
                                    const Text('Delivery Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(order['deliveryAddress']),
                                  ],
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _reorder(order),
                                          child: const Text('Reorder'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _trackOrder(order),
                                          child: const Text('Track Order'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule;
      case 'CONFIRMED':
        return Icons.check_circle;
      case 'PREPARING':
        return Icons.restaurant;
      case 'READY':
        return Icons.done_all;
      case 'DELIVERED':
        return Icons.delivery_dining;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _reorder(dynamic order) {
    // TODO: Implement reorder functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Items added to cart for reorder!')),
    );
  }

  void _trackOrder(dynamic order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order['id']} Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTrackingStep('Order Placed', true),
            _buildTrackingStep('Confirmed', order['status'] != 'PENDING'),
            _buildTrackingStep('Preparing', ['PREPARING', 'READY', 'DELIVERED'].contains(order['status'])),
            _buildTrackingStep('Ready', ['READY', 'DELIVERED'].contains(order['status'])),
            _buildTrackingStep('Delivered', order['status'] == 'DELIVERED'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(String title, bool isCompleted) {
    return Row(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isCompleted ? Colors.green : Colors.grey,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}