import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';

import 'offline_cache_service.dart';

/// 🎯 **Map Tiles Cache Service**
/// Handles offline caching of map tiles for offline viewing
class MapTilesCacheService {
  static final MapTilesCacheService _instance =
      MapTilesCacheService._internal();
  factory MapTilesCacheService() => _instance;
  MapTilesCacheService._internal();

  final OfflineCacheService _cacheService = OfflineCacheService();
  final http.Client _httpClient = http.Client();

  /// 🎯 **Download and Cache Tile**
  Future<String?> downloadAndCacheTile({
    required String url,
    required int zoom,
    required int x,
    required int y,
  }) async {
    try {
      final tileKey = _generateTileKey(zoom, x, y);

      // Check if tile already exists in cache
      final cachedTile = await _getCachedTile(tileKey);
      if (cachedTile != null) {
        await _updateTileAccessTime(tileKey);
        return cachedTile;
      }

      // Download tile
      debugPrint('🗺️ Downloading tile: $url');
      final response = await _httpClient.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Save to cache
        final filePath = await _saveTileToCache(
          tileKey: tileKey,
          url: url,
          zoom: zoom,
          x: x,
          y: y,
          tileData: response.bodyBytes,
        );

        return filePath;
      } else {
        debugPrint('❌ Failed to download tile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Tile download error: $e');
      return null;
    }
  }

  /// 🎯 **Get Cached Tile**
  Future<String?> _getCachedTile(String tileKey) async {
    try {
      final db = _cacheService.database;
      if (db == null) return null;

      final result = await db.query(
        'tiles_cache',
        where: 'tile_key = ?',
        whereArgs: [tileKey],
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
            'tiles_cache',
            where: 'tile_key = ?',
            whereArgs: [tileKey],
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to get cached tile: $e');
    }
    return null;
  }

  /// 🎯 **Save Tile to Cache**
  Future<String> _saveTileToCache({
    required String tileKey,
    required String url,
    required int zoom,
    required int x,
    required int y,
    required List<int> tileData,
  }) async {
    final cacheDir = _cacheService.cacheDirectory!;
    final fileName = '$tileKey.png';
    final filePath = path.join(cacheDir.path, 'tiles', fileName);

    // Save file
    final file = File(filePath);
    await file.writeAsBytes(tileData);

    // Save to database
    final db = _cacheService.database!;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('tiles_cache', {
      'tile_key': tileKey,
      'url': url,
      'file_path': filePath,
      'zoom_level': zoom,
      'x_coord': x,
      'y_coord': y,
      'created_at': now,
      'accessed_at': now,
      'size_bytes': tileData.length,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Update cache statistics
    await _cacheService.loadCacheStatistics();

    debugPrint('✅ Tile cached: $fileName (${tileData.length} bytes)');
    return filePath;
  }

  /// 🎯 **Update Tile Access Time**
  Future<void> _updateTileAccessTime(String tileKey) async {
    try {
      final db = _cacheService.database;
      if (db == null) return;

      await db.update(
        'tiles_cache',
        {'accessed_at': DateTime.now().millisecondsSinceEpoch},
        where: 'tile_key = ?',
        whereArgs: [tileKey],
      );
    } catch (e) {
      debugPrint('❌ Failed to update tile access time: $e');
    }
  }

  /// 🎯 **Generate Tile Key**
  String _generateTileKey(int zoom, int x, int y) {
    return '${zoom}_${x}_$y';
  }

  /// 🎯 **Download Map Area for Offline Use**
  Future<void> downloadMapArea({
    required LatLng center,
    required int minZoom,
    required int maxZoom,
    required double radiusKm,
    Function(int downloaded, int total)? onProgress,
  }) async {
    debugPrint('🗺️ Starting map area download...');
    debugPrint('📍 Center: ${center.latitude}, ${center.longitude}');
    debugPrint('🔍 Zoom levels: $minZoom - $maxZoom');
    debugPrint('📐 Radius: ${radiusKm}km');

    int totalTiles = 0;
    int downloadedTiles = 0;

    try {
      // Calculate tiles to download
      for (int zoom = minZoom; zoom <= maxZoom; zoom++) {
        final bounds = _calculateTileBounds(center, radiusKm, zoom);
        final tilesInZoom =
            (bounds['maxX']! - bounds['minX']! + 1) *
            (bounds['maxY']! - bounds['minY']! + 1);
        totalTiles += tilesInZoom;
      }

      debugPrint('📦 Total tiles to download: $totalTiles');

      // Download tiles
      for (int zoom = minZoom; zoom <= maxZoom; zoom++) {
        final bounds = _calculateTileBounds(center, radiusKm, zoom);

        for (int x = bounds['minX']!; x <= bounds['maxX']!; x++) {
          for (int y = bounds['minY']!; y <= bounds['maxY']!; y++) {
            final url = 'https://tile.openstreetmap.org/$zoom/$x/$y.png';

            await downloadAndCacheTile(url: url, zoom: zoom, x: x, y: y);

            downloadedTiles++;
            onProgress?.call(downloadedTiles, totalTiles);

            // Small delay to avoid overwhelming the server
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }
      }

      debugPrint('✅ Map area download completed: $downloadedTiles tiles');
    } catch (e) {
      debugPrint('❌ Map area download failed: $e');
      rethrow;
    }
  }

  /// 🎯 **Calculate Tile Bounds**
  Map<String, int> _calculateTileBounds(
    LatLng center,
    double radiusKm,
    int zoom,
  ) {
    // Convert radius to degrees (approximate)
    final radiusDeg = radiusKm / 111.32; // 111.32 km per degree at equator

    final minLat = center.latitude - radiusDeg;
    final maxLat = center.latitude + radiusDeg;
    final minLng = center.longitude - radiusDeg;
    final maxLng = center.longitude + radiusDeg;

    // Convert to tile coordinates
    final minX = _longitudeToTileX(minLng, zoom);
    final maxX = _longitudeToTileX(maxLng, zoom);
    final minY = _latitudeToTileY(maxLat, zoom); // Note: Y is inverted
    final maxY = _latitudeToTileY(minLat, zoom);

    return {'minX': minX, 'maxX': maxX, 'minY': minY, 'maxY': maxY};
  }

  /// 🎯 **Convert Longitude to Tile X**
  int _longitudeToTileX(double longitude, int zoom) {
    return ((longitude + 180.0) / 360.0 * (1 << zoom)).floor();
  }

  /// 🎯 **Convert Latitude to Tile Y**
  int _latitudeToTileY(double latitude, int zoom) {
    final latRad = latitude * (math.pi / 180.0);
    return ((1.0 -
                math.log(math.tan(latRad) + (1.0 / math.cos(latRad))) /
                    math.pi) /
            2.0 *
            (1 << zoom))
        .floor();
  }

  /// 🎯 **Get Cached Tiles Count**
  Future<int> getCachedTilesCount() async {
    try {
      final db = _cacheService.database;
      if (db == null) return 0;

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tiles_cache',
      );
      return result.first['count'] as int;
    } catch (e) {
      debugPrint('❌ Failed to get cached tiles count: $e');
      return 0;
    }
  }

  /// 🎯 **Clear Tiles Cache**
  Future<void> clearTilesCache() async {
    try {
      final db = _cacheService.database;
      if (db == null) return;

      await db.delete('tiles_cache');

      // Delete tile files
      final tilesDir = Directory(
        path.join(_cacheService.cacheDirectory!.path, 'tiles'),
      );
      if (await tilesDir.exists()) {
        await tilesDir.delete(recursive: true);
        await tilesDir.create();
      }

      await _cacheService.loadCacheStatistics();
      debugPrint('✅ Tiles cache cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear tiles cache: $e');
    }
  }
}

/// 🎯 **Cached Tile Provider**
/// Custom tile layer that uses cached tiles when available
class CachedTileProvider extends TileLayer {
  final MapTilesCacheService _cacheService = MapTilesCacheService();
  final String _userAgentPackageName;

  CachedTileProvider({
    super.key,
    required String super.urlTemplate,
    super.userAgentPackageName = 'com.example.driver_tablet_demo',
    super.maxZoom = 18.0,
    super.errorTileCallback,
  }) : _userAgentPackageName = userAgentPackageName;

  /// Override to use cached tiles
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: urlTemplate!,
      userAgentPackageName: _userAgentPackageName,
      maxZoom: maxZoom,
      tileProvider: CachedNetworkTileProvider(),
      errorTileCallback: errorTileCallback,
    );
  }
}

/// 🎯 **Cached Network Tile Provider**
class CachedNetworkTileProvider extends TileProvider {
  final MapTilesCacheService _cacheService = MapTilesCacheService();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    // Try to get cached tile first, then fallback to network
    return CachedTileImage(
      coordinates: coordinates,
      options: options,
      cacheService: _cacheService,
    );
  }
}

