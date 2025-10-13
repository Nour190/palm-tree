// chat_cubit.dart
// Cubit + States aligned with chat_tab.dart behavior.
// - Persisted chat (Supabase) via ChatRepository
// - Per-message translation toggle (user & model); voice notes never translated
// - Live translation for streaming model message (debounced)
// - Five-language TTS/translation target selection handled in Cubit
//
// deps:
//   flutter_bloc, equatable
//   translator: ^1.0.4+1
//
// repo contract (previous step):
//   ChatRepository, ConversationRecord, MessageRecord

import 'package:baseqat/modules/artwork_details/data/models/conversation_models.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus { initial, loading, ready, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final ConversationRecord? conversation;

  /// Messages sorted ASC by createdAt (oldest -> newest)
  final List<MessageRecord> messages;

  /// UI flags
  final bool isSending;
  final bool isLoadingMore;

  /// Paging: if there are more older messages to load
  final bool hasMore;

  /// Oldest loaded message timestamp (used as `before` anchor)
  final DateTime? anchorBefore;

  /// Last error message (for one-shot snackbars / banners)
  final String? error;

  /// IDs currently translating (spinner in bubbles)
  final Set<String> translatingIds;

  /// TTS & translation target locale for UI header selector (e.g., 'en-US', 'ar-SA')
  final String ttsLocale;

  /// Streaming model message: a temporary local id while streaming
  final String? streamingMessageId;

  /// Streaming text (so UI can render partials if needed)
  final String streamingText;

  /// When toggle is ON for the streaming message
  final bool streamingShowTranslation;

  /// Cached translation of streaming text
  final String streamingTranslationText;

  /// Translation language code used (e.g., 'en', 'ar', 'fr', 'es', 'zh-cn')
  final String streamingTranslationCode;

  const ChatState({
    this.status = ChatStatus.initial,
    this.conversation,
    this.messages = const [],
    this.isSending = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.anchorBefore,
    this.error,
    this.translatingIds = const {},
    this.ttsLocale = 'en-US',
    this.streamingMessageId,
    this.streamingText = '',
    this.streamingShowTranslation = false,
    this.streamingTranslationText = '',
    this.streamingTranslationCode = 'en',
  });

  ChatState copyWith({
    ChatStatus? status,
    ConversationRecord? conversation,
    List<MessageRecord>? messages,
    bool? isSending,
    bool? isLoadingMore,
    bool? hasMore,
    DateTime? anchorBefore,
    String? error,
    bool clearError = false,
    Set<String>? translatingIds,
    String? ttsLocale,
    String? streamingMessageId,
    String? streamingText,
    bool? streamingShowTranslation,
    String? streamingTranslationText,
    String? streamingTranslationCode,
  }) {
    return ChatState(
      status: status ?? this.status,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      anchorBefore: anchorBefore ?? this.anchorBefore,
      error: clearError ? null : (error ?? this.error),
      translatingIds: translatingIds ?? this.translatingIds,
      ttsLocale: ttsLocale ?? this.ttsLocale,
      streamingMessageId: streamingMessageId ?? this.streamingMessageId,
      streamingText: streamingText ?? this.streamingText,
      streamingShowTranslation:
      streamingShowTranslation ?? this.streamingShowTranslation,
      streamingTranslationText:
      streamingTranslationText ?? this.streamingTranslationText,
      streamingTranslationCode:
      streamingTranslationCode ?? this.streamingTranslationCode,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    conversation,
    messages,
    isSending,
    isLoadingMore,
    hasMore,
    anchorBefore,
    error,
    translatingIds,
    ttsLocale,
    streamingMessageId,
    streamingText,
    streamingShowTranslation,
    streamingTranslationText,
    streamingTranslationCode,
  ];
}
