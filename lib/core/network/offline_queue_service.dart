import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:baseqat/core/network/connectivity_service.dart';
import 'package:baseqat/core/session/session_manager.dart';

/// Represents a queued operation to be synced when online
class QueuedOperation {
  final String id;
  final String type; // 'feedback', 'chat_message', 'location'
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  QueuedOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory QueuedOperation.fromMap(Map<String, dynamic> map) {
    return QueuedOperation(
      id: map['id'] as String,
      type: map['type'] as String,
      data: Map<String, dynamic>.from(map['data'] as Map),
      createdAt: DateTime.parse(map['createdAt'] as String),
      retryCount: map['retryCount'] as int? ?? 0,
    );
  }

  QueuedOperation copyWith({int? retryCount}) {
    return QueuedOperation(
      id: id,
      type: type,
      data: data,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Service to queue operations when offline and sync when online
class OfflineQueueService {
  static final OfflineQueueService _instance = OfflineQueueService._internal();
  factory OfflineQueueService() => _instance;
  OfflineQueueService._internal();

  static const String _queueBoxName = 'offline_queue_box';
  static const int _maxRetries = 3;

  final ConnectivityService _connectivityService = ConnectivityService();
  final SessionManager _sessionManager = SessionManager();

  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  /// Initialize the queue service and start listening to connectivity changes
  Future<void> initialize() async {
    // Open the queue box if not already open
    if (!Hive.isBoxOpen(_queueBoxName)) {
      await Hive.openBox(_queueBoxName);
    }

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen((_) async {
      final isOnline = await _connectivityService.hasConnection();
      if (isOnline && !_isSyncing) {
        debugPrint('[OfflineQueueService] Connection restored, starting sync...');
        await syncQueue();
      }
    });

    debugPrint('[OfflineQueueService] Initialized successfully');
  }

  /// Add an operation to the queue
  Future<void> enqueue({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final box = Hive.box(_queueBoxName);
    final operation = QueuedOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      data: data,
      createdAt: DateTime.now(),
    );

    await box.put(operation.id, jsonEncode(operation.toMap()));
    debugPrint('[OfflineQueueService] Enqueued $type operation: ${operation.id}');
  }

  /// Get all queued operations
  Future<List<QueuedOperation>> getQueue() async {
    final box = Hive.box(_queueBoxName);
    final operations = <QueuedOperation>[];

    for (var key in box.keys) {
      try {
        final jsonStr = box.get(key) as String;
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        operations.add(QueuedOperation.fromMap(map));
      } catch (e) {
        debugPrint('[OfflineQueueService] Error parsing operation $key: $e');
      }
    }

    return operations;
  }

  /// Sync all queued operations
  Future<void> syncQueue() async {
    if (_isSyncing) {
      debugPrint('[OfflineQueueService] Sync already in progress');
      return;
    }

    final isOnline = await _connectivityService.hasConnection();
    if (!isOnline) {
      debugPrint('[OfflineQueueService] Cannot sync: offline');
      return;
    }

    _isSyncing = true;
    debugPrint('[OfflineQueueService] Starting queue sync...');

    try {
      final operations = await getQueue();
      debugPrint('[OfflineQueueService] Found ${operations.length} operations to sync');

      for (var operation in operations) {
        try {
          await processWithHandler(operation);
          await _removeFromQueue(operation.id);
          debugPrint('[OfflineQueueService] Successfully synced ${operation.type}: ${operation.id}');
        } catch (e) {
          debugPrint('[OfflineQueueService] Error syncing ${operation.type}: $e');

          // Increment retry count
          if (operation.retryCount < _maxRetries) {
            await _updateRetryCount(operation);
          } else {
            debugPrint('[OfflineQueueService] Max retries reached for ${operation.id}, removing from queue');
            await _removeFromQueue(operation.id);
          }
        }
      }

      debugPrint('[OfflineQueueService] Queue sync completed');
    } finally {
      _isSyncing = false;
    }
  }

  /// Update retry count for an operation
  Future<void> _updateRetryCount(QueuedOperation operation) async {
    final box = Hive.box(_queueBoxName);
    final updated = operation.copyWith(retryCount: operation.retryCount + 1);
    await box.put(operation.id, jsonEncode(updated.toMap()));
  }

  /// Remove an operation from the queue
  Future<void> _removeFromQueue(String operationId) async {
    final box = Hive.box(_queueBoxName);
    await box.delete(operationId);
  }

  /// Get queue size
  Future<int> getQueueSize() async {
    final box = Hive.box(_queueBoxName);
    return box.length;
  }

  /// Clear all queued operations
  Future<void> clearQueue() async {
    final box = Hive.box(_queueBoxName);
    await box.clear();
    debugPrint('[OfflineQueueService] Queue cleared');
  }

  /// Register a handler for a specific operation type
  final Map<String, Future<void> Function(Map<String, dynamic>)> _handlers = {};

  void registerHandler(String type, Future<void> Function(Map<String, dynamic>) handler) {
    _handlers[type] = handler;
    debugPrint('[OfflineQueueService] Registered handler for $type');
  }

  /// Process operation with registered handler
  Future<void> processWithHandler(QueuedOperation operation) async {
    final handler = _handlers[operation.type];
    if (handler == null) {
      debugPrint('[OfflineQueueService] No handler registered for ${operation.type}, skipping');
      return;
    }

    // Add sessionId to data if not present
    final sessionId = _sessionManager.currentSessionId;
    if (sessionId != null) {
      operation.data['sessionId'] = sessionId;
    }

    await handler(operation.data);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}
