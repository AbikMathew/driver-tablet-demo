import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/map_controller.dart';
import '../widgets/map_controls.dart';
import '../widgets/map_header.dart';
import '../widgets/map_view.dart';
import '../widgets/route_panel.dart';

/// 🎯 **Refactored Maps Screen**
/// Clean, maintainable, and well-structured map interface
///
/// 📁 **Structure:**
/// - models/map_state.dart: State management
/// - controllers/map_controller.dart: Business logic
/// - widgets/: Reusable UI components
/// - presentation/: Screens and complex widgets
class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late final MapStateController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MapStateController();

    // Set up navigation dialog callback
    _controller.onShowNavigationDialog = _showNavigationDialog;

    _initializeMap();
  }

  /// 🎯 **Initialize Map**
  /// Clean initialization with error handling
  Future<void> _initializeMap() async {
    try {
      await _controller.initialize();
    } catch (e) {
      debugPrint('❌ Map initialization failed: $e');
      _showInitializationError(e);
    }
  }

  /// 🎯 **Show Initialization Error**
  void _showInitializationError(dynamic error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Map initialization failed: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _initializeMap,
        ),
      ),
    );
  }

  /// 🎯 **Show Navigation Dialog**
  void _showNavigationDialog(LatLng location, String label) {
    if (!mounted) return;

    String distanceInfo = '';
    if (_controller.state.currentLocation != null) {
      final distance = _controller.calculateDistance(
        _controller.state.currentLocation!,
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
          onPressed: () => _controller.calculateRoute(location),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 🎨 **Header Section**
        /// Location status and navigation controls
        MapHeader(controller: _controller),

        /// 🛣️ **Route Information Panel**
        /// Route status and controls (shown when active)
        RoutePanel(controller: _controller),

        /// 🗺️ **Main Map View**
        /// Interactive map with all layers
        Expanded(
          child: Stack(
            children: [
              MapView(controller: _controller),

              /// 🎮 **Floating Controls**
              /// TTS, navigation, and zoom controls
              MapControls(controller: _controller),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// 🎯 **Key Benefits of This Refactored Structure:**
/// 
/// ✅ **Maintainability**: Each component has a single responsibility
/// ✅ **Readability**: Clean separation of concerns
/// ✅ **Testability**: Business logic isolated in controllers
/// ✅ **Reusability**: Widgets can be used in other screens
/// ✅ **Scalability**: Easy to add new features
/// ✅ **Team Collaboration**: Clear file organization
/// 
/// 📁 **File Structure:**
/// ```
/// features/maps/
/// ├── controllers/
/// │   └── map_controller.dart          # Business logic
/// ├── models/
/// │   └── map_state.dart              # State management
/// ├── widgets/
/// │   ├── map_header.dart             # Header component
/// │   ├── route_panel.dart            # Route info panel
/// │   ├── map_view.dart               # Core map widget
/// │   └── map_controls.dart           # Floating controls
/// └── presentation/
///     ├── maps_screen.dart            # Main screen
///     ├── maps_screen_backup.dart     # Original backup
///     └── tts_demo_screen.dart        # TTS demo
/// ```
