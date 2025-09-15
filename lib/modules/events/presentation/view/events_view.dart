// lib/modules/events/presentation/view/events_screen.dart
import 'package:baseqat/modules/events/presentation/view/gallery_tav_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:baseqat/core/components/custom_widgets/events_search_field.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

import 'package:baseqat/modules/arts_works/presentation/widgets/category_model.dart';
import 'package:baseqat/modules/events/data/models/week_model.dart';

import 'package:baseqat/modules/events/presentation/view/art_works_view.dart';
import 'package:baseqat/modules/events/presentation/view/artist_tab.dart';
import 'package:baseqat/modules/events/presentation/view/speakers_tab.dart';

import 'package:baseqat/modules/events/presentation/manger/events_cubit.dart';
import 'package:baseqat/modules/events/presentation/manger/events_state.dart';
import '../../data/datasources/events_remote_data_source.dart';
import '../../data/repositories/events_repository_impl.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int _selectedIndex = 0;

  final List<CategoryModel> _categories = [
    CategoryModel(title: 'Art Works', isSelected: true),
    CategoryModel(title: 'Artist', isSelected: false),
    CategoryModel(title: 'Speakers', isSelected: false),
    CategoryModel(title: 'Gallery', isSelected: false),
    CategoryModel(title: 'Virtual Tour', isSelected: false),
  ];

  // --- Month navigation state ---
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

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  // Initial stub week (SpeakersTabContent now builds its own rolling 30d+7d slice,
  // but we keep WeekModel for header/week visuals compatibility)
  static const _weekJson = {
    "weekdays": ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
    "dates": [1, 2, 3, 4, 5, 6, 7],
    "selectedIndex": 0,
  };
  late final WeekModel _week = WeekModel.fromJson(_weekJson);

  void _onCategoryTap(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
      for (int i = 0; i < _categories.length; i++) {
        _categories[i].isSelected = (i == index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final repo = EventsRepositoryImpl(EventsRemoteDataSourceImpl(client));

    return BlocProvider(
      create: (_) => EventsCubit(repo)..loadAll(),
      child: Scaffold(
        backgroundColor: AppColor.white,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.all(8.h),
                child: Column(
                  spacing: 24.h,
                  children: [
                    const EventsSearchField(),
                    EventsCategoryChips(
                      categories: _categories,
                      onTap: _onCategoryTap,
                      showIndex: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              Expanded(
                child: BlocConsumer<EventsCubit, EventsState>(
                  listener: (context, state) {
                    if (state is EventsError) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
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
        // Pass ALL speakers. SpeakersTabContent will:
        // - build 30-day window from currentMonth
        // - page by 7 days (prev/next)
        // - filter by selected day (UTC)
        return SpeakersTabContent(
          headerTitle: 'Festival Schedule',
          monthLabel: _monthLabel,
          currentMonth: _currentMonth,
          week: _week,
          speakers: s.speakers,
          ctaTitle: 'We look forward\nto seeing you\ntomorrow',
          ctaSubtitle:
              'Don’t miss the exciting sessions on dates and palm cultivation.',
          onPrevMonth: _prevMonth,
          onNextMonth: _nextMonth,
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

// Optional placeholder; keep your existing implementation if present.
class ComingSoon extends StatelessWidget {
  final String title;
  const ComingSoon(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title — coming soon'));
  }
}
