import 'dart:async';
import 'package:baseqat/modules/artwork_details/presentation/view/manger/chat/chat_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/artwork_repository.dart';
import 'package:baseqat/modules/artwork_details/data/models/chat_models.dart';

class ChatCubit extends Cubit<ChatState> {
  final ArtworkDetailsRepository repo;
  StreamSubscription<List<ChatMessage>>? _chatSub;

  ChatCubit(this.repo) : super(const ChatState());

  /// Load latest chat page (or older page if [before] is provided).
  Future<void> loadHistory({
    required String artworkId,
    required String userId,
    int limit = 50,
    DateTime? before,
    bool appendOlder = false,
  }) async {
    emit(state.copyWith(status: ChatStatus.loadingHistory, clearError: true));

    final either = await repo.getChatHistory(
      artworkId: artworkId,
      userId: userId,
      limit: limit,
      // NOTE: add `before` to repository if you support cursor paging there
    );

    either.fold(
      (f) => emit(state.copyWith(status: ChatStatus.error, error: f.message)),
      (msgs) {
        final merged = appendOlder ? [...msgs, ...state.messages] : msgs;
        final oldest = merged.isNotEmpty
            ? merged.first.createdAt
            : state.oldestCursor;
        final hasMore = msgs.length >= limit;

        emit(
          state.copyWith(
            status: state.status == ChatStatus.streaming
                ? ChatStatus.streaming
                : ChatStatus.idle,
            messages: merged,
            oldestCursor: oldest,
            hasMore: hasMore,
            clearError: true,
          ),
        );
      },
    );
  }

  /// Start realtime stream after initial history load.
  Future<void> startStream({
    required String artworkId,
    required String userId,
  }) async {
    await _chatSub?.cancel();
    emit(state.copyWith(status: ChatStatus.streaming, clearError: true));

    _chatSub = repo
        .watchChat(artworkId: artworkId, userId: userId)
        .listen(
          (list) {
            final oldest = list.isNotEmpty
                ? list.first.createdAt
                : state.oldestCursor;
            emit(
              state.copyWith(
                messages: list,
                oldestCursor: oldest,
                status: ChatStatus.streaming,
                clearError: true,
              ),
            );
          },
          onError: (e, _) => emit(
            state.copyWith(status: ChatStatus.error, error: e.toString()),
          ),
          cancelOnError: false,
        );
  }

  Future<void> stopStream() async {
    await _chatSub?.cancel();
    _chatSub = null;
    emit(state.copyWith(status: ChatStatus.idle));
  }

  Future<void> sendMessage({
    required String artworkId,
    required String userId,
    String? text,
    List<UploadBlob> files = const [],
  }) async {
    emit(state.copyWith(status: ChatStatus.sendingMessage, clearError: true));

    final either = await repo.sendChatMessage(
      artworkId: artworkId,
      userId: userId,
      text: text,
      files: files,
    );

    either.fold(
      (f) => emit(state.copyWith(status: ChatStatus.error, error: f.message)),
      (_) => emit(
        state.copyWith(
          status: _chatSub == null ? ChatStatus.idle : ChatStatus.streaming,
        ),
      ),
    );
  }

  /// Upload files without sending a message (for compose UI).
  Future<EitherUpload> uploadFilesOnly({
    required String artworkId,
    required String userId,
    required List<UploadBlob> files,
    bool useSignedUrls = false,
    Duration signedUrlTTL = const Duration(hours: 1),
  }) async {
    emit(state.copyWith(status: ChatStatus.uploadingFiles, clearError: true));

    final either = await repo.uploadFiles(
      artworkId: artworkId,
      userId: userId,
      files: files,
      useSignedUrls: useSignedUrls,
      signedUrlTTL: signedUrlTTL,
    );

    return either.fold(
      (f) {
        emit(state.copyWith(status: ChatStatus.error, error: f.message));
        return EitherUpload.left(f.message);
      },
      (atts) {
        emit(
          state.copyWith(
            status: _chatSub == null ? ChatStatus.idle : ChatStatus.streaming,
          ),
        );
        return EitherUpload.right(atts);
      },
    );
  }

  Future<void> deleteMessage({
    required String messageId,
    required String userId,
  }) async {
    emit(state.copyWith(status: ChatStatus.deletingMessage, clearError: true));

    final either = await repo.deleteMessage(
      messageId: messageId,
      userId: userId,
    );

    either.fold(
      (f) => emit(state.copyWith(status: ChatStatus.error, error: f.message)),
      (_) {
        if (_chatSub == null) {
          final pruned = state.messages
              .where((m) => m.id != messageId)
              .toList();
          emit(state.copyWith(messages: pruned, status: ChatStatus.idle));
        } else {
          emit(state.copyWith(status: ChatStatus.streaming));
        }
      },
    );
  }

  Future<void> deleteAttachment(String storagePath) async {
    final either = await repo.deleteAttachment(storagePath: storagePath);
    either.fold(
      (f) => emit(state.copyWith(status: ChatStatus.error, error: f.message)),
      (_) {},
    );
  }

  @override
  Future<void> close() async {
    await _chatSub?.cancel();
    _chatSub = null;
    return super.close();
  }
}

/// Same helper you had, kept local for convenience.
class EitherUpload {
  final String? _left;
  final List<ChatAttachment>? _right;
  bool get isLeft => _left != null;
  bool get isRight => _right != null;
  String get left => _left!;
  List<ChatAttachment> get right => _right!;

  EitherUpload._(this._left, this._right);
  factory EitherUpload.left(String message) => EitherUpload._(message, null);
  factory EitherUpload.right(List<ChatAttachment> atts) =>
      EitherUpload._(null, atts);
}
