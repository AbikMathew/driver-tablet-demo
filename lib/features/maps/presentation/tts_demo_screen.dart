import 'package:flutter/material.dart';

import '../../../core/services/navigation_tts_service.dart';

/// 🎯 **TTS Demo Screen**
/// Interactive demo to test all Text-to-Speech navigation features
class TTSDemoScreen extends StatefulWidget {
  const TTSDemoScreen({super.key});

  @override
  State<TTSDemoScreen> createState() => _TTSDemoScreenState();
}

class _TTSDemoScreenState extends State<TTSDemoScreen> {
  final NavigationTTSService _ttsService = NavigationTTSService();
  bool _isInitialized = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    setState(() => _isInitializing = true);

    try {
      await _ttsService.initialize();
      setState(() {
        _isInitialized = true;
        _isInitializing = false;
      });
      debugPrint('✅ TTS Demo: Service initialized');
    } catch (e) {
      setState(() => _isInitializing = false);
      debugPrint('❌ TTS Demo: Initialization failed: $e');
    }
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 Text-to-Speech Demo'),
        backgroundColor: Colors.blue.shade50,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🎯 **Status Card**
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _isInitialized
                          ? Icons.check_circle
                          : _isInitializing
                          ? Icons.hourglass_empty
                          : Icons.error,
                      color:
                          _isInitialized
                              ? Colors.green
                              : _isInitializing
                              ? Colors.orange
                              : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TTS Service Status',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            _isInitialized
                                ? 'Ready for voice guidance'
                                : _isInitializing
                                ? 'Initializing TTS engine...'
                                : 'Failed to initialize',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isInitialized && !_isInitializing)
                      TextButton(
                        onPressed: _initializeTTS,
                        child: const Text('Retry'),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// 🎯 **Basic TTS Testing**
            _buildSection('Basic Voice Testing', [
              _buildTTSButton(
                '🎵 Test Voice',
                'Test the basic TTS functionality',
                () => _ttsService.testVoice(),
              ),
              _buildTTSButton(
                '🔊 Voice Settings Demo',
                'Demonstrate different voice settings',
                _demonstrateVoiceSettings,
              ),
            ]),

            /// 🎯 **Navigation Instructions**
            _buildSection('Navigation Instructions', [
              _buildTTSButton(
                '🧭 Turn Instructions',
                'Various turn-by-turn instructions',
                _demonstrateTurnInstructions,
              ),
              _buildTTSButton(
                '📍 Distance Announcements',
                'Distance-based instruction timing',
                _demonstrateDistanceAnnouncements,
              ),
              _buildTTSButton(
                '🛣️ Route Overview',
                'Journey start announcement',
                _demonstrateRouteStart,
              ),
            ]),

            /// 🎯 **Traffic Alerts**
            _buildSection('Traffic & Road Conditions', [
              _buildTTSButton(
                '⚠️ Traffic Delays',
                'Traffic alert announcements',
                _demonstrateTrafficAlerts,
              ),
              _buildTTSButton(
                '🚧 Road Closures',
                'Road closure notifications',
                _demonstrateRoadClosures,
              ),
              _buildTTSButton(
                '🚨 Speed Alerts',
                'Speed limit and camera warnings',
                _demonstrateSpeedAlerts,
              ),
            ]),

            /// 🎯 **Arrival & Waypoints**
            _buildSection('Arrivals & Destinations', [
              _buildTTSButton(
                '🎯 Destination Arrival',
                'Final destination announcements',
                _demonstrateArrival,
              ),
              _buildTTSButton(
                '📍 Waypoint Stops',
                'Intermediate stop announcements',
                _demonstrateWaypoints,
              ),
              _buildTTSButton(
                '📝 Custom Notes',
                'Driver-specific instructions',
                _demonstrateCustomNotes,
              ),
            ]),

            /// 🎯 **Advanced Features**
            _buildSection('Advanced TTS Features', [
              _buildTTSButton(
                '🎛️ Voice Settings',
                'Adjust speed, pitch, and volume',
                _showVoiceSettings,
              ),
              _buildTTSButton(
                '🔄 Full Demo Sequence',
                'Complete navigation simulation',
                _runFullNavigationDemo,
              ),
            ]),

            const SizedBox(height: 24),

            /// 🎯 **Stop All Button**
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _ttsService.stop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('🛑 Stop All Speech'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTTSButton(
    String title,
    String subtitle,
    VoidCallback onPressed,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.play_arrow,
          color: _isInitialized ? Colors.blue : Colors.grey,
        ),
        onTap: _isInitialized ? onPressed : null,
      ),
    );
  }

  /// 🎯 **TTS Demo Methods**

  Future<void> _demonstrateVoiceSettings() async {
    await _ttsService.updateSettings(rate: 0.3);
    await _ttsService.testVoice();

    await Future.delayed(const Duration(seconds: 3));
    await _ttsService.updateSettings(rate: 0.8);
    await _ttsService.testVoice();

    // Reset to normal
    await _ttsService.updateSettings(rate: 0.5);
  }

  Future<void> _demonstrateTurnInstructions() async {
    final instructions = [
      "Turn right onto Market Street",
      "Turn left onto Van Ness Avenue",
      "Continue straight for 2 kilometers",
      "Make a U-turn when possible",
      "At the roundabout, take the second exit",
    ];

    for (int i = 0; i < instructions.length; i++) {
      await _ttsService.announceNavigationInstruction(
        instruction: instructions[i],
        distanceToTurn: 100,
        isImmediate: false,
      );

      if (i < instructions.length - 1) {
        await Future.delayed(const Duration(seconds: 4));
      }
    }
  }

  Future<void> _demonstrateDistanceAnnouncements() async {
    final distances = [1000.0, 500.0, 200.0, 100.0, 50.0];
    const instruction = "Turn right onto Market Street";

    for (double distance in distances) {
      await _ttsService.announceNavigationInstruction(
        instruction: instruction,
        distanceToTurn: distance,
        isImmediate: distance <= 50,
      );
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  Future<void> _demonstrateRouteStart() async {
    await _ttsService.announceRouteStart(
      totalDistance: 5200, // 5.2 km
      estimatedDuration: 900, // 15 minutes
      destination: "Golden Gate Bridge",
    );
  }

  Future<void> _demonstrateTrafficAlerts() async {
    await _ttsService.announceTrafficAlert(
      alertType: 'delay',
      delayMinutes: 5,
      alternativeAvailable: 'Alternative route found.',
    );

    await Future.delayed(const Duration(seconds: 4));

    await _ttsService.announceTrafficAlert(
      alertType: 'accident',
      delayMinutes: 8,
      alternativeAvailable: null,
    );
  }

  Future<void> _demonstrateRoadClosures() async {
    await _ttsService.announceTrafficAlert(
      alertType: 'closure',
      delayMinutes: 0,
      alternativeAvailable: 'Recalculating route to avoid closure.',
    );
  }

  Future<void> _demonstrateSpeedAlerts() async {
    await _ttsService.announceSpeedAlert(
      currentSpeed: 65,
      speedLimit: 50,
      alertType: 'warning',
    );

    await Future.delayed(const Duration(seconds: 4));

    await _ttsService.announceSpeedAlert(
      currentSpeed: 45,
      speedLimit: 50,
      alertType: 'camera',
    );

    await Future.delayed(const Duration(seconds: 4));

    await _ttsService.announceSpeedAlert(
      currentSpeed: 35,
      speedLimit: 25,
      alertType: 'school_zone',
    );
  }

  Future<void> _demonstrateArrival() async {
    await _ttsService.announceArrival(
      locationType: 'destination',
      locationName: 'Golden Gate Bridge Visitor Center',
    );
  }

  Future<void> _demonstrateWaypoints() async {
    await _ttsService.announceArrival(
      locationType: 'waypoint',
      locationName: 'Union Square',
    );

    await Future.delayed(const Duration(seconds: 3));

    await _ttsService.announceArrival(
      locationType: 'stop',
      locationName: 'Coffee shop pickup',
    );
  }

  Future<void> _demonstrateCustomNotes() async {
    final notes = [
      "Remember to pick up the package from the front desk",
      "Customer prefers delivery to the back entrance",
      "Call the customer when you arrive",
    ];

    for (int i = 0; i < notes.length; i++) {
      await _ttsService.readCustomNote(notes[i]);
      if (i < notes.length - 1) {
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  Future<void> _runFullNavigationDemo() async {
    // Full navigation sequence
    await _demonstrateRouteStart();
    await Future.delayed(const Duration(seconds: 3));

    await _ttsService.announceNavigationInstruction(
      instruction: "Turn right onto Market Street",
      distanceToTurn: 200,
      isImmediate: false,
    );
    await Future.delayed(const Duration(seconds: 4));

    await _ttsService.announceNavigationInstruction(
      instruction: "Turn right",
      distanceToTurn: 30,
      isImmediate: true,
    );
    await Future.delayed(const Duration(seconds: 3));

    await _ttsService.announceTrafficAlert(
      alertType: 'delay',
      delayMinutes: 3,
      alternativeAvailable: null,
    );
    await Future.delayed(const Duration(seconds: 4));

    await _ttsService.announceNavigationInstruction(
      instruction: "Continue straight for 1 kilometer",
      distanceToTurn: 1000,
      isImmediate: false,
    );
    await Future.delayed(const Duration(seconds: 4));

    await _demonstrateArrival();
  }

  void _showVoiceSettings() {
    showDialog(
      context: context,
      builder: (context) => _VoiceSettingsDialog(ttsService: _ttsService),
    );
  }
}

/// 🎯 **Voice Settings Dialog**
/// Allow users to customize TTS parameters
class _VoiceSettingsDialog extends StatefulWidget {
  final NavigationTTSService ttsService;

  const _VoiceSettingsDialog({required this.ttsService});

  @override
  State<_VoiceSettingsDialog> createState() => _VoiceSettingsDialogState();
}

class _VoiceSettingsDialogState extends State<_VoiceSettingsDialog> {
  double _volume = 1.0;
  double _rate = 0.5;
  double _pitch = 1.0;

  @override
  void initState() {
    super.initState();
    final settings = widget.ttsService.currentSettings;
    _volume = settings['volume'] ?? 1.0;
    _rate = settings['rate'] ?? 0.5;
    _pitch = settings['pitch'] ?? 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🎛️ Voice Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSlider('Volume', _volume, 0.0, 1.0, (value) {
            setState(() => _volume = value);
            widget.ttsService.updateSettings(volume: value);
          }),
          _buildSlider('Speech Rate', _rate, 0.1, 1.0, (value) {
            setState(() => _rate = value);
            widget.ttsService.updateSettings(rate: value);
          }),
          _buildSlider('Pitch', _pitch, 0.5, 2.0, (value) {
            setState(() => _pitch = value);
            widget.ttsService.updateSettings(pitch: value);
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => widget.ttsService.testVoice(),
          child: const Text('Test'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(2)}'),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 20,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
