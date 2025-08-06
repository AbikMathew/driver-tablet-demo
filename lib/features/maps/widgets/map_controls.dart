import 'package:flutter/material.dart';

import '../controllers/map_controller.dart';
import '../models/map_state.dart';

/// 🎯 **Map Controls Widget**
/// Floating action buttons for map and navigation control
class MapControls extends StatelessWidget {
  final MapStateController controller;

  const MapControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final state = controller.state;

        return Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              _buildTTSToggle(state, controller),
              const SizedBox(height: 8),
              if (state.currentRoute != null) ...[
                _buildNavigationToggle(state, controller),
                const SizedBox(height: 8),
              ],
              _buildZoomControls(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTTSToggle(MapState state, MapStateController controller) {
    return FloatingActionButton.small(
      heroTag: "tts_toggle",
      onPressed: controller.toggleTTS,
      backgroundColor: state.isTTSEnabled ? Colors.blue : Colors.grey,
      child: Icon(
        state.isTTSEnabled ? Icons.volume_up : Icons.volume_off,
        color: Colors.white,
      ),
    );
  }

  Widget _buildNavigationToggle(MapState state, MapStateController controller) {
    return FloatingActionButton.small(
      heroTag: "navigation_toggle",
      onPressed:
          state.isNavigationActive
              ? controller.stopNavigation
              : controller.startNavigation,
      backgroundColor: state.isNavigationActive ? Colors.red : Colors.green,
      child: Icon(
        state.isNavigationActive ? Icons.stop : Icons.navigation,
        color: Colors.white,
      ),
    );
  }

  Widget _buildZoomControls(MapStateController controller) {
    return Column(
      children: [
        FloatingActionButton.small(
          heroTag: "zoom_in",
          onPressed: controller.zoomIn,
          child: const Icon(Icons.zoom_in),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: "zoom_out",
          onPressed: controller.zoomOut,
          child: const Icon(Icons.zoom_out),
        ),
      ],
    );
  }
}
