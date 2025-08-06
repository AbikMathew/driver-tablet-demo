import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../services/offline_cache_service.dart';

/// 🎯 **TTS Cache Service**
/// Handles offline caching of TTS audio for navigation instructions
class TTSCacheService {
  static final TTSCacheService _instance = TTSCacheService._internal();
  factory TTSCacheService() => _instance;
  TTSCacheService._internal();

  final OfflineCacheService _cacheService = OfflineCacheService();
  final FlutterTts _flutterTts = FlutterTts();

  /// 🎯 **Common Navigation Instructions for Pre-caching**
  static const List<String> commonNavigationInstructions = [
    // Turn instructions
    'Turn left',
    'Turn right',
    'Turn left onto Main Street',
    'Turn right onto First Avenue',
    'Continue straight',
    'Make a U-turn',
    'Keep left',
    'Keep right',

    // Distance callouts
    'In 100 meters, turn left',
    'In 200 meters, turn right',
    'In 500 meters, turn left',
    'In 1 kilometer, turn right',
    'In 100 feet, turn left',
    'In 500 feet, turn right',

    // Highway instructions
    'Take the exit',
    'Merge onto the highway',
    'Exit the highway',
    'Enter the roundabout',
    'Exit the roundabout',

    // Arrival instructions
    'You have arrived at your destination',
    'Your destination is on the left',
    'Your destination is on the right',
    'Destination reached',

    // Traffic and alerts
    'Traffic ahead',
    'Speed camera ahead',
    'School zone ahead',
    'Construction zone ahead',
    'Slow down',
    'Speed limit 50 kilometers per hour',

    // Route recalculation
    'Recalculating route',
    'Route updated',
    'Please make a U-turn when possible',
    'GPS signal lost',
    'GPS signal restored',
  ];

  /// 🎯 **Generate TTS Audio and Cache**
  Future<String?> generateAndCacheTTS({
    required String text,
    String language = 'en-US',
    String voice = 'default',
    double rate = 0.5,
    double pitch = 1.0,
  }) async {
    try {
      final textHash = _generateTextHash(text, language, voice);

      // Check if already cached
      final cachedAudio = await _getCachedTTS(textHash);
      if (cachedAudio != null) {
        await _updateTTSAccessTime(textHash);
        return cachedAudio;
      }

      // Generate TTS audio
      debugPrint('🎵 Generating TTS for: "$text"');

      // Configure TTS
      await _flutterTts.setLanguage(language);
      await _flutterTts.setSpeechRate(rate);
      await _flutterTts.setPitch(pitch);

      // For now, we'll cache the text and settings
      // In a full implementation, you'd capture the actual audio
      final filePath = await _saveTTSToCache(
        textHash: textHash,
        text: text,
        language: language,
        voice: voice,
      );

      return filePath;
    } catch (e) {
      debugPrint('❌ TTS generation error: $e');
      return null;
    }
  }

