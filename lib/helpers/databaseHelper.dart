import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mobile_proj/models/userProfile.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'app_database.db');

    return await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE all_users_table (
          id TEXT PRIMARY KEY ,
          fullName TEXT,
          email TEXT,
          phoneNumber TEXT,
          userType TEXT
        )
      ''');
    });
  }

  Future<void> insertUserProfile(UserProfile userProfile) async {
    try {
      UserProfile? existingProfile = await getUserProfile(userProfile.id);
      if (existingProfile == null) {
        await _database?.insert(
          'all_users_table',
          userProfile.toMap(), // Assuming toMap() converts UserProfile to a map
          conflictAlgorithm: ConflictAlgorithm.replace, // Use replace to update if a conflict occurs
        );
      } else {
        print('Profile with ID ${userProfile.id} already exists.');
      }
    } catch (e) {
      print('Error inserting user profile: $e');
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('all_users_table', where: 'id = ?', whereArgs: [uid]);

    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }

    return null;
  }

}
