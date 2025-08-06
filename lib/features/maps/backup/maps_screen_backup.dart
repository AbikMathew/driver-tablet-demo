// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';

// import '../../../core/services/amazon_location_service.dart';
// import '../../../core/services/navigation_tts_service.dart';
// import 'amazon_location_demo_screen.dart';
// import 'tts_demo_screen.dart';

// class MapsScreen extends StatefulWidget {
//   const MapsScreen({super.key});

//   @override
//   State<MapsScreen> createState() => _MapsScreenState();
// }

// class _MapsScreenState extends State<MapsScreen> {
//   /// 🎯 **Key Learning Point 1: MapController**
//   /// The MapController is your main interface to programmatically control the map
//   /// - Move to locations: animatedMove()
//   /// - Get current center: controller.camera.center
//   /// - Set zoom levels: controller.camera.zoom
//   late final MapController _mapController;

//   /// 🎯 **Key Learning Point 2: Map Configuration**
//   /// These are fundamental settings for your map behavior
//   static const double _defaultZoom = 15.0;
//   static const LatLng _defaultCenter = LatLng(
//     37.7749,
//     -122.4194,
//   ); // San Francisco

//   /// 🎯 **Key Learning Point 8: Interactive Markers**
//   /// We'll store markers that users can interact with
//   List<Marker> _markers = [];
//   LatLng? _selectedLocation;

//   /// 🎯 **Key Learning Point 16: Current Location State**
//   /// Track user's current location for navigation
//   LatLng? _currentLocation;
//   bool _isLocationLoading = false;
//   String _locationStatus = 'Location not available';

//   /// 🎯 **Key Learning Point 21: Routing State**
//   /// Track route information for navigation
//   List<LatLng> _routePoints = [];
//   LatLng? _routeDestination;
//   bool _isRouting = false;
//   String _routeInfo = '';
//   double _routeDistance = 0.0;

//   /// 🎯 **Key Learning Point 22: Route Colors & Styles**
//   /// Different route types with different visual styles
//   final Map<String, Color> _routeColors = {
//     'active': Colors.blue,
//     'alternative': Colors.grey,
//     'completed': Colors.green,
//   };

//   /// 🎯 **Key Learning Point 40: Amazon Location Service Integration**
//   /// Real-world routing service for production use
//   final AmazonLocationService _amazonLocationService = AmazonLocationService();
//   AmazonRouteResponse? _currentRoute;
//   List<AmazonRouteResponse> _alternativeRoutes = [];
//   TrafficUpdate? _trafficUpdate;

//   /// 🎯 **Key Learning Point 61: Text-to-Speech Navigation**
//   /// Voice guidance system for hands-free navigation
//   final NavigationTTSService _ttsService = NavigationTTSService();
//   bool _isNavigationActive = false;
//   bool _isTTSEnabled = true;
//   final String _lastAnnouncedInstruction = '';
//   final DateTime _lastAnnouncementTime = DateTime.now();

//   /// 🎯 **Key Learning Point 9: Demo Locations**
//   /// Some interesting locations in San Francisco for testing
//   final List<LatLng> _demoLocations = [
//     const LatLng(37.7749, -122.4194), // San Francisco City Hall
//     const LatLng(37.8075, -122.4158), // Fisherman's Wharf
//     const LatLng(37.8020, -122.4058), // Lombard Street
//     const LatLng(37.7699, -122.4781), // Golden Gate Park
//     const LatLng(37.8199, -122.4783), // Golden Gate Bridge
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _mapController = MapController();
//     _setupDemoMarkers();
//     _initializeLocation();
//     _initializeTTS();
//   }

//   /// 🎯 **Key Learning Point 62: TTS Initialization**
//   /// Initialize text-to-speech service for voice navigation
//   Future<void> _initializeTTS() async {
//     try {
//       await _ttsService.initialize();
//       debugPrint('✅ TTS Service initialized successfully');

//       // Test TTS with a welcome message
//       if (_isTTSEnabled) {
//         await _ttsService.testVoice();
//       }
//     } catch (e) {
//       debugPrint('❌ TTS initialization failed: $e');
//     }
//   }

//   /// 🎯 **Key Learning Point 17: Location Initialization**
//   /// This is the proper way to set up location services
//   Future<void> _initializeLocation() async {
//     setState(() {
//       _isLocationLoading = true;
//       _locationStatus = 'Checking location permissions...';
//     });

