import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_cache_service.dart';

/// 🎯 **Enhanced Text-to-Speech Navigation Service**
/// Handles all voice guidance functionality with offline caching support
class NavigationTTSService {
  static final NavigationTTSService _instance =
      NavigationTTSService._internal();
  factory NavigationTTSService() => _instance;
  NavigationTTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final TTSCacheService _cacheService = TTSCacheService();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  /// 🎯 **Key Learning Point 47: TTS Configuration**
  /// Essential settings for navigation voice guidance
  final Map<String, dynamic> _ttsSettings = {
    'volume': 1.0,
    'rate': 0.5, // Slower speech for navigation
    'pitch': 1.0,
    'language': 'en-US',
    'voiceType': 'female', // Can be male/female
  };

  /// 🎯 **Key Learning Point 48: TTS Initialization**
  /// Proper setup for iOS and Android TTS engines
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      /// 🔍 **Learning Focus: Platform-specific TTS Setup**
      await _flutterTts.setLanguage(_ttsSettings['language']);
      await _flutterTts.setSpeechRate(_ttsSettings['rate']);
      await _flutterTts.setVolume(_ttsSettings['volume']);
      await _flutterTts.setPitch(_ttsSettings['pitch']);

      /// 🔍 **Learning Focus: iOS-specific Settings**
      /// Safely handle iOS-specific features that may not work on simulators
      try {
        // Check if language is installed (may not work on simulators)
        bool isInstalled = await _flutterTts.isLanguageInstalled(
          _ttsSettings['language'],
        );
        if (isInstalled) {
          await _flutterTts.setVoice({
            'name': 'com.apple.ttsbundle.Samantha-compact', // iOS voice
            'locale': _ttsSettings['language'],
          });
        }
      } catch (e) {
        debugPrint(
          '⚠️ iOS-specific TTS features not available (simulator): $e',
        );
        // Continue without iOS-specific voice settings
      }

      /// 🔍 **Learning Focus: Android-specific Settings**
      try {
        await _flutterTts.setEngine(
          'com.google.android.tts',
        ); // Android TTS engine
      } catch (e) {
        debugPrint('⚠️ Android-specific TTS features not available: $e');
        // Continue without Android-specific engine settings
      }

      /// 🔍 **Learning Focus: TTS Event Handlers**
      _flutterTts.setStartHandler(() {
        debugPrint('🎵 TTS: Started speaking');
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        debugPrint('🎵 TTS: Finished speaking');
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((message) {
        debugPrint('❌ TTS Error: $message');
        _isSpeaking = false;
      });

      _isInitialized = true;
      debugPrint('✅ TTS Service initialized successfully');
    } catch (e) {
      debugPrint('❌ TTS Initialization failed: $e');
      // Mark as initialized anyway for basic functionality
      _isInitialized = true;
      debugPrint('⚠️ TTS Service initialized with limited functionality');
    }
  }

  /// 🎯 **Key Learning Point 49: Smart Voice Announcements**
  /// Distance-based announcements for better user experience
  Future<void> announceNavigationInstruction({
    required String instruction,
    required double distanceToTurn,
    required bool isImmediate,
  }) async {
    if (!_isInitialized) await initialize();
    if (_isSpeaking && !isImmediate) return; // Don't interrupt unless urgent

    String announcement = _buildAnnouncementText(
      instruction,
      distanceToTurn,
      isImmediate,
    );
    await _speak(announcement);
  }

  /// 🎯 **Enhanced Speak Method with Caching**
  /// Uses cached TTS when available for faster response
  Future<void> speakWithCache(String text) async {
    if (!_isInitialized) {
      debugPrint('⚠️ TTS not initialized, initializing now...');
      await initialize();
    }

    if (_isSpeaking) {
      await _flutterTts.stop();
    }

    try {
      _isSpeaking = true;
      debugPrint('🎵 TTS Announcing with cache: $text');

      // Use cached TTS service for better performance
      await _cacheService.speakWithCache(
        text: text,
        language: _ttsSettings['language'],
        rate: _ttsSettings['rate'],
        pitch: _ttsSettings['pitch'],
      );

      debugPrint('🎵 TTS: Started speaking');
    } catch (e) {
      debugPrint('❌ TTS Error: $e');
      // Fallback to regular speak
      await _speak(text);
    }
  }

  /// 🎯 **Pre-cache Common Instructions**
  /// Download and cache common navigation instructions for offline use
  Future<void> preCacheInstructions({
    Function(int completed, int total)? onProgress,
  }) async {
    try {
      await _cacheService.preCacheCommonInstructions(
        language: _ttsSettings['language'],
        onProgress: onProgress,
      );
      debugPrint('✅ TTS instructions pre-cached successfully');
    } catch (e) {
      debugPrint('❌ TTS pre-caching failed: $e');
    }
  }

