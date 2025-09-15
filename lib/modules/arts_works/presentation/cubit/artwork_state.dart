// lib/presentation/cubit/artwork_state.dart
part of 'artwork_cubit.dart';

abstract class ArtworkState extends Equatable {
  const ArtworkState();

  @override
  List<Object> get props => [];
}

class ArtworkInitial extends ArtworkState {}

class ArtworkLoading extends ArtworkState {}

class ArtworkLoaded extends ArtworkState {
  final List<ArtworkModel> artworks;

  const ArtworkLoaded(this.artworks);

  @override
  List<Object> get props => [artworks];
}

class ArtistLoaded extends ArtworkState {
  final ArtistModel artist;

  const ArtistLoaded(this.artist);

  @override
  List<Object> get props => [artist];
}

class LocationLoaded extends ArtworkState {
  final LocationModel location;

  const LocationLoaded(this.location);

  @override
  List<Object> get props => [location];
}

class FeedbacksLoaded extends ArtworkState {
  final List<FeedbackModel> feedbacks;

  const FeedbacksLoaded(this.feedbacks);

  @override
  List<Object> get props => [feedbacks];
}

class ArtworksWithDetailsLoaded extends ArtworkState {
  final List<Map<String, dynamic>> artworksWithDetails;

  const ArtworksWithDetailsLoaded(this.artworksWithDetails);

  @override
  List<Object> get props => [artworksWithDetails];
}

class ArtworkError extends ArtworkState {
  final String message;

  const ArtworkError(this.message);

  @override
  List<Object> get props => [message];
}