  /// 🎯 **Get Cached TTS**
  Future<String?> _getCachedTTS(String textHash) async {
    try {
      final db = _cacheService.database;
      if (db == null) return null;

      final result = await db.query(
        'tts_cache',
        where: 'text_hash = ?',
        whereArgs: [textHash],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final filePath = result.first['file_path'] as String;
        final file = File(filePath);

        if (await file.exists()) {
          return filePath;
        } else {
          // File doesn't exist, remove from database
          await db.delete(
            'tts_cache',
            where: 'text_hash = ?',
            whereArgs: [textHash],
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to get cached TTS: $e');
    }
    return null;
  }

  /// 🎯 **Save TTS to Cache**
  Future<String> _saveTTSToCache({
    required String textHash,
    required String text,
    required String language,
    required String voice,
  }) async {
    final cacheDir = _cacheService.cacheDirectory!;
    final fileName = '$textHash.json'; // Store metadata for now
    final filePath = path.join(cacheDir.path, 'tts', fileName);

    // Save TTS metadata (in a full implementation, save actual audio)
    final ttsData = {
      'text': text,
      'language': language,
      'voice': voice,
      'generated_at': DateTime.now().toIso8601String(),
    };

    final file = File(filePath);
    await file.writeAsString(jsonEncode(ttsData));

    // Save to database
    final db = _cacheService.database!;
    final now = DateTime.now().millisecondsSinceEpoch;
    final fileSize = await file.length();

    await db.insert('tts_cache', {
      'text_hash': textHash,
      'text_content': text,
      'file_path': filePath,
      'language': language,
      'voice': voice,
      'created_at': now,
      'accessed_at': now,
      'size_bytes': fileSize,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Update cache statistics
    await _cacheService.loadCacheStatistics();

    debugPrint('✅ TTS cached: $fileName ($fileSize bytes)');
    return filePath;
  }

  /// 🎯 **Update TTS Access Time**
  Future<void> _updateTTSAccessTime(String textHash) async {
    try {
      final db = _cacheService.database;
      if (db == null) return;

      await db.update(
        'tts_cache',
        {'accessed_at': DateTime.now().millisecondsSinceEpoch},
        where: 'text_hash = ?',
        whereArgs: [textHash],
      );
    } catch (e) {
      debugPrint('❌ Failed to update TTS access time: $e');
    }
  }

  /// 🎯 **Generate Text Hash**
  String _generateTextHash(String text, String language, String voice) {
    final input = '$text|$language|$voice';
    final bytes = utf8.encode(input.toLowerCase());
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16); // Shorter hash for filenames
  }

  /// 🎯 **Pre-cache Common Instructions**
  Future<void> preCacheCommonInstructions({
    String language = 'en-US',
    String voice = 'default',
    Function(int completed, int total)? onProgress,
  }) async {
    debugPrint('🎵 Pre-caching common TTS instructions...');

    try {
      int completed = 0;
      final total = commonNavigationInstructions.length;

      for (final instruction in commonNavigationInstructions) {
        await generateAndCacheTTS(
          text: instruction,
          language: language,
          voice: voice,
        );

        completed++;
        onProgress?.call(completed, total);

        // Small delay to avoid overwhelming the system
        await Future.delayed(const Duration(milliseconds: 100));
      }

      debugPrint('✅ Pre-cached $total TTS instructions');
    } catch (e) {
      debugPrint('❌ Pre-caching failed: $e');
      rethrow;
    }
  }

  /// 🎯 **Speak with Cache**
  Future<void> speakWithCache({
    required String text,
    String language = 'en-US',
    String voice = 'default',
    double rate = 0.5,
    double pitch = 1.0,
  }) async {
    try {
      // Try to get cached version
      final textHash = _generateTextHash(text, language, voice);
      final cachedAudio = await _getCachedTTS(textHash);

      if (cachedAudio != null) {
        debugPrint('🎵 Using cached TTS for: "$text"');
        await _updateTTSAccessTime(textHash);

        // In a full implementation, play the cached audio file
        // For now, use regular TTS
        await _flutterTts.speak(text);
      } else {
        // Generate and cache for future use
        await generateAndCacheTTS(
          text: text,
          language: language,
          voice: voice,
          rate: rate,
          pitch: pitch,
        );

        // Speak normally
        await _flutterTts.speak(text);
      }
    } catch (e) {
      debugPrint('❌ TTS speak error: $e');
      // Fallback to regular TTS
      await _flutterTts.speak(text);
    }
  }

  /// 🎯 **Get Cached TTS Count**
  Future<int> getCachedTTSCount() async {
    try {
      final db = _cacheService.database;
      if (db == null) return 0;

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tts_cache',
      );
      return result.first['count'] as int;
    } catch (e) {
      debugPrint('❌ Failed to get cached TTS count: $e');
      return 0;
    }
  }

  /// 🎯 **Clear TTS Cache**
  Future<void> clearTTSCache() async {
    try {
      final db = _cacheService.database;
      if (db == null) return;

      await db.delete('tts_cache');

      // Delete TTS files
      final ttsDir = Directory(
        path.join(_cacheService.cacheDirectory!.path, 'tts'),
      );
      if (await ttsDir.exists()) {
        await ttsDir.delete(recursive: true);
        await ttsDir.create();
      }

      await _cacheService.loadCacheStatistics();
      debugPrint('✅ TTS cache cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear TTS cache: $e');
    }
  }

  /// 🎯 **Get TTS Cache Statistics**
  Future<Map<String, dynamic>> getTTSCacheStats() async {
    try {
      final db = _cacheService.database;
      if (db == null) return {};

      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tts_cache',
      );
      final sizeResult = await db.rawQuery(
        'SELECT SUM(size_bytes) as size FROM tts_cache',
      );

      final count = countResult.first['count'] as int;
      final size = sizeResult.first['size'] as int? ?? 0;

      return {
        'count': count,
        'size': size,
        'formattedSize': _formatBytes(size),
      };
    } catch (e) {
      debugPrint('❌ Failed to get TTS cache stats: $e');
      return {};
    }
  }

  /// 🎯 **Format Bytes**
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
