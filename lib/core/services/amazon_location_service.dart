import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// 🎯 **Amazon Location Service Integration**
/// This service handles all interactions with Amazon Location Service for routing
class AmazonLocationService {
  final Dio _dio = Dio();

  /// 🔍 **Learning Focus: AWS Configuration**
  /// In production, these would come from environment variables or AWS Cognito
  static const String _region = 'us-east-1';
  static const String _calculatorName = 'your-route-calculator-name';

  /// 🎯 **Key Learning Point 31: Route Request Structure**
  /// This is exactly what Amazon Location Service expects
  Future<AmazonRouteResponse> calculateRoute({
    required LatLng departure,
    required LatLng destination,
    List<LatLng>? waypoints,
    String travelMode = 'Car',
    bool avoidTolls = false,
    bool avoidFerries = false,
  }) async {
    try {
      /// 🔍 **Learning Focus: Real Amazon LS Request Format**
      final requestData = {
        'DeparturePosition': [departure.longitude, departure.latitude],
        'DestinationPosition': [destination.longitude, destination.latitude],
        'TravelMode': travelMode, // Car, Truck, Walking, Bicycle
        'DepartureTime': DateTime.now().toIso8601String(),
        'DistanceUnit': 'Kilometers',
        'IncludeLegGeometry': true,
        'CarModeOptions': {
          'AvoidFerries': avoidFerries,
          'AvoidTolls': avoidTolls,
        },
        if (waypoints != null && waypoints.isNotEmpty)
          'WaypointPositions':
              waypoints.map((wp) => [wp.longitude, wp.latitude]).toList(),
      };

      print('🌍 Amazon LS Request: ${jsonEncode(requestData)}');

      /// 🔍 **Learning Focus: AWS API Endpoint Structure**
      final url =
          'https://routes.$_region.amazonaws.com/routes/v0/calculators/$_calculatorName/calculate/route';

      /// 🎯 **Key Learning Point 32: AWS Signature V4 Authentication**
      /// In production, you'd use AWS SDK or implement Signature V4
      final response = await _dio.post(
        url,
        data: jsonEncode(requestData),
        options: Options(
          headers: {
            'Content-Type': 'application/x-amz-json-1.0',
            'X-Amz-Target': 'com.amazon.geo.routes.CalculateRoute',
            // In production, add AWS authentication headers:
            // 'Authorization': 'AWS4-HMAC-SHA256 Credential=...',
            // 'X-Amz-Date': '20250731T120000Z',
          },
        ),
      );

      return AmazonRouteResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Amazon LS Error: $e');
      // Fallback to demo data for learning purposes
      return _createDemoResponse(departure, destination);
    }
  }

  /// 🎯 **Key Learning Point 33: Demo Response Structure**
  /// This shows exactly what Amazon Location Service returns
  AmazonRouteResponse _createDemoResponse(
    LatLng departure,
    LatLng destination,
  ) {
    return AmazonRouteResponse(
      summary: RouteSummary(
        routeId: 'demo-route-${DateTime.now().millisecondsSinceEpoch}',
        distance: 12.5, // kilometers
        durationSeconds: 1800, // 30 minutes
        dataSource: 'Here', // Amazon LS uses Here Technologies data
      ),
      legs: [
        RouteLeg(
          distance: 12.5,
          durationSeconds: 1800,
          startPosition: [departure.longitude, departure.latitude],
          endPosition: [destination.longitude, destination.latitude],
          steps: _generateDemoSteps(departure, destination),
          geometry: _generateDemoGeometry(departure, destination),
        ),
      ],
    );
  }

