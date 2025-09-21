// lib/modules/events/presentation/view/events_screen.dart
import 'package:baseqat/core/components/custom_widgets/custom_search_view.dart';
import 'package:baseqat/core/components/custom_widgets/events_search_field.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

import 'package:baseqat/modules/events/data/models/fav_extension.dart';
import 'package:baseqat/modules/events/data/models/gallery_item.dart';
import 'package:baseqat/modules/events/data/models/week_model.dart';
import 'package:baseqat/modules/events/presentation/view/art_works_view.dart';
import 'package:baseqat/modules/events/presentation/view/artist_tab.dart';
import 'package:baseqat/modules/events/presentation/view/gallery_tav_view.dart';
import 'package:baseqat/modules/events/presentation/view/speakers_info_view.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/events_remote_data_source.dart';
import '../../data/repositories/events/events_repository_impl.dart';

import '../manger/events/events_cubit.dart';
import '../manger/events/events_state.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int _selectedIndex = 0;

  final List<CategoryModel> _categories = const [
    CategoryModel(title: 'Art Works', isSelected: true),
    CategoryModel(title: 'Artist', isSelected: false),
    CategoryModel(title: 'Speakers', isSelected: false),
    CategoryModel(title: 'Gallery', isSelected: false),
    CategoryModel(title: 'Virtual Tour', isSelected: false),
  ];

  // Local UI flags for "Favorites only" per tab (mirrors EventsCubit state)
  bool _favOnlyArtworks = false;
  bool _favOnlyArtists = false;
  bool _favOnlySpeakers = false;

  // --- Month navigation state (kept as-is) ---
  DateTime _currentMonth = DateTime(2025, 10); // October 2025 start
  static const _monthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
  String get _monthLabel =>
      "${_monthNames[_currentMonth.month - 1]} ${_currentMonth.year}";
  void _prevMonth() => setState(() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
  });
  void _nextMonth() => setState(() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
  });

  // Initial stub week (kept for header compatibility)
  static const _weekJson = {
    "weekdays": ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
    "dates": [1, 2, 3, 4, 5, 6, 7],
    "selectedIndex": 0,
  };
  late final WeekModel _week = WeekModel.fromJson(_weekJson);

  final TextEditingController searchController = TextEditingController();

  // keep repo & userId stable across rebuilds
  late final SupabaseClient _client;
  late final EventsRepositoryImpl _repo;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;
    _repo = EventsRepositoryImpl(EventsRemoteDataSourceImpl(_client));
    _userId = "d0030cf6-3830-47e8-9ca4-a2d00d51427a"; // mocked for now
  }

  // Helper: toggle "favorites only" for current tab
  void _toggleFavOnlyForCurrentTab(BuildContext ctx) {
    final cubit = ctx.read<EventsCubit>();
    switch (_selectedIndex) {
      case 0: // Artworks
        setState(() => _favOnlyArtworks = !_favOnlyArtworks);
        cubit.setFavoritesOnly(
          kind: EntityKind.artwork,
          value: _favOnlyArtworks,
        );
        break;
      case 1: // Artists
        setState(() => _favOnlyArtists = !_favOnlyArtists);
        cubit.setFavoritesOnly(kind: EntityKind.artist, value: _favOnlyArtists);
        break;
      case 2: // Speakers
        setState(() => _favOnlySpeakers = !_favOnlySpeakers);
        cubit.setFavoritesOnly(
          kind: EntityKind.speaker,
          value: _favOnlySpeakers,
        );
        break;
      default:
        break;
    }
  }

  void _onCategoryTap(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventsCubit>(
      create: (_) {
        final c = EventsCubit(_repo);
        if (_userId != null) {
          c.loadHome(userId: _userId!, limit: 10);
        } else {
          c
            ..loadArtists(limit: 10)
            ..loadArtworks(limit: 10)
            ..loadSpeakers(limit: 10)
            ..loadGallery(limitArtists: 10);
        }
        return c;
      },
      // get a context UNDER the provider
      child: Builder(
        builder: (ctx) => Scaffold(
          backgroundColor: AppColor.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // --------- Search Header (uses EventsCubit only) ----------
                if (_selectedIndex != 2) // hide on speakers tab like before
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Discover',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'What do you want to see today?',
                          style: TextStyle(color: AppColor.gray600),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: CustomSearchView(
                                  controller: searchController,
                                  hintText:
                                      'Search events, artists, artworks...',
                                  prefixIcon: AppAssetsManager.imgSearch,
                                  fillColor: AppColor.white,
                                  borderColor: AppColor.gray400,
                                  onChanged: (v) =>
                                      ctx.read<EventsCubit>().setSearchQuery(v),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Per-tab "favorites only" toggle (acts like a chip)
                            _FavToggleChip(
                              active: switch (_selectedIndex) {
                                0 => _favOnlyArtworks,
                                1 => _favOnlyArtists,
                                2 => _favOnlySpeakers,
                                _ => false,
                              },
                              onTap: () => _toggleFavOnlyForCurrentTab(ctx),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // --------- Category chips ----------
                EventsCategoryChips(
                  categories: _categories
                      .asMap()
                      .entries
                      .map(
                        (e) => CategoryModel(
                          title: e.value.title,
                          isSelected: e.key == _selectedIndex,
                        ),
                      )
                      .toList(),
                  onTap: _onCategoryTap,
                  enableScrollIndicators: true,
                  animationDuration: const Duration(milliseconds: 250),
                  height: 60,
                ),

                SizedBox(height: 8.h),

                // --------- Main body by tab ----------
                Expanded(child: _buildBody(ctx)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------- Body by selected tab (slice-based) -----------------------
  Widget _buildBody(BuildContext ctx) {
    switch (_selectedIndex) {
      case 0:
        return _ArtworksSliceView(
          userId: _userId ?? '',
          onToggleFavorite: (_userId != null)
              ? (id) => ctx.read<EventsCubit>().toggleFavorite(
                  userId: _userId!,
                  kind: EntityKind.artwork,
                  entityId: id,
                )
              : null,
        );
      case 1:
        return _ArtistsSliceView(
          userId: _userId ?? '',
          onToggleFavorite: (_userId != null)
              ? (id) => ctx.read<EventsCubit>().toggleFavorite(
                  userId: _userId!,
                  kind: EntityKind.artist,
                  entityId: id,
                )
              : null,
        );
      case 2:
        return _SpeakersSliceView(
          monthLabel: _monthLabel,
          userId: _userId!,
          week: _week,
          onToggleFavorite: (_userId != null)
              ? (id) => ctx.read<EventsCubit>().toggleFavorite(
                  userId: _userId!,
                  kind: EntityKind.speaker,
                  entityId: id,
                )
              : null,
        );
      case 3:
        return _GallerySliceView();
      case 4:
        return const ComingSoon('Virtual Tour');
      default:
        return const SizedBox.shrink();
    }
  }
}

// ===================================================================
// Slice Views — rebuild only when their own slice changes.
// Lists are ALREADY filtered by EventsCubit.
// ===================================================================

class _ArtworksSliceView extends StatelessWidget {
  final String userId;
  final void Function(String artworkId)? onToggleFavorite;
  const _ArtworksSliceView({required this.userId, this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    final artworks = context.select<EventsCubit, List<Artwork>>(
      (c) => c.state.artworks,
    );
    final status = context.select<EventsCubit, SliceStatus>(
      (c) => c.state.artworksStatus,
    );

    if (status == SliceStatus.loading) return const _LoadingView();

    return ArtWorksGalleryContent(
      artworks: artworks, // already filtered
      userId: userId,
      onArtworkTap: (art) {},
      onFavoriteTap: (art) => onToggleFavorite?.call(art.id),
    );
  }
}

class _ArtistsSliceView extends StatelessWidget {
  final String userId;
  final void Function(String artistId)? onToggleFavorite;
  const _ArtistsSliceView({required this.userId, this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    final artists = context.select<EventsCubit, List<Artist>>(
      (c) => c.state.artists,
    );
    final status = context.select<EventsCubit, SliceStatus>(
      (c) => c.state.artistsStatus,
    );
    if (status == SliceStatus.loading) return const _LoadingView();

    return ArtistTabContent(
      artists: artists, // already filtered
      userId: userId,
      onFavoriteTap: (artist) => onToggleFavorite?.call(artist.id),
    );
  }
}

class _SpeakersSliceView extends StatelessWidget {
  final String monthLabel;
  final WeekModel week;
  final String userId;

  final void Function(String speakerId)? onToggleFavorite;

  const _SpeakersSliceView({
    required this.monthLabel,
    required this.week,
    this.onToggleFavorite,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final speakers = context.select<EventsCubit, List<Speaker>>(
      (c) => c.state.speakers,
    );
    final status = context.select<EventsCubit, SliceStatus>(
      (c) => c.state.speakersStatus,
    );
    if (status == SliceStatus.loading) return const _LoadingView();

    if (speakers.isEmpty) return const Center(child: Text('No speakers yet'));
    return SpeakersInfoScreen(speaker: speakers[0], userId: userId);
  }
}

class _GallerySliceView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gallery = context.select<EventsCubit, List<GalleryItem>>(
      (c) => c.state.gallery,
    );
    final status = context.select<EventsCubit, SliceStatus>(
      (c) => c.state.galleryStatus,
    );
    if (status == SliceStatus.loading) return const _LoadingView();

    return GalleryGrid(
      items: gallery, // already derived in cubit
      onTap: (item) {},
    );
  }
}

// ------------------ Small widgets ------------------

class _FavToggleChip extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _FavToggleChip({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = active ? AppColor.primaryColor.withOpacity(.1) : AppColor.gray50;
    final border = active ? AppColor.primaryColor : AppColor.gray200;
    final fg = active ? AppColor.primaryColor : AppColor.gray700;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              active ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: fg,
            ),
            const SizedBox(width: 6),
            Text(
              'Favorites only',
              style: TextStyle(color: fg, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ Loading ------------------

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 36.h,
        height: 36.h,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

// Optional placeholder; keep your existing implementation if present.
class ComingSoon extends StatelessWidget {
  final String title;
  const ComingSoon(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title — coming soon'));
  }
}
