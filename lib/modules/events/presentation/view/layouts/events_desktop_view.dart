// D:/ithra project/ithra/lib/modules/events/presentation/view/events_desktop_view.dart

import 'package:baseqat/modules/events/data/models/fav_extension.dart';
import 'package:baseqat/modules/events/data/models/gallery_item.dart';
import 'package:baseqat/modules/events/data/models/month_data.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/components/custom_widgets/custom_search_view.dart';
import '../../../../../core/responsive/size_ext.dart';
import '../../../../../core/resourses/assets_manager.dart';
import '../../../../../core/resourses/color_manager.dart';
import '../../../../../core/resourses/style_manager.dart';
import '../../../../../core/components/alerts/custom_loading.dart';
import '../../../../../core/components/alerts/custom_error_page.dart';
import '../../../../../core/components/alerts/custom_snackbar.dart';
import '../../../data/datasources/events_remote_data_source.dart';
import '../../../data/repositories/events/events_repository_impl.dart';
import '../../../data/models/category_model.dart';
import '../../manger/events/events_cubit.dart';
import '../../manger/events/events_state.dart';
import '../tabs/art_works_tab.dart';
import '../tabs/artist_tab.dart';
import '../tabs/speakers_tab.dart';
import '../tabs/gallery_tav_tab.dart';
import 'desktop_navigation_bar.dart';
import '../tabs/virtual_tour_tab.dart';

class EventsDesktopView extends StatefulWidget {
  const EventsDesktopView({super.key});

  @override
  State<EventsDesktopView> createState() => _EventsDesktopViewState();
}

class _EventsDesktopViewState extends State<EventsDesktopView> {
  int _selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();

  bool _favOnlyArtworks = false;
  bool _favOnlyArtists = false;
  bool _favOnlySpeakers = false;

  late final SupabaseClient _client;
  late final EventsRepositoryImpl _repo;
  String? _userId;

  bool _errorRouteOpen = false;

