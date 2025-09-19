// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// import '../../../../core/components/custom_widgets/custom_search_view.dart';
// import '../../../../core/responsive/size_ext.dart';
// import '../../../../core/resourses/assets_manager.dart';
// import '../../../../core/resourses/color_manager.dart';
// import '../../../../core/resourses/style_manager.dart';
// import '../../data/datasources/events_remote_data_source.dart';
// import '../../data/repositories/events_repository_impl.dart';
// import '../../data/models/category_model.dart' ;
// import '../manger/events_cubit.dart';
// import '../manger/events_state.dart';
// import '../view/art_works_view.dart';
// import '../view/artist_tab.dart';
// import '../view/speakers_info_view.dart';
// import '../view/speakers_tab.dart';
// import '../view/gallery_tav_view.dart';
// import '../widgets/desktop_navigation_bar.dart';
//
// class EventsDesktopView extends StatefulWidget {
//   const EventsDesktopView({super.key});
//
//   @override
//   State<EventsDesktopView> createState() => _EventsDesktopViewState();
// }
//
// class _EventsDesktopViewState extends State<EventsDesktopView> {
//   int _selectedIndex = 0;
//   final TextEditingController searchController = TextEditingController();
//
//   final List<CategoryModel> _categories = [
//     CategoryModel(title: 'Art Works', isSelected: true),
//     CategoryModel(title: 'Artist', isSelected: false),
//     CategoryModel(title: 'Speakers', isSelected: false),
//     CategoryModel(title: 'Gallery', isSelected: false),
//     CategoryModel(title: 'Virtual Tour', isSelected: false),
//   ];
//
//   void _onCategoryTap(int index) {
//     if (_selectedIndex == index) return;
//     setState(() {
//       _selectedIndex = index;
//       for (int i = 0; i < _categories.length; i++) {
//         _categories[i] = CategoryModel(
//           title: _categories[i].title,
//           isSelected: i == index,
//         );
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final client = Supabase.instance.client;
//     final repo = EventsRepositoryImpl(EventsRemoteDataSourceImpl(client));
//
//     return BlocProvider(
//       create: (_) => EventsCubit(repo)..loadAll(),
//       child: Scaffold(
//         backgroundColor: AppColor.white,
//         body: SafeArea(
//           child: Row(
//             children: [
//               Container(
//                 width: 280.sW,
//                 decoration: BoxDecoration(
//                   color: AppColor.backgroundWhite,
//                   border: Border(
//                     right: BorderSide(
//                       color: AppColor.gray200,
//                       width: 1.sW,
//                     ),
//                   ),
//                 ),
//                 child: DesktopNavigationBar(
//                   selectedIndex: _selectedIndex,
//                   onItemTap: _onCategoryTap,
//                   categories: _categories,
//                 ),
//               ),
//
//               Expanded(
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(24.sW),
//                       decoration: BoxDecoration(
//                         color: AppColor.white,
//                         border: Border(
//                           bottom: BorderSide(
//                             color: AppColor.gray200,
//                             width: 1.sW,
//                           ),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Discover Events',
//                                   style: TextStyleHelper.instance.headline32BoldInter,
//                                 ),
//                                 SizedBox(height: 8.sH),
//                                 Text(
//                                   'What do you want to see today?',
//                                   style: TextStyleHelper.instance.title16RegularInter
//                                       .copyWith(color: AppColor.gray600),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(width: 24.sW),
//                           SizedBox(
//                             width: 400.sW,
//                             child: CustomSearchView(
//                               controller: searchController,
//                               hintText: 'Search events, artists, artworks...',
//                               prefixIcon: AppAssetsManager.imgSearch,
//                               fillColor: AppColor.backgroundWhite,
//                               borderColor: AppColor.gray400,
//                             ),
//                           ),
//                           SizedBox(width: 16.sW),
//                           IconButton(
//                             onPressed: () {},
//                             icon: Icon(
//                               Icons.tune,
//                               size: 24.sW,
//                               color: AppColor.gray600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     Expanded(
//                       child: BlocConsumer<EventsCubit, EventsState>(
//                         listener: (context, state) {
//                           if (state is EventsError) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text(state.message)),
//                             );
//                           }
//                         },
//                         builder: (context, state) {
//                           if (state is EventsInitial || state is EventsLoading) {
//                             return const _LoadingView();
//                           }
//                           if (state is EventsError) {
//                             return _ErrorView(
//                               message: state.message,
//                               onRetry: () => context.read<EventsCubit>().loadAll(),
//                             );
//                           }
//                           final s = state as EventsLoaded;
//                           return Container(
//                             padding: EdgeInsets.all(24.sW),
//                             child: _buildTabBody(s),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTabBody(EventsLoaded s) {
//     switch (_selectedIndex) {
//       case 0:
//         return ArtWorksGalleryContent(
//           artworks: s.artworks,
//           onArtworkTap: (art) {},
//         );
//       case 1:
//         return ArtistTabContent(artists: s.artists);
//       case 2:
//         return SpeakersInfoScreen(speaker: s.speakers[0]);
//       case 3:
//         return GalleryGrid(items: s.gallery, onTap: (item) {});
//       case 4:
//         return const ComingSoon('Virtual Tour');
//       default:
//         return const SizedBox.shrink();
//     }
//   }
// }
//
// class _LoadingView extends StatelessWidget {
//   const _LoadingView();
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SizedBox(
//         width: 48.sW,
//         height: 48.sH,
//         child: const CircularProgressIndicator(),
//       ),
//     );
//   }
// }
//
// class _ErrorView extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry;
//   const _ErrorView({required this.message, required this.onRetry});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         padding: EdgeInsets.all(32.sW),
//         constraints: BoxConstraints(maxWidth: 400.sW),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 48.sW, color: Colors.red),
//             SizedBox(height: 16.sH),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: TextStyleHelper.instance.title18MediumInter,
//             ),
//             SizedBox(height: 24.sH),
//             ElevatedButton.icon(
//               onPressed: onRetry,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Retry'),
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(horizontal: 24.sW, vertical: 12.sH),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class ComingSoon extends StatelessWidget {
//   final String title;
//   const ComingSoon(this.title, {super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.construction,
//             size: 64.sW,
//             color: AppColor.gray400,
//           ),
//           SizedBox(height: 16.sH),
//           Text(
//             '$title — Coming Soon',
//             style: TextStyleHelper.instance.headline24BoldInter
//                 .copyWith(color: AppColor.gray600),
//           ),
//         ],
//       ),
//     );
//   }
// }
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
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final repo = EventsRepositoryImpl(EventsRemoteDataSourceImpl(client));

    return BlocProvider(
      create: (_) => EventsCubit(repo)..loadAll(),
      child: Container(
        color: AppColor.white,
        child: Scaffold(
          //    backgroundColor: AppColor.white,
          body: SafeArea(
            child: Row(
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
                                  style:
                                      TextStyleHelper.instance.headline32BoldInter,
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
                                          prefixIcon: AppAssetsManager.imgSearch,
                                          fillColor: AppColor.backgroundWhite,
                                          borderColor: AppColor.gray400,
                                          iconSize: 24.sSp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.sW),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.tune,
                                        size: 24.sW,
                                        color: AppColor.gray600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

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
                                  //padding: EdgeInsets.all(24.sW),
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
          ),
        ),
      ),
    );
  }
  // DateTime _currentMonth = DateTime(2025, 10); // October 2025 start
  // static const _monthNames = [
  //   "January",
  //   "February",
  //   "March",
  //   "April",
  //   "May",
  //   "June",
  //   "July",
  //   "August",
  //   "September",
  //   "October",
  //   "November",
  //   "December",
  // ];
  //
  // String get _monthLabel =>
  //     "${_monthNames[_currentMonth.month - 1]} ${_currentMonth.year}";
  //
  // void _prevMonth() {
  //   setState(() {
  //     _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
  //   });
  // }
  //
  // void _nextMonth() {
  //   setState(() {
  //     _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
  //   });
  // }
  //
  // // Initial stub week (SpeakersTabContent now builds its own rolling 30d+7d slice,
  // // but we keep WeekModel for header/week visuals compatibility)
  // static const _weekJson = {
  //   "weekdays": ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
  //   "dates": [1, 2, 3, 4, 5, 6, 7],
  //   "selectedIndex": 0,
  // };
  // late final WeekModel _week = WeekModel.fromJson(_weekJson);

  Widget _buildTabBody(EventsLoaded s) {
    final   speaker=s.speakers[0];
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
              ctaSubtitle: "Don't miss the exciting sessions on dates and palm cultivation.",ctaTitle: "We look forward\nto seeing you\ntomorrow",
              onNextMonth: monthData.nextMonth,
              onPrevMonth: monthData.prevMonth,
              onSpeakerTap: (speaker){

              },
            );
          },
        );

    //SpeakersTabContent(headerTitle: "Festival Schedule", monthLabel: _monthLabel,currentMonth: _currentMonth,week: _week,speakers: s.speakers,ctaSubtitle: "Don't miss the exciting sessions on dates and palm cultivation.",ctaTitle: "We look forward\nto seeing you\ntomorrow", onNextMonth:_nextMonth ,onPrevMonth: _prevMonth,);
          //SpeakersInfoScreen(speaker: s.speakers[0]);
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