  /// Context-aware voice instructions based on distance and urgency
  String _buildAnnouncementText(
    String instruction,
    double distanceToTurn,
    bool isImmediate,
  ) {
    if (isImmediate) {
      return instruction; // "Turn right now" or "You have arrived"
    }

    // Distance-based announcements
    if (distanceToTurn > 800) {
      return 'In ${(distanceToTurn / 1000).toStringAsFixed(1)} kilometers, $instruction';
    } else if (distanceToTurn > 400) {
      return 'In ${distanceToTurn.round()} meters, $instruction';
    } else if (distanceToTurn > 100) {
      return 'In ${distanceToTurn.round()} meters, $instruction';
    } else if (distanceToTurn > 50) {
      return 'Prepare to $instruction';
    } else {
      return instruction; // "Turn right" for immediate turns
    }
  }

  /// 🎯 **Key Learning Point 51: Route Overview Announcements**
  /// Provide journey context at the start of navigation
  Future<void> announceRouteStart({
    required double totalDistance,
    required int estimatedDuration,
    required String destination,
  }) async {
    String distanceText =
        totalDistance > 1000
            ? '${(totalDistance / 1000).toStringAsFixed(1)} kilometers'
            : '${totalDistance.round()} meters';

    int minutes = estimatedDuration ~/ 60;
    String durationText =
        minutes > 60
            ? '${minutes ~/ 60} hour and ${minutes % 60} minutes'
            : '$minutes minutes';

    String announcement =
        'Starting navigation to $destination. '
        'The route is $distanceText and will take approximately $durationText. '
        'Drive safely!';

    await _speak(announcement);
  }

  /// 🎯 **Key Learning Point 52: Traffic Alert Announcements**
  /// Voice notifications for road conditions
  Future<void> announceTrafficAlert({
    required String alertType, // 'delay', 'closure', 'accident'
    required int delayMinutes,
    required String? alternativeAvailable,
  }) async {
    String announcement;

    switch (alertType.toLowerCase()) {
      case 'delay':
        announcement =
            'Traffic alert: There is a $delayMinutes minute delay ahead.';
        break;
      case 'closure':
        announcement = 'Road closure detected. Calculating alternative route.';
        break;
      case 'accident':
        announcement =
            'Accident reported ahead. Adding $delayMinutes minutes to your journey.';
        break;
      default:
        announcement = 'Traffic condition updated.';
    }

    if (alternativeAvailable != null) {
      announcement += ' $alternativeAvailable';
    }

    await _speak(announcement);
  }

  /// 🎯 **Key Learning Point 53: Arrival Announcements**
  /// Different announcement types for various arrival scenarios
  Future<void> announceArrival({
    required String locationType, // 'destination', 'waypoint', 'stop'
    required String locationName,
  }) async {
    String announcement;

    switch (locationType.toLowerCase()) {
      case 'destination':
        announcement = 'You have arrived at your destination: $locationName';
        break;
      case 'waypoint':
        announcement =
            'Waypoint reached: $locationName. Continuing to next destination.';
        break;
      case 'stop':
        announcement = 'Arriving at stop: $locationName';
        break;
      default:
        announcement = 'You have arrived at $locationName';
    }

    await _speak(announcement);
  }

  /// 🎯 **Key Learning Point 54: Speed and Safety Alerts**
  /// Voice warnings for driver safety
  Future<void> announceSpeedAlert({
    required double currentSpeed,
    required double speedLimit,
    required String alertType, // 'warning', 'camera', 'school_zone'
  }) async {
    String announcement;

    switch (alertType.toLowerCase()) {
      case 'warning':
        announcement =
            'Speed limit is ${speedLimit.round()} kilometers per hour. '
            'Your current speed is ${currentSpeed.round()}.';
        break;
      case 'camera':
        announcement =
            'Speed camera ahead. Speed limit: ${speedLimit.round()} kilometers per hour.';
        break;
      case 'school_zone':
        announcement =
            'Entering school zone. Reduce speed to ${speedLimit.round()} kilometers per hour.';
        break;
      default:
        announcement =
            'Speed limit: ${speedLimit.round()} kilometers per hour.';
    }

    await _speak(announcement);
  }

  /// 🎯 **Key Learning Point 55: Reading Custom Notes**
  /// TTS for driver instructions or stop-specific information
  Future<void> readCustomNote(String note) async {
    if (note.trim().isEmpty) return;

    String announcement = 'Driver note: $note';
    await _speak(announcement);
  }

  /// 🎯 **Key Learning Point 56: TTS Control Methods**
  /// Essential playback controls for navigation
  Future<void> _speak(String text) async {
    if (!_isInitialized) return;

    try {
      debugPrint('🎵 TTS Announcing: $text');
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('❌ TTS Speak error: $e');
    }
  }

