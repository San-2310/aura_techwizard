// keystroke_analysis.dart (This contains all the models, providers and UI)
import 'dart:async';
import 'dart:math' as math;

import 'package:aura_techwizard/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class KeystrokeAnalysisScreen extends StatelessWidget {
  const KeystrokeAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keystroke Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keystroke Metrics',
                    //style: Theme.of(context).textTheme.headline6,
                  ),
                  Consumer<KeystrokeProvider>(
                    builder: (context, keystrokeProvider, _) {
                      return Column(
                        children: [
                          // Displaying the Keystroke Metrics Graph
                          SizedBox(
                            height: 200,
                            child: CustomPaint(
                              painter: GraphPainter(
                                metrics: keystrokeProvider.metrics,
                                baselineSpeed:
                                    keystrokeProvider.baselineTypingSpeed,
                                primaryColor: Colors.blueAccent,
                                baselineColor: Colors.green,
                                thresholdColor: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Keystroke Summary
                          _buildKeystrokeSummary(keystrokeProvider),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Usage Metrics',
                    //style: Theme.of(context).textTheme.headline6,
                  ),
                  Consumer<AppUsageProvider>(
                    builder: (context, appUsageProvider, _) {
                      return Column(
                        children: [
                          // Displaying the App Usage Metrics Graph
                          SizedBox(
                            height: 200,
                            child: CustomPaint(
                              painter: AppUsageGraphPainter(
                                metrics: appUsageProvider.metrics,
                                primaryColor: Colors.orangeAccent,
                                thresholdColor: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // App Usage Summary
                          _buildAppUsageSummary(appUsageProvider),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeystrokeSummary(KeystrokeProvider keystrokeProvider) {
    final typingSpeed = keystrokeProvider.baselineTypingSpeed;
    final errorRate = keystrokeProvider.metrics.isNotEmpty
        ? keystrokeProvider.metrics.last.errorRate
        : 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text('Typing Speed', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${typingSpeed.toStringAsFixed(2)} wpm'),
          ],
        ),
        Column(
          children: [
            Text('Error Rate', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${(errorRate * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ],
    );
  }

  Widget _buildAppUsageSummary(AppUsageProvider appUsageProvider) {
    final intensity = appUsageProvider.metrics.isNotEmpty
        ? appUsageProvider.metrics.last.intensity
        : 0;
    final switchCount = appUsageProvider.metrics.isNotEmpty
        ? appUsageProvider.metrics.last.switchCount
        : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text('Intensity', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(intensity.toStringAsFixed(2)),
          ],
        ),
        Column(
          children: [
            Text('Switch Count', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(switchCount.toString()),
          ],
        ),
      ],
    );
  }
}

// Models
class KeystrokeMetric {
  final double typingSpeed;
  final double dwellTime;
  final double flightTime;
  final double rhythmConsistency;
  final double errorRate;
  final DateTime timestamp;

  KeystrokeMetric({
    required this.typingSpeed,
    required this.dwellTime,
    required this.flightTime,
    required this.rhythmConsistency,
    required this.errorRate,
    required this.timestamp,
  });
}

class AppUsageMetric {
  final int switchCount;
  final DateTime timestamp;
  final double intensity;

  AppUsageMetric({
    required this.switchCount,
    required this.timestamp,
    required this.intensity,
  });
}

// Providers
class KeystrokeProvider with ChangeNotifier {
  final List<KeystrokeMetric> _metrics = [];
  final Map<String, int> _keyPressTimestamps = {};
  final Map<String, int> _keyReleaseTimestamps = {};
  int _totalKeystrokes = 0;
  int _errorCount = 0;
  double _baselineTypingSpeed = 0;
  Timer? _analysisTimer;

  List<KeystrokeMetric> get metrics => _metrics;
  double get baselineTypingSpeed => _baselineTypingSpeed;

  KeystrokeProvider() {
    _analysisTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _analyzePatterns();
    });
  }

  void handleTextInput(String text) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < text.length; i++) {
      recordKeyPress(text[i], timestamp + i);
      recordKeyRelease(text[i], timestamp + i + 50);
    }
  }

  void recordKeyPress(String key, int timestamp) {
    _keyPressTimestamps[key] = timestamp;
    _totalKeystrokes++;

    if (key == 'Backspace' || key == '⌫') {
      _errorCount++;
    }
  }

  void recordKeyRelease(String key, int timestamp) {
    if (_keyPressTimestamps.containsKey(key)) {
      final pressTime = _keyPressTimestamps[key]!;
      final dwellTime = timestamp - pressTime;
      final flightTime = _calculateFlightTime(pressTime);

      _processKeystroke(key, dwellTime, flightTime, timestamp);
      _keyReleaseTimestamps[key] = timestamp;
      _keyPressTimestamps.remove(key);
    }
  }

  double _calculateFlightTime(int pressTime) {
    if (_keyReleaseTimestamps.isEmpty) return 0;
    final lastRelease = _keyReleaseTimestamps.values.reduce(math.max);
    return (pressTime - lastRelease).toDouble();
  }

  void _processKeystroke(
      String key, int dwellTime, double flightTime, int timestamp) {
    final now = DateTime.fromMillisecondsSinceEpoch(timestamp);

    final typingSpeed = _calculateTypingSpeed();
    final rhythmConsistency = _calculateRhythmConsistency();
    final errorRate = _errorCount / math.max(_totalKeystrokes, 1);

    final metric = KeystrokeMetric(
      typingSpeed: typingSpeed,
      dwellTime: dwellTime.toDouble(),
      flightTime: flightTime,
      rhythmConsistency: rhythmConsistency,
      errorRate: errorRate,
      timestamp: now,
    );

    _metrics.add(metric);
    _cleanOldData();
    _updateBaseline();
    notifyListeners();
  }

  double _calculateTypingSpeed() {
    if (_metrics.isEmpty) return 0;

    final recentMetrics = _getRecentMetrics(const Duration(seconds: 30));
    if (recentMetrics.isEmpty) return 0;

    final timeSpan = recentMetrics.last.timestamp
        .difference(recentMetrics.first.timestamp)
        .inMinutes;
    if (timeSpan == 0) return 0;

    return _totalKeystrokes / (timeSpan * 5);
  }

  double _calculateRhythmConsistency() {
    final recentMetrics = _getRecentMetrics(const Duration(seconds: 10));
    if (recentMetrics.length < 2) return 1.0;

    List<double> intervals = [];
    for (int i = 1; i < recentMetrics.length; i++) {
      intervals.add(recentMetrics[i].flightTime);
    }

    final mean = intervals.reduce((a, b) => a + b) / intervals.length;
    final variance =
        intervals.map((t) => math.pow(t - mean, 2)).reduce((a, b) => a + b) /
            intervals.length;

    final stdDev = math.sqrt(variance);
    return 1 - (stdDev / mean).clamp(0.0, 1.0);
  }

  List<KeystrokeMetric> _getRecentMetrics(Duration duration) {
    final cutoff = DateTime.now().subtract(duration);
    return _metrics.where((m) => m.timestamp.isAfter(cutoff)).toList();
  }

  void _cleanOldData() {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 5));
    _metrics.removeWhere((m) => m.timestamp.isBefore(cutoff));
  }

  void _updateBaseline() {
    if (_metrics.length < 100) return;
    _baselineTypingSpeed =
        _metrics.map((m) => m.typingSpeed).reduce((a, b) => a + b) /
            _metrics.length;
  }

  void _analyzePatterns() {
    final recentMetrics = _getRecentMetrics(const Duration(minutes: 3));
    if (recentMetrics.length < 10) return;

    int stressIndicators = 0;
    for (final metric in recentMetrics) {
      if (_isStressIndicator(metric)) {
        stressIndicators++;
      }
    }

    if (stressIndicators >= 5) {
      _showStressNotification();
    }
  }

  bool _isStressIndicator(KeystrokeMetric metric) {
    return metric.typingSpeed > _baselineTypingSpeed * 1.3 ||
        metric.rhythmConsistency < 0.7 ||
        metric.errorRate > 0.1;
  }

  Future<void> _showStressNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'stress_channel',
      'Stress Notifications',
      channelDescription: 'Notifications for stress detection',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Stress Detection',
      'We noticed some stress indicators in your typing pattern. Would you like to take a break?',
      details,
    );
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    super.dispose();
  }
}

class AppUsageProvider with ChangeNotifier {
  final List<AppUsageMetric> _metrics = [];
  DateTime? _lastSwitch;
  int _switchCount = 0;
  Timer? _analysisTimer;
  bool _isActive = false;

  // Cooldown properties
  DateTime? lastNotificationTime;
  static const Duration notificationCooldown = Duration(minutes: 3);

  List<AppUsageMetric> get metrics => _metrics;
  bool get isActive => _isActive;

  AppUsageProvider() {
    _analysisTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _analyzePatterns();
    });

    // Start tracking when app becomes active
    WidgetsBinding.instance.addObserver(
      LifecycleObserver(
        onResume: () {
          _isActive = true;
          recordAppSwitch();
        },
        onPause: () {
          _isActive = false;
          notifyListeners();
        },
      ),
    );
  }

  void recordAppSwitch() {
    final now = DateTime.now();
    _switchCount++;

    if (_lastSwitch != null) {
      final timeSinceLastSwitch = now.difference(_lastSwitch!).inSeconds;
      final intensity = 60 / math.max(timeSinceLastSwitch, 1);

      _metrics.add(AppUsageMetric(
        switchCount: _switchCount,
        timestamp: now,
        intensity: intensity,
      ));

      _cleanOldData();
      notifyListeners();
    }

    _lastSwitch = now;
  }

  void _cleanOldData() {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 5));
    _metrics.removeWhere((m) => m.timestamp.isBefore(cutoff));
  }

  void _analyzePatterns() {
    if (!_isActive) return;

    final recentMetrics = _getRecentMetrics(const Duration(minutes: 3));
    if (recentMetrics.isEmpty) return;

    final totalSwitches =
        recentMetrics.last.switchCount - recentMetrics.first.switchCount;

    if (totalSwitches >= 7) {
      // Check cooldown before sending notification
      if (lastNotificationTime == null ||
          DateTime.now().difference(lastNotificationTime!) >
              notificationCooldown) {
        _showUsageNotification();
        _switchCount = 0; // Reset switch count after notification
        lastNotificationTime = DateTime.now(); // Update last notification time
      }
    }
  }

  List<AppUsageMetric> _getRecentMetrics(Duration duration) {
    final cutoff = DateTime.now().subtract(duration);
    return _metrics.where((m) => m.timestamp.isAfter(cutoff)).toList();
  }

  Future<void> _showUsageNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'usage_channel',
      'Usage Notifications',
      channelDescription: 'Notifications for app usage patterns',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      1,
      'App Usage Pattern',
      'We noticed frequent app switching. Would you like to focus on one task?',
      details,
    );
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    super.dispose();
  }
}