  final List<CategoryModel> _categories = [
    CategoryModel(title: 'Art Works', isSelected: true), // 1
    CategoryModel(title: 'Artist', isSelected: false), // 2
    CategoryModel(title: 'Calender', isSelected: false), // 3
    CategoryModel(title: 'Gallery', isSelected: false), // 4
    CategoryModel(title: 'Virtual Tour', isSelected: false), // 5
  ];

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;
    _repo = EventsRepositoryImpl(EventsRemoteDataSourceImpl(_client));
    _userId = "d0030cf6-3830-47e8-9ca4-a2d00d51427a";
  }

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
      case 1:
        final next = !_favOnlyArtworks;
        setState(() => _favOnlyArtworks = next);
        cubit.setFavoritesOnly(kind: EntityKind.artwork, value: next);
        ctx.showInfoSnackBar(
          next ? 'Showing favorite artworks' : 'Showing all artworks',
        );
        break;
      case 2:
        final next = !_favOnlyArtists;
        setState(() => _favOnlyArtists = next);
        cubit.setFavoritesOnly(kind: EntityKind.artist, value: next);
        ctx.showInfoSnackBar(
          next ? 'Showing favorite artists' : 'Showing all artists',
        );
        break;
      case 3:
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

  bool _hasAnyError(EventsState s) {
    // INCLUDE eventsStatus now
    return s.eventsStatus == SliceStatus.error ||
        s.artworksStatus == SliceStatus.error ||
        s.artistsStatus == SliceStatus.error ||
        s.speakersStatus == SliceStatus.error ||
        s.galleryStatus == SliceStatus.error;
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
            ..loadEvents(limit: 10)
            ..loadArtists(limit: 10)
            ..loadArtworks(limit: 10)
            ..loadSpeakers(limit: 10)
            ..loadGallery(limitArtists: 10);
        }
        return c;
      },
      child: BlocListener<EventsCubit, EventsState>(
        listenWhen: (prev, curr) => _hasAnyError(curr) != _hasAnyError(prev),
        listener: (ctx, state) {
          if (_hasAnyError(state) && !_errorRouteOpen) {
            _errorRouteOpen = true;
          }
        },
        child: Builder(
          builder: (ctx) {
            final state = ctx.watch<EventsCubit>().state;
            final isLoading = _isAnyLoading(state);
            return Container(
              color: AppColor.white,
              child: Scaffold(
                body: SafeArea(
                  child: LoadingOverlay(
                    isLoading: isLoading,
                    message: 'Loading…',
                    child: Row(
                      children: [
                        Container(
                          width: 280.sW,
                          decoration: BoxDecoration(
                            color: AppColor.backgroundWhite,
                            border: Border(
                              right: BorderSide(
                                color: AppColor.gray200,
                                width: 1.sW,
                              ),
                            ),
                          ),
                          child: DesktopNavigationBar(
                            selectedIndex: _selectedIndex,
                            onItemTap: (i) => _onCategoryTap(ctx, i),
                            categories: _categories,
                          ),
                        ),

                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 1200.sW),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(15.sW),
                                    decoration: BoxDecoration(
                                      color: AppColor.white,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: AppColor.gray200,
                                          width: 1.sW,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Discover Events',
                                          style: TextStyleHelper
                                              .instance
                                              .headline32BoldInter,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        SizedBox(height: 8.sH),
                                        Text(
                                          'What do you want to see today?',
                                          style: TextStyleHelper
                                              .instance
                                              .title16RegularInter
                                              .copyWith(
                                            color: AppColor.gray600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        if (_selectedIndex != 4 &&
                                            _selectedIndex != 5) ...[
                                          SizedBox(height: 16.sH),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: 60.sH,
                                                  child: CustomSearchView(
                                                    controller:
                                                    searchController,
                                                    hintText:
                                                    'Search events, artists, artworks...',
                                                    prefixIcon: AppAssetsManager
                                                        .imgSearch,
                                                    fillColor: AppColor
                                                        .backgroundWhite,
                                                    borderColor:
                                                    AppColor.gray400,
                                                    iconSize: 24.sSp,
                                                    onChanged: (value) {
                                                      ctx
                                                          .read<EventsCubit>()
                                                          .setSearchQuery(
                                                        value,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 16.sW),
                                              if (_selectedIndex == 1 ||
                                                  _selectedIndex == 2 ||
                                                  _selectedIndex == 3)
                                                _FavToggleChip(
                                                  active:
                                                  switch (_selectedIndex) {
                                                    1 => _favOnlyArtworks,
                                                    2 => _favOnlyArtists,
                                                    3 => _favOnlySpeakers,
                                                    _ => false,
                                                  },
                                                  onTap: () =>
                                                      _toggleFavOnlyForCurrentTab(
                                                        ctx,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // -------- Main body
                                  Expanded(child: _buildBody(ctx)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

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
          onRetry: () =>
              ctx.read<EventsCubit>().loadArtworks(limit: 10, force: true),
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
          onRetry: () =>
              ctx.read<EventsCubit>().loadArtists(limit: 10, force: true),
        );

      case 2:
        return _SpeakersSliceView(
          userId: _userId ?? '',
          onToggleFavorite: (_userId != null)
              ? (id) => ctx.read<EventsCubit>().toggleFavorite(
            userId: _userId!,
            kind: EntityKind.speaker,
            entityId: id,
          )
              : null,
          onRetry: () =>
              ctx.read<EventsCubit>().loadSpeakers(limit: 10, force: true),
        );

      case 3:
        return _GallerySliceView(
          onRetry: () => ctx.read<EventsCubit>().loadGallery(
            limitArtists: 10,
            force: true,
          ),
        );

      case 4:
        return const VirtualTourView(
          url: 'https://www.3dvista.com/en/',
        );

      default:
        return const SizedBox.shrink();
    }
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
  final String userId;
  final void Function(String speakerId)? onToggleFavorite;
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
          onSpeakerTap: (s) {},
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

// ------------------ Small loading & helper widgets ------------------

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

class ComingSoon extends StatelessWidget {
  final String title;
  const ComingSoon(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64.sW, color: AppColor.gray400),
          SizedBox(height: 16.sH),
          Text(
            '$title — Coming Soon',
            style: TextStyleHelper.instance.headline24BoldInter.copyWith(
              color: AppColor.gray600,
            ),
          ),
        ],
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
