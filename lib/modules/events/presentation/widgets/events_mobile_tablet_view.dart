import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/components/custom_widgets/custom_search_view.dart';
import '../../../../core/components/custom_widgets/events_search_field.dart';
import '../../../../core/responsive/size_utils.dart';
import '../../../../core/resourses/assets_manager.dart';
import '../../../../core/resourses/color_manager.dart';
import '../../data/datasources/events_remote_data_source.dart';
import '../../data/repositories/events_repository_impl.dart';
import '../../data/models/category_model.dart' hide CategoryModel;
import '../manger/events_cubit.dart';
import '../manger/events_state.dart';
import '../view/art_works_view.dart';
import '../view/artist_tab.dart';
import '../view/speakers_info_view.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final repo = EventsRepositoryImpl(EventsRemoteDataSourceImpl(client));

    return BlocProvider(
      create: (_) => EventsCubit(repo)..loadAll(),
      child: Container(
        color: AppColor.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Text(
                    //       'Discover',
                    //       style: TextStyle(
                    //         fontSize: 28.fSize,
                    //         fontWeight: FontWeight.bold,
                    //         color: AppColor.gray900,
                    //         height: 1.2,
                    //       ),
                    //     ),
                    //     SizedBox(height: 4.h),
                    //     Text(
                    //       'What do you want to see today?',
                    //       style: TextStyle(
                    //         fontSize: 16.fSize,
                    //         color: AppColor.gray600,
                    //         height: 1.4,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 20.h),
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
                        decoration: InputDecoration(
                          hintText: 'Search events, artists, artworks...',
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
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.tune,
                              color: AppColor.gray500,
                              size: 15.sSp,
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
              ),
              SizedBox(height: 15.sH),
              EventsCategoryChips(
                categories: _categories,
                onTap: _onCategoryTap,
                enableScrollIndicators: false,
                animationDuration: const Duration(milliseconds: 250),
                height: 60.sH,
              ),
          //    SizedBox(height: 16.h),
              Expanded(
                child: BlocConsumer<EventsCubit, EventsState>(
                  listener: (context, state) {
                    if (state is EventsError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is EventsInitial || state is EventsLoading) {
                      return const _LoadingView();
                    }
                    if (state is EventsError) {
                      return _ErrorView(
                        message: state.message,
                        onRetry: () => context.read<EventsCubit>().loadAll(),
                      );
                    }
                    final s = state as EventsLoaded;
                    return _buildTabBody(s);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBody(EventsLoaded s) {
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
              ctaSubtitle: "Don't miss the exciting sessions on dates and palm cultivation.",ctaTitle: "We look forward to seeing youtomorrow",
              onNextMonth: monthData.nextMonth,
              onPrevMonth: monthData.prevMonth,
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
  }
}

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
