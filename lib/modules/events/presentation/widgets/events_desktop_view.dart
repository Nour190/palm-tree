import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/components/custom_widgets/custom_search_view.dart';
import '../../../../core/responsive/size_ext.dart';
import '../../../../core/resourses/assets_manager.dart';
import '../../../../core/resourses/color_manager.dart';
import '../../../../core/resourses/style_manager.dart';
import '../../data/datasources/events_remote_data_source.dart';
import '../../data/models/week_model.dart';
import '../../data/repositories/events_repository_impl.dart';
import '../../data/models/category_model.dart';
import '../manger/events_cubit.dart';
import '../manger/events_state.dart';
import '../manger/search_cubit.dart';
import '../manger/search_state.dart';
import '../widgets/search_filter_panel.dart';
import '../view/art_works_view.dart';
import '../view/artist_tab.dart';
import '../view/speakers_info_view.dart';
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

  final List<CategoryModel> _categories = [
    CategoryModel(title: 'Art Works', isSelected: true),
    CategoryModel(title: 'Artist', isSelected: false),
    CategoryModel(title: 'Speakers', isSelected: false),
    CategoryModel(title: 'Gallery', isSelected: false),
    CategoryModel(title: 'Virtual Tour', isSelected: false),
  ];

  void _onCategoryTap(int index) {
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
    context.read<SearchCubit>().updateTabIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final repo = EventsRepositoryImpl(EventsRemoteDataSourceImpl(client));

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => EventsCubit(repo)..loadAll(),
        ),
        BlocProvider(
          create: (_) => SearchCubit(),
        ),
      ],
      child: Container(
        color: AppColor.white,
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Row(
                  children: [
                    Container(
                      width: 280.sW,
                      decoration: BoxDecoration(
                        color: AppColor.backgroundWhite,
                        border: Border(
                          right: BorderSide(color: AppColor.gray200, width: 1.sW),
                        ),
                      ),
                      child: DesktopNavigationBar(
                        selectedIndex: _selectedIndex,
                        onItemTap: _onCategoryTap,
                        categories: _categories,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 1200.sW),
                          child: Column(
                            children: [
                              BlocBuilder<SearchCubit, SearchState>(
                                builder: (context, searchState) {
                                  final isSearchBarVisible = searchState is SearchLoaded
                                      ? searchState.isSearchBarVisible
                                      : _selectedIndex != 2; // Hide for speakers tab

                                  return Container(
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
                                          style: TextStyleHelper.instance.headline32BoldInter,
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
                                        if (isSearchBarVisible) ...[
                                          SizedBox(height: 16.sH),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: 60.sH,
                                                  child: CustomSearchView(
                                                    controller: searchController,
                                                    hintText: 'Search events, artists, artworks...',
                                                    prefixIcon: AppAssetsManager.imgSearch,
                                                    fillColor: AppColor.backgroundWhite,
                                                    borderColor: AppColor.gray400,
                                                    iconSize: 24.sSp,
                                                    onChanged: (value) {
                                                      context.read<SearchCubit>().updateSearchQuery(value);
                                                    },
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 16.sW),
                                              IconButton(
                                                onPressed: () {
                                                  context.read<SearchCubit>().toggleFilter();
                                                },
                                                icon: Icon(
                                                  Icons.tune,
                                                  size: 24.sW,
                                                  color: searchState is SearchLoaded && searchState.isFilterVisible
                                                      ? AppColor.primaryColor
                                                      : AppColor.gray600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Expanded(
                                child: BlocConsumer<EventsCubit, EventsState>(
                                  listener: (context, state) {
                                    if (state is EventsError) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(state.message)),
                                      );
                                    }
                                    if (state is EventsLoaded) {
                                      context.read<SearchCubit>().initializeData(
                                        artists: state.artists,
                                        artworks: state.artworks,
                                        speakers: state.speakers,
                                        gallery: state.gallery,
                                      );
                                    }
                                  },
                                  builder: (context, state) {
                                    if (state is EventsInitial ||
                                        state is EventsLoading) {
                                      return const _LoadingView();
                                    }
                                    if (state is EventsError) {
                                      return _ErrorView(
                                        message: state.message,
                                        onRetry: () =>
                                            context.read<EventsCubit>().loadAll(),
                                      );
                                    }
                                    final s = state as EventsLoaded;
                                    return Container(
                                      child: _buildTabBody(s),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 140.sH, // Position below header
                  child: BlocBuilder<SearchCubit, SearchState>(
                    builder: (context, state) {
                      final isFilterVisible = state is SearchLoaded ? state.isFilterVisible : false;
                      if (!isFilterVisible) return const SizedBox.shrink();

                      return const SearchFilterPanel(
                        isDesktop: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBody(EventsLoaded s) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, searchState) {
        final speaker = s.speakers[0];

        if (searchState is SearchLoaded) {
          switch (_selectedIndex) {
            case 0:
              return ArtWorksGalleryContent(
                artworks: searchState.isSearching ? searchState.filteredArtworks : s.artworks,
                onArtworkTap: (art) {},
              );
            case 1:
              return ArtistTabContent(
                artists: searchState.isSearching ? searchState.filteredArtists : s.artists,
              );
            case 2:
              return MonthWidget(
                builder: (context, monthData) {
                  return SpeakersTabContent(
                    headerTitle: "Festival Schedule",
                    monthLabel: monthData.monthLabel,
                    currentMonth: monthData.currentMonth,
                    week: monthData.week,
                    speakers: s.speakers,
                    ctaSubtitle: "Don't miss the exciting sessions on dates and palm cultivation.",
                    ctaTitle: "We look forward\\nto seeing you\\ntomorrow",
                    onNextMonth: monthData.nextMonth,
                    onPrevMonth: monthData.prevMonth,
                    onSpeakerTap: (speaker) {},
                  );
                },
              );
            case 3:
              return GalleryGrid(
                items: searchState.isSearching ? searchState.filteredGallery : s.gallery,
                onTap: (item) {},
              );
            case 4:
              return const ComingSoon('Virtual Tour');
            default:
              return const SizedBox.shrink();
          }
        }

        switch (_selectedIndex) {
          case 0:
            return ArtWorksGalleryContent(
              artworks: s.artworks,
              onArtworkTap: (art) {},
            );
          case 1:
            return ArtistTabContent(artists: s.artists);
          case 2:
            return MonthWidget(
              builder: (context, monthData) {
                return SpeakersTabContent(
                  headerTitle: "Festival Schedule",
                  monthLabel: monthData.monthLabel,
                  currentMonth: monthData.currentMonth,
                  week: monthData.week,
                  speakers: s.speakers,
                  ctaSubtitle: "Don't miss the exciting sessions on dates and palm cultivation.",
                  ctaTitle: "We look forward\\nto seeing you\\ntomorrow",
                  onNextMonth: monthData.nextMonth,
                  onPrevMonth: monthData.prevMonth,
                  onSpeakerTap: (speaker) {},
                );
              },
            );
          case 3:
            return GalleryGrid(items: s.gallery, onTap: (item) {});
          case 4:
            return const ComingSoon('Virtual Tour');
          default:
            return const SizedBox.shrink();
        }
      },
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
        child: const CircularProgressIndicator(color: AppColor.primaryColor,),
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
    return Center(
      child: Container(
        padding: EdgeInsets.all(32.sW),
        constraints: BoxConstraints(maxWidth: 400.sW),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sW, color: Colors.red),
            SizedBox(height: 16.sH),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.title16RegularInter,
            ),
            SizedBox(height: 24.sH),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.sW,
                  vertical: 12.sH,
                ),
              ),
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
