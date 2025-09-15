import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:baseqat/modules/home/data/models/InfoModel.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';

sealed class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading({this.message = 'Loading…'});
  final String message;
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.artists,
    required this.artworks,
    required this.info,
    this.artistsError,
    this.artworksError,
    this.infoError,
  });

  final List<Artist> artists;
  final List<Artwork> artworks;
  final InfoModel? info;

  final Failure? artistsError;
  final Failure? artworksError;
  final Failure? infoError;

  bool get hasAnyError =>
      artistsError != null || artworksError != null || infoError != null;
}

class HomeError extends HomeState {
  const HomeError(this.failure);
  final Failure failure;
}