  /// 🎯 **Key Learning Point 34: Turn-by-Turn Steps**
  /// Amazon LS provides detailed navigation instructions
  List<RouteStep> _generateDemoSteps(LatLng start, LatLng end) {
    return [
      RouteStep(
        distance: 0.2,
        durationSeconds: 60,
        instruction: 'Head north on Market St',
        type: 'Depart',
        position: [start.longitude, start.latitude],
      ),
      RouteStep(
        distance: 0.8,
        durationSeconds: 180,
        instruction: 'Turn right onto Van Ness Ave',
        type: 'Turn',
        position: [start.longitude + 0.001, start.latitude + 0.002],
      ),
      RouteStep(
        distance: 2.1,
        durationSeconds: 300,
        instruction: 'Continue straight for 2.1 km',
        type: 'Continue',
        position: [start.longitude + 0.005, start.latitude + 0.008],
      ),
      RouteStep(
        distance: 1.2,
        durationSeconds: 240,
        instruction: 'Turn left onto Golden Gate Ave',
        type: 'Turn',
        position: [start.longitude + 0.008, start.latitude + 0.012],
      ),
      RouteStep(
        distance: 8.2,
        durationSeconds: 960,
        instruction: 'Continue on Golden Gate Ave for 8.2 km',
        type: 'Continue',
        position: [start.longitude + 0.015, start.latitude + 0.020],
      ),
      RouteStep(
        distance: 0.0,
        durationSeconds: 0,
        instruction: 'Arrive at destination',
        type: 'Arrive',
        position: [end.longitude, end.latitude],
      ),
    ];
  }

  /// 🎯 **Key Learning Point 35: Route Geometry**
  /// Amazon LS returns detailed coordinate points for drawing the route
  List<List<double>> _generateDemoGeometry(LatLng start, LatLng end) {
    List<List<double>> points = [];

    // Start point
    points.add([start.longitude, start.latitude]);

    // Generate intermediate points for smooth route
    double latDiff = end.latitude - start.latitude;
    double lngDiff = end.longitude - start.longitude;

    for (int i = 1; i < 20; i++) {
      double ratio = i / 20.0;
      // Add slight curves for realistic routing
      double curveFactor = 0.0001 * (i % 3 - 1);

      points.add([
        start.longitude + (lngDiff * ratio) + curveFactor,
        start.latitude + (latDiff * ratio) + curveFactor,
      ]);
    }

    // End point
    points.add([end.longitude, end.latitude]);

    return points;
  }

  /// 🎯 **Key Learning Point 36: Real-Time Traffic Updates**
  /// Amazon LS can provide traffic-aware routing
  Future<TrafficUpdate> getTrafficUpdate(String routeId) async {
    // This would call Amazon LS traffic API
    return TrafficUpdate(
      routeId: routeId,
      delays: [
        TrafficDelay(
          segmentIndex: 2,
          delayMinutes: 5,
          reason: 'Heavy traffic',
          severity: 'Moderate',
        ),
        TrafficDelay(
          segmentIndex: 4,
          delayMinutes: 12,
          reason: 'Road closure - construction',
          severity: 'High',
        ),
      ],
      alternativeRoutesAvailable: true,
      updatedAt: DateTime.now(),
    );
  }

  /// 🎯 **Key Learning Point 37: Road Closure Handling**
  /// How to handle dynamic road closures
  Future<List<AmazonRouteResponse>> getAlternativeRoutes({
    required LatLng departure,
    required LatLng destination,
    required List<String> avoidanceReasons,
  }) async {
    /// 🔍 **Learning Focus: Alternative Route Request**
    final requestData = {
      'DeparturePosition': [departure.longitude, departure.latitude],
      'DestinationPosition': [destination.longitude, destination.latitude],
      'TravelMode': 'Car',
      'OptimizeFor': 'FastestRoute', // or 'ShortestRoute'
      'Avoid': avoidanceReasons, // ['Tolls', 'Ferries', 'Highways']
      'MaxAlternatives': 3,
      'IncludeLegGeometry': true,
    };

    print('🛣️ Alternative Routes Request: ${jsonEncode(requestData)}');

    // Return multiple route options
    return [
      _createDemoResponse(departure, destination),
      // Alternative route 1 (avoiding highways)
      AmazonRouteResponse(
        summary: RouteSummary(
          routeId: 'alt-1-${DateTime.now().millisecondsSinceEpoch}',
          distance: 15.2,
          durationSeconds: 2100,
          dataSource: 'Here',
        ),
        legs: [],
      ),
      // Alternative route 2 (avoiding tolls)
      AmazonRouteResponse(
        summary: RouteSummary(
          routeId: 'alt-2-${DateTime.now().millisecondsSinceEpoch}',
          distance: 13.8,
          durationSeconds: 1950,
          dataSource: 'Here',
        ),
        legs: [],
      ),
    ];
  }
}

/// 🎯 **Key Learning Point 38: Amazon LS Data Models**
/// These match the exact structure Amazon Location Service returns

class AmazonRouteResponse {
  final RouteSummary summary;
  final List<RouteLeg> legs;

