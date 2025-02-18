import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:track_eet/models/media_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('media_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE media_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        author TEXT,
        rating REAL,
        type TEXT,
        imagePath TEXT,
        startedAt TEXT NOT NULL,   
        endedAt TEXT 
      )
    ''');
  }

  Future<MediaItem> create(MediaItem mediaItem) async {
    final db = await instance.database;
    final id = await db.insert('media_items', mediaItem.toMap());
    return mediaItem.copyWith(id: id);
  }

  Future<MediaItem?> readMediaItem(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'media_items',
      columns: null,
      where: 'id = ?',
      whereArgs: [id],
    );

    return maps.isNotEmpty ? MediaItem.fromMap(maps.first) : null;
  }

  Future<List<MediaItem>> readAllMediaItems() async {
    final db = await instance.database;
    final result = await db.query('media_items');
    return result.map((json) => MediaItem.fromMap(json)).toList();
  }

  Future<int> update(MediaItem mediaItem) async {
    final db = await instance.database;
    return db.update(
      'media_items',
      mediaItem.toMap(),
      where: 'id = ?',
      whereArgs: [mediaItem.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'media_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}