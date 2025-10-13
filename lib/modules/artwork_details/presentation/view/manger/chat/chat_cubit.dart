// chat_cubit.dart
import 'dart:async';
import 'package:baseqat/modules/artwork_details/data/models/conversation_models.dart';
import 'package:baseqat/modules/artwork_details/data/repositories/chat_repository.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/manger/chat/chat_states.dart';
import 'package:baseqat/core/network/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:translator/translator.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repo;
  final int _pageSize;
  final GoogleTranslator _translator;
  final ConnectivityService _connectivityService = ConnectivityService();

  Timer? _streamTranslateDebouncer;

  ChatCubit(this._repo, {int pageSize = 50, GoogleTranslator? translator})
      : _pageSize = pageSize,
        _translator = translator ?? GoogleTranslator(),
        super(const ChatState());

  // ============================
  // Init / Load
  // ============================
  Future<void> init({
    required String sessionId, // Changed from userId to sessionId
    required String artworkId,
    String? sessionLabel,
    Map<String, dynamic>? metadata,
    bool singleActive = false,
    int? initialLimit,

    // NEW: denormalized artwork snapshot (stored only when a new conversation is created)
    String? artworkName,
    List<String>? artworkGallery,
    String? artworkDescription,
  }) async {
    print('═══════════════════════════════════════════════════════════');
    print('[ChatCubit] init() START');
    print('[ChatCubit] sessionId: $sessionId');
    print('[ChatCubit] artworkId: $artworkId');
    print('[ChatCubit] artworkName: $artworkName');
    print('═══════════════════════════════════════════════════════════');

    final hasConnection = await _connectivityService.hasConnection();
    print('[ChatCubit] Has connection: $hasConnection');

    if (!hasConnection) {
      print('[ChatCubit] No internet connection - aborting init');
      emit(state.copyWith(
        status: ChatStatus.error,
        error: 'Chat requires an internet connection',
      ));
      return;
    }

    emit(state.copyWith(status: ChatStatus.loading, clearError: true));

    try {
      print('[ChatCubit] Calling _repo.initConversation()...');

      final conv = await _repo.initConversation(
        sessionId: sessionId, // Using sessionId instead of userId
        artworkId: artworkId,
        sessionLabel: sessionLabel,
        metadata: metadata,
        singleActive: singleActive,
        artworkName: artworkName,
        artworkGallery: artworkGallery,
        artworkDescription: artworkDescription,
      );

      print('[ChatCubit] Conversation returned: ${conv.id}');
      print('[ChatCubit] Conversation user_id: ${conv.sessionId}');
      print('[ChatCubit] Conversation artwork_id: ${conv.artworkId}');

      final limit = initialLimit ?? _pageSize;

      print('[ChatCubit] Fetching message history (limit: $limit)...');

      final msgs = await _repo.getHistory(
        conversationId: conv.id,
        limit: limit,
      );

      msgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      print('[ChatCubit] Fetched ${msgs.length} messages');

      emit(
        state.copyWith(
          status: ChatStatus.ready,
          conversation: conv,
          messages: msgs,
          hasMore: msgs.length >= limit,
          anchorBefore: msgs.isNotEmpty ? msgs.first.createdAt : null,
          clearError: true,
        ),
      );

      print('[ChatCubit] init() COMPLETE. Status: ready, conversation ID: ${conv.id}');
      print('═══════════════════════════════════════════════════════════');
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════════════════════════');
      print('[ChatCubit] init() ERROR: $e');
      print('[ChatCubit] Stack trace: $stackTrace');
      print('═══════════════════════════════════════════════════════════');
      emit(state.copyWith(status: ChatStatus.error, error: e.toString()));
    }
  }

  /// Convenience: list all conversations for this session (optionally by artwork).
  Future<List<ConversationRecord>> listUserConversations({
    required String sessionId, // Changed from userId to sessionId
    String? artworkId,
    int limit = 20,
    int offset = 0,
    bool activeOnly = false,
  }) async {
    try {
      return await _repo.listConversations(
        sessionId: sessionId, // Using sessionId instead of userId
        artworkId: artworkId,
        limit: limit,
        offset: offset,
        activeOnly: activeOnly,
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> refresh() async {
    final conv = state.conversation;
    if (conv == null) return;

    try {
      final msgs = await _repo.getHistory(
        conversationId: conv.id,
        limit: _pageSize,
      );
      msgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      emit(
        state.copyWith(
          status: ChatStatus.ready,
          messages: msgs,
          hasMore: msgs.length >= _pageSize,
          anchorBefore: msgs.isNotEmpty ? msgs.first.createdAt : null,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.error, error: e.toString()));
    }
  }

  Future<void> loadMore() async {
    final conv = state.conversation;
    if (conv == null || state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true, clearError: true));
    try {
      final older = await _repo.getHistory(
        conversationId: conv.id,
        before: state.anchorBefore,
        limit: _pageSize,
      );
      older.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final merged = <MessageRecord>[...older, ...state.messages];
      final newAnchor = merged.isNotEmpty
          ? merged.first.createdAt
          : state.anchorBefore;

      emit(
        state.copyWith(
          isLoadingMore: false,
          messages: merged,
          anchorBefore: newAnchor,
          hasMore: older.length >= _pageSize,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }

  // ============================
  // TTS / Translation Locale (header)
  // ============================
  void setTtsLocale(String locale) {
    // e.g., 'en-US', 'ar-SA', 'fr-FR', 'es-ES', 'zh-CN'
    emit(state.copyWith(ttsLocale: locale));
  }

  String get currentTargetLang => _translatorCodeForLocale(state.ttsLocale);

  /// For your `_speak(text)` in UI: call this to get translated text for speech.
  Future<String> translateForSpeech(String text) async {
    final to = currentTargetLang;
    try {
      final res = await _translator.translate(text, to: to);
      return res.text;
    } catch (_) {
      return text;
    }
  }

  String _translatorCodeForLocale(String code) {
    final lower = code.toLowerCase();
    if (lower.startsWith('en')) return 'en';
    if (lower.startsWith('ar')) return 'ar';
    if (lower.startsWith('fr')) return 'fr';
    if (lower.startsWith('es')) return 'es';
    if (lower.startsWith('zh')) return 'zh-cn'; // Simplified
    return 'en';
  }

  // ============================
  // Send / Save messages
  // ============================
  Future<void> sendUserMessage({
    required String content,
    bool isVoice = false,
    Duration? voiceDuration,
    String? languageCode,
    bool showTranslation = false,
    String? translationText,
    String? translationLang,
    String? ttsLang,
    Map<String, dynamic>? extras,
  }) async {
    final conv = state.conversation;
    if (conv == null) {
      debugPrint('[ChatCubit] sendUserMessage() error: No active conversation');
      return;
    }

    debugPrint('[ChatCubit] sendUserMessage() called. Content: $content, isVoice: $isVoice');

    final hasConnection = await _connectivityService.hasConnection();
    if (!hasConnection) {
      debugPrint('[ChatCubit] sendUserMessage() error: No internet connection');
      emit(state.copyWith(error: 'Chat requires an internet connection'));
      return;
    }

    emit(state.copyWith(isSending: true, clearError: true));
    try {
      // Enforce "voice notes are not translated" rule
      if (isVoice) {
        showTranslation = false;
        translationText = null;
        translationLang = null;
      }

      debugPrint('[ChatCubit] Sending message to repository...');

      final created = await _repo.sendUserMessage(
        content: content,
        isVoice: isVoice,
        voiceDurationS: voiceDuration?.inSeconds,
        languageCode: languageCode,
        showTranslation: showTranslation,
        translationText: translationText,
        translationLang: translationLang,
        ttsLang: ttsLang,
        extras: extras,
      );

      debugPrint('[ChatCubit] Message sent successfully. ID: ${created.id}');

      final next = [...state.messages, created]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      emit(state.copyWith(isSending: false, messages: next));

      debugPrint('[ChatCubit] State updated. Total messages: ${next.length}');
    } catch (e) {
      debugPrint('[ChatCubit] sendUserMessage() error: $e');
      emit(state.copyWith(isSending: false, error: e.toString()));
    }
  }

  Future<void> saveModelMessage({
    required String content,
    String? languageCode,
    bool showTranslation = false,
    String? translationText,
    String? translationLang,
    String? ttsLang,
    Map<String, dynamic>? extras,
  }) async {
    final conv = state.conversation;
    if (conv == null) {
      debugPrint('[ChatCubit] saveModelMessage() error: No active conversation');
      return;
    }

    debugPrint('[ChatCubit] saveModelMessage() called. Content length: ${content.length}');

    try {
      final created = await _repo.saveModelMessage(
        content: content,
        languageCode: languageCode,
        showTranslation: showTranslation,
        translationText: translationText,
        translationLang: translationLang,
        ttsLang: ttsLang,
        extras: extras,
      );

      debugPrint('[ChatCubit] Model message saved successfully. ID: ${created.id}');

      final next = [...state.messages, created]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      emit(state.copyWith(messages: next, clearError: true));

      debugPrint('[ChatCubit] State updated. Total messages: ${next.length}');
    } catch (e) {
      debugPrint('[ChatCubit] saveModelMessage() error: $e');
      emit(state.copyWith(error: e.toString()));
    }
  }

  // ============================
  // Streaming model message (for Gemini)
  // ============================
  void beginModelStream({bool showTranslation = false}) {
    // Create a temp "local" message id
    final tempId = 'local-${DateTime.now().microsecondsSinceEpoch}';

    emit(
      state.copyWith(
        streamingMessageId: tempId,
        streamingText: '',
        streamingShowTranslation: showTranslation,
        streamingTranslationText: '',
        streamingTranslationCode: currentTargetLang,
        clearError: true,
      ),
    );
  }

  void appendModelChunk(String chunk) {
    final id = state.streamingMessageId;
    if (id == null) return;

    final newText = state.streamingText + (chunk.isNotEmpty ? chunk : '');
    // Update streaming text (UI can show partials if desired)
    emit(state.copyWith(streamingText: newText));

    // Debounced translation while streaming if toggle ON
    if (state.streamingShowTranslation && newText.trim().isNotEmpty) {
      _streamTranslateDebouncer?.cancel();
      _streamTranslateDebouncer = Timer(
        const Duration(milliseconds: 350),
            () async {
          final to = currentTargetLang;
          try {
            final res = await _translator.translate(newText, to: to);
            // Only apply if still same streaming id
            if (state.streamingMessageId == id) {
              emit(
                state.copyWith(
                  streamingTranslationText: res.text,
                  streamingTranslationCode: to,
                ),
              );
            }
          } catch (_) {
            // keep silent; UI can retry by toggling later
          }
        },
      );
    }
  }

  /// Finalize: save the streamed text as a persisted model message.
  Future<void> endModelStream({
    String? languageCode,
    String? ttsLang,
    Map<String, dynamic>? extras,
  }) async {
    final id = state.streamingMessageId;
    if (id == null) return;

    _streamTranslateDebouncer?.cancel();

    final finalText = state.streamingText.trim();
    final showTr = state.streamingShowTranslation && finalText.isNotEmpty;

    try {
      final saved = await _repo.saveModelMessage(
        content: finalText,
        languageCode: languageCode,
        showTranslation: showTr,
        translationText: showTr ? state.streamingTranslationText : null,
        translationLang: showTr ? state.streamingTranslationCode : null,
        ttsLang: ttsLang,
        extras: extras,
      );

      final next = [...state.messages, saved]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      emit(
        state.copyWith(
          messages: next,
          streamingMessageId: null,
          streamingText: '',
          streamingShowTranslation: false,
          streamingTranslationText: '',
          clearError: true,
        ),
      );
    } catch (e) {
      // do not drop partials silently; just clear streaming state and surface error
      emit(
        state.copyWith(
          error: e.toString(),
          streamingMessageId: null,
          streamingText: '',
          streamingShowTranslation: false,
          streamingTranslationText: '',
        ),
      );
    }
  }

  // ============================
  // Per-message translation toggle (persisted)
  // ============================
  Future<void> toggleMessageTranslation(String messageId) async {
    // Find message
    final idx = state.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;

    final m = state.messages[idx];
    // Voice notes: blocked
    if (m.isVoice == true) {
      // No state change; UI can show a snack
      return;
    }

    final nowTranslating = Set<String>.from(state.translatingIds);

    // If ON -> turn OFF (and persist)
    if (m.showTranslation) {
      // optimistic off
      final updated = MessageRecord(
        id: m.id,
        conversationId: m.conversationId,
        role: m.role,
        content: m.content,
        isVoice: m.isVoice,
        voiceDurationS: m.voiceDurationS,
        languageCode: m.languageCode,
        showTranslation: false,
        translationText: null,
        translationLang: null,
        ttsLang: m.ttsLang,
        extras: m.extras,
        createdAt: m.createdAt,
      );
      final patched = [...state.messages]..[idx] = updated;
      emit(state.copyWith(messages: patched));

      try {
        await _repo.setMessageTranslation(
          messageId: m.id,
          showTranslation: false,
          translationText: null,
          translationLang: null,
        );
      } catch (e) {
        // rollback
        final rollback = [...state.messages]..[idx] = m;
        emit(state.copyWith(messages: rollback, error: e.toString()));
      }
      return;
    }

    // If OFF -> turn ON: translate and persist
    nowTranslating.add(m.id);
    emit(state.copyWith(translatingIds: nowTranslating));

    try {
      final to = currentTargetLang;
      final res = await _translator.translate(m.content, to: to);

      final updated = MessageRecord(
        id: m.id,
        conversationId: m.conversationId,
        role: m.role,
        content: m.content,
        isVoice: m.isVoice,
        voiceDurationS: m.voiceDurationS,
        languageCode: m.languageCode,
        showTranslation: true,
        translationText: res.text,
        translationLang: to,
        ttsLang: m.ttsLang,
        extras: m.extras,
        createdAt: m.createdAt,
      );

      final patched = [...state.messages]..[idx] = updated;
      nowTranslating.remove(m.id);

      emit(state.copyWith(messages: patched, translatingIds: nowTranslating));

      await _repo.setMessageTranslation(
        messageId: m.id,
        showTranslation: true,
        translationText: res.text,
        translationLang: to,
      );
    } catch (e) {
      nowTranslating.remove(m.id);
      emit(state.copyWith(translatingIds: nowTranslating, error: e.toString()));
    }
  }

  // ============================
  // Utilities
  // ============================
  void consumeError() {
    if (state.error != null) {
      emit(state.copyWith(clearError: true));
    }
  }

  Future<void> clearConversationCache(String conversationId) async {
    try {
      debugPrint('[ChatCubit] Clearing conversation cache for: $conversationId');
      // This would call a method in the repository to clear local cache
      // For now, just clear the messages from state
      emit(state.copyWith(messages: []));
      debugPrint('[ChatCubit] Conversation cache cleared');
    } catch (e) {
      debugPrint('[ChatCubit] Error clearing conversation cache: $e');
      emit(state.copyWith(error: e.toString()));
    }
  }
}
