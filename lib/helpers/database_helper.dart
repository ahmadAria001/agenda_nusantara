import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user.dart';
import '../models/task.dart';
import '../utils/password_hasher.dart';

/// Singleton helper that manages the local SQLite database connection.
///
/// This class is strictly offline — no API calls, Firebase, or external
/// network requests are made.
class DatabaseHelper {
  // ── Singleton ──────────────────────────────────────────────────────────
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  static Database? _database;

  /// Returns the cached [Database] instance, initialising it on first access.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // ── Initialisation ────────────────────────────────────────────────────
  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/agenda_nusantara.db';

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Handles schema migrations.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE tasks ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0'
      );
    }
  }

  /// Creates the schema and seeds default data on first run.
  Future<void> _onCreate(Database db, int version) async {
    // ── Users table ───────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE users (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT    NOT NULL,
        password TEXT    NOT NULL
      )
    ''');

    // ── Tasks table ───────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE tasks (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        title        TEXT    NOT NULL,
        description  TEXT,
        due_date     TEXT,
        category     TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        is_deleted   INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── Seed default user ─────────────────────────────────────────────
    final hasher = PasswordHasher();
    final hashedPassword = await hasher.hashPassword('user');
    
    await db.insert('users', {
      'username': 'user',
      'password': hashedPassword,
    });
  }

  // ── User Operations ───────────────────────────────────────────────────

  /// Fetches a user by [username].
  /// Returns the [User] or `null` if not found.
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (results.isEmpty) return null;
    return User.fromMap(results.first);
  }

  /// Updates the password for the user with the given [username].
  /// Returns the number of rows affected (1 on success, 0 if not found).
  Future<int> updatePassword(String username, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // ── Task CRUD ─────────────────────────────────────────────────────────

  /// Inserts a new task and returns its auto-generated id.
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  /// Returns every active task in the database, ordered by most recent first.
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final results = await db.query(
      'tasks',
      where: 'is_deleted = 0',
      orderBy: 'id DESC',
    );
    return results.map(Task.fromMap).toList();
  }

  /// Returns a single active task by its [id], or `null` if not found.
  Future<Task?> getTaskById(int id) async {
    final db = await database;
    final results = await db.query(
      'tasks',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return Task.fromMap(results.first);
  }

  /// Updates an existing task. Returns the number of rows affected.
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Deletes a task by its [id]. Returns the number of rows affected.
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Toggles the completion status of a task.
  Future<int> toggleTaskCompletion(int id, bool isCompleted) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Returns active tasks filtered by [category] ('penting' or 'biasa').
  Future<List<Task>> getTasksByCategory(String category) async {
    final db = await database;
    final results = await db.query(
      'tasks',
      where: 'category = ? AND is_deleted = 0',
      whereArgs: [category],
      orderBy: 'due_date IS NULL ASC, due_date ASC',
    );
    return results.map(Task.fromMap).toList();
  }
}
