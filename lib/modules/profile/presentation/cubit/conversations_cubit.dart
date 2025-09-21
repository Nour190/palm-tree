// conversations_cubit.dart
// Cubit + State in one file to keep the bundle at 3 files total.

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseqat/modules/artwork_details/data/models/conversation_models.dart';

import '../../data/repositories/conversations_repository.dart';

// ---- State ----

enum ConversationsStatus { initial, loading, ready, error }

class ConversationsState extends Equatable {
  final ConversationsStatus status;
  final String? userId;

  final List<ConversationRecord> items;

  final bool hasMore;
  final bool isLoadingMore;

  final int pageSize;
  final int offset;

  final bool activeOnly;

  final String? error;

  const ConversationsState({
    this.status = ConversationsStatus.initial,
    this.userId,
    this.items = const [],
    this.hasMore = false,
    this.isLoadingMore = false,
    this.pageSize = 20,
    this.offset = 0,
    this.activeOnly = false,
    this.error,
  });

  ConversationsState copyWith({
    ConversationsStatus? status,
    String? userId,
    List<ConversationRecord>? items,
    bool? hasMore,
    bool? isLoadingMore,
    int? pageSize,
    int? offset,
    bool? activeOnly,
    String? error,
    bool clearError = false,
  }) {
    return ConversationsState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      pageSize: pageSize ?? this.pageSize,
      offset: offset ?? this.offset,
      activeOnly: activeOnly ?? this.activeOnly,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props =>
      [status, userId, items, hasMore, isLoadingMore, pageSize, offset, activeOnly, error];
}

// ---- Cubit ----

class ConversationsCubit extends Cubit<ConversationsState> {
  final ConversationsRepository _repo;

  ConversationsCubit(this._repo, {int pageSize = 20})
      : super(ConversationsState(pageSize: pageSize));

  /// Loads the first page for a given userId.
  Future<void> loadFirst({
    required String userId,
    bool activeOnly = false,
    int? pageSize,
  }) async {
    emit(
      state.copyWith(
        status: ConversationsStatus.loading,
        userId: userId,
        activeOnly: activeOnly,
        pageSize: pageSize ?? state.pageSize,
        offset: 0,
        items: const [],
        hasMore: false,
        isLoadingMore: false,
        clearError: true,
      ),
    );

    try {
      final limit = pageSize ?? state.pageSize;
      final rows = await _repo.getUserConversations(
        userId: userId,
        limit: limit,
        offset: 0,
        activeOnly: activeOnly,
      );

      emit(
        state.copyWith(
          status: ConversationsStatus.ready,
          items: rows,
          hasMore: rows.length >= limit,
          offset: rows.length, // next page starts from here
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConversationsStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  /// Loads the next page (uses the same filters as the last `loadFirst`).
  Future<void> loadMore() async {
    if (state.status != ConversationsStatus.ready ||
        state.isLoadingMore ||
        !state.hasMore ||
        (state.userId ?? '').isEmpty) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearError: true));

    try {
      final rows = await _repo.getUserConversations(
        userId: state.userId!,
        limit: state.pageSize,
        offset: state.offset,
        activeOnly: state.activeOnly,
      );

      final merged = <ConversationRecord>[...state.items, ...rows];

      emit(
        state.copyWith(
          isLoadingMore: false,
          items: merged,
          offset: state.offset + rows.length,
          hasMore: rows.length >= state.pageSize,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }

  Future<void> refresh() async {
    final userId = state.userId;
    if (userId == null || userId.isEmpty) return;
    await loadFirst(
      userId: userId,
      activeOnly: state.activeOnly,
      pageSize: state.pageSize,
    );
  }

  void consumeError() {
    if (state.error != null) {
      emit(state.copyWith(clearError: true));
    }
  }
}
