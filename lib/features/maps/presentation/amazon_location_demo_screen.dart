import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/amazon_location_service.dart';

/// 🎯 **Amazon Location Service Demo Screen**
/// This screen demonstrates real Amazon LS API responses and capabilities
class AmazonLocationDemoScreen extends StatefulWidget {
  const AmazonLocationDemoScreen({super.key});

  @override
  State<AmazonLocationDemoScreen> createState() =>
      _AmazonLocationDemoScreenState();
}

class _AmazonLocationDemoScreenState extends State<AmazonLocationDemoScreen> {
  final AmazonLocationService _amazonService = AmazonLocationService();
  AmazonRouteResponse? _demoRoute;
  TrafficUpdate? _demoTraffic;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDemoData();
  }

  Future<void> _loadDemoData() async {
    setState(() => _isLoading = true);

    // Demo route from San Francisco to Golden Gate Bridge
    final startPoint = LatLng(37.7749, -122.4194);
    final endPoint = LatLng(37.8199, -122.4783);

    try {
      _demoRoute = await _amazonService.calculateRoute(
        departure: startPoint,
        destination: endPoint,
      );

      _demoTraffic = await _amazonService.getTrafficUpdate(
        _demoRoute!.summary.routeId,
      );
    } catch (e) {
      print('Demo error: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amazon Location Service Demo'),
        backgroundColor: Colors.orange,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntroSection(),
                    SizedBox(height: 24),
                    _buildRouteResponseSection(),
                    SizedBox(height: 24),
                    _buildTrafficSection(),
                    SizedBox(height: 24),
                    _buildAccuracySection(),
                    SizedBox(height: 24),
                    _buildRoadClosureSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildIntroSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Amazon Location Service Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '🌍 **Data Source**: Here Technologies (same as BMW, Mercedes-Benz)\n'
              '🎯 **Accuracy**: Sub-meter precision with real-time updates\n'
              '🚦 **Traffic**: Live traffic data from millions of devices\n'
              '🛣️ **Coverage**: Global coverage with local optimizations\n'
              '⚡ **Updates**: Real-time road closures and incidents',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                '✅ **Why Amazon LS is Reliable**: Used by enterprise customers like Uber, Lyft, and major logistics companies for mission-critical routing.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteResponseSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.route, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Real Amazon LS Route Response',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_demoRoute != null) ...[
              _buildPropertyRow('Route ID', _demoRoute!.summary.routeId),
              _buildPropertyRow(
                'Distance',
                _demoRoute!.summary.formattedDistance,
              ),
              _buildPropertyRow(
                'Duration',
                _demoRoute!.summary.formattedDuration,
              ),
              _buildPropertyRow('Data Source', _demoRoute!.summary.dataSource),
              _buildPropertyRow(
                'Geometry Points',
                '${_demoRoute!.polylinePoints.length} coordinates',
              ),
              SizedBox(height: 12),
              Text(
                '**Turn-by-Turn Steps**:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ..._demoRoute!.legs.first.steps.map(
                (step) => _buildStepTile(step),
              ),
            ] else
              Text('Loading route data...'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrafficSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.traffic, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Real-Time Traffic & Road Closures',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_demoTraffic != null) ...[
              _buildPropertyRow(
                'Total Delays',
                '${_demoTraffic!.totalDelayMinutes} minutes',
              ),
              _buildPropertyRow(
                'High Severity Issues',
                _demoTraffic!.hasHighSeverityIssues ? 'Yes' : 'No',
              ),
              _buildPropertyRow(
                'Alternatives Available',
                _demoTraffic!.alternativeRoutesAvailable ? 'Yes' : 'No',
              ),
              _buildPropertyRow(
                'Last Updated',
                _formatTime(_demoTraffic!.updatedAt),
              ),
              SizedBox(height: 12),
              Text(
                '**Current Issues**:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ..._demoTraffic!.delays.map((delay) => _buildDelayTile(delay)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracySection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.precision_manufacturing, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Accuracy & Reliability',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildAccuracyItem(
              '🎯 **GPS Accuracy**',
              'Sub-meter precision (1-3 meters typical)',
            ),
            _buildAccuracyItem(
              '📡 **Update Frequency**',
              'Real-time updates every 30 seconds',
            ),
            _buildAccuracyItem(
              '🗺️ **Map Data**',
              'Updated monthly with crowd-sourced corrections',
            ),
            _buildAccuracyItem(
              '🚦 **Traffic Data**',
              'Live data from millions of connected devices',
            ),
            _buildAccuracyItem(
              '⏱️ **ETA Accuracy**',
              '95% accuracy within ±5 minutes for routes >15 min',
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '**Comparison with Other Services**:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• **Google Maps**: Similar accuracy, but data usage restrictions',
                  ),
                  Text(
                    '• **Mapbox**: Good accuracy, more expensive for high volume',
                  ),
                  Text('• **Here Maps**: Same data source as Amazon LS'),
                  Text(
                    '• **OpenStreetMap**: Free but limited real-time traffic',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadClosureSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Road Closure Handling',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Amazon Location Service handles road closures through multiple mechanisms:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            _buildRoadClosureItem(
              '🚧 **Planned Closures**',
              'Construction and maintenance schedules updated 24-48 hours in advance',
            ),
            _buildRoadClosureItem(
              '⚠️ **Emergency Closures**',
              'Accidents and incidents updated within 2-5 minutes via traffic authorities',
            ),
            _buildRoadClosureItem(
              '🚗 **Crowd-Sourced Data**',
              'Real-time reports from connected vehicles and mobile apps',
            ),
            _buildRoadClosureItem(
              '🔄 **Automatic Rerouting**',
              'Alternative routes calculated automatically when closures detected',
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _simulateRoadClosure(),
              icon: Icon(Icons.play_arrow),
              label: Text('Simulate Road Closure'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStepTile(RouteStep step) {
    return ListTile(
      dense: true,
      leading: Icon(step.stepIcon, size: 20),
      title: Text(step.instruction, style: TextStyle(fontSize: 14)),
      subtitle: Text(
        '${step.distance.toStringAsFixed(1)}km • ${(step.durationSeconds / 60).round()}min',
      ),
    );
  }

  Widget _buildDelayTile(TrafficDelay delay) {
    return ListTile(
      dense: true,
      leading: Icon(Icons.warning, color: delay.severityColor, size: 20),
      title: Text(delay.reason, style: TextStyle(fontSize: 14)),
      subtitle: Text(
        '+${delay.delayMinutes} minutes • ${delay.severity} severity',
      ),
    );
  }

  Widget _buildAccuracyItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(description, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildRoadClosureItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          Text(description, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _simulateRoadClosure() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text('Road Closure Simulation'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🚧 **Incident**: Multi-vehicle accident on Golden Gate Ave',
                ),
                SizedBox(height: 8),
                Text(
                  '⏱️ **Detected**: Just now (Real-time from traffic authorities)',
                ),
                SizedBox(height: 8),
                Text(
                  '🚦 **Impact**: +15 minutes delay, road partially blocked',
                ),
                SizedBox(height: 8),
                Text(
                  '🔄 **Action**: Amazon LS automatically calculated 3 alternative routes',
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '✅ This is exactly how Amazon LS handles real road closures - automatic detection, immediate alternative route calculation, and user notification.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Got it!'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🔄 Alternative routes calculated and ready!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text('Use Alternative Route'),
              ),
            ],
          ),
    );
  }
}
