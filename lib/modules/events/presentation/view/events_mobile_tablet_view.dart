import 'package:baseqat/core/components/custom_widgets/events_search_field.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/events/data/models/fav_extension.dart';
import 'package:baseqat/modules/events/data/models/gallery_item.dart';
import 'package:baseqat/modules/events/data/models/month_data.dart';
import 'package:baseqat/modules/events/presentation/view/tabs/art_works_view.dart';
import 'package:baseqat/modules/events/presentation/view/tabs/artist_tab.dart';
import 'package:baseqat/modules/events/presentation/view/tabs/events_tab_view.dart';
import 'package:baseqat/modules/events/presentation/view/tabs/gallery_tav_view.dart';
import 'package:baseqat/modules/events/presentation/view/tabs/speakers_tab.dart';
import 'package:baseqat/modules/home/data/models/events_model.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/responsive/size_utils.dart';
import '../../../../core/resourses/assets_manager.dart';
import '../../../../core/resourses/color_manager.dart';
import '../../../../core/resourses/style_manager.dart';

import '../../../../core/components/alerts/custom_loading.dart';
import '../../../../core/components/alerts/custom_error_page.dart';
import '../../../../core/components/alerts/custom_snackbar.dart';

import '../../data/datasources/events_remote_data_source.dart';
import '../../data/repositories/events/events_repository_impl.dart';

import '../manger/events/events_cubit.dart';
import '../manger/events/events_state.dart';
import '../widgets/virtual_tour_view.dart';

class EventsMobileTabletView extends StatefulWidget {
  const EventsMobileTabletView({super.key});

  @override
  State<EventsMobileTabletView> createState() => _EventsMobileTabletViewState();
}

class _EventsMobileTabletViewState extends State<EventsMobileTabletView> {
  int _selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();

  // Favorites-only flags per tab
  bool _favOnlyArtworks = false;
  bool _favOnlyArtists = false;
  bool _favOnlySpeakers = false;

  // repo + user id (stable)
  late final SupabaseClient _client;
  late final EventsRepositoryImpl _repo;
  final String _userId = "d0030cf6-3830-47e8-9ca4-a2d00d51427a";

