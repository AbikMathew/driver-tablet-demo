import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/amazon_location_service.dart';

/// 🎯 **Map State Model**
/// Centralized state management for map functionality
class MapState {
  // Map Configuration
  static const double defaultZoom = 15.0;
  static const LatLng defaultCenter = LatLng(
    37.7749,
    -122.4194,
  ); // San Francisco

  // Location State
  final LatLng? currentLocation;
  final bool isLocationLoading;
  final String locationStatus;
  final LatLng? selectedLocation;

  // Routing State
  final List<LatLng> routePoints;
  final bool isRouting;
  final String routeInfo;
  final AmazonRouteResponse? currentRoute;
  final List<AmazonRouteResponse> alternativeRoutes;
  final TrafficUpdate? trafficUpdate;

  // Navigation State
  final bool isNavigationActive;
  final bool isTTSEnabled;

  // Markers
  final List<Marker> markers;

  // Route Colors
  static const Map<String, Color> defaultRouteColors = {
    'active': Colors.blue,
    'alternative': Colors.grey,
    'completed': Colors.green,
  };

  final Map<String, Color> routeColors;

  const MapState({
    this.currentLocation,
    this.isLocationLoading = false,
    this.locationStatus = 'Location not available',
    this.selectedLocation,
    this.routePoints = const [],
    this.isRouting = false,
    this.routeInfo = '',
    this.currentRoute,
    this.alternativeRoutes = const [],
    this.trafficUpdate,
    this.isNavigationActive = false,
    this.isTTSEnabled = true,
    this.markers = const [],
    this.routeColors = defaultRouteColors,
  });

  /// Create initial state
  factory MapState.initial() {
    return const MapState(routeColors: defaultRouteColors);
  }

  /// Copy with method for state updates
  MapState copyWith({
    LatLng? currentLocation,
    bool? isLocationLoading,
    String? locationStatus,
    LatLng? selectedLocation,
    List<LatLng>? routePoints,
    bool? isRouting,
    String? routeInfo,
    AmazonRouteResponse? currentRoute,
    List<AmazonRouteResponse>? alternativeRoutes,
    TrafficUpdate? trafficUpdate,
    bool? isNavigationActive,
    bool? isTTSEnabled,
    List<Marker>? markers,
    Map<String, Color>? routeColors,
  }) {
    return MapState(
      currentLocation: currentLocation ?? this.currentLocation,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      locationStatus: locationStatus ?? this.locationStatus,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      routePoints: routePoints ?? this.routePoints,
      isRouting: isRouting ?? this.isRouting,
      routeInfo: routeInfo ?? this.routeInfo,
      currentRoute: currentRoute ?? this.currentRoute,
      alternativeRoutes: alternativeRoutes ?? this.alternativeRoutes,
      trafficUpdate: trafficUpdate ?? this.trafficUpdate,
      isNavigationActive: isNavigationActive ?? this.isNavigationActive,
      isTTSEnabled: isTTSEnabled ?? this.isTTSEnabled,
      markers: markers ?? this.markers,
      routeColors: routeColors ?? this.routeColors,
    );
  }

  /// Clear route state
  MapState clearRoute() {
    return copyWith(
      routePoints: const [],
      isRouting: false,
      routeInfo: '',
      currentRoute: null,
      alternativeRoutes: const [],
      trafficUpdate: null,
      isNavigationActive: false,
    );
  }

  /// Check if we have an active route
  bool get hasActiveRoute => routePoints.isNotEmpty || isRouting;

  /// Check if location is available
  bool get hasLocation => currentLocation != null;

  /// Get formatted route summary
  String get routeSummary {
    if (currentRoute == null) return '';

    String baseInfo =
        'Route: ${currentRoute!.summary.formattedDistance} • ${currentRoute!.summary.formattedDuration}';

    if (trafficUpdate != null && trafficUpdate!.delays.isNotEmpty) {
      int totalDelay = trafficUpdate!.totalDelayMinutes;
      baseInfo += ' • +${totalDelay}m delay';
    }

    return baseInfo;
  }
}
