// lib/services/local_db_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/event.dart';

class LocalDbService {
  static Database? _database;

  /// Uygulama açılırken çağrılacak
  static Future<LocalDbService> getInstance() async {
    final service = LocalDbService();
    await service._initDb();
    return service;
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      join(dbPath, 'dayanisma.db'),
      version: 2,
      onCreate: (db, version) async {
        // users tablosu
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');
        // events tablosu
        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            date TEXT,
            location TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // v1 → v2 geçişinde events tablosunu ekle
          await db.execute('''
            CREATE TABLE events (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              description TEXT,
              date TEXT,
              location TEXT
            )
          ''');
        }
      },
    );
  }

  Database get db {
    if (_database == null) {
      throw Exception('Database not initialized!');
    }
    return _database!;
  }

  /// Yeni bir etkinlik ekle
  Future<int> insertEvent(Event event) async {
    return await db.insert('events', event.toMap());
  }

  /// Tüm etkinlikleri getir
  Future<List<Event>> getAllEvents() async {
    final maps = await db.query('events', orderBy: 'date DESC');
    return maps.map((m) => Event.fromMap(m)).toList();
  }

  /// Var olan bir etkinliği güncelle
  Future<int> updateEvent(Event event) async {
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  /// Bir etkinliği sil
  Future<int> deleteEvent(int id) async {
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}
