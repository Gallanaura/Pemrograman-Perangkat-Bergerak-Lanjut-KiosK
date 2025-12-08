import 'package:sqflite/sqflite.dart';
import 'package:kiosk/core/database/database_helper.dart';
import 'package:kiosk/features/home/data/models/drink.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await _dbHelper.database;
    return await db.query('products', orderBy: 'name');
  }

  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    final db = await _dbHelper.database;
    return await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name',
    );
  }

  Future<Map<String, dynamic>?> getProductById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertProduct({
    required String name,
    required int price,
    double rating = 4.0,
    String? imageUrl,
    String category = 'all',
  }) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'products',
      {
        'name': name,
        'price': price,
        'rating': rating,
        'image_url': imageUrl ?? '',
        'category': category,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<int> updateProduct({
    required int id,
    String? name,
    int? price,
    double? rating,
    String? imageUrl,
    String? category,
  }) async {
    final db = await _dbHelper.database;
    final Map<String, dynamic> data = {
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (name != null) data['name'] = name;
    if (price != null) data['price'] = price;
    if (rating != null) data['rating'] = rating;
    if (imageUrl != null) data['image_url'] = imageUrl;
    if (category != null) data['category'] = category;

    return await db.update(
      'products',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  List<Drink> mapToDrinks(List<Map<String, dynamic>> maps) {
    return maps.map((map) {
      return Drink(
        map['name'] as String,
        id: map['id'] as int?,
        price: map['price'] as int,
        rating: (map['rating'] as num).toDouble(),
        imageUrl: map['image_url'] as String?,
        category: map['category'] as String? ?? 'all',
      );
    }).toList();
  }
}

