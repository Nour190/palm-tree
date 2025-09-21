import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/events/data/models/fav_extension.dart';
import 'package:baseqat/modules/events/data/models/gallery_item.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/components/custom_widgets/events_search_field.dart';
import '../../../../core/responsive/size_utils.dart';
import '../../../../core/resourses/assets_manager.dart';
import '../../../../core/resourses/color_manager.dart';

import '../../data/datasources/events_remote_data_source.dart';
import '../../data/repositories/events/events_repository_impl.dart';
import '../../data/models/category_model.dart' hide CategoryModel;

import '../manger/events/events_cubit.dart';
import '../manger/events/events_state.dart';

import '../view/art_works_view.dart';
import '../view/artist_tab.dart';
import '../view/speakers_tab.dart';
import '../view/gallery_tav_view.dart';

import 'month_data.dart';

class EventsMobileTabletView extends StatefulWidget {
  const EventsMobileTabletView({super.key});

  @override
  State<EventsMobileTabletView> createState() => _EventsMobileTabletViewState();
}

class _EventsMobileTabletViewState extends State<EventsMobileTabletView> {
  int _selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();

  // Simple per-tab favorites-only flags (for the heart/tune icon color)
  bool _favOnlyArtworks = false;
  bool _favOnlyArtists = false;
  bool _favOnlySpeakers = false;

  // repo + user id (stable)
  late final SupabaseClient _client;
  late final EventsRepositoryImpl _repo;
  final String _userId = "d0030cf6-3830-47e8-9ca4-a2d00d51427a";

