import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/amazon_location_service.dart';
import '../../../core/services/navigation_tts_service.dart';
import '../models/map_state.dart';

/// 🎯 **Map Controller**
/// Handles all business logic and state management for the map
class MapStateController extends ChangeNotifier {
  MapState _state = MapState.initial();
  MapState get state => _state;

  // Services
  final MapController _mapController = MapController();
  final AmazonLocationService _amazonLocationService = AmazonLocationService();
  final NavigationTTSService _ttsService = NavigationTTSService();

  // Callback for showing navigation dialogs
  Function(LatLng, String)? onShowNavigationDialog;

  // Demo locations for testing
  final List<LatLng> _demoLocations = [
    const LatLng(37.7749, -122.4194), // San Francisco City Hall
    const LatLng(37.8075, -122.4158), // Fisherman's Wharf
    const LatLng(37.8020, -122.4058), // Lombard Street
    const LatLng(37.7699, -122.4781), // Golden Gate Park
    const LatLng(37.8199, -122.4783), // Golden Gate Bridge
  ];

  final List<String> _markerLabels = [
    'City Hall',
    'Fisherman\'s Wharf',
    'Lombard Street',
    'Golden Gate Park',
    'Golden Gate Bridge',
  ];

  // Getters
  MapController get mapController => _mapController;
  List<LatLng> get demoLocations => _demoLocations;
  List<String> get markerLabels => _markerLabels;

  /// Initialize the controller
  Future<void> initialize() async {
    await _initializeTTS();
    await _initializeLocation();
    _setupDemoMarkers();
  }

  /// Update state and notify listeners
  void _updateState(MapState newState) {
    _state = newState;
    notifyListeners();
  }

  /// 🎯 **TTS Initialization**
  Future<void> _initializeTTS() async {
    try {
      await _ttsService.initialize();
      debugPrint('✅ TTS Service initialized successfully');

      if (_state.isTTSEnabled) {
        await _ttsService.testVoice();
      }
    } catch (e) {
      debugPrint('❌ TTS initialization failed: $e');
    }
  }

