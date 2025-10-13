
import 'package:baseqat/modules/artwork_details/data/repositories/artwork_repository.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/manger/feedback/feedback_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  final ArtworkDetailsRepository repo;

  FeedbackCubit(this.repo) : super(const FeedbackState());

  Future<void> submitFeedback({
    required String userId, // This is now sessionId
    required String artworkId,
    required int rating,
    required String message,
    List<String> tags = const [],
  }) async {
    debugPrint('[FeedbackCubit] ========== SUBMIT FEEDBACK ==========');
    debugPrint('[FeedbackCubit] User/Session ID: $userId');
    debugPrint('[FeedbackCubit] Artwork ID: $artworkId');
    debugPrint('[FeedbackCubit] Rating: $rating');
    debugPrint('[FeedbackCubit] Message: $message');
    debugPrint('[FeedbackCubit] Tags: $tags');

    // lightweight client-side validation (fail fast)
    if (rating < 1 || rating > 5) {
      debugPrint('[FeedbackCubit] Validation failed: Invalid rating');
      emit(
        state.copyWith(
          status: FeedbackStatus.error,
          error: 'Rating must be between 1 and 5.',
        ),
      );
      return;
    }
    if (message.trim().isEmpty) {
      debugPrint('[FeedbackCubit] Validation failed: Empty message');
      emit(
        state.copyWith(
          status: FeedbackStatus.error,
          error: 'Feedback message cannot be empty.',
        ),
      );
      return;
    }

    debugPrint('[FeedbackCubit] Validation passed, submitting to repository...');
    emit(state.copyWith(status: FeedbackStatus.submitting, clearError: true));

    final either = await repo.submitFeedback(
      sessionId: userId, // This is actually sessionId now
      artworkId: artworkId,
      rating: rating,
      message: message.trim(),
      tags: tags,
    );

    either.fold(
          (f) {
        debugPrint('[FeedbackCubit] Submission failed: ${f.message}');
        emit(state.copyWith(status: FeedbackStatus.error, error: f.message));
      },
          (_) {
        debugPrint('[FeedbackCubit] Submission successful');
        emit(state.copyWith(status: FeedbackStatus.success, clearError: true));
      },
    );
  }

  /// Optional helper if you want to clear state after showing a toast/snackbar.
  void reset() {
    debugPrint('[FeedbackCubit] Resetting state');
    emit(const FeedbackState());
  }
}
