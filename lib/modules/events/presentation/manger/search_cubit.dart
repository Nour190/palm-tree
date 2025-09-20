import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import '../../data/models/gallery_item.dart';
import 'search_state.dart';

enum FilterCategory { artist, artwork, gallery }
enum SortOption { dateNewest, dateOldest, nameAZ, nameZA }

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchInitial());

  // Store original data for filtering
  List<Artist> _allArtists = [];
  List<Artwork> _allArtworks = [];
  List<Speaker> _allSpeakers = [];
  List<GalleryItem> _allGallery = [];

  String _currentQuery = '';
  bool _isFilterVisible = false;
  int _currentTabIndex = 0;

  Set<FilterCategory> _selectedCategories = {FilterCategory.artist, FilterCategory.artwork, FilterCategory.gallery};
  SortOption _selectedSortOption = SortOption.dateNewest;

  // Initialize data from events cubit
  void initializeData({
    required List<Artist> artists,
    required List<Artwork> artworks,
    required List<Speaker> speakers,
    required List<GalleryItem> gallery,
  }) {
    _allArtists = artists;
    _allArtworks = artworks;
    _allSpeakers = speakers;
    _allGallery = gallery;

    emit(SearchLoaded(
      query: _currentQuery,
      filteredArtists: _sortArtists(_allArtists),
      filteredArtworks: _sortArtworks(_allArtworks),
      filteredSpeakers: _allSpeakers,
      filteredGallery: _sortGallery(_allGallery),
      isFilterVisible: _isFilterVisible,
      currentTabIndex: _currentTabIndex,
      isSearchBarVisible: _shouldShowSearchBar(_currentTabIndex),
      selectedCategories: _selectedCategories,
      selectedSortOption: _selectedSortOption,
    ));
  }

  // Update search query and filter results
  void updateSearchQuery(String query) {
    _currentQuery = query.toLowerCase().trim();
    _performSearch();
  }

  // Toggle filter visibility
  void toggleFilter() {
    _isFilterVisible = !_isFilterVisible;
    _emitCurrentState();
  }

  // Update current tab index and search bar visibility
  void updateTabIndex(int index) {
    _currentTabIndex = index;
    _emitCurrentState();
  }

  // Clear search
  void clearSearch() {
    _currentQuery = '';
    _performSearch();
  }

  void _performSearch() {
    if (_currentQuery.isEmpty) {
      // Show all data when no search query, but apply sorting
      emit(SearchLoaded(
        query: _currentQuery,
        filteredArtists: _sortArtists(_allArtists),
        filteredArtworks: _sortArtworks(_allArtworks),
        filteredSpeakers: _allSpeakers,
        filteredGallery: _sortGallery(_allGallery),
        isFilterVisible: _isFilterVisible,
        currentTabIndex: _currentTabIndex,
        isSearchBarVisible: _shouldShowSearchBar(_currentTabIndex),
        selectedCategories: _selectedCategories,
        selectedSortOption: _selectedSortOption,
      ));
      return;
    }

    List<Artist> filteredArtists = [];
    List<Artwork> filteredArtworks = [];
    List<GalleryItem> filteredGallery = [];

    // Filter artists with comprehensive attribute search
    if (_selectedCategories.contains(FilterCategory.artist)) {
      filteredArtists = _allArtists.where((artist) {
        return artist.name.toLowerCase().contains(_currentQuery) ||
            (artist.about?.toLowerCase().contains(_currentQuery) ?? false) ||
            (artist.country?.toLowerCase().contains(_currentQuery) ?? false) ||
            (artist.city?.toLowerCase().contains(_currentQuery) ?? false) ||
            (artist.platform?.toLowerCase().contains(_currentQuery) ?? false);
      }).toList();
      filteredArtists = _sortArtists(filteredArtists);
    }

    // Filter artworks with comprehensive attribute search
    if (_selectedCategories.contains(FilterCategory.artwork)) {
      filteredArtworks = _allArtworks.where((artwork) {
        return artwork.name.toLowerCase().contains(_currentQuery) ||
            (artwork.description?.toLowerCase().contains(_currentQuery) ?? false) ||
            (artwork.materials?.toLowerCase().contains(_currentQuery) ?? false) ||
            (artwork.vision?.toLowerCase().contains(_currentQuery) ?? false) ||
            (artwork.artistName?.toLowerCase().contains(_currentQuery) ?? false);
      }).toList();
      filteredArtworks = _sortArtworks(filteredArtworks);
    }

    // Filter gallery items
    if (_selectedCategories.contains(FilterCategory.gallery)) {
      filteredGallery = _allGallery.where((item) {
        return item.artistName.toLowerCase().contains(_currentQuery);
      }).toList();
      filteredGallery = _sortGallery(filteredGallery);
    }

    // Filter speakers (always included regardless of category filter)
    final filteredSpeakers = _allSpeakers.where((speaker) {
      return speaker.name.toLowerCase().contains(_currentQuery) ||
          (speaker.bio?.toLowerCase().contains(_currentQuery) ?? false) ;
          //||
          //(speaker.?.toLowerCase().contains(_currentQuery) ?? false);
    }).toList();

    emit(SearchLoaded(
      query: _currentQuery,
      filteredArtists: filteredArtists,
      filteredArtworks: filteredArtworks,
      filteredSpeakers: filteredSpeakers,
      filteredGallery: filteredGallery,
      isFilterVisible: _isFilterVisible,
      currentTabIndex: _currentTabIndex,
      isSearchBarVisible: _shouldShowSearchBar(_currentTabIndex),
      selectedCategories: _selectedCategories,
      selectedSortOption: _selectedSortOption,
    ));
  }

  List<Artist> _sortArtists(List<Artist> artists) {
    switch (_selectedSortOption) {
      case SortOption.dateNewest:
        return artists..sort((a, b) => (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
      case SortOption.dateOldest:
        return artists..sort((a, b) => (a.createdAt ?? DateTime(1970)).compareTo(b.createdAt ?? DateTime(1970)));
      case SortOption.nameAZ:
        return artists..sort((a, b) => a.name.compareTo(b.name));
      case SortOption.nameZA:
        return artists..sort((a, b) => b.name.compareTo(a.name));
    }
  }

  List<Artwork> _sortArtworks(List<Artwork> artworks) {
    switch (_selectedSortOption) {
      case SortOption.dateNewest:
        return artworks..sort((a, b) => (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
      case SortOption.dateOldest:
        return artworks..sort((a, b) => (a.createdAt ?? DateTime(1970)).compareTo(b.createdAt ?? DateTime(1970)));
      case SortOption.nameAZ:
        return artworks..sort((a, b) => a.name.compareTo(b.name));
      case SortOption.nameZA:
        return artworks..sort((a, b) => b.name.compareTo(a.name));
    }
  }

  List<GalleryItem> _sortGallery(List<GalleryItem> gallery) {
    switch (_selectedSortOption) {
      case SortOption.nameAZ:
        return gallery..sort((a, b) => a.artistName.compareTo(b.artistName));
      case SortOption.nameZA:
        return gallery..sort((a, b) => b.artistName.compareTo(a.artistName));
      default:
        return gallery; // Gallery items don't have date fields
    }
  }

  // Update filter categories
  void updateFilterCategories(Set<FilterCategory> categories) {
    _selectedCategories = categories;
    _performSearch();
  }

  // Update sort option
  void updateSortOption(SortOption sortOption) {
    _selectedSortOption = sortOption;
    _performSearch();
  }

  // Emit current state with updated visibility
  void _emitCurrentState() {
    final currentState = state;
    if (currentState is SearchLoaded) {
      emit(SearchLoaded(
        query: currentState.query,
        filteredArtists: currentState.filteredArtists,
        filteredArtworks: currentState.filteredArtworks,
        filteredSpeakers: currentState.filteredSpeakers,
        filteredGallery: currentState.filteredGallery,
        isFilterVisible: _isFilterVisible,
        currentTabIndex: _currentTabIndex,
        isSearchBarVisible: _shouldShowSearchBar(_currentTabIndex),
        selectedCategories: _selectedCategories,
        selectedSortOption: _selectedSortOption,
      ));
    }
  }

  // Determine if search bar should be visible based on current tab
  bool _shouldShowSearchBar(int tabIndex) {
    // Hide search bar for speakers tab (index 2)
    return tabIndex != 2;
  }
}
