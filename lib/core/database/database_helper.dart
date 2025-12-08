import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide openDatabase, getDatabasesPath;

// Conditional imports for mobile vs desktop
import 'database_stub.dart'
    if (dart.library.io) 'database_io.dart'
    if (dart.library.html) 'database_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDB('kiosk.db');
      // Ensure default users exist after database is created
      await _ensureDefaultUsers();
      return _database!;
    } catch (e) {
      print('Database initialization error: $e');
      rethrow;
    }
  }

  Future<void> _ensureDefaultUsers() async {
    if (_database == null) {
      print('Database is null, cannot ensure default users');
      return;
    }
    
    try {
      print('Checking default users...');
      
      // Check if admin exists
      final adminCheck = await _database!.query(
        'users',
        where: 'username = ?',
        whereArgs: ['admin'],
        limit: 1,
      );
      
      // Check if user exists
      final userCheck = await _database!.query(
        'users',
        where: 'username = ?',
        whereArgs: ['user'],
        limit: 1,
      );
      
      print('Admin exists: ${adminCheck.isNotEmpty}');
      print('User exists: ${userCheck.isNotEmpty}');
      
      final now = DateTime.now().toIso8601String();
      
      // Insert admin if doesn't exist
      if (adminCheck.isEmpty) {
        print('Inserting admin user...');
        await _database!.insert(
          'users',
          {
            'username': 'admin',
            'email': 'admin@kiosk.com',
            'password': 'admin123',
            'phone': '',
            'created_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        print('Admin user inserted');
      }
      
      // Insert user if doesn't exist
      if (userCheck.isEmpty) {
        print('Inserting regular user...');
        await _database!.insert(
          'users',
          {
            'username': 'user',
            'email': 'user@kiosk.com',
            'password': 'user123',
            'phone': '081234567890',
            'created_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        print('Regular user inserted');
      }
      
      // Verify all users
      final allUsers = await _database!.query('users');
      print('Total users after ensuring defaults: ${allUsers.length}');
      for (var user in allUsers) {
        print('  - ${user['username']} (${user['email']})');
      }
    } catch (e) {
      print('Error ensuring default users: $e');
    }
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      // Create databases directory if it doesn't exist (for desktop)
      // Skip for web platform
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        final dir = Directory(dbPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      }
      final path = kIsWeb ? filePath : join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 2,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
        singleInstance: true,
      );
    } catch (e) {
      print('Database init error: $e');
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        phone TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        rating REAL DEFAULT 4.0,
        image_url TEXT,
        category TEXT DEFAULT 'all',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        table_number TEXT,
        notes TEXT,
        total_price INTEGER NOT NULL,
        payment_method TEXT,
        status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Order items table
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price INTEGER NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Promos table
    await db.execute('''
      CREATE TABLE promos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        discount TEXT NOT NULL,
        description TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Create indexes for faster queries
    await db.execute('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id)');

    // Insert default data using batch for better performance
    final batch = db.batch();
    _insertDefaultProductsBatch(batch);
    _insertDefaultPromosBatch(batch);
    _insertDefaultAdminBatch(batch);
    await batch.commit(noResult: true);
  }

  void _insertDefaultAdminBatch(Batch batch) {
    final now = DateTime.now().toIso8601String();
    
    // Insert default admin user
    batch.insert(
      'users',
      {
        'username': 'admin',
        'email': 'admin@kiosk.com',
        'password': 'admin123',
        'phone': '',
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    
    // Insert default regular user for testing
    batch.insert(
      'users',
      {
        'username': 'user',
        'email': 'user@kiosk.com',
        'password': 'user123',
        'phone': '081234567890',
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  void _insertDefaultProductsBatch(Batch batch) {
    final products = [
      {'name': 'Dark Korawa', 'price': 20000, 'rating': 4.5, 'category': 'recommended'},
      {'name': 'Merseyside', 'price': 15000, 'rating': 4.0, 'category': 'recommended'},
      {'name': 'Savaya', 'price': 15000, 'rating': 4.2, 'category': 'all'},
      {'name': 'Taro', 'price': 15000, 'rating': 4.3, 'category': 'recommended'},
    ];

    final now = DateTime.now().toIso8601String();
    
    for (var product in products) {
      batch.insert(
        'products',
        {
          'name': product['name'],
          'price': product['price'],
          'rating': product['rating'],
          'category': product['category'],
          'created_at': now,
          'updated_at': now,
        },
      );
    }
  }

  void _insertDefaultPromosBatch(Batch batch) {
    final promos = [
      {
        'title': 'Special Discount',
        'discount': '30%',
        'description': 'Get up to 30% off on all drinks',
      },
      {
        'title': 'Buy 2 Get 1 Free',
        'discount': 'FREE',
        'description': 'Buy any 2 drinks and get 1 free',
      },
      {
        'title': 'Weekend Special',
        'discount': '25%',
        'description': 'Enjoy 25% discount every weekend',
      },
      {
        'title': 'Student Discount',
        'discount': '15%',
        'description': 'Show your student ID and get 15% off',
      },
    ];

    final now = DateTime.now().toIso8601String();
    
    for (var promo in promos) {
      batch.insert(
        'promos',
        {
          'title': promo['title'],
          'discount': promo['discount'],
          'description': promo['description'],
          'is_active': 1,
          'created_at': now,
        },
      );
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add category column to products table
      try {
        await db.execute('ALTER TABLE products ADD COLUMN category TEXT DEFAULT \'all\'');
        print('Database upgraded: Added category column');
      } catch (e) {
        // Column might already exist
        print('Upgrade note: $e');
      }
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}

