import 'package:baseqat/modules/events/data/models/fav_extension.dart';
import 'package:baseqat/modules/events/data/models/gallery_item.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/components/custom_widgets/custom_search_view.dart';
import '../../../../core/responsive/size_ext.dart';
import '../../../../core/resourses/assets_manager.dart';
import '../../../../core/resourses/color_manager.dart';
import '../../../../core/resourses/style_manager.dart';

import '../../data/datasources/events_remote_data_source.dart';
import '../../data/repositories/events/events_repository_impl.dart';
import '../../data/models/category_model.dart';

import '../manger/events/events_cubit.dart';
import '../manger/events/events_state.dart';

import '../view/art_works_view.dart';
import '../view/artist_tab.dart';
import '../view/speakers_tab.dart';
import '../view/gallery_tav_view.dart';
import '../widgets/desktop_navigation_bar.dart';
import 'month_data.dart';

class EventsDesktopView extends StatefulWidget {
  const EventsDesktopView({super.key});

  @override
  State<EventsDesktopView> createState() => _EventsDesktopViewState();
}

class _EventsDesktopViewState extends State<EventsDesktopView> {
  int _selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();

  // per-tab "favorites only" toggles (local mirrors for icon state)
  bool _favOnlyArtworks = false;
  bool _favOnlyArtists = false;
  bool _favOnlySpeakers = false;

  late final SupabaseClient _client;
  late final EventsRepositoryImpl _repo;
  String? _userId;

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
      child: Builder(
        builder: (ctx) {
          return Container(
            color: AppColor.white,
            child: Scaffold(
              body: SafeArea(
                child: Row(
                  children: [
                    // -------------------- Left Nav --------------------
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

                    // -------------------- Main Content --------------------
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 1200.sW),
                          child: Column(
                            children: [
                              // -------- Header with search + fav-only toggle (hide on speakers tab)
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          .copyWith(color: AppColor.gray600),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    if (_selectedIndex != 2) ...[
                                      SizedBox(height: 16.sH),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 60.sH,
                                              child: CustomSearchView(
                                                controller: searchController,
                                                hintText:
                                                    'Search events, artists, artworks...',
                                                prefixIcon:
                                                    AppAssetsManager.imgSearch,
                                                fillColor:
                                                    AppColor.backgroundWhite,
                                                borderColor: AppColor.gray400,
                                                iconSize: 24.sSp,
                                                onChanged: (value) {
                                                  ctx
                                                      .read<EventsCubit>()
                                                      .setSearchQuery(value);
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16.sW),
                                          _FavToggleChip(
                                            active: switch (_selectedIndex) {
                                              0 => _favOnlyArtworks,
                                              1 => _favOnlyArtists,
                                              2 => _favOnlySpeakers,
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

                              // -------- Main body (no dropdown filter bar anymore)
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
          );
        },
      ),
    );
  }

  // ============================ Body by Tab ============================
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
          userId: _userId!,
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

    if (status == SliceStatus.loading) return const _LoadingView();

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

    if (status == SliceStatus.loading) return const _LoadingView();

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
  const _SpeakersSliceView({this.onToggleFavorite, required this.userId});

  @override
  Widget build(BuildContext context) {
    final speakers = context.select<EventsCubit, List<Speaker>>(
      (c) => c.state.speakers,
    );
    final status = context.select<EventsCubit, SliceStatus>(
      (c) => c.state.speakersStatus,
    );

    if (status == SliceStatus.loading) return const _LoadingView();

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
          onSpeakerTap: (s) {
            // onToggleFavorite?.call(s.id);
          },
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

    if (status == SliceStatus.loading) return const _LoadingView();

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

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 40.sW,
        height: 48.sH,
        child: const CircularProgressIndicator(color: AppColor.primaryColor),
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