  final List<CategoryModel> _categories = [
    CategoryModel(title: 'Art Works', isSelected: true),
    CategoryModel(title: 'Artist', isSelected: false),
    CategoryModel(title: 'Speakers', isSelected: false),
    CategoryModel(title: 'Gallery', isSelected: false),
    CategoryModel(title: 'Virtual Tour', isSelected: false),
  ];

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;
    _repo = EventsRepositoryImpl(EventsRemoteDataSourceImpl(_client));
  }

  // IMPORTANT: use a ctx that lives UNDER the provider
  void _onCategoryTap(BuildContext ctx, int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
      for (int i = 0; i < _categories.length; i++) {
        _categories[i] = CategoryModel(
          title: _categories[i].title,
          isSelected: i == index,
        );
      }
    });
  }

  void _toggleFavOnlyForCurrentTab(BuildContext ctx) {
    final cubit = ctx.read<EventsCubit>();
    switch (_selectedIndex) {
      case 0:
        setState(() => _favOnlyArtworks = !_favOnlyArtworks);
        cubit.setFavoritesOnly(
          kind: EntityKind.artwork,
          value: _favOnlyArtworks,
        );
        break;
      case 1:
        setState(() => _favOnlyArtists = !_favOnlyArtists);
        cubit.setFavoritesOnly(kind: EntityKind.artist, value: _favOnlyArtists);
        break;
      case 2:
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventsCubit>(
      create: (_) {
        final c = EventsCubit(_repo)
          ..loadArtists(limit: 10)
          ..loadArtworks(limit: 10)
          ..loadSpeakers(limit: 10)
          ..loadGallery(limitArtists: 10);
        // initial favorites
        c.loadFavorites(userId: _userId);
        return c;
      },
      // Use a Builder to obtain a context under the provider
      child: Builder(
        builder: (ctx) => Container(
          color: AppColor.white,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                // ---------------- Search bar (hidden for Speakers tab) ----------------
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _selectedIndex != 2 ? null : 0,
                  child: _selectedIndex != 2
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 60.sH,
                                decoration: BoxDecoration(
                                  color: AppColor.gray50,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: AppColor.gray200,
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (query) => ctx
                                      .read<EventsCubit>()
                                      .setSearchQuery(query),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search events, artists, artworks...',
                                    hintStyle: TextStyle(
                                      color: AppColor.gray500,
                                      fontSize: 14.sSp,
                                    ),
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(12.h),
                                      child: Image.asset(
                                        AppAssetsManager.imgSearch,
                                        width: 15.sW,
                                        height: 15.sH,
                                        color: AppColor.gray500,
                                      ),
                                    ),
                                    // Favorites-only toggle (no filter bottom sheet)
                                    suffixIcon: IconButton(
                                      tooltip: 'Favorites only',
                                      onPressed: () =>
                                          _toggleFavOnlyForCurrentTab(ctx),
                                      icon: Icon(
                                        // using tune icon for parity; swap to heart if you prefer
                                        Icons.tune,
                                        size: 15.sSp,
                                        color: switch (_selectedIndex) {
                                          0 =>
                                            _favOnlyArtworks
                                                ? AppColor.primaryColor
                                                : AppColor.gray500,
                                          1 =>
                                            _favOnlyArtists
                                                ? AppColor.primaryColor
                                                : AppColor.gray500,
                                          2 =>
                                            _favOnlySpeakers
                                                ? AppColor.primaryColor
                                                : AppColor.gray500,
                                          _ => AppColor.gray500,
                                        },
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.sW,
                                      vertical: 28.sH,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                SizedBox(height: 15.sH),

                // ---------------- Category chips ----------------
                EventsCategoryChips(
                  categories: _categories,
                  onTap: (i) => _onCategoryTap(ctx, i),
                  enableScrollIndicators: false,
                  animationDuration: const Duration(milliseconds: 250),
                  height: 60.sH,
                ),

                // ---------------- Body ----------------
                Expanded(
                  child: Builder(builder: (innerCtx) => _buildBody(innerCtx)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================ Body by Tab ============================
  Widget _buildBody(BuildContext ctx) {
    switch (_selectedIndex) {
      case 0:
        return _ArtworksSliceView(
          userId: _userId,
          onToggleFavorite: (id) => ctx.read<EventsCubit>().toggleFavorite(
            userId: _userId,
            kind: EntityKind.artwork,
            entityId: id,
          ),
        );
      case 1:
        return _ArtistsSliceView(
          userId: _userId,
          onToggleFavorite: (id) => ctx.read<EventsCubit>().toggleFavorite(
            userId: _userId,
            kind: EntityKind.artist,
            entityId: id,
          ),
        );
      case 2:
        return _SpeakersSliceView(
          userId: _userId,
          onToggleFavorite: (id) => ctx.read<EventsCubit>().toggleFavorite(
            userId: _userId,
            kind: EntityKind.speaker,
            entityId: id,
          ),
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
// Slice Views — use EventsCubit.state.* lists (already filtered locally)
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

    if (status == SliceStatus.loading) {
      return const _LoadingView();
    }

    return ArtWorksGalleryContent(
      artworks: artworks,
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

    if (status == SliceStatus.loading) {
      return const _LoadingView();
    }

    return ArtistTabContent(
      artists: artists,
      userId: userId,
      onFavoriteTap: (artist) => onToggleFavorite?.call(artist.id),
    );
  }
}

class _SpeakersSliceView extends StatelessWidget {
  final void Function(String speakerId)? onToggleFavorite;
  final String userId;

  const _SpeakersSliceView({this.onToggleFavorite, required this.userId});

  @override
  Widget build(BuildContext context) {
    final speakers = context.select<EventsCubit, List<Speaker>>(
      (c) => c.state.speakers,
    );
    final status = context.select<EventsCubit, SliceStatus>(
      (c) => c.state.speakersStatus,
    );

    if (status == SliceStatus.loading) {
      return const _LoadingView();
    }

    return MonthWidget(
      builder: (context, monthData) {
        return SpeakersTabContent(
          userId: userId,
          headerTitle: "Festival Schedule",
          monthLabel: monthData.monthLabel,
          currentMonth: monthData.currentMonth,
          week: monthData.week,
          speakers: speakers,
          ctaSubtitle:
              "Don't miss the exciting sessions on dates and palm cultivation.",
          ctaTitle: "We look forward to seeing you tomorrow",
          onNextMonth: monthData.nextMonth,
          onPrevMonth: monthData.prevMonth,
          onSpeakerTap: (s) => onToggleFavorite?.call(s.id),
        );
      },
    );
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

    if (status == SliceStatus.loading) {
      return const _LoadingView();
    }

    return GalleryGrid(items: gallery, onTap: (item) {});
  }
}

// ------------------ Small loading & error widgets ------------------

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

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 36.h, color: Colors.red),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class ComingSoon extends StatelessWidget {
  final String title;
  const ComingSoon(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title — coming soon'));
  }
}
