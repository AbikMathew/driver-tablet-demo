import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// 🎯 **Offline Cache Service**
/// Comprehensive caching system for maps tiles, TTS audio, and route data
class OfflineCacheService {
  static final OfflineCacheService _instance = OfflineCacheService._internal();
  factory OfflineCacheService() => _instance;
  OfflineCacheService._internal();

  Database? _database;
  Directory? _cacheDirectory;
  bool _isInitialized = false;

  /// 🎯 **Public Getters**
  Database? get database => _database;
  Directory? get cacheDirectory => _cacheDirectory;
  bool get isInitialized => _isInitialized;

  /// 🎯 **Cache Statistics**
  Map<String, int> _cacheStats = {
    'tiles': 0,
    'tts': 0,
    'routes': 0,
    'totalSize': 0,
  };

  Map<String, int> get cacheStats => Map.from(_cacheStats);

  /// 🎯 **Initialize Cache System**
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize cache directory
      _cacheDirectory = await _initializeCacheDirectory();

      // Initialize database
      _database = await _initializeDatabase();

      // Load cache statistics
      await loadCacheStatistics();

      _isInitialized = true;
      debugPrint('✅ Offline Cache Service initialized');
      debugPrint('📊 Cache Stats: $_cacheStats');
    } catch (e) {
      debugPrint('❌ Cache initialization failed: $e');
      rethrow;
    }
  }

  /// 🎯 **Initialize Cache Directory**
  Future<Directory> _initializeCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(path.join(appDir.path, 'offline_cache'));

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    // Create subdirectories
    final subDirs = ['tiles', 'tts', 'routes'];
    for (final subDir in subDirs) {
      final dir = Directory(path.join(cacheDir.path, subDir));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }

    return cacheDir;
  }

  /// 🎯 **Initialize Database**
  Future<Database> _initializeDatabase() async {
    final dbPath = path.join(_cacheDirectory!.path, 'cache.db');

    return await openDatabase(dbPath, version: 1, onCreate: _createTables);
  }

  /// 🎯 **Create Database Tables**
  Future<void> _createTables(Database db, int version) async {
    // Tiles cache table
    await db.execute('''
      CREATE TABLE tiles_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tile_key TEXT UNIQUE NOT NULL,
        url TEXT NOT NULL,
        file_path TEXT NOT NULL,
        zoom_level INTEGER NOT NULL,
        x_coord INTEGER NOT NULL,
        y_coord INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        accessed_at INTEGER NOT NULL,
        size_bytes INTEGER NOT NULL
      )
    ''');

    // TTS cache table
    await db.execute('''
      CREATE TABLE tts_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text_hash TEXT UNIQUE NOT NULL,
        text_content TEXT NOT NULL,
        file_path TEXT NOT NULL,
        language TEXT NOT NULL,
        voice TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        accessed_at INTEGER NOT NULL,
        size_bytes INTEGER NOT NULL
      )
    ''');

    // Routes cache table
    await db.execute('''
      CREATE TABLE routes_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        route_key TEXT UNIQUE NOT NULL,
        departure_lat REAL NOT NULL,
        departure_lng REAL NOT NULL,
        destination_lat REAL NOT NULL,
        destination_lng REAL NOT NULL,
        route_data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        accessed_at INTEGER NOT NULL,
        size_bytes INTEGER NOT NULL
      )
    ''');

    // Cache metadata table
    await db.execute('''
      CREATE TABLE cache_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    debugPrint('✅ Cache database tables created');
  }

  /// 🎯 **Load Cache Statistics**
  Future<void> loadCacheStatistics() async {
    if (_database == null) return;

    try {
      // Count tiles
      final tilesCount =
          Sqflite.firstIntValue(
            await _database!.rawQuery('SELECT COUNT(*) FROM tiles_cache'),
          ) ??
          0;

      // Count TTS files
      final ttsCount =
          Sqflite.firstIntValue(
            await _database!.rawQuery('SELECT COUNT(*) FROM tts_cache'),
          ) ??
          0;

      // Count routes
      final routesCount =
          Sqflite.firstIntValue(
            await _database!.rawQuery('SELECT COUNT(*) FROM routes_cache'),
          ) ??
          0;

      // Calculate total size
      final tilesSize =
          Sqflite.firstIntValue(
            await _database!.rawQuery(
              'SELECT SUM(size_bytes) FROM tiles_cache',
            ),
          ) ??
          0;

      final ttsSize =
          Sqflite.firstIntValue(
            await _database!.rawQuery('SELECT SUM(size_bytes) FROM tts_cache'),
          ) ??
          0;

      final routesSize =
          Sqflite.firstIntValue(
            await _database!.rawQuery(
              'SELECT SUM(size_bytes) FROM routes_cache',
            ),
          ) ??
          0;

      _cacheStats = {
        'tiles': tilesCount,
        'tts': ttsCount,
        'routes': routesCount,
        'totalSize': tilesSize + ttsSize + routesSize,
      };
    } catch (e) {
      debugPrint('❌ Failed to load cache statistics: $e');
    }
  }

  /// 🎯 **Generate Cache Key**
  String _generateCacheKey(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 🎯 **Get File Size**
  Future<int> _getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      debugPrint('❌ Failed to get file size: $e');
    }
    return 0;
  }

  /// 🎯 **Update Access Time**
  Future<void> _updateAccessTime(
    String table,
    String keyColumn,
    String key,
  ) async {
    if (_database == null) return;

    try {
      await _database!.update(
        table,
        {'accessed_at': DateTime.now().millisecondsSinceEpoch},
        where: '$keyColumn = ?',
        whereArgs: [key],
      );
    } catch (e) {
      debugPrint('❌ Failed to update access time: $e');
    }
  }

  /// 🎯 **Cleanup Old Cache Entries**
  Future<void> cleanupOldEntries({
    Duration maxAge = const Duration(days: 30),
    int maxEntries = 10000,
  }) async {
    if (_database == null) return;

    try {
      final cutoffTime = DateTime.now().subtract(maxAge).millisecondsSinceEpoch;

      // Clean up old tiles
      await _database!.delete(
        'tiles_cache',
        where: 'accessed_at < ?',
        whereArgs: [cutoffTime],
      );

      // Clean up old TTS files
      await _database!.delete(
        'tts_cache',
        where: 'accessed_at < ?',
        whereArgs: [cutoffTime],
      );

      // Clean up old routes
      await _database!.delete(
        'routes_cache',
        where: 'accessed_at < ?',
        whereArgs: [cutoffTime],
      );

      // Remove excess entries if too many
      await _cleanupExcessEntries('tiles_cache', maxEntries);
      await _cleanupExcessEntries('tts_cache', maxEntries);
      await _cleanupExcessEntries('routes_cache', maxEntries);

      await loadCacheStatistics();
      debugPrint('✅ Cache cleanup completed');
    } catch (e) {
      debugPrint('❌ Cache cleanup failed: $e');
    }
  }

  /// 🎯 **Cleanup Excess Entries**
  Future<void> _cleanupExcessEntries(String table, int maxEntries) async {
    if (_database == null) return;

    try {
      final count =
          Sqflite.firstIntValue(
            await _database!.rawQuery('SELECT COUNT(*) FROM $table'),
          ) ??
          0;

      if (count > maxEntries) {
        final excessCount = count - maxEntries;
        await _database!.rawDelete(
          '''
          DELETE FROM $table 
          WHERE id IN (
            SELECT id FROM $table 
            ORDER BY accessed_at ASC 
            LIMIT ?
          )
        ''',
          [excessCount],
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to cleanup excess entries: $e');
    }
  }

  /// 🎯 **Clear All Cache**
  Future<void> clearAllCache() async {
    if (_database == null) return;

    try {
      await _database!.delete('tiles_cache');
      await _database!.delete('tts_cache');
      await _database!.delete('routes_cache');

      // Delete cache files
      if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
        await _cacheDirectory!.delete(recursive: true);
        await _initializeCacheDirectory();
      }

      await loadCacheStatistics();
      debugPrint('✅ All cache cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear cache: $e');
    }
  }

  /// 🎯 **Get Cache Size in Human Readable Format**
  String getFormattedCacheSize() {
    final bytes = _cacheStats['totalSize'] ?? 0;

    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// 🎯 **Dispose Resources**
  Future<void> dispose() async {
    try {
      await _database?.close();
      _database = null;
      _isInitialized = false;
      debugPrint('✅ Cache service disposed');
    } catch (e) {
      debugPrint('❌ Failed to dispose cache service: $e');
    }
  }
}

/// 🎯 **Cache Entry Model**
class CacheEntry {
  final String key;
  final String filePath;
  final DateTime createdAt;
  final DateTime accessedAt;
  final int sizeBytes;

  const CacheEntry({
    required this.key,
    required this.filePath,
    required this.createdAt,
    required this.accessedAt,
    required this.sizeBytes,
  });

  factory CacheEntry.fromMap(Map<String, dynamic> map) {
    return CacheEntry(
      key: map['tile_key'] ?? map['text_hash'] ?? map['route_key'] ?? '',
      filePath: map['file_path'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] ?? 0),
      accessedAt: DateTime.fromMillisecondsSinceEpoch(map['accessed_at'] ?? 0),
      sizeBytes: map['size_bytes'] ?? 0,
    );
  }
}