/// 🎯 **Cached Tile Image Provider**
class CachedTileImage extends ImageProvider<CachedTileImage> {
  final TileCoordinates coordinates;
  final TileLayer options;
  final MapTilesCacheService cacheService;

  const CachedTileImage({
    required this.coordinates,
    required this.options,
    required this.cacheService,
  });

  @override
  Future<CachedTileImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedTileImage>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(
    CachedTileImage key,
    DecoderBufferCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
    );
  }

  Future<Codec> _loadAsync(
    CachedTileImage key,
    DecoderBufferCallback decode,
  ) async {
    try {
      // Build URL
      final url = options.urlTemplate!
          .replaceAll('{x}', coordinates.x.toString())
          .replaceAll('{y}', coordinates.y.toString())
          .replaceAll('{z}', coordinates.z.toString());

      // Try to get from cache or download
      final cachedPath = await cacheService.downloadAndCacheTile(
        url: url,
        zoom: coordinates.z,
        x: coordinates.x,
        y: coordinates.y,
      );

      if (cachedPath != null) {
        final file = File(cachedPath);
        final bytes = await file.readAsBytes();
        final buffer = await ImmutableBuffer.fromUint8List(bytes);
        return await decode(buffer);
      } else {
        throw Exception('Failed to load tile');
      }
    } catch (e) {
      debugPrint('❌ Failed to load cached tile: $e');
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CachedTileImage &&
        other.coordinates == coordinates &&
        other.options == options;
  }

  @override
  int get hashCode => Object.hash(coordinates, options);
}
