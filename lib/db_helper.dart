import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await DBHelper.database;
    return await db.query('users');
  }

  static Future<List<Map<String, dynamic>>> getAllOrder() async {
    final db = await DBHelper.database;
    return await db.query('orders');
  }

  static Future<void> updateOrderQuantity(int orderId, int newQuantity) async {
    final db = await database;
    await db.update(
      'orders',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  static Future<void> updateOrderStatus(int orderId, String newStatus) async {
    final db = await DBHelper.database;
    await db.update(
      'orders',
      {'status': newStatus},
      where: 'id=?',
      whereArgs: [orderId],
    );
  }

  static Future<List<Map<String, dynamic>>> getAllOrdersWithUsers() async {
    final db = await database;
    return await db.rawQuery('''
    SELECT orders.id, orders.mealName, orders.quantity, orders.status,
           orders.userId, users.username
    FROM orders
    INNER JOIN users ON orders.userId = users.id
  ''');
  }

  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'orders.db');
    return await openDatabase(path, version: 4, // زوّد الرقم إلى 3 أو أعلى
        onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE orders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customerName TEXT,
          mealName TEXT,
          notes TEXT,
          status TEXT,
          dateTime TEXT,
          quantity INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT,
          password TEXT,
          role TEXT
        )
      ''');
      await db.execute('ALTER TABLE orders ADD COLUMN userId INTEGER');

      await db.insert('users', {
        'username': 'admin',
        'password': 'admin123',
        'role': 'admin',
      });
    }, onUpgrade: (db, oldVersion, newVersion) async {
      await db.execute('DROP TABLE IF EXISTS orders');
      await db.execute('DROP TABLE IF EXISTS users');

      await db.execute('''
    CREATE TABLE orders(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customerName TEXT,
      mealName TEXT,
      notes TEXT,
      status TEXT,
      dateTime TEXT,
      quantity INTEGER,
      userId INTEGER
    )
  ''');

      await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT,
      password TEXT,
      role TEXT
    )
  ''');

      await db.insert('users', {
        'username': 'admin',
        'password': 'admin123',
        'role': 'admin',
      });
    }

        // ✅ يحذف الجداول القديمة إذا رفعنا النسخة
        // onUpgrade: (db, oldVersion, newVersion) async {
        //   await db.execute('DROP TABLE IF EXISTS orders');
        //   await db.execute('DROP TABLE IF EXISTS users');

        //   await db.execute('''
        //   CREATE TABLE orders(
        //     id INTEGER PRIMARY KEY AUTOINCREMENT,
        //     customerName TEXT,
        //     mealName TEXT,
        //     notes TEXT,
        //     status TEXT,
        //     dateTime TEXT,
        //     quantity INTEGER
        //   )
        // ''');

        //   await db.execute('''
        //   CREATE TABLE users(
        //     id INTEGER PRIMARY KEY AUTOINCREMENT,
        //     username TEXT,
        //     password TEXT,
        //     role TEXT
        //   )
        // ''');

        //   await db.insert('users', {
        //     'username': 'admin',
        //     'password': 'admin123',
        //     'role': 'admin',
        //   });
        // },
        );
  }
}