  AmazonRouteResponse({required this.summary, required this.legs});

  factory AmazonRouteResponse.fromJson(Map<String, dynamic> json) {
    return AmazonRouteResponse(
      summary: RouteSummary.fromJson(json['Summary']),
      legs:
          (json['Legs'] as List).map((leg) => RouteLeg.fromJson(leg)).toList(),
    );
  }

  /// Convert to Flutter Map polyline points
  List<LatLng> get polylinePoints {
    List<LatLng> points = [];
    for (var leg in legs) {
      for (var point in leg.geometry) {
        points.add(LatLng(point[1], point[0])); // Note: AWS uses [lng, lat]
      }
    }
    return points;
  }
}

class RouteSummary {
  final String routeId;
  final double distance; // kilometers
  final int durationSeconds;
  final String dataSource;

  RouteSummary({
    required this.routeId,
    required this.distance,
    required this.durationSeconds,
    required this.dataSource,
  });

  factory RouteSummary.fromJson(Map<String, dynamic> json) {
    return RouteSummary(
      routeId: json['RouteId'] ?? '',
      distance: (json['Distance'] ?? 0.0).toDouble(),
      durationSeconds: json['DurationSeconds'] ?? 0,
      dataSource: json['DataSource'] ?? '',
    );
  }

  String get formattedDuration {
    int hours = durationSeconds ~/ 3600;
    int minutes = (durationSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).round()}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }
}

class RouteLeg {
  final double distance;
  final int durationSeconds;
  final List<double> startPosition;
  final List<double> endPosition;
  final List<RouteStep> steps;
  final List<List<double>> geometry;

  RouteLeg({
    required this.distance,
    required this.durationSeconds,
    required this.startPosition,
    required this.endPosition,
    required this.steps,
    required this.geometry,
  });

  factory RouteLeg.fromJson(Map<String, dynamic> json) {
    return RouteLeg(
      distance: (json['Distance'] ?? 0.0).toDouble(),
      durationSeconds: json['DurationSeconds'] ?? 0,
      startPosition: List<double>.from(json['StartPosition'] ?? []),
      endPosition: List<double>.from(json['EndPosition'] ?? []),
      steps:
          (json['Steps'] as List? ?? [])
              .map((step) => RouteStep.fromJson(step))
              .toList(),
      geometry:
          (json['Geometry']['LineString'] as List? ?? [])
              .map((point) => List<double>.from(point))
              .toList(),
    );
  }
}

class RouteStep {
  final double distance;
  final int durationSeconds;
  final String instruction;
  final String type; // Depart, Turn, Continue, Arrive
  final List<double> position;

  RouteStep({
    required this.distance,
    required this.durationSeconds,
    required this.instruction,
    required this.type,
    required this.position,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      distance: (json['Distance'] ?? 0.0).toDouble(),
      durationSeconds: json['DurationSeconds'] ?? 0,
      instruction: json['Instruction'] ?? '',
      type: json['Type'] ?? '',
      position: List<double>.from(json['StartPosition'] ?? []),
    );
  }

  IconData get stepIcon {
    switch (type.toLowerCase()) {
      case 'depart':
        return Icons.my_location;
      case 'turn':
        return Icons.turn_right;
      case 'continue':
        return Icons.straight;
      case 'arrive':
        return Icons.place;
      default:
        return Icons.navigation;
    }
  }
}

/// 🎯 **Key Learning Point 39: Traffic & Road Closure Models**
class TrafficUpdate {
  final String routeId;
  final List<TrafficDelay> delays;
  final bool alternativeRoutesAvailable;
  final DateTime updatedAt;

  TrafficUpdate({
    required this.routeId,
    required this.delays,
    required this.alternativeRoutesAvailable,
    required this.updatedAt,
  });

  int get totalDelayMinutes {
    return delays.fold(0, (sum, delay) => sum + delay.delayMinutes);
  }

  bool get hasHighSeverityIssues {
    return delays.any((delay) => delay.severity == 'High');
  }
}

class TrafficDelay {
  final int segmentIndex;
  final int delayMinutes;
  final String reason;
  final String severity; // Low, Moderate, High

  TrafficDelay({
    required this.segmentIndex,
    required this.delayMinutes,
    required this.reason,
    required this.severity,
  });

  Color get severityColor {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