// Lifecycle observer for app state changes
class LifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;
  final VoidCallback onPause;

  LifecycleObserver({required this.onResume, required this.onPause});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResume();
        break;
      case AppLifecycleState.paused:
        onPause();
        break;
      default:
        break;
    }
  }
}

// Custom Painters for Graphs
class GraphPainter extends CustomPainter {
  final List<KeystrokeMetric> metrics;
  final double baselineSpeed;
  final Color primaryColor;
  final Color baselineColor;
  final Color thresholdColor;

  GraphPainter({
    required this.metrics,
    required this.baselineSpeed,
    required this.primaryColor,
    required this.baselineColor,
    required this.thresholdColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw threshold line
    paint.color = thresholdColor.withOpacity(0.5);
    final thresholdY = size.height * 0.3;
    canvas.drawLine(
      Offset(0, thresholdY),
      Offset(size.width, thresholdY),
      paint,
    );

    // Draw baseline
    paint.color = baselineColor;
    final baselineY = _normalizeValue(baselineSpeed, size.height);
    canvas.drawLine(
      Offset(0, baselineY),
      Offset(size.width, baselineY),
      paint,
    );

    // Draw typing speed line
    paint.color = primaryColor;
    final path = Path();
    bool first = true;

    for (var i = 0; i < metrics.length; i++) {
      final x = size.width * (i / (metrics.length - 1));
      final y = _normalizeValue(metrics[i].typingSpeed, size.height);

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  double _normalizeValue(double value, double height) {
    return height - (value / 100 * height);
  }

  @override
  bool shouldRepaint(GraphPainter oldDelegate) => true;
}

class AppUsageGraphPainter extends CustomPainter {
  final List<AppUsageMetric> metrics;
  final Color primaryColor;
  final Color thresholdColor;

  AppUsageGraphPainter({
    required this.metrics,
    required this.primaryColor,
    required this.thresholdColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw threshold line (7 switches/3min)
    paint.color = thresholdColor.withOpacity(0.5);
    final thresholdY = size.height * 0.3;
    canvas.drawLine(
      Offset(0, thresholdY),
      Offset(size.width, thresholdY),
      paint,
    );

    // Draw intensity bars
    paint.color = primaryColor;
    final barWidth = size.width / 20;

    for (var i = 0; i < metrics.length; i++) {
      final x = size.width * (i / (metrics.length - 1));
      final height = size.height * (metrics[i].intensity / 10);

      canvas.drawRect(
        Rect.fromLTWH(
          x - barWidth / 2,
          size.height - height,
          barWidth,
          height,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(AppUsageGraphPainter oldDelegate) => true;
}