  Future<void> stop() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
    }
  }

  Future<void> pause() async {
    if (_isSpeaking) {
      await _flutterTts.pause();
    }
  }

  /// 🎯 **Key Learning Point 57: TTS Settings Management**
  /// Allow users to customize voice settings
  Future<void> updateSettings({
    double? volume,
    double? rate,
    double? pitch,
    String? language,
  }) async {
    if (volume != null) {
      _ttsSettings['volume'] = volume;
      await _flutterTts.setVolume(volume);
    }

    if (rate != null) {
      _ttsSettings['rate'] = rate;
      await _flutterTts.setSpeechRate(rate);
    }

    if (pitch != null) {
      _ttsSettings['pitch'] = pitch;
      await _flutterTts.setPitch(pitch);
    }

    if (language != null) {
      _ttsSettings['language'] = language;
      await _flutterTts.setLanguage(language);
    }
  }

  /// 🎯 **Key Learning Point 58: Distance-Based Navigation Logic**
  /// Smart logic for when to announce turn instructions
  bool shouldAnnounceInstruction({
    required double distanceToTurn,
    required double currentSpeed, // km/h
    required String lastAnnouncedInstruction,
    required DateTime lastAnnouncementTime,
  }) {
    // Don't repeat the same instruction too frequently
    if (DateTime.now().difference(lastAnnouncementTime).inSeconds < 10) {
      return false;
    }

    // Calculate time to turn based on current speed
    double timeToTurnSeconds = (distanceToTurn / 1000) / (currentSpeed / 3600);

    // Announce at strategic distances/times
    if (distanceToTurn <= 50) return true; // Immediate turn
    if (distanceToTurn <= 100 && timeToTurnSeconds <= 15)
      return true; // 15 seconds ahead
    if (distanceToTurn <= 200 && timeToTurnSeconds <= 30)
      return true; // 30 seconds ahead
    if (distanceToTurn <= 500 && timeToTurnSeconds <= 45)
      return true; // 45 seconds ahead
    if (distanceToTurn <= 1000 && timeToTurnSeconds <= 60)
      return true; // 1 minute ahead

    return false;
  }

  // Getters for current state
  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  Map<String, dynamic> get currentSettings => Map.from(_ttsSettings);

  /// 🎯 **Key Learning Point 59: TTS Testing Method**
  /// Useful for testing voice settings and clarity
  Future<void> testVoice() async {
    await _speak(
      'Text to speech is working correctly. Navigation voice guidance is ready.',
    );
  }

  /// 🎯 **Simple TTS Test for Debugging**
  /// Basic test without complex features
  Future<void> simpleSpeakTest() async {
    try {
      await _flutterTts.speak("Hello, TTS is working!");
      debugPrint('✅ Simple TTS test successful');
    } catch (e) {
      debugPrint('❌ Simple TTS test failed: $e');
    }
  }

  /// Clean up resources
  void dispose() {
    _flutterTts.stop();
    _isInitialized = false;
  }
}

/// 🎯 **Key Learning Point 60: Navigation Instruction Types**
/// Standardized instruction categories for consistent voice guidance
enum NavigationInstructionType {
  depart,
  turn,
  continueStr, // Renamed from 'continue' since it's a keyword
  merge,
  roundabout,
  uturn,
  arrive,
  waypoint,
}

/// 🎯 **Navigation Instruction Helper**
/// Converts route steps into natural voice instructions
class NavigationInstructionHelper {
  static String getVoiceInstruction({
    required NavigationInstructionType type,
    required String roadName,
    String? direction, // 'left', 'right', 'straight'
    int? exitNumber,
  }) {
    switch (type) {
      case NavigationInstructionType.depart:
        return 'Head ${direction ?? 'forward'} on $roadName';

      case NavigationInstructionType.turn:
        return 'Turn $direction onto $roadName';

      case NavigationInstructionType.continueStr:
        return 'Continue straight on $roadName';

      case NavigationInstructionType.merge:
        return 'Merge $direction onto $roadName';

      case NavigationInstructionType.roundabout:
        return 'At the roundabout, take the ${_getOrdinalNumber(exitNumber ?? 1)} exit onto $roadName';

      case NavigationInstructionType.uturn:
        return 'Make a U-turn onto $roadName';

      case NavigationInstructionType.arrive:
        return 'You have arrived at $roadName';

      case NavigationInstructionType.waypoint:
        return 'Waypoint reached: $roadName';
    }
  }

  static String _getOrdinalNumber(int number) {
    switch (number) {
      case 1:
        return 'first';
      case 2:
        return 'second';
      case 3:
        return 'third';
      case 4:
        return 'fourth';
      case 5:
        return 'fifth';
      default:
        return '${number}th';
    }
  }
}
