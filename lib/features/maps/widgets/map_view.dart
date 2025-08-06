import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/map_tiles_cache_service.dart';
import '../controllers/map_controller.dart';
import '../models/map_state.dart';

/// 🎯 **Map View Widget**
/// Core FlutterMap widget with layers
class MapView extends StatelessWidget {
  final MapStateController controller;

  const MapView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final state = controller.state;

        return FlutterMap(
          mapController: controller.mapController,
          options: MapOptions(
            initialCenter: MapState.defaultCenter,
            initialZoom: MapState.defaultZoom,
            minZoom: 3.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onTap:
                (tapPosition, point) =>
                    _onMapTapped(context, point, controller),
          ),
          children: [
            _buildTileLayer(),
            _buildAttributionLayer(),
            _buildPolylineLayer(state),
            _buildMarkerLayer(state),
          ],
        );
      },
    );
  }

  Widget _buildTileLayer() {
    return CachedTileProvider(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.driver_tablet_demo',
      maxZoom: 18,
      errorTileCallback: (tile, error, stackTrace) {
        debugPrint('🗺️ Tile Error: $error');
      },
    );
  }

  Widget _buildAttributionLayer() {
    return const RichAttributionWidget(
      attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
    );
  }

  Widget _buildPolylineLayer(MapState state) {
    return PolylineLayer(polylines: _buildPolylines(state));
  }

  Widget _buildMarkerLayer(MapState state) {
    return MarkerLayer(markers: state.markers);
  }

  List<Polyline> _buildPolylines(MapState state) {
    List<Polyline> polylines = [];

    // Add main route if we have route points
    if (state.routePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          points: state.routePoints,
          color: state.routeColors['active']!,
          strokeWidth: 5.0,
          borderStrokeWidth: 2.0,
          borderColor: Colors.white,
        ),
      );
    }

    // Add demo route connecting current location to selected location
    if (state.currentLocation != null && state.selectedLocation != null) {
      polylines.add(
        Polyline(
          points: [state.currentLocation!, state.selectedLocation!],
          color: state.routeColors['alternative']!,
          strokeWidth: 3.0,
          borderStrokeWidth: 1.0,
          borderColor: Colors.white,
          pattern: StrokePattern.dashed(segments: [5, 3]),
        ),
      );
    }

    return polylines;
  }

  void _onMapTapped(
    BuildContext context,
    LatLng point,
    MapStateController controller,
  ) {
    controller.onMapTapped(point);

    // Show navigation dialog for tapped location
    _showNavigationDialog(context, point, 'Custom Location');
  }

  void _showNavigationDialog(
    BuildContext context,
    LatLng location,
    String label,
  ) {
    String distanceInfo = '';
    if (controller.state.currentLocation != null) {
      final distance = controller.calculateDistance(
        controller.state.currentLocation!,
        location,
      );
      distanceInfo = ' • $distance away';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: $label$distanceInfo'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Navigate',
          onPressed: () => controller.calculateRoute(location),
        ),
      ),
    );
  }
}
