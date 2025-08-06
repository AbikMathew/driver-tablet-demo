import 'package:flutter/material.dart';

import '../controllers/map_controller.dart';
import '../models/map_state.dart';
import '../presentation/amazon_location_demo_screen.dart';
import '../presentation/offline_cache_screen.dart';
import '../presentation/tts_demo_screen.dart';

/// 🎯 **Map Header Widget**
/// Displays location status and navigation controls
class MapHeader extends StatelessWidget {
  final MapStateController controller;

  const MapHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final state = controller.state;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
          ),
          child: Row(
            children: [
              _buildLocationIcon(state),
              const SizedBox(width: 12),
              Expanded(child: _buildLocationInfo(state)),
              if (state.isLocationLoading)
                const _LoadingIndicator()
              else
                _buildActionButtons(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationIcon(MapState state) {
    return Icon(
      state.hasLocation ? Icons.location_on : Icons.location_off,
      color: state.hasLocation ? Colors.green : Colors.red,
    );
  }

  Widget _buildLocationInfo(MapState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Flutter Map with Location',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          state.locationStatus,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        if (state.isNavigationActive || !state.isTTSEnabled)
          _buildNavigationStatus(state),
      ],
    );
  }

  Widget _buildNavigationStatus(MapState state) {
    return Row(
      children: [
        if (state.isNavigationActive) ...[
          const Icon(Icons.navigation, size: 12, color: Colors.green),
          const SizedBox(width: 4),
          const Text(
            'Navigation Active',
            style: TextStyle(
              color: Colors.green,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (state.isNavigationActive && !state.isTTSEnabled)
          const SizedBox(width: 8),
        if (!state.isTTSEnabled) ...[
          const Icon(Icons.volume_off, size: 12, color: Colors.orange),
          const SizedBox(width: 4),
          const Text(
            'Voice Muted',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    MapStateController controller,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderButton(
          icon: Icons.cloud_download,
          onPressed:
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OfflineCacheScreen(),
                ),
              ),
          tooltip: 'Offline Cache',
        ),
        _HeaderButton(
          icon: Icons.my_location,
          onPressed:
              controller.state.hasLocation
                  ? controller.centerOnCurrentLocation
                  : controller.getCurrentLocation,
          tooltip:
              controller.state.hasLocation
                  ? 'Center on current location'
                  : 'Get current location',
        ),
        _HeaderButton(
          icon: Icons.refresh,
          onPressed: controller.getCurrentLocation,
          tooltip: 'Refresh location',
        ),
        _HeaderButton(
          icon: Icons.info,
          onPressed:
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AmazonLocationDemoScreen(),
                ),
              ),
          tooltip: 'Amazon LS Demo',
        ),
        _HeaderButton(
          icon: Icons.record_voice_over,
          onPressed:
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TTSDemoScreen()),
              ),
          tooltip: 'TTS Demo',
        ),
      ],
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _HeaderButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(icon), onPressed: onPressed, tooltip: tooltip);
  }
}