  /// 🎯 **Location Initialization**
  Future<void> _initializeLocation() async {
    _updateState(
      _state.copyWith(
        isLocationLoading: true,
        locationStatus: 'Checking location permissions...',
      ),
    );

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _updateState(
          _state.copyWith(
            locationStatus: 'Location services are disabled',
            isLocationLoading: false,
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _updateState(
            _state.copyWith(
              locationStatus: 'Location permissions denied',
              isLocationLoading: false,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _updateState(
          _state.copyWith(
            locationStatus: 'Location permissions permanently denied',
            isLocationLoading: false,
          ),
        );
        return;
      }

      await getCurrentLocation();
    } catch (e) {
      _updateState(
        _state.copyWith(
          locationStatus: 'Error getting location: $e',
          isLocationLoading: false,
        ),
      );
    }
  }

  /// 🎯 **Get Current Location**
  Future<void> getCurrentLocation() async {
    try {
      _updateState(
        _state.copyWith(
          isLocationLoading: true,
          locationStatus: 'Getting current location...',
        ),
      );

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final currentLocation = LatLng(position.latitude, position.longitude);

      _updateState(
        _state.copyWith(
          currentLocation: currentLocation,
          locationStatus:
              'Location found: ${position.accuracy.toStringAsFixed(1)}m accuracy',
          isLocationLoading: false,
        ),
      );

      _updateMarkersWithCurrentLocation();
      _mapController.move(currentLocation, 16.0);
    } catch (e) {
      _updateState(
        _state.copyWith(
          locationStatus: 'Failed to get location: $e',
          isLocationLoading: false,
        ),
      );
    }
  }

  /// 🎯 **Setup Demo Markers**
  void _setupDemoMarkers() {
    final markers =
        _demoLocations.asMap().entries.map((entry) {
          final index = entry.key;
          final location = entry.value;

          return Marker(
            point: location,
            width: 80.0,
            height: 80.0,
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () => onMarkerTapped(location, _markerLabels[index]),
              child: _buildMarkerWidget(location, _markerLabels[index]),
            ),
          );
        }).toList();

    _updateState(_state.copyWith(markers: markers));
  }

  /// 🎯 **Build Marker Widget**
  Widget _buildMarkerWidget(LatLng location, String label) {
    final isSelected = _state.selectedLocation == location;
    final color = isSelected ? Colors.blue : Colors.red;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Container(width: 2, height: 10, color: color),
      ],
    );
  }

  /// 🎯 **Update Markers with Current Location**
  void _updateMarkersWithCurrentLocation() {
    if (_state.currentLocation == null) return;

    final currentLocationMarker = Marker(
      point: _state.currentLocation!,
      width: 60.0,
      height: 60.0,
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[600],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: const Icon(Icons.my_location, color: Colors.white, size: 24),
      ),
    );

    final updatedMarkers = [..._state.markers, currentLocationMarker];
    _updateState(_state.copyWith(markers: updatedMarkers));
  }

  /// 🎯 **Marker Tap Handler**
  void onMarkerTapped(LatLng location, String label) {
    _updateState(_state.copyWith(selectedLocation: location));
    _setupDemoMarkers(); // Rebuild markers with new selection

    // Show navigation dialog if callback is set
    onShowNavigationDialog?.call(location, label);
  }

  /// 🎯 **Map Tap Handler**
  void onMapTapped(LatLng location) {
    final newMarker = Marker(
      point: location,
      width: 60.0,
      height: 60.0,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () => onMarkerTapped(location, 'Custom Location'),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.place, color: Colors.white, size: 20),
            ),
            Container(width: 2, height: 10, color: Colors.green),
          ],
        ),
      ),
    );

    final updatedMarkers = [..._state.markers, newMarker];
    _updateState(
      _state.copyWith(selectedLocation: location, markers: updatedMarkers),
    );
  }

  /// 🎯 **Calculate Distance**
  String calculateDistance(LatLng from, LatLng to) {
    final distance = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );

    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  /// 🎯 **Calculate Route**
  Future<void> calculateRoute(LatLng destination) async {
    if (_state.currentLocation == null) return;

    _updateState(
      _state.copyWith(
        isRouting: true,
        routeInfo: 'Calculating route with Amazon Location Service...',
      ),
    );

    try {
      final route = await _amazonLocationService.calculateRoute(
        departure: _state.currentLocation!,
        destination: destination,
        travelMode: 'Car',
        avoidTolls: false,
        avoidFerries: false,
      );

      final alternativeRoutes = await _amazonLocationService
          .getAlternativeRoutes(
            departure: _state.currentLocation!,
            destination: destination,
            avoidanceReasons: ['Tolls'],
          );

      final trafficUpdate = await _amazonLocationService.getTrafficUpdate(
        route.summary.routeId,
      );

      _updateState(
        _state.copyWith(
          currentRoute: route,
          routePoints: route.polylinePoints,
          alternativeRoutes: alternativeRoutes,
          trafficUpdate: trafficUpdate,
          isRouting: false,
          routeInfo: _state.routeSummary,
        ),
      );

      if (_state.isTTSEnabled) {
        await _announceRouteStart();
      }

      startNavigation();
      fitRouteBounds();
    } catch (e) {
      _updateState(
        _state.copyWith(
          isRouting: false,
          routeInfo: 'Amazon LS routing failed: $e',
        ),
      );

      await _generateSimpleRoute(_state.currentLocation!, destination);
    }
  }

  /// 🎯 **Generate Simple Route**
  Future<void> _generateSimpleRoute(LatLng start, LatLng end) async {
    List<LatLng> routePoints = [start];

    double latDiff = end.latitude - start.latitude;
    double lngDiff = end.longitude - start.longitude;

    for (int i = 1; i < 5; i++) {
      double ratio = i / 5.0;
      double curveFactor = 0.0002;
      double offsetLat = (i % 2 == 0 ? curveFactor : -curveFactor);
      double offsetLng = (i % 3 == 0 ? curveFactor : -curveFactor);

      LatLng intermediatePoint = LatLng(
        start.latitude + (latDiff * ratio) + offsetLat,
        start.longitude + (lngDiff * ratio) + offsetLng,
      );

      routePoints.add(intermediatePoint);
    }

    routePoints.add(end);

    _updateState(_state.copyWith(routePoints: routePoints));
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  /// 🎯 **Clear Route**
  void clearRoute() {
    _updateState(_state.clearRoute());
  }

  /// 🎯 **Fit Route Bounds**
  void fitRouteBounds() {
    if (_state.routePoints.isEmpty) return;

    double minLat = _state.routePoints
        .map((p) => p.latitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLat = _state.routePoints
        .map((p) => p.latitude)
        .reduce((a, b) => a > b ? a : b);
    double minLng = _state.routePoints
        .map((p) => p.longitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLng = _state.routePoints
        .map((p) => p.longitude)
        .reduce((a, b) => a > b ? a : b);

    LatLng center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);

    _mapController.move(center, 12.0);
  }

  /// 🎯 **Map Controls**
  void zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  void centerOnCurrentLocation() {
    if (_state.currentLocation != null) {
      _mapController.move(_state.currentLocation!, 16.0);
    }
  }

  /// 🎯 **Navigation Controls**
  void startNavigation() {
    _updateState(_state.copyWith(isNavigationActive: true));
    _startLocationTracking();
    debugPrint('🧭 Navigation started with voice guidance');
  }

  void stopNavigation() {
    _updateState(_state.copyWith(isNavigationActive: false));
    _ttsService.stop();
    debugPrint('🛑 Navigation stopped');
  }

  void toggleTTS() {
    final newTTSState = !_state.isTTSEnabled;
    _updateState(_state.copyWith(isTTSEnabled: newTTSState));

    if (newTTSState) {
      _ttsService.testVoice();
    } else {
      _ttsService.stop();
    }
  }

  /// 🎯 **TTS Methods**
  Future<void> _announceRouteStart() async {
    if (_state.currentRoute == null) return;

    await _ttsService.announceRouteStart(
      totalDistance: _state.currentRoute!.summary.distance * 1000,
      estimatedDuration: _state.currentRoute!.summary.durationSeconds,
      destination: "your destination",
    );
  }

  void _startLocationTracking() {
    _simulateNavigationAnnouncements();
  }

  Future<void> _simulateNavigationAnnouncements() async {
    if (!_state.isNavigationActive || !_state.isTTSEnabled) return;

    await Future.delayed(const Duration(seconds: 3));
    if (_state.isNavigationActive) {
      await _ttsService.announceNavigationInstruction(
        instruction: "Turn right onto Market Street",
        distanceToTurn: 200,
        isImmediate: false,
      );
    }

    await Future.delayed(const Duration(seconds: 8));
    if (_state.isNavigationActive) {
      await _ttsService.announceNavigationInstruction(
        instruction: "Turn right",
        distanceToTurn: 50,
        isImmediate: true,
      );
    }

    await Future.delayed(const Duration(seconds: 15));
    if (_state.isNavigationActive) {
      await _ttsService.announceNavigationInstruction(
        instruction: "Continue straight for 500 meters",
        distanceToTurn: 500,
        isImmediate: false,
      );
    }

    await Future.delayed(const Duration(seconds: 10));
    if (_state.isNavigationActive) {
      await _ttsService.announceTrafficAlert(
        alertType: 'delay',
        delayMinutes: 3,
        alternativeAvailable: 'Alternative route available.',
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _ttsService.dispose();
    super.dispose();
  }
}
