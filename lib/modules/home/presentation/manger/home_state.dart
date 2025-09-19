// lib/modules/home/presentation/manger/home_state.dart
import 'package:equatable/equatable.dart';
import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:baseqat/modules/home/data/models/InfoModel.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/review_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  final String? message;
  const HomeLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class HomeError extends HomeState {
  final Failure failure;
  const HomeError(this.failure);

  @override
  List<Object?> get props => [failure];
}

class HomeLoaded extends HomeState {
  final List<Artist> artists;
  final List<Artwork> artworks;
  final List<ReviewModel> reviews;
  final InfoModel? info;

  final Failure? artistsError;
  final Failure? artworksError;
  final Failure? reviewsError;
  final Failure? infoError;

  final bool isRefreshing;
  final bool isRefreshingArtists;
  final bool isRefreshingArtworks;
  final bool isRefreshingReviews;

  const HomeLoaded({
    required this.artists,
    required this.artworks,
    required this.reviews,
    required this.info,
    this.artistsError,
    this.artworksError,
    this.reviewsError,
    this.infoError,
    this.isRefreshing = false,
    this.isRefreshingArtists = false,
    this.isRefreshingArtworks = false,
    this.isRefreshingReviews = false,
  });

  HomeLoaded copyWith({
    List<Artist>? artists,
    List<Artwork>? artworks,
    List<ReviewModel>? reviews,
    InfoModel? info,
    Failure? artistsError,
    Failure? artworksError,
    Failure? reviewsError,
    Failure? infoError,
    bool? isRefreshing,
    bool? isRefreshingArtists,
    bool? isRefreshingArtworks,
    bool? isRefreshingReviews,
  }) {
    return HomeLoaded(
      artists: artists ?? this.artists,
      artworks: artworks ?? this.artworks,
      reviews: reviews ?? this.reviews,
      info: info ?? this.info,
      artistsError: artistsError ?? this.artistsError,
      artworksError: artworksError ?? this.artworksError,
      reviewsError: reviewsError ?? this.reviewsError,
      infoError: infoError ?? this.infoError,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isRefreshingArtists: isRefreshingArtists ?? this.isRefreshingArtists,
      isRefreshingArtworks: isRefreshingArtworks ?? this.isRefreshingArtworks,
      isRefreshingReviews: isRefreshingReviews ?? this.isRefreshingReviews,
    );
  }

  @override
  List<Object?> get props => [
    artists,
    artworks,
    reviews,
    info,
    artistsError,
    artworksError,
    reviewsError,
    infoError,
    isRefreshing,
    isRefreshingArtists,
    isRefreshingArtworks,
    isRefreshingReviews,
  ];
}
