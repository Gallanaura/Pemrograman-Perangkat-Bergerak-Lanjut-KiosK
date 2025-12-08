import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';
import 'package:kiosk/features/home/data/repositories/order_repository.dart';
import 'package:kiosk/features/home/data/repositories/product_repository.dart';
import 'package:intl/intl.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final OrderRepository _orderRepository = OrderRepository();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    final orders = await _orderRepository.getAllOrders();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  Future<void> _showOrderDetails(int orderId) async {
    final items = await _orderRepository.getOrderItems(orderId);
    final order = _orders.firstWhere((o) => o['id'] == orderId);

    if (!mounted) return;

    // Get product names for order items
    final productRepository = ProductRepository();
    final allProducts = await productRepository.getAllProducts();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Order Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brandBrown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Table Number', order['table_number']?.toString() ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Payment Method', order['payment_method']?.toString() ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Status', order['status']?.toString() ?? 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Notes
              if (order['notes'] != null && (order['notes'] as String).isNotEmpty) ...[
                const Text(
                  'Notes / Catatan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    order['notes'] as String,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Order Items
              const Text(
                'Order Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...items.map((item) {
                final product = allProducts.firstWhere(
                  (p) => p['id'] == item['product_id'],
                  orElse: () => <String, dynamic>{'name': 'Unknown Product'},
                );
                final subtotal = (item['price'] as int) * (item['quantity'] as int);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item['quantity']}x ${product['name']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        'Rp ${subtotal.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]}.',
                            )}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 24),
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Rp ${(order['total_price'] as int).toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]}.',
                        )}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.brandBrown,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (order['status'] == 'pending') ...[
            TextButton(
              onPressed: () async {
                await _orderRepository.updateOrderStatus(orderId, 'completed');
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadOrders();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order berhasil di-approve!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text(
                'Approve Order',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Orders',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadOrders,
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                  ? Center(
                      child: Text(
                        'No orders yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final date = DateTime.parse(order['created_at'] as String);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.brandBrown.withOpacity(0.2),
                              child: Text(
                                '#${order['id']}',
                                style: const TextStyle(
                                  color: AppColors.brandBrown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              'Order #${order['id']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dateFormat.format(date)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.table_restaurant, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Table: ${order['table_number'] == null || (order['table_number'] as String).isEmpty ? 'N/A' : order['table_number']}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                if (order['payment_method'] != null && (order['payment_method'] as String).isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.payment, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Payment: ${order['payment_method']}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                                if (order['notes'] != null && (order['notes'] as String).isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.note, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Notes: ${order['notes']}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rp ${(order['total_price'] as int).toString().replaceAllMapped(
                                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                        (Match m) => '${m[1]}.',
                                      )}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.brandBrown,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: order['status'] == 'completed'
                                        ? Colors.green
                                        : order['status'] == 'pending'
                                            ? Colors.orange
                                            : Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    (order['status'] as String).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _showOrderDetails(order['id'] as int),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

