import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/user.dart';
import 'models/project.dart';
import 'models/cashflow.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'investment_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        passwordHash TEXT NOT NULL,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // РЕГИСТРАЦИЯ
  Future<int> registerUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  // ПРОВЕРКА EMAIL
  Future<bool> isEmailExists(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // ВХОД
  Future<User?> loginUser(String email, String passwordHash) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND passwordHash = ?',
      whereArgs: [email, passwordHash],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // ПОЛУЧИТЬ ВСЕХ ПОЛЬЗОВАТЕЛЕЙ
  Future<List<User>> getAllUsers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }
}