import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import '../../data/models/gallery_item.dart';
import '../manger/search_cubit.dart';

sealed class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final String query;
  final List<Artist> filteredArtists;
  final List<Artwork> filteredArtworks;
  final List<Speaker> filteredSpeakers;
  final List<GalleryItem> filteredGallery;
  final bool isFilterVisible;
  final int currentTabIndex;
  final bool isSearchBarVisible;
  final Set<FilterCategory> selectedCategories;
  final SortOption selectedSortOption;

  const SearchLoaded({
    required this.query,
    required this.filteredArtists,
    required this.filteredArtworks,
    required this.filteredSpeakers,
    required this.filteredGallery,
    required this.isFilterVisible,
    required this.currentTabIndex,
    required this.isSearchBarVisible,
    required this.selectedCategories,
    required this.selectedSortOption,
  });

  // Helper methods to get results count
  int get totalResults =>
      filteredArtists.length +
          filteredArtworks.length +
          filteredSpeakers.length +
          filteredGallery.length;

  bool get hasResults => totalResults > 0;
  bool get isSearching => query.isNotEmpty;
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
}