//     try {
//       /// 🔍 **Learning Focus: Permission Handling**
//       /// Always check and request location permissions first
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         setState(() {
//           _locationStatus = 'Location services are disabled';
//           _isLocationLoading = false;
//         });
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           setState(() {
//             _locationStatus = 'Location permissions denied';
//             _isLocationLoading = false;
//           });
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         setState(() {
//           _locationStatus = 'Location permissions permanently denied';
//           _isLocationLoading = false;
//         });
//         return;
//       }

//       /// 🔍 **Learning Focus: Getting Current Position**
//       /// Different accuracy levels and timeout settings
//       await _getCurrentLocation();
//     } catch (e) {
//       setState(() {
//         _locationStatus = 'Error getting location: $e';
//         _isLocationLoading = false;
//       });
//     }
//   }

//   /// 🎯 **Key Learning Point 18: Get Current Location**
//   /// How to get the user's current position with proper error handling
//   Future<void> _getCurrentLocation() async {
//     try {
//       setState(() {
//         _isLocationLoading = true;
//         _locationStatus = 'Getting current location...';
//       });

//       Position position = await Geolocator.getCurrentPosition(
//         /// 🔍 **Learning Focus: Location Accuracy Settings**
//         desiredAccuracy: LocationAccuracy.high, // Best accuracy
//         timeLimit: const Duration(seconds: 10), // Timeout after 10 seconds
//       );

//       setState(() {
//         _currentLocation = LatLng(position.latitude, position.longitude);
//         _locationStatus =
//             'Location found: ${position.accuracy.toStringAsFixed(1)}m accuracy';
//         _isLocationLoading = false;
//       });

//       // Update markers to include current location
//       _updateMarkersWithCurrentLocation();

//       // Center map on current location
//       _mapController.move(_currentLocation!, 16.0);
//     } catch (e) {
//       setState(() {
//         _locationStatus = 'Failed to get location: $e';
//         _isLocationLoading = false;
//       });
//     }
//   }

//   /// 🎯 **Key Learning Point 19: Current Location Marker**
//   /// Add a special marker for the user's current location
//   void _updateMarkersWithCurrentLocation() {
//     if (_currentLocation == null) return;

//     // Remove any existing current location marker
//     _markers.removeWhere(
//       (marker) =>
//           marker.child is Column &&
//           (marker.child as Column).children.first is Container &&
//           ((marker.child as Column).children.first as Container).decoration
//               is BoxDecoration &&
//           (((marker.child as Column).children.first as Container).decoration
//                       as BoxDecoration)
//                   .color ==
//               Colors.green[700],
//     );

//     // Add current location marker
//     final currentLocationMarker = Marker(
//       point: _currentLocation!,
//       width: 60.0,
//       height: 60.0,
//       alignment: Alignment.center,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.blue[600],
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.white, width: 3),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               offset: const Offset(0, 2),
//               blurRadius: 6,
//             ),
//           ],
//         ),
//         child: const Icon(Icons.my_location, color: Colors.white, size: 24),
//       ),
//     );

//     setState(() {
//       _markers.add(currentLocationMarker);
//     });
//   }

//   /// 🎯 **Key Learning Point 10: Creating Markers**
//   /// This shows you how to create markers programmatically
//   void _setupDemoMarkers() {
//     final List<String> markerLabels = [
//       'City Hall',
//       'Fisherman\'s Wharf',
//       'Lombard Street',
//       'Golden Gate Park',
//       'Golden Gate Bridge',
//     ];

//     _markers =
//         _demoLocations.asMap().entries.map((entry) {
//           final index = entry.key;
//           final location = entry.value;

//           return Marker(
//             /// 🔍 **Learning Focus: Marker Properties**
//             point: location, // Where to place the marker
//             width: 80.0, // Marker width
//             height: 80.0, // Marker height
//             alignment: Alignment.topCenter, // How to align the marker
//             /// 🔍 **Learning Focus: Custom Marker Widget**
//             /// You can use any Flutter widget as a marker!
//             child: GestureDetector(
//               onTap: () => _onMarkerTapped(location, markerLabels[index]),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color:
//                           _selectedLocation == location
//                               ? Colors.blue
//                               : Colors.red,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.3),
//                           offset: const Offset(0, 2),
//                           blurRadius: 4,
//                         ),
//                       ],
//                     ),
//                     child: Text(
//                       markerLabels[index],
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color:
//                           _selectedLocation == location
//                               ? Colors.blue
//                               : Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   Container(
//                     width: 2,
//                     height: 10,
//                     color:
//                         _selectedLocation == location
//                             ? Colors.blue
//                             : Colors.red,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         /// 🎯 **Key Learning Point 3: Map Info Header**
//         /// Always good to show users current map status
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.blue.shade50,
//             border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 _currentLocation != null
//                     ? Icons.location_on
//                     : Icons.location_off,
//                 color: _currentLocation != null ? Colors.green : Colors.red,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Flutter Map with Location',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     Text(
//                       _locationStatus,
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 12,
//                       ),
//                     ),

//                     /// 🎯 **Key Learning Point 74: Navigation Status Display**
//                     /// Show current TTS and navigation state
//                     if (_isNavigationActive || !_isTTSEnabled)
//                       Row(
//                         children: [
//                           if (_isNavigationActive) ...[
//                             Icon(
//                               Icons.navigation,
//                               size: 12,
//                               color: Colors.green,
//                             ),
//                             SizedBox(width: 4),
//                             Text(
//                               'Navigation Active',
//                               style: TextStyle(
//                                 color: Colors.green,
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                           if (_isNavigationActive && !_isTTSEnabled)
//                             SizedBox(width: 8),
//                           if (!_isTTSEnabled) ...[
//                             Icon(
//                               Icons.volume_off,
//                               size: 12,
//                               color: Colors.orange,
//                             ),
//                             SizedBox(width: 4),
//                             Text(
//                               'Voice Muted',
//                               style: TextStyle(
//                                 color: Colors.orange,
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//               if (_isLocationLoading)
//                 const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//               else ...[
//                 IconButton(
//                   icon: const Icon(Icons.my_location),
//                   onPressed:
//                       _currentLocation != null
//                           ? () => _mapController.move(_currentLocation!, 16.0)
//                           : _getCurrentLocation,
//                   tooltip:
//                       _currentLocation != null
//                           ? 'Center on current location'
//                           : 'Get current location',
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.refresh),
//                   onPressed: _getCurrentLocation,
//                   tooltip: 'Refresh location',
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.info),
//                   onPressed:
//                       () => Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder:
//                               (context) => const AmazonLocationDemoScreen(),
//                         ),
//                       ),
//                   tooltip: 'Amazon LS Demo',
//                 ),

//                 /// 🎯 **Key Learning Point 75: TTS Demo Access**
//                 /// Direct access to comprehensive TTS testing
//                 IconButton(
//                   icon: const Icon(Icons.record_voice_over),
//                   onPressed:
//                       () => Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => const TTSDemoScreen(),
//                         ),
//                       ),
//                   tooltip: 'TTS Demo',
//                 ),
//               ],
//             ],
//           ),
//         ),

//         /// 🎯 **Key Learning Point 30: Route Information Panel**
//         /// Show current route status and controls
//         if (_routePoints.isNotEmpty || _isRouting)
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.green.shade50,
//               border: Border(bottom: BorderSide(color: Colors.green.shade200)),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   _isRouting ? Icons.route : Icons.navigation,
//                   color: _isRouting ? Colors.orange : Colors.green,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         _isRouting ? 'Calculating Route...' : 'Route Active',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                       if (_routeInfo.isNotEmpty)
//                         Text(
//                           _routeInfo,
//                           style: TextStyle(
//                             color: Colors.grey.shade600,
//                             fontSize: 12,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 if (_isRouting)
//                   const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 else if (_routePoints.isNotEmpty) ...[
//                   IconButton(
//                     icon: const Icon(Icons.center_focus_strong),
//                     onPressed: _fitRouteBounds,
//                     tooltip: 'Center route',
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.clear),
//                     onPressed: _clearRoute,
//                     tooltip: 'Clear route',
//                   ),
//                 ],
//               ],
//             ),
//           ),

//         /// 🎯 **Key Learning Point 4: The FlutterMap Widget**
//         /// This is the core widget that renders your interactive map
//         Expanded(
//           child: Stack(
//             children: [
//               FlutterMap(
//                 mapController: _mapController,
//                 options: MapOptions(
//                   /// 🔍 **Learning Focus: MapOptions**
//                   /// - initialCenter: Where the map starts
//                   /// - initialZoom: How zoomed in (1-18+, higher = more zoomed)
//                   /// - minZoom/maxZoom: Zoom limits
//                   /// - interactionOptions: Control user interactions
//                   initialCenter: _defaultCenter,
//                   initialZoom: _defaultZoom,
//                   minZoom: 3.0,
//                   maxZoom: 18.0,

//                   /// 🔍 **Learning Focus: Interaction Control**
//                   interactionOptions: const InteractionOptions(
//                     flags: InteractiveFlag.all, // Enable all interactions
//                   ),

//                   /// 🎯 **Key Learning Point 12: Map Tap Events**
//                   /// Handle user taps on the map to add new markers
//                   onTap: _onMapTapped,
//                 ),
//                 children: [
//                   /// 🎯 **Key Learning Point 5: TileLayer - The Map Tiles**
//                   /// This is what actually draws the map imagery
//                   TileLayer(
//                     /// 🔍 **Learning Focus: OpenStreetMap Tiles**
//                     /// - {s}: Server subdomain (a, b, c for load balancing)
//                     /// - {z}: Zoom level
//                     /// - {x}, {y}: Tile coordinates
//                     urlTemplate:
//                         'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

//                     /// 🔍 **Learning Focus: Attribution & User Agent**
//                     /// Always important to respect tile server requirements
//                     userAgentPackageName: 'com.example.driver_tablet_demo',

//                     /// 🔍 **Learning Focus: Tile Display Options**
//                     maxZoom: 18,

//                     /// 🔍 **Learning Focus: Error Handling**
//                     errorTileCallback: (tile, error, stackTrace) {
//                       debugPrint('🗺️ Tile Error: $error');
//                     },
//                   ),

//                   /// 🎯 **Key Learning Point 6: Attribution Layer**
//                   /// Required for OpenStreetMap usage - always include this!
//                   const RichAttributionWidget(
//                     attributions: [
//                       TextSourceAttribution(
//                         '© OpenStreetMap contributors',
//                         // You can add onTap to link to OSM website
//                       ),
//                     ],
//                   ),

//                   /// 🎯 **Key Learning Point 23: PolylineLayer - Drawing Routes**
//                   /// This layer displays route lines between locations
//                   PolylineLayer(polylines: _buildPolylines()),

//                   /// 🎯 **Key Learning Point 11: MarkerLayer**
//                   /// This layer displays all your markers on top of the map
//                   MarkerLayer(markers: _markers),
//                 ],
//               ),

//               /// 🎯 **Key Learning Point 7: Map Controls**
//               /// Floating controls for common map operations
//               Positioned(
//                 right: 16,
//                 bottom: 100,
//                 child: Column(
//                   children: [
//                     /// 🎯 **Key Learning Point 72: TTS Control Button**
//                     /// Voice guidance toggle for navigation
//                     FloatingActionButton.small(
//                       heroTag: "tts_toggle",
//                       onPressed: _toggleTTS,
//                       backgroundColor:
//                           _isTTSEnabled ? Colors.blue : Colors.grey,
//                       child: Icon(
//                         _isTTSEnabled ? Icons.volume_up : Icons.volume_off,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 8),

//                     /// 🎯 **Key Learning Point 73: Navigation Control Button**
//                     /// Start/stop turn-by-turn navigation
//                     if (_currentRoute != null)
//                       FloatingActionButton.small(
//                         heroTag: "navigation_toggle",
//                         onPressed:
//                             _isNavigationActive
//                                 ? _stopNavigation
//                                 : _startNavigation,
//                         backgroundColor:
//                             _isNavigationActive ? Colors.red : Colors.green,
//                         child: Icon(
//                           _isNavigationActive ? Icons.stop : Icons.navigation,
//                           color: Colors.white,
//                         ),
//                       ),
//                     if (_currentRoute != null) const SizedBox(height: 8),

//                     FloatingActionButton.small(
//                       heroTag: "zoom_in",
//                       onPressed: _zoomIn,
//                       child: const Icon(Icons.zoom_in),
//                     ),
//                     const SizedBox(height: 8),
//                     FloatingActionButton.small(
//                       heroTag: "zoom_out",
//                       onPressed: _zoomOut,
//                       child: const Icon(Icons.zoom_out),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   /// 🎯 **Key Learning Point 8: Programmatic Map Control**
//   /// These methods show you how to control the map from code

//   void _zoomIn() {
//     final currentZoom = _mapController.camera.zoom;
//     _mapController.move(_mapController.camera.center, currentZoom + 1);
//   }

//   void _zoomOut() {
//     final currentZoom = _mapController.camera.zoom;
//     _mapController.move(_mapController.camera.center, currentZoom - 1);
//   }

//   /// 🎯 **Key Learning Point 13: Marker Interaction**
//   /// Handle when user taps on a marker
//   void _onMarkerTapped(LatLng location, String label) {
//     setState(() {
//       _selectedLocation = location;
//       _setupDemoMarkers(); // Rebuild markers with new selection
//     });

//     // Calculate distance to selected location
//     String distanceInfo = '';
//     if (_currentLocation != null) {
//       final distance = _calculateDistance(_currentLocation!, location);
//       distanceInfo = ' • $distance away';
//     }

//     // Show information about the selected location
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Selected: $label$distanceInfo'),
//         duration: const Duration(seconds: 3),
//         action: SnackBarAction(
//           label: 'Navigate',
//           onPressed: () => _navigateToLocation(location),
//         ),
//       ),
//     );
//   }

//   /// 🎯 **Key Learning Point 14: Map Tap Events**
//   /// Handle when user taps on empty map area
//   void _onMapTapped(TapPosition tapPosition, LatLng location) {
//     setState(() {
//       _selectedLocation = location;

//       // Add a new temporary marker at tap location
//       _markers.add(
//         Marker(
//           point: location,
//           width: 60.0,
//           height: 60.0,
//           alignment: Alignment.topCenter,
//           child: GestureDetector(
//             onTap: () => _onMarkerTapped(location, 'Custom Location'),
//             child: Column(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.green,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         offset: const Offset(0, 2),
//                         blurRadius: 4,
//                       ),
//                     ],
//                   ),
//                   child: const Icon(Icons.place, color: Colors.white, size: 20),
//                 ),
//                 Container(width: 2, height: 10, color: Colors.green),
//               ],
//             ),
//           ),
//         ),
//       );
//     });

//     // Show coordinates in a snackbar
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Tapped at: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
//         ),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   /// 🎯 **Key Learning Point 15: Navigation to Location**
//   /// Animate the map to a specific location and calculate route
//   void _navigateToLocation(LatLng location) {
//     // Start route calculation
//     _calculateRoute(location);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('🧭 Calculating route...'),
//         duration: const Duration(seconds: 2),
//         action: SnackBarAction(label: 'Cancel', onPressed: _clearRoute),
//       ),
//     );
//   }

//   /// 🎯 **Key Learning Point 20: Distance Calculation**
//   /// Calculate distance between two geographic points
//   String _calculateDistance(LatLng from, LatLng to) {
//     final distance = Geolocator.distanceBetween(
//       from.latitude,
//       from.longitude,
//       to.latitude,
//       to.longitude,
//     );

//     if (distance < 1000) {
//       return '${distance.toStringAsFixed(0)}m';
//     } else {
//       return '${(distance / 1000).toStringAsFixed(1)}km';
//     }
//   }

//   /// 🎯 **Key Learning Point 24: Building Polylines**
//   /// Create polyline objects for rendering routes on the map
//   List<Polyline> _buildPolylines() {
//     List<Polyline> polylines = [];

//     // Add main route if we have route points
//     if (_routePoints.isNotEmpty) {
//       polylines.add(
//         Polyline(
//           points: _routePoints,
//           color: _routeColors['active']!,
//           strokeWidth: 5.0,

//           /// 🔍 **Learning Focus: Polyline Styling**
//           /// - strokeWidth: Line thickness
//           /// - color: Route color (blue for active)
//           /// - borderStrokeWidth: Outline thickness
//           /// - borderColor: Outline color for better visibility
//           borderStrokeWidth: 2.0,
//           borderColor: Colors.white,
//         ),
//       );
//     }

//     // Add a demo route connecting current location to selected location
//     if (_currentLocation != null && _selectedLocation != null) {
//       polylines.add(
//         Polyline(
//           points: [_currentLocation!, _selectedLocation!],
//           color: _routeColors['alternative']!,
//           strokeWidth: 3.0,
//           borderStrokeWidth: 1.0,
//           borderColor: Colors.white,

//           /// 🔍 **Learning Focus: Pattern Effects**
//           /// You can add dashed patterns for different route types
//           pattern: StrokePattern.dashed(segments: [5, 3]),
//         ),
//       );
//     }

//     return polylines;
//   }

//   /// 🎯 **Key Learning Point 41: Amazon Location Service Route Calculation**
//   /// Real routing with traffic awareness and road closure handling
//   Future<void> _calculateRoute(LatLng destination) async {
//     if (_currentLocation == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('❌ Current location not available for routing'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isRouting = true;
//       _routeDestination = destination;
//       _routeInfo = 'Calculating route with Amazon Location Service...';
//     });

//     try {
//       /// 🔍 **Learning Focus: Real Amazon LS Integration**
//       /// This is how you'd call Amazon Location Service in production
//       _currentRoute = await _amazonLocationService.calculateRoute(
//         departure: _currentLocation!,
//         destination: destination,
//         travelMode: 'Car',
//         avoidTolls: false,
//         avoidFerries: false,
//       );

//       /// 🔍 **Learning Focus: Extract Route Geometry**
//       /// Amazon LS returns precise GPS coordinates for the route
//       _routePoints = _currentRoute!.polylinePoints;
//       _routeDistance =
//           _currentRoute!.summary.distance * 1000; // Convert to meters

//       /// 🔍 **Learning Focus: Get Alternative Routes**
//       /// Always good to provide options, especially for road closures
//       _alternativeRoutes = await _amazonLocationService.getAlternativeRoutes(
//         departure: _currentLocation!,
//         destination: destination,
//         avoidanceReasons: ['Tolls'], // Example: avoid tolls for alternatives
//       );

//       /// 🔍 **Learning Focus: Check Traffic Conditions**
//       /// Real-time traffic updates for better user experience
//       _trafficUpdate = await _amazonLocationService.getTrafficUpdate(
//         _currentRoute!.summary.routeId,
//       );

//       setState(() {
//         _isRouting = false;
//         _routeInfo = _buildRouteInfoText();
//       });

//       /// 🎯 **Key Learning Point 63: Route Start Announcement**
//       /// Voice guidance for journey overview
//       if (_isTTSEnabled) {
//         await _announceRouteStart();
//       }

//       /// 🎯 **Key Learning Point 64: Start Navigation Mode**
//       /// Begin turn-by-turn navigation with voice guidance
//       _startNavigation();

//       // Center map to show entire route
//       _fitRouteBounds();

//       // Show traffic alerts if any
//       _showTrafficAlerts();
//     } catch (e) {
//       setState(() {
//         _isRouting = false;
//         _routeInfo = 'Amazon LS routing failed: $e';
//       });

//       // Fallback to simple routing
//       print('🔄 Falling back to simple routing...');
//       await _generateSimpleRoute(_currentLocation!, destination);
//     }
//   }

//   /// 🎯 **Key Learning Point 26: Generate Simple Route**
//   /// Create intermediate points for a more realistic looking route
//   Future<void> _generateSimpleRoute(LatLng start, LatLng end) async {
//     /// 🔍 **Learning Focus: Route Point Generation**
//     /// This creates a simple curved route between two points
//     /// In a real app, you'd use routing APIs like:
//     /// - OpenRouteService
//     /// - OSRM (Open Source Routing Machine)
//     /// - Mapbox Directions API
//     /// - Google Directions API

//     List<LatLng> routePoints = [start];

//     // Add intermediate points for a more realistic route
//     double latDiff = end.latitude - start.latitude;
//     double lngDiff = end.longitude - start.longitude;

//     // Create 5 intermediate points with slight curves
//     for (int i = 1; i < 5; i++) {
//       double ratio = i / 5.0;

//       // Add some randomness to create curves
//       double curveFactor = 0.0002; // Small offset for realistic curves
//       double offsetLat = (i % 2 == 0 ? curveFactor : -curveFactor);
//       double offsetLng = (i % 3 == 0 ? curveFactor : -curveFactor);

//       LatLng intermediatePoint = LatLng(
//         start.latitude + (latDiff * ratio) + offsetLat,
//         start.longitude + (lngDiff * ratio) + offsetLng,
//       );

//       routePoints.add(intermediatePoint);
//     }

//     routePoints.add(end);

//     setState(() {
//       _routePoints = routePoints;
//     });

//     // Simulate network delay
//     await Future.delayed(const Duration(milliseconds: 1500));
//   }

//   /// 🎯 **Key Learning Point 29: Clear Route**
//   /// Remove current route and reset routing state

//   /// 🎯 **Key Learning Point 28: Fit Route Bounds**
//   /// Automatically zoom and center the map to show the entire route
//   void _fitRouteBounds() {
//     if (_routePoints.isEmpty) return;

//     // Calculate bounds of the route
//     double minLat = _routePoints
//         .map((p) => p.latitude)
//         .reduce((a, b) => a < b ? a : b);
//     double maxLat = _routePoints
//         .map((p) => p.latitude)
//         .reduce((a, b) => a > b ? a : b);
//     double minLng = _routePoints
//         .map((p) => p.longitude)
//         .reduce((a, b) => a < b ? a : b);
//     double maxLng = _routePoints
//         .map((p) => p.longitude)
//         .reduce((a, b) => a > b ? a : b);

//     // Add padding
//     double padding = 0.01; // Degrees of padding
//     LatLng southwest = LatLng(minLat - padding, minLng - padding);
//     LatLng northeast = LatLng(maxLat + padding, maxLng + padding);

//     // Center on the middle of the bounds
//     LatLng center = LatLng(
//       (southwest.latitude + northeast.latitude) / 2,
//       (southwest.longitude + northeast.longitude) / 2,
//     );

//     _mapController.move(
//       center,
//       12.0,
//     ); // Zoom level that typically shows city-wide routes
//   }

//   /// 🎯 **Key Learning Point 29: Clear Route**
//   /// Remove current route and reset routing state
//   void _clearRoute() {
//     setState(() {
//       _routePoints.clear();
//       _routeDestination = null;
//       _isRouting = false;
//       _routeInfo = '';
//       _routeDistance = 0.0;
//       _currentRoute = null;
//       _alternativeRoutes.clear();
//       _trafficUpdate = null;
//     });
//   }

//   /// 🎯 **Key Learning Point 42: Route Information Display**
//   /// Format route data for user-friendly display
//   String _buildRouteInfoText() {
//     if (_currentRoute == null) return '';

//     String baseInfo =
//         'Route: ${_currentRoute!.summary.formattedDistance} • ${_currentRoute!.summary.formattedDuration}';

//     if (_trafficUpdate != null && _trafficUpdate!.delays.isNotEmpty) {
//       int totalDelay = _trafficUpdate!.totalDelayMinutes;
//       baseInfo += ' • +${totalDelay}m delay';
//     }

//     return baseInfo;
//   }

//   /// 🎯 **Key Learning Point 43: Traffic Alert System**
//   /// Handle road closures and traffic incidents
//   void _showTrafficAlerts() {
//     if (_trafficUpdate == null || _trafficUpdate!.delays.isEmpty) return;

//     // Find highest severity issue
//     TrafficDelay mostSevere = _trafficUpdate!.delays.reduce(
//       (a, b) => a.severity == 'High' ? a : (b.severity == 'High' ? b : a),
//     );

//     if (mostSevere.severity == 'High') {
//       _showRoadClosureDialog(mostSevere);
//     } else {
//       _showTrafficSnackBar();
//     }
//   }

//   /// 🎯 **Key Learning Point 44: Road Closure Handling**
//   /// Critical for driver safety and route reliability
//   void _showRoadClosureDialog(TrafficDelay closure) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Row(
//               children: [
//                 Icon(Icons.warning, color: Colors.red),
//                 SizedBox(width: 8),
//                 Text('Road Closure Alert'),
//               ],
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   closure.reason,
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 8),
//                 Text('Additional delay: ${closure.delayMinutes} minutes'),
//                 SizedBox(height: 12),
//                 Text('Would you like to see alternative routes?'),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: Text('Continue Current Route'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   _showAlternativeRoutes();
//                 },
//                 child: Text('Show Alternatives'),
//               ),
//             ],
//           ),
//     );
//   }

//   /// 🎯 **Key Learning Point 45: Alternative Route Selection**
//   /// Essential for handling road closures and traffic
//   void _showAlternativeRoutes() {
//     showModalBottomSheet(
//       context: context,
//       builder:
//           (context) => Container(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Alternative Routes',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 16),
//                 ...(_alternativeRoutes
//                     .take(3)
//                     .map(
//                       (route) => ListTile(
//                         leading: Icon(Icons.route, color: Colors.blue),
//                         title: Text(
//                           '${route.summary.formattedDistance} • ${route.summary.formattedDuration}',
//                         ),
//                         subtitle: Text('Via alternate roads'),
//                         trailing: Icon(Icons.arrow_forward),
//                         onTap: () {
//                           Navigator.of(context).pop();
//                           _selectAlternativeRoute(route);
//                         },
//                       ),
//                     )
//                     .toList()),
//                 SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text('Keep Current Route'),
//                 ),
//               ],
//             ),
//           ),
//     );
//   }

//   /// 🎯 **Key Learning Point 46: Route Switching**
//   /// Seamlessly switch between routes based on conditions
//   void _selectAlternativeRoute(AmazonRouteResponse newRoute) {
//     setState(() {
//       _currentRoute = newRoute;
//       _routePoints = newRoute.polylinePoints;
//       _routeDistance = newRoute.summary.distance * 1000;
//       _routeInfo =
//           'Alternative route: ${newRoute.summary.formattedDistance} • ${newRoute.summary.formattedDuration}';
//     });

//     _fitRouteBounds();

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('✅ Switched to alternative route'),
//         backgroundColor: Colors.green,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   void _showTrafficSnackBar() {
//     int totalDelay = _trafficUpdate!.totalDelayMinutes;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('⚠️ Traffic delay: +$totalDelay minutes'),
//         backgroundColor: Colors.orange,
//         duration: Duration(seconds: 4),
//         action: SnackBarAction(
//           label: 'Alternatives',
//           onPressed: _showAlternativeRoutes,
//         ),
//       ),
//     );
//   }

//   /// 🎯 **Key Learning Point 65: Route Start Voice Announcement**
//   /// Provide journey overview when navigation begins
//   Future<void> _announceRouteStart() async {
//     if (_currentRoute == null) return;

//     String destination =
//         "your destination"; // In real app, get from address lookup
//     await _ttsService.announceRouteStart(
//       totalDistance: _currentRoute!.summary.distance * 1000,
//       estimatedDuration: _currentRoute!.summary.durationSeconds,
//       destination: destination,
//     );
//   }

//   /// 🎯 **Key Learning Point 66: Start Navigation Mode**
//   /// Begin turn-by-turn voice guidance
//   void _startNavigation() {
//     setState(() {
//       _isNavigationActive = true;
//     });

//     // Start location tracking for turn-by-turn navigation
//     _startLocationTracking();

//     debugPrint('🧭 Navigation started with voice guidance');
//   }

//   /// 🎯 **Key Learning Point 67: Continuous Location Tracking**
//   /// Monitor user position for navigation updates
//   void _startLocationTracking() {
//     // This would typically use a Stream for continuous updates
//     // For demo purposes, we'll simulate navigation announcements
//     _simulateNavigationAnnouncements();
//   }

//   /// 🎯 **Key Learning Point 68: Simulated Navigation Announcements**
//   /// Demo of how voice guidance works during navigation
//   Future<void> _simulateNavigationAnnouncements() async {
//     if (!_isNavigationActive || !_isTTSEnabled) return;

//     // Simulate upcoming turn announcements
//     await Future.delayed(Duration(seconds: 3));
//     if (_isNavigationActive) {
//       await _ttsService.announceNavigationInstruction(
//         instruction: "Turn right onto Market Street",
//         distanceToTurn: 200,
//         isImmediate: false,
//       );
//     }

//     await Future.delayed(Duration(seconds: 8));
//     if (_isNavigationActive) {
//       await _ttsService.announceNavigationInstruction(
//         instruction: "Turn right",
//         distanceToTurn: 50,
//         isImmediate: true,
//       );
//     }

//     await Future.delayed(Duration(seconds: 15));
//     if (_isNavigationActive) {
//       await _ttsService.announceNavigationInstruction(
//         instruction: "Continue straight for 500 meters",
//         distanceToTurn: 500,
//         isImmediate: false,
//       );
//     }

//     // Simulate traffic alert
//     await Future.delayed(Duration(seconds: 10));
//     if (_isNavigationActive) {
//       await _ttsService.announceTrafficAlert(
//         alertType: 'delay',
//         delayMinutes: 3,
//         alternativeAvailable: 'Alternative route available.',
//       );
//     }
//   }

//   /// 🎯 **Key Learning Point 69: Stop Navigation**
//   /// End voice guidance and navigation mode
//   void _stopNavigation() {
//     setState(() {
//       _isNavigationActive = false;
//     });

//     _ttsService.stop();
//     debugPrint('🛑 Navigation stopped');
//   }

//   /// 🎯 **Key Learning Point 70: Toggle TTS**
//   /// Allow users to enable/disable voice guidance
//   void _toggleTTS() {
//     setState(() {
//       _isTTSEnabled = !_isTTSEnabled;
//     });

//     if (_isTTSEnabled) {
//       _ttsService.testVoice();
//     } else {
//       _ttsService.stop();
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           _isTTSEnabled
//               ? '🔊 Voice guidance enabled'
//               : '🔇 Voice guidance disabled',
//         ),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   /// 🎯 **Key Learning Point 71: Arrival Announcement**
//   /// Voice notification when reaching destination
//   Future<void> _announceArrival() async {
//     if (!_isTTSEnabled) return;

//     await _ttsService.announceArrival(
//       locationType: 'destination',
//       locationName: 'your destination',
//     );

//     _stopNavigation();
//   }

//   @override
//   void dispose() {
//     _ttsService.dispose();
//     super.dispose();
//   }
// }