  // Tabs
  late List<CategoryModel> _categories;

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;
    _repo = EventsRepositoryImpl(EventsRemoteDataSourceImpl(_client));
    _categories = [
      CategoryModel(title: 'Events', isSelected: true),
      CategoryModel(title: 'Art Works', isSelected: false),
      CategoryModel(title: 'Artist', isSelected: false),
      CategoryModel(title: 'Speakers', isSelected: false),
      CategoryModel(title: 'Gallery', isSelected: false),
      CategoryModel(title: 'Virtual Tour', isSelected: false),
    ];
  }

  void _onCategoryTap(BuildContext ctx, int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
      final newList = [..._categories];
      for (int i = 0; i < newList.length; i++) {
        newList[i] = CategoryModel(
          title: newList[i].title,
          isSelected: i == index,
        );
      }
      _categories = newList;
    });
  }

  void _toggleFavOnlyForCurrentTab(BuildContext ctx) {
    final cubit = ctx.read<EventsCubit>();
    switch (_selectedIndex) {
      case 1: // Artworks
        final next = !_favOnlyArtworks;
        setState(() => _favOnlyArtworks = next);
        cubit.setFavoritesOnly(kind: EntityKind.artwork, value: next);
        ctx.showInfoSnackBar(
          next ? 'Showing favorite artworks' : 'Showing all artworks',
        );
        break;
      case 2: // Artists
        final next = !_favOnlyArtists;
        setState(() => _favOnlyArtists = next);
        cubit.setFavoritesOnly(kind: EntityKind.artist, value: next);
        ctx.showInfoSnackBar(
          next ? 'Showing favorite artists' : 'Showing all artists',
        );
        break;
      case 3: // Speakers
        final next = !_favOnlySpeakers;
        setState(() => _favOnlySpeakers = next);
        cubit.setFavoritesOnly(kind: EntityKind.speaker, value: next);
        ctx.showInfoSnackBar(
          next ? 'Showing favorite speakers' : 'Showing all speakers',
        );
        break;
      default:
        break;
    }
  }

  bool _isAnyLoading(EventsState s) {
    return s.eventsStatus == SliceStatus.loading ||
        s.artworksStatus == SliceStatus.loading ||
        s.artistsStatus == SliceStatus.loading ||
        s.speakersStatus == SliceStatus.loading ||
        s.galleryStatus == SliceStatus.loading;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventsCubit>(
      create: (_) {
        final c = EventsCubit(_repo);
        // Load everything (includes EVENTS) + favorites
        c.loadHome(userId: _userId, limit: 10);
        c.loadFavorites(userId: _userId);
        return c;
      },
      child: Builder(
        builder: (ctx) {
          final state = ctx.watch<EventsCubit>().state;
          final isLoading = _isAnyLoading(state);

          return Container(
            color: AppColor.white,
            child: SafeArea(
              child: LoadingOverlay(
                isLoading: isLoading,
                message: 'Loading…',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),

                    // ---------------- Heading ----------------
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discover Events',
                            style: TextStyleHelper.instance.headline24BoldInter,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 6.sH),
                          Text(
                            'What do you want to see today?',
                            style: TextStyleHelper.instance.title16RegularInter
                                .copyWith(color: AppColor.gray600),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10.sH),

                    // ---------------- Search row (hide on Gallery & Virtual Tour) ----------------
                    if (_selectedIndex != 4 && _selectedIndex != 5)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.h),
                        child: Row(
                          children: [
                            // Search input (keeps the mobile visual style)
                            Expanded(
                              child: Container(
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
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.sW,
                                      vertical: 28.sH,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.sW),
                            if (_selectedIndex == 1 ||
                                _selectedIndex == 2 ||
                                _selectedIndex == 3)
                              _FavToggleChip(
                                active: switch (_selectedIndex) {
                                  1 => _favOnlyArtworks,
                                  2 => _favOnlyArtists,
                                  3 => _favOnlySpeakers,
                                  _ => false,
                                },
                                onTap: () => _toggleFavOnlyForCurrentTab(ctx),
                              ),
                          ],
                        ),
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
                      child: Builder(
                        builder: (innerCtx) => _buildBody(innerCtx),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================ Body by Tab ============================
  Widget _buildBody(BuildContext ctx) {
    switch (_selectedIndex) {
      case 0: // EVENTS (LIVE)
        return _EventsSliceView(
          onRetry: () =>
              ctx.read<EventsCubit>().loadEvents(limit: 10, force: true),
        );

      case 1: // ARTWORKS
        return _ArtworksSliceView(
          userId: _userId,
          onToggleFavorite: (id) => ctx.read<EventsCubit>().toggleFavorite(
            userId: _userId,
            kind: EntityKind.artwork,
            entityId: id,
          ),
          onRetry: () =>
              ctx.read<EventsCubit>().loadArtworks(limit: 10, force: true),
        );

      case 2: // ARTISTS
        return _ArtistsSliceView(
          userId: _userId,
          onToggleFavorite: (id) => ctx.read<EventsCubit>().toggleFavorite(
            userId: _userId,
            kind: EntityKind.artist,
            entityId: id,
          ),
          onRetry: () =>
              ctx.read<EventsCubit>().loadArtists(limit: 10, force: true),
        );

      case 3: // SPEAKERS
        return _SpeakersSliceView(
          userId: _userId,
          onToggleFavorite: (id) => ctx.read<EventsCubit>().toggleFavorite(
            userId: _userId,
            kind: EntityKind.speaker,
            entityId: id,
          ),
          onRetry: () =>
              ctx.read<EventsCubit>().loadSpeakers(limit: 10, force: true),
        );

      case 4: // GALLERY
        return _GallerySliceView(
          onRetry: () => ctx.read<EventsCubit>().loadGallery(
            limitArtists: 10,
            force: true,
          ),
        );

      case 5: // VIRTUAL TOUR
        return const VirtualTourView(
          url: 'https://www.3dvista.com/en/',
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// ===================================================================
// Slice Views — match Desktop behaviors (error handling + overlay)
// ===================================================================

class _EventsSliceView extends StatelessWidget {
  final VoidCallback onRetry;
  const _EventsSliceView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final events = context.select<EventsCubit, List<Event>>(
          (c) => c.state.events,
    );
    final status = context.select<EventsCubit, SliceStatus>(
          (c) => c.state.eventsStatus,
    );

    if (status == SliceStatus.error) {
      return _InlineError(
        title: 'Couldn\'t load events',
        onRetry: onRetry,
        onShowDetails: () => context.showErrorPage(
          errorType: ErrorType.generic,
          customMessage: 'Couldn\'t load events',
          details: 'Tap retry to attempt fetching events again.',
          onRetry: onRetry,
          canContactSupport: false,
          showDetails: true,
        ),
      );
    }

    return EventsTab(
      events: events,
      onOpen: (e) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Open: ${e.title}'))),
    );
  }
}

class _ArtworksSliceView extends StatelessWidget {
  final String userId;
  final void Function(String artworkId)? onToggleFavorite;
  final VoidCallback onRetry;
  const _ArtworksSliceView({
    required this.userId,
    this.onToggleFavorite,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final artworks = context.select<EventsCubit, List<Artwork>>(
          (c) => c.state.artworks,
    );
    final status = context.select<EventsCubit, SliceStatus>(
          (c) => c.state.artworksStatus,
    );

    if (status == SliceStatus.error) {
      return _InlineError(
        title: 'Couldn\'t load artworks',
        onRetry: onRetry,
        onShowDetails: () => context.showErrorPage(
          errorType: ErrorType.generic,
          customMessage: 'Couldn\'t load artworks',
          details: 'Tap retry to attempt fetching artworks again.',
          onRetry: onRetry,
          canContactSupport: false,
          showDetails: true,
        ),
      );
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
  final VoidCallback onRetry;
  const _ArtistsSliceView({
    required this.userId,
    this.onToggleFavorite,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final artists = context.select<EventsCubit, List<Artist>>(
          (c) => c.state.artists,
    );
    final status = context.select<EventsCubit, SliceStatus>(
          (c) => c.state.artistsStatus,
    );

    if (status == SliceStatus.error) {
      return _InlineError(
        title: 'Couldn\'t load artists',
        onRetry: onRetry,
        onShowDetails: () => context.showErrorPage(
          errorType: ErrorType.generic,
          customMessage: 'Couldn\'t load artists',
          details: 'Tap retry to attempt fetching artists again.',
          onRetry: onRetry,
          canContactSupport: false,
          showDetails: true,
        ),
      );
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
  final VoidCallback onRetry;

  const _SpeakersSliceView({
    this.onToggleFavorite,
    required this.userId,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final speakers = context.select<EventsCubit, List<Speaker>>(
          (c) => c.state.speakers,
    );
    final status = context.select<EventsCubit, SliceStatus>(
          (c) => c.state.speakersStatus,
    );

    if (status == SliceStatus.error) {
      return _InlineError(
        title: 'Couldn\'t load speakers',
        onRetry: onRetry,
        onShowDetails: () => context.showErrorPage(
          errorType: ErrorType.generic,
          customMessage: 'Couldn\'t load speakers',
          details: 'Tap retry to attempt fetching speakers again.',
          onRetry: onRetry,
          canContactSupport: false,
          showDetails: true,
        ),
      );
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
          ctaTitle: "We look forward\nto seeing you\ntomorrow",
          onNextMonth: monthData.nextMonth,
          onPrevMonth: monthData.prevMonth,
          onSpeakerTap: (s) => onToggleFavorite?.call(s.id),
        );
      },
    );
  }
}

class _GallerySliceView extends StatelessWidget {
  final VoidCallback onRetry;
  const _GallerySliceView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final gallery = context.select<EventsCubit, List<GalleryItem>>(
          (c) => c.state.gallery,
    );
    final status = context.select<EventsCubit, SliceStatus>(
          (c) => c.state.galleryStatus,
    );

    if (status == SliceStatus.error) {
      return _InlineError(
        title: 'Couldn\'t load gallery',
        onRetry: onRetry,
        onShowDetails: () => context.showErrorPage(
          errorType: ErrorType.generic,
          customMessage: 'Couldn\'t load gallery',
          details: 'Tap retry to attempt fetching gallery again.',
          onRetry: onRetry,
          canContactSupport: false,
          showDetails: true,
        ),
      );
    }

    return GalleryGrid(items: gallery, onTap: (item) {});
  }
}

// ------------------ Helper widgets (mirroring Desktop) ------------------

class _FavToggleChip extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _FavToggleChip({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? AppColor.primaryColor.withValues(alpha: 0.1)
        : AppColor.gray50;
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
          mainAxisSize: MainAxisSize.min,
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

class _InlineError extends StatelessWidget {
  final String title;
  final VoidCallback onRetry;
  final VoidCallback onShowDetails;
  const _InlineError({
    required this.title,
    required this.onRetry,
    required this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(24.sSp),
        padding: EdgeInsets.all(20.sSp),
        decoration: BoxDecoration(
          color: AppColor.gray50,
          border: Border.all(color: AppColor.gray200),
          borderRadius: BorderRadius.circular(12.sSp),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColor.gray700,
              size: 28.sSp,
            ),
            SizedBox(height: 12.sH),
            Text(
              title,
              style: TextStyleHelper.instance.body16MediumInter.copyWith(
                color: AppColor.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.sH),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
                SizedBox(width: 12.sW),
                TextButton(
                  onPressed: onShowDetails,
                  child: const Text('View details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
