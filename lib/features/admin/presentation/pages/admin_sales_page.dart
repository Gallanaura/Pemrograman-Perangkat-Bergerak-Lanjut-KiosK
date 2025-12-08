import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';
import 'package:kiosk/features/home/data/repositories/order_repository.dart';
import 'package:intl/intl.dart';

class AdminSalesPage extends StatefulWidget {
  const AdminSalesPage({super.key});

  @override
  State<AdminSalesPage> createState() => _AdminSalesPageState();
}

class _AdminSalesPageState extends State<AdminSalesPage> {
  final OrderRepository _orderRepository = OrderRepository();
  Map<String, dynamic> _weeklySales = {};
  Map<String, dynamic> _monthlySales = {};
  List<Map<String, dynamic>> _topProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSalesData();
  }

  Future<void> _loadSalesData() async {
    setState(() {
      _isLoading = true;
    });

    final weekly = await _orderRepository.getWeeklySales();
    final monthly = await _orderRepository.getMonthlySales();
    final topProducts = await _orderRepository.getTopProducts();

    setState(() {
      _weeklySales = weekly;
      _monthlySales = monthly;
      _topProducts = topProducts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weekly Sales Card
                Card(
                  color: AppColors.brandBrown,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Weekly Sales',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currencyFormat.format(
                            (_weeklySales['total_sales'] as num?)?.toInt() ?? 0,
                          ),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_weeklySales['total_orders'] ?? 0} orders',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Monthly Sales Card
                Card(
                  color: Colors.blue[600],
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Monthly Sales',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currencyFormat.format(
                            (_monthlySales['total_sales'] as num?)?.toInt() ?? 0,
                          ),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_monthlySales['total_orders'] ?? 0} orders',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Top Products
                Text(
                  'Top Products',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ..._topProducts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final product = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.brandBrown.withOpacity(0.2),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: AppColors.brandBrown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        product['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Sold: ${product['total_quantity']} units',
                      ),
                      trailing: Text(
                        currencyFormat.format(
                          (product['total_revenue'] as num?)?.toInt() ?? 0,
                        ),
                        style: TextStyle(
                          color: AppColors.brandBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
                if (_topProducts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No sales data yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
              ],
            ),
          );
  }
}

