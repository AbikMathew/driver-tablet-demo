import 'package:flutter/material.dart';

import '../controllers/map_controller.dart';
import '../models/map_state.dart';

/// 🎯 **Route Panel Widget**
/// Displays route information and controls
class RoutePanel extends StatelessWidget {
  final MapStateController controller;

  const RoutePanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final state = controller.state;

        if (!state.hasActiveRoute) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            border: Border(bottom: BorderSide(color: Colors.green.shade200)),
          ),
          child: Row(
            children: [
              _buildRouteIcon(state),
              const SizedBox(width: 12),
              Expanded(child: _buildRouteInfo(state)),
              _buildRouteActions(state, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRouteIcon(MapState state) {
    return Icon(
      state.isRouting ? Icons.route : Icons.navigation,
      color: state.isRouting ? Colors.orange : Colors.green,
    );
  }

  Widget _buildRouteInfo(MapState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.isRouting ? 'Calculating Route...' : 'Route Active',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        if (state.routeInfo.isNotEmpty)
          Text(
            state.routeInfo,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildRouteActions(MapState state, MapStateController controller) {
    if (state.isRouting) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (state.routePoints.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: controller.fitRouteBounds,
            tooltip: 'Center route',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: controller.clearRoute,
            tooltip: 'Clear route',
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
