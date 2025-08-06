import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/map_tiles_cache_service.dart';
import '../../../core/services/navigation_tts_service.dart';
import '../../../core/services/offline_cache_service.dart';
import '../../../core/services/tts_cache_service.dart';

/// 🎯 **Offline Cache Management Screen**
/// Comprehensive UI for managing offline cache
class OfflineCacheScreen extends StatefulWidget {
  const OfflineCacheScreen({super.key});

  @override
  State<OfflineCacheScreen> createState() => _OfflineCacheScreenState();
}

class _OfflineCacheScreenState extends State<OfflineCacheScreen> {
  final OfflineCacheService _cacheService = OfflineCacheService();
  final MapTilesCacheService _mapCache = MapTilesCacheService();
  final TTSCacheService _ttsCache = TTSCacheService();
  final NavigationTTSService _ttsService = NavigationTTSService();

  bool _isLoading = true;
  bool _isDownloading = false;
  Map<String, int> _cacheStats = {};

  // Download progress
  double _downloadProgress = 0.0;
  String _downloadStatus = '';

  @override
  void initState() {
    super.initState();
    _initializeCacheService();
  }

  /// 🎯 **Initialize Cache Service**
  Future<void> _initializeCacheService() async {
    try {
      await _cacheService.initialize();
      await _loadCacheStats();
    } catch (e) {
      debugPrint('❌ Cache initialization error: $e');
      _showError('Failed to initialize cache service');
    }
  }

  /// 🎯 **Load Cache Statistics**
  Future<void> _loadCacheStats() async {
    try {
      setState(() => _isLoading = true);

      await _cacheService.loadCacheStatistics();
      _cacheStats = _cacheService.cacheStats;

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('❌ Failed to load cache stats: $e');
      setState(() => _isLoading = false);
    }
  }

  /// 🎯 **Show Error**
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// 🎯 **Show Success**
  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Offline Cache'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCacheStats,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadCacheStats,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCacheOverview(),
                      const SizedBox(height: 20),
                      _buildMapCacheSection(),
                      const SizedBox(height: 20),
                      _buildTTSCacheSection(),
                      const SizedBox(height: 20),
                      _buildCacheManagementSection(),
                      const SizedBox(height: 20),
                      if (_isDownloading) _buildDownloadProgress(),
                    ],
                  ),
                ),
              ),
    );
  }

  /// 🎯 **Build Cache Overview**
  Widget _buildCacheOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Cache Overview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Map Tiles',
              '${_cacheStats['tiles'] ?? 0}',
              Icons.map,
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              'TTS Audio',
              '${_cacheStats['tts'] ?? 0}',
              Icons.volume_up,
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              'Routes',
              '${_cacheStats['routes'] ?? 0}',
              Icons.route,
            ),
            const Divider(),
            _buildStatRow(
              'Total Size',
              _cacheService.getFormattedCacheSize(),
              Icons.storage,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 **Build Stat Row**
  Widget _buildStatRow(
    String label,
    String value,
    IconData icon, {
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isTotal ? Colors.orange : Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.orange : Colors.black87,
          ),
        ),
      ],
    );
  }

  /// 🎯 **Build Map Cache Section**
  Widget _buildMapCacheSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.map, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Map Tiles Cache',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Download map tiles for offline viewing in areas with poor connectivity.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDownloading ? null : _downloadCurrentArea,
                    icon: const Icon(Icons.download),
                    label: const Text('Download Current Area'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isDownloading ? null : _clearMapCache,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Map Cache'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 **Build TTS Cache Section**
  Widget _buildTTSCacheSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.volume_up, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Voice Instructions Cache',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Pre-download common navigation instructions for faster voice guidance.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDownloading ? null : _preCacheTTSInstructions,
                    icon: const Icon(Icons.download),
                    label: const Text('Pre-cache Instructions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isDownloading ? null : _clearTTSCache,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear TTS Cache'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 **Build Cache Management Section**
  Widget _buildCacheManagementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Cache Management',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDownloading ? null : _cleanupOldCache,
                    icon: const Icon(Icons.cleaning_services),
                    label: const Text('Cleanup Old Cache'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _isDownloading ? null : () => _showClearAllDialog(),
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear All Cache'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 **Build Download Progress**
  Widget _buildDownloadProgress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Downloading...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(_downloadStatus),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _downloadProgress),
            const SizedBox(height: 8),
            Text('${(_downloadProgress * 100).toStringAsFixed(1)}% complete'),
          ],
        ),
      ),
    );
  }

  /// 🎯 **Download Current Area**
  Future<void> _downloadCurrentArea() async {
    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
        _downloadStatus = 'Preparing to download map tiles...';
      });

      // San Francisco area (demo coordinates)
      const center = LatLng(37.7749, -122.4194);
      const radiusKm = 5.0;
      const minZoom = 10;
      const maxZoom = 16;

      await _mapCache.downloadMapArea(
        center: center,
        minZoom: minZoom,
        maxZoom: maxZoom,
        radiusKm: radiusKm,
        onProgress: (downloaded, total) {
          setState(() {
            _downloadProgress = downloaded / total;
            _downloadStatus = 'Downloaded $downloaded of $total tiles';
          });
        },
      );

      setState(() => _isDownloading = false);
      await _loadCacheStats();
      _showSuccess('Map area downloaded successfully!');
    } catch (e) {
      setState(() => _isDownloading = false);
      _showError('Download failed: $e');
    }
  }

  /// 🎯 **Pre-cache TTS Instructions**
  Future<void> _preCacheTTSInstructions() async {
    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
        _downloadStatus = 'Pre-caching voice instructions...';
      });

      await _ttsService.preCacheInstructions(
        onProgress: (completed, total) {
          setState(() {
            _downloadProgress = completed / total;
            _downloadStatus = 'Cached $completed of $total instructions';
          });
        },
      );

      setState(() => _isDownloading = false);
      await _loadCacheStats();
      _showSuccess('TTS instructions pre-cached successfully!');
    } catch (e) {
      setState(() => _isDownloading = false);
      _showError('TTS pre-caching failed: $e');
    }
  }

  /// 🎯 **Clear Map Cache**
  Future<void> _clearMapCache() async {
    try {
      await _mapCache.clearTilesCache();
      await _loadCacheStats();
      _showSuccess('Map cache cleared successfully!');
    } catch (e) {
      _showError('Failed to clear map cache: $e');
    }
  }

  /// 🎯 **Clear TTS Cache**
  Future<void> _clearTTSCache() async {
    try {
      await _ttsCache.clearTTSCache();
      await _loadCacheStats();
      _showSuccess('TTS cache cleared successfully!');
    } catch (e) {
      _showError('Failed to clear TTS cache: $e');
    }
  }

  /// 🎯 **Cleanup Old Cache**
  Future<void> _cleanupOldCache() async {
    try {
      await _cacheService.cleanupOldEntries();
      await _loadCacheStats();
      _showSuccess('Old cache entries cleaned up!');
    } catch (e) {
      _showError('Cache cleanup failed: $e');
    }
  }

  /// 🎯 **Show Clear All Dialog**
  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Cache'),
            content: const Text(
              'This will permanently delete all cached map tiles, voice instructions, and routes. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _clearAllCache();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  /// 🎯 **Clear All Cache**
  Future<void> _clearAllCache() async {
    try {
      await _cacheService.clearAllCache();
      await _loadCacheStats();
      _showSuccess('All cache cleared successfully!');
    } catch (e) {
      _showError('Failed to clear all cache: $e');
    }
  }
}
