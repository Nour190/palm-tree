import 'package:baseqat/modules/artwork_details/data/models/chat_models.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus {
  idle,
  loadingHistory,
  streaming,
  sendingMessage,
  uploadingFiles,
  deletingMessage,
  error,
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessage> messages; // oldest → newest
  final DateTime? oldestCursor;
  final bool hasMore;
  final String? error;

  const ChatState({
    this.status = ChatStatus.idle,
    this.messages = const [],
    this.oldestCursor,
    this.hasMore = false,
    this.error,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    DateTime? oldestCursor,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      oldestCursor: oldestCursor ?? this.oldestCursor,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, messages, oldestCursor, hasMore, error];
}
