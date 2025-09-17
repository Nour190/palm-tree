// lib/modules/artwork_details/presentation/view/manger/feedback/feedback_cubit.dart

import 'package:baseqat/modules/artwork_details/data/repositories/artwork_repository.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/manger/feedback/feedback_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  final ArtworkDetailsRepository repo;

  FeedbackCubit(this.repo) : super(const FeedbackState());

  Future<void> submitFeedback({
    required String userId,
    required String artworkId,
    required int rating,
    required String message,
    List<String> tags = const [],
  }) async {
    // lightweight client-side validation (fail fast)
    if (rating < 1 || rating > 5) {
      emit(
        state.copyWith(
          status: FeedbackStatus.error,
          error: 'Rating must be between 1 and 5.',
        ),
      );
      return;
    }
    if (message.trim().isEmpty) {
      emit(
        state.copyWith(
          status: FeedbackStatus.error,
          error: 'Feedback message cannot be empty.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: FeedbackStatus.submitting, clearError: true));

    final either = await repo.submitFeedback(
      userId: userId,
      artworkId: artworkId,
      rating: rating,
      message: message.trim(),
      tags: tags,
    );

    either.fold(
      (f) =>
          emit(state.copyWith(status: FeedbackStatus.error, error: f.message)),
      (_) => emit(
        state.copyWith(status: FeedbackStatus.success, clearError: true),
      ),
    );
  }

  /// Optional helper if you want to clear state after showing a toast/snackbar.
  void reset() => emit(const FeedbackState());
}
