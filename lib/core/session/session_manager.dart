import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:baseqat/core/database/hive_service.dart';
import 'package:flutter/foundation.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static const String _sessionIdKey = 'current_session_id';
  static const String _sessionStartKey = 'session_start_time';

  String? _currentSessionId;
  DateTime? _sessionStartTime;

  String? get currentSessionId => _currentSessionId;
  String get sessionId {
    if (_currentSessionId == null) {
      throw StateError('Session not initialized. Call restoreSession() or startSession() first.');
    }
    return _currentSessionId!;
  }

  DateTime? get sessionStartTime => _sessionStartTime;
  bool get hasActiveSession => _currentSessionId != null;

  /// Start a new session with a unique UUID
  Future<void> startSession() async {
    final uuid = const Uuid();
    _currentSessionId = uuid.v4();
    _sessionStartTime = DateTime.now();

    final sessionBox = Hive.box(HiveService.sessionBox);
    await sessionBox.put(_sessionIdKey, _currentSessionId);
    await sessionBox.put(_sessionStartKey, _sessionStartTime!.toIso8601String());

    debugPrint('[SessionManager] New session started: $_currentSessionId');
  }

  /// Restore session from Hive (if exists)
  Future<void> restoreSession() async {
    final sessionBox = Hive.box(HiveService.sessionBox);
    _currentSessionId = sessionBox.get(_sessionIdKey) as String?;

    final startTimeStr = sessionBox.get(_sessionStartKey) as String?;
    if (startTimeStr != null) {
      _sessionStartTime = DateTime.parse(startTimeStr);
    }

    if (_currentSessionId != null) {
      debugPrint('[SessionManager] Session restored: $_currentSessionId');
    }
  }

  /// End the current session and clear all cached data
  Future<void> endSession() async {
    if (_currentSessionId == null) return;

    debugPrint('[SessionManager] Ending session: $_currentSessionId');

    // Clear all Hive data
    await HiveService.clearAllData();

    // Clear session info
    final sessionBox = Hive.box(HiveService.sessionBox);
    await sessionBox.delete(_sessionIdKey);
    await sessionBox.delete(_sessionStartKey);

    _currentSessionId = null;
    _sessionStartTime = null;

    debugPrint('[SessionManager] Session ended and data cleared');
  }

  /// Get session duration
  Duration? getSessionDuration() {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!);
  }
}
