import 'package:sqflite/sqflite.dart';
import 'package:kiosk/core/database/database_helper.dart';

class OrderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> createOrder({
    required int userId,
    required int totalPrice,
    String? tableNumber,
    String? notes,
    String? paymentMethod,
    String status = 'completed',
  }) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'orders',
      {
        'user_id': userId,
        'table_number': tableNumber ?? '',
        'notes': notes ?? '',
        'total_price': totalPrice,
        'payment_method': paymentMethod ?? '',
        'status': status,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<int> updateOrderStatus(int orderId, String status) async {
    final db = await _dbHelper.database;
    return await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> createOrderItems({
    required int orderId,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var item in items) {
      batch.insert(
        'order_items',
        {
          'order_id': orderId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'price': item['price'],
        },
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getOrdersByUserId(int userId) async {
    final db = await _dbHelper.database;
    return await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await _dbHelper.database;
    return await db.query(
      'orders',
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    final db = await _dbHelper.database;
    return await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  // Sales statistics
  Future<Map<String, dynamic>> getWeeklySales() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final result = await db.rawQuery('''
      SELECT 
        SUM(total_price) as total_sales,
        COUNT(*) as total_orders
      FROM orders
      WHERE created_at >= ? AND status = 'completed'
    ''', [weekAgo.toIso8601String()]);

    return result.first;
  }

  Future<Map<String, dynamic>> getMonthlySales() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    final result = await db.rawQuery('''
      SELECT 
        SUM(total_price) as total_sales,
        COUNT(*) as total_orders
      FROM orders
      WHERE created_at >= ? AND status = 'completed'
    ''', [monthAgo.toIso8601String()]);

    return result.first;
  }

  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 10}) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        p.id,
        p.name,
        SUM(oi.quantity) as total_quantity,
        SUM(oi.price * oi.quantity) as total_revenue
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      JOIN orders o ON oi.order_id = o.id
      WHERE o.status = 'completed'
      GROUP BY p.id, p.name
      ORDER BY total_quantity DESC
      LIMIT ?
    ''', [limit]);
  }
}

