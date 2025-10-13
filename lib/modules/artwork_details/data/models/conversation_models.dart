// chat_remote_data_source.dart (models section)
// Adds denormalized artwork fields to ConversationRecord:
//   - artworkName: String?
//   - artworkGallery: List<String>
//   - artworkDescription: String?
//
// Works with any of these shapes in your SELECT:
//   1) conversations.*, artworks.name AS artwork_name, artworks.gallery AS artwork_gallery, artworks.description AS artwork_description
//   2) conversations.*, artworks.*   (so keys are `name`, `gallery`, `description`)
//   3) conversations.*, artwork: artworks(*)  (nested object with { name, gallery, description })
//
// Tip: For (3) with Supabase, you can do:
//   .select('*, artwork:artworks(name, gallery, description))')

import 'dart:convert';

class ConversationRecord {
  final String id;
  final String sessionId;
  final String artworkId;
  final String? sessionLabel;
  final Map<String, dynamic> metadata;
  final DateTime startedAt;
  final DateTime? lastMessageAt;
  final int messageCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool? isActive; // optional column
  final String? artworkName;
  final List<String> artworkGallery;
  final String? artworkDescription;

  ConversationRecord({
    required this.id,
    required this.sessionId,
    required this.artworkId,
    this.sessionLabel,
    this.metadata = const {},
    required this.startedAt,
    this.lastMessageAt,
    this.messageCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive,

    // NEW
    this.artworkName,
    this.artworkGallery = const [],
    this.artworkDescription,
  });

  factory ConversationRecord.fromMap(Map<String, dynamic> m) {
    // If you selected a nested artwork object, extract it
    final Map<String, dynamic>? artwork = (m['artwork'] is Map)
        ? (m['artwork'] as Map).cast<String, dynamic>()
        : null;

    // Name resolution priority:
    // artwork_name -> name -> artwork.name
    final String? name =
        _readString(m['artwork_name']) ??
            _readString(m['name']) ??
            _readString(artwork?['name']);

    // Description resolution priority:
    // artwork_description -> description -> artwork.description
    final String? desc =
        _readString(m['artwork_description']) ??
            _readString(m['description']) ??
            _readString(artwork?['description']);

    // Gallery resolution priority:
    // artwork_gallery -> gallery -> artwork.gallery
    final List<String> gallery =
        _readStringList(m['artwork_gallery']) ??
            _readStringList(m['gallery']) ??
            _readStringList(artwork?['gallery']) ??
            const <String>[];

    return ConversationRecord(
      id: m['id'] as String,
      sessionId: m['user_id'] as String,
      artworkId: m['artwork_id'] as String,
      sessionLabel: m['session_label'] as String?,
      metadata: (m['metadata'] is Map)
          ? (m['metadata'] as Map).cast<String, dynamic>()
          : const {},
      startedAt: DateTime.parse(m['started_at'] as String),
      lastMessageAt: (m['last_message_at'] == null)
          ? null
          : DateTime.parse(m['last_message_at'] as String),
      messageCount: (m['message_count'] ?? 0) as int,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      isActive: m['is_active'] as bool?,

      // NEW
      artworkName: name,
      artworkGallery: gallery,
      artworkDescription: desc,
    );
  }

  // (Optional helper) If you ever need to serialize back to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': sessionId,
      'artwork_id': artworkId,
      'session_label': sessionLabel,
      'metadata': metadata,
      'started_at': startedAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'message_count': messageCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,

      'artwork_name': artworkName,
      'artwork_gallery': artworkGallery,
      'artwork_description': artworkDescription,
    };
  }
}

class MessageRecord {
  final String id;
  final String conversationId;
  final String role; // 'user' | 'model' | 'system'
  final String content;
  final bool isVoice;
  final int? voiceDurationS;
  final String? languageCode;
  final bool showTranslation;
  final String? translationText;
  final String? translationLang;
  final String? ttsLang;
  final Map<String, dynamic> extras;
  final DateTime createdAt;

  MessageRecord({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.isVoice = false,
    this.voiceDurationS,
    this.languageCode,
    this.showTranslation = false,
    this.translationText,
    this.translationLang,
    this.ttsLang,
    this.extras = const {},
    required this.createdAt,
  });

  factory MessageRecord.fromMap(Map<String, dynamic> m) {
    return MessageRecord(
      id: m['id'] as String,
      conversationId: m['conversation_id'] as String,
      role: m['role'] as String,
      content: m['content'] as String,
      isVoice: (m['is_voice'] ?? false) as bool,
      voiceDurationS: m['voice_duration_s'] as int?,
      languageCode: m['language_code'] as String?,
      showTranslation: (m['show_translation'] ?? false) as bool,
      translationText: m['translation_text'] as String?,
      translationLang: m['translation_lang'] as String?,
      ttsLang: m['tts_lang'] as String?,
      extras: (m['extras'] is Map)
          ? (m['extras'] as Map).cast<String, dynamic>()
          : const {},
      createdAt: DateTime.parse(m['created_at'] as String),
    );
  }
}

/// ------------
/// Helpers
/// ------------
String? _readString(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  return v.toString();
}

List<String>? _readStringList(dynamic v) {
  if (v == null) return null;

  // Already a list
  if (v is List) {
    return v
        .map((e) => e?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // JSON string like '["a","b"]'
  if (v is String) {
    final s = v.trim();
    if (s.startsWith('[') && s.endsWith(']')) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is List) {
          return decoded
              .map((e) => e?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList();
        }
      } catch (_) {
        // fallthrough to single-string
      }
    }
    // Comma-separated fallback: "a,b,c"
    if (s.contains(',')) {
      return s
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    // Single string -> single element list
    if (s.isNotEmpty) return [s];
    return <String>[];
  }

  // Unknown type -> stringify
  return [v.toString()];
}
