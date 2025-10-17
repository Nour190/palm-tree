import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/chat_route.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/location_tab.dart';
import 'package:baseqat/modules/artwork_details/presentation/widgets/artwork_desktop_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/zondicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';

import 'package:baseqat/core/network/connectivity_service.dart';
import 'package:baseqat/core/session/session_manager.dart';

// ---- Repos & Data Sources
import 'package:baseqat/modules/artwork_details/data/datasources/artwork_details_remote_data_source.dart';
import 'package:baseqat/modules/artwork_details/data/datasources/artwork_details_local_data_source.dart';
import 'package:baseqat/modules/artwork_details/data/repositories/artwork_repository.dart';

// ---- Cubits & States
import 'package:baseqat/modules/artwork_details/presentation/view/manger/artwork/artwork_cubit.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/manger/artwork/artwork_state.dart';

import 'package:baseqat/modules/artwork_details/presentation/view/manger/artist/artist_cubit.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/manger/artist/artist_states.dart';

import 'package:baseqat/modules/artwork_details/presentation/view/manger/feedback/feedback_cubit.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/manger/feedback/feedback_states.dart';

// ---- Tabs & Widgets (artwork details)
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/about_tab.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/gallery_tab.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/feedback_tab.dart';

// ---- Events desktop nav reused for "same style"
import 'package:baseqat/modules/programs/data/models/category_model.dart'
as events;

// ---- Models
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';

// ---- Optional location (if you surface distance inside About tab)
import 'package:baseqat/core/location/location_service.dart';

class ArtWorkDetailsScreen extends StatefulWidget {
  const ArtWorkDetailsScreen({
    super.key,
    required this.artworkId,
    required this.userId,
    this.initialTabIndex = 0,
  });

  final String artworkId;
  final String userId;
  final int initialTabIndex;

  @override
  State<ArtWorkDetailsScreen> createState() => _ArtWorkDetailsScreenState();
}

class _ArtWorkDetailsScreenState extends State<ArtWorkDetailsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  int _selectedIndex = 0;
  bool _isFavorite = false;

  // Left nav categories (same component & style as EventsDesktopView)
  late List<events.CategoryModel> _categories;

  // Optional distance computation
  double? _distanceKm;
  String? _distanceError;
  bool _isRefreshingDistance = false;

  bool _isOnline = true;

  late ArtworkDetailsRepositoryImpl _repository;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;

    final client = Supabase.instance.client;
    _repository = ArtworkDetailsRepositoryImpl(
      remote: ArtworkDetailsRemoteDataSourceImpl(client),
      local: ArtworkDetailsLocalDataSourceImpl(),
      connectivity: ConnectivityService(),
    );

    // Initialize loading animation
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _loadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.linear),
    );

    _categories = [
      events.CategoryModel(title: 'about', isSelected: _selectedIndex == 0),
      events.CategoryModel(title: 'gallery', isSelected: _selectedIndex == 1),
      events.CategoryModel(title: 'location', isSelected: _selectedIndex == 2),
      events.CategoryModel(title: 'chat_ai', isSelected: _selectedIndex == 3),
      events.CategoryModel(title: 'feedback', isSelected: _selectedIndex == 4),
    ];

    _checkConnectivity();
    _listenToConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final hasConnection = await ConnectivityService().hasConnection();
    if (mounted) {
      setState(() {
        _isOnline = hasConnection;
      });
    }
  }

  void _listenToConnectivity() {
    ConnectivityService().onConnectivityChanged.listen((_) async {
      debugPrint('[ArtworkDetailsScreen] ========== CONNECTIVITY CHANGED ==========');

      final hasConnection = await ConnectivityService().hasConnection();
      debugPrint('[ArtworkDetailsScreen] New connection status: $hasConnection');

      if (mounted) {
        setState(() {
          _isOnline = hasConnection;
        });

        if (hasConnection) {
          debugPrint('[ArtworkDetailsScreen] Connection restored - triggering feedback sync');

          try {
            debugPrint('[ArtworkDetailsScreen] Calling syncPendingFeedback on stored repository...');
            await _repository.syncPendingFeedback();
            debugPrint('[ArtworkDetailsScreen] syncPendingFeedback completed successfully');
          } catch (e, stackTrace) {
            debugPrint('[ArtworkDetailsScreen] Error during syncPendingFeedback: $e');
            debugPrint('[ArtworkDetailsScreen] Stack trace: $stackTrace');
          }
        } else {
          debugPrint('[ArtworkDetailsScreen] Connection lost - offline mode');
        }
      }
    });
  }

  void _onCategoryTap(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
      for (int i = 0; i < _categories.length; i++) {
        _categories[i] = events.CategoryModel(
          title: _categories[i].title,
          isSelected: i == index,
        );
      }
    });
  }

  Future<void> _computeDistanceIfPossible({required Artist? artist}) async {
    if (_isRefreshingDistance) return;

    setState(() {
      _isRefreshingDistance = true;
      _distanceKm = null;
      _distanceError = null;
    });

    final lat = artist?.latitude;
    final lon = artist?.longitude;
    if (lat == null || lon == null) {
      setState(() {
        _distanceError = 'artist_location_unavailable'.tr();
        _isRefreshingDistance = false;
      });
      return;
    }

    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos == null) {
        setState(() {
          _distanceError = 'location_permission_denied'.tr();
          _isRefreshingDistance = false;
        });
        return;
      }
      final km = LocationService.distanceKm(
        startLat: pos.latitude,
        startLon: pos.longitude,
        endLat: lat,
        endLon: lon,
      );
      setState(() {
        _distanceKm = km;
        _isRefreshingDistance = false;
      });
    } catch (e) {
      setState(() {
        _distanceError =
        '${'failed_to_get_location'.tr()}: ${e.toString().split(':').last.trim()}';
        _isRefreshingDistance = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final devType = Responsive.deviceTypeOf(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<ArtworkCubit>(
          create: (_) => ArtworkCubit(_repository)..getArtworkById(widget.artworkId),
        ),
        BlocProvider<ArtistCubit>(create: (_) => ArtistCubit(_repository)),
        BlocProvider<FeedbackCubit>(create: (_) => FeedbackCubit(_repository)),
      ],
      child: Scaffold(
        backgroundColor: AppColor.white,
        body: SafeArea(
          child: MultiBlocListener(
            listeners: [
              // When artwork loads, fetch its artist
              BlocListener<ArtworkCubit, ArtworkState>(
                listenWhen: (p, c) =>
                p.status != ArtworkStatus.loaded &&
                    c.status == ArtworkStatus.loaded,
                listener: (context, s) {
                  final artistId = s.artwork?.artistId;
                  if (artistId != null && artistId.isNotEmpty) {
                    context.read<ArtistCubit>().getArtistById(artistId);
                  }
                },
              ),
              // When artist loads, optionally compute distance
              BlocListener<ArtistCubit, ArtistState>(
                listenWhen: (p, c) =>
                p.artist?.id != c.artist?.id &&
                    c.status == ArtistStatus.loaded,
                listener: (context, s) {
                  _computeDistanceIfPossible(artist: s.artist);
                },
              ),
            ],
            child: devType == DeviceType.desktop ? _buildDesktopLayout() :_buildMobileLayout() ,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return _selectedIndex == 3 ? Column(
      children: [
        // Mobile Header
        _MobileHeader(searchCtrl: _searchCtrl),
        // Mobile Tab Bar

        if(_selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2)
          _bannerImageWidget(),

        if(_selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2)
          SizedBox(height: 10.sH,),

        _MobileTabBar(
          selectedIndex: _selectedIndex,
          onTabSelected: _onCategoryTap,
          categories: _categories,
        ),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16.sW),
            child: _buildContent(),
          ),
        ),
      ],
    ):SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          // Mobile Header
          _MobileHeader(searchCtrl: _searchCtrl),
          // Mobile Tab Bar

          if(_selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2)
            _bannerImageWidget(),

          if(_selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2)
            SizedBox(height: 10.sH,),

          _MobileTabBar(
            selectedIndex: _selectedIndex,
            onTabSelected: _onCategoryTap,
            categories: _categories,
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(16.sW),
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final devType = Responsive.deviceTypeOf(context);
    return Row(
      children: [
        // Left Sidebar
        Container(
          width: devType == DeviceType.tablet ? 240.sW : 280.sW,
          decoration: BoxDecoration(
            color: AppColor.backgroundWhite,
            border: Border(
              right: BorderSide(color: AppColor.gray200, width: 1.sW),
            ),
          ),
          child: ArtworkDesktopNavigationBar(
            selectedIndex: _selectedIndex,
            onItemTap: _onCategoryTap,
            categories: _categories,
          ),
        ),
        // Right Content
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1200.sW),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16.sW),
                      child: _buildContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return BlocBuilder<ArtworkCubit, ArtworkState>(
      builder: (context, artState) {
        if (artState.status == ArtworkStatus.idle ||
            artState.status == ArtworkStatus.loading) {
          return _EnhancedLoadingView(animation: _loadingAnimation);
        }

        if (artState.status == ArtworkStatus.error) {
          // If we're offline and have cached data, show it instead of error
          if (!_isOnline && artState.artwork != null) {
            // Show offline indicator banner but continue to display content
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.sW, vertical: 8.sH),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(color: Colors.black.withOpacity(0.3), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_off, size: 16.sW, color: Colors.black),
                      SizedBox(width: 8.sW),
                      Expanded(
                        child: Text(
                          'offline_mode'.tr(),
                          style: TextStyleHelper.instance.body14RegularInter.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<ArtistCubit, ArtistState>(
                    builder: (context, artistState) {
                      final Artist? artist = artistState.artist;
                      return _buildTabBody(
                        index: _selectedIndex,
                        artwork: artState.artwork,
                        artist: artist,
                      );
                    },
                  ),
                ),
              ],
            );
          } else if ((artState.error ?? '').isNotEmpty) {
            // Show error only if we don't have cached data
            return _EnhancedErrorView(
              message: artState.error!,
              onRetry: () =>
                  context.read<ArtworkCubit>().getArtworkById(widget.artworkId),
            );
          }
        }

        final Artwork? artwork = artState.artwork;

        return BlocBuilder<ArtistCubit, ArtistState>(
          builder: (context, artistState) {
            final Artist? artist = artistState.artist;

            return _buildTabBody(
              index: _selectedIndex,
              artwork: artwork,
              artist: artist,
            );
          },
        );
      },
    );
  }

  Widget _bannerImageWidget(){
    return BlocBuilder<ArtworkCubit, ArtworkState>(
      builder: (context, artState) {
        if (artState.status == ArtworkStatus.idle ||
            artState.status == ArtworkStatus.loading) {
          return _EnhancedLoadingView(animation: _loadingAnimation);
        }
        if (artState.status == ArtworkStatus.error &&
            (artState.error ?? '').isNotEmpty) {
          return _EnhancedErrorView(
            message: artState.error!,
            onRetry: () =>
                context.read<ArtworkCubit>().getArtworkById(widget.artworkId),
          );
        }

        final Artwork? artwork = artState.artwork;

        return BlocBuilder<ArtistCubit, ArtistState>(
            builder: (context, artistState) {
              final Artist? artist = artistState.artist;
              return Container(
                height:Responsive.isTablet(context)?400.sH: 200.sH,
                margin: EdgeInsets.symmetric(horizontal: 16.sW, vertical: 8.sH),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      height: Responsive.isTablet(context)?400.sH: 200.sH,
                      decoration: BoxDecoration(
                        color: AppColor.backgroundGray,
                        borderRadius: BorderRadius.circular(24),
                        image: artwork?.gallery.isNotEmpty ?? false
                            ? DecorationImage(
                          image: NetworkImage(
                            _selectedIndex == 1? artist!.profileImage!.isNotEmpty ? artist.profileImage! :artwork!.gallery.first  :artwork!.gallery.first,
                          ),
                          fit: BoxFit.fill,
                        )
                            : null,
                      ),
                    ),

                    // Positioned(
                    //   left: 16.sW,
                    //   bottom: 16.sH,
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       setState(() => _isFavorite = !_isFavorite);
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         SnackBar(
                    //           content: Text(_isFavorite ? 'added_to_favorites'.tr() : 'removed_from_favorites'.tr()),
                    //           duration: const Duration(milliseconds: 900),
                    //           behavior: SnackBarBehavior.floating,
                    //         ),
                    //       );
                    //     },
                    //     child: Container(
                    //       height: 40.sH,
                    //       width: 40.sW,
                    //       decoration: BoxDecoration(
                    //         color: Colors.transparent,
                    //         shape: BoxShape.circle,
                    //         border: Border.all(color: AppColor.white, width: 1.sW),
                    //         boxShadow: [
                    //           BoxShadow(
                    //             color: Colors.black.withOpacity(0.1),
                    //             blurRadius: 8,
                    //             offset: Offset(0, 2),
                    //           ),
                    //         ],
                    //       ),
                    //       alignment: Alignment.center,
                    //       child: Icon(
                    //         _isFavorite ? Icons.favorite : Icons.favorite_border,
                    //         size: 20.sH,
                    //         color: AppColor.white,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  Widget _buildTabBody({required int index, Artwork? artwork, Artist? artist}) {
    switch (index) {
      case 0: // About
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AboutTab(
              title: artwork?.name ?? '—',
              about: artwork?.description ?? '—',
              materials: artwork?.materials ?? '—',
              vision: artwork?.vision ?? '—',
              galleryImages: artwork?.gallery ?? const [],
              onAskAi: () {
                if (!_isOnline) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ai_requires_internet'.tr()),
                      backgroundColor: Colors.black,
                    ),
                  );
                  return;
                }
                _onCategoryTap(3);
              },
            ),
          ],
        );

      case 1: // Gallery
        final images = artist?.gallery ?? artwork?.gallery ?? const [];
        final title = artist?.name;
        final about = artist?.about;
        final hero = (artist?.profileImage?.isNotEmpty ?? false)
            ? artist!.profileImage
            : ((images.isNotEmpty) ? images.first : null);
        return GalleryTab(
          images: images,
          title: title,
          about: about,
          hero: hero,
        );

      case 2: // Location
        final lat = artist?.latitude;
        final lon = artist?.longitude;

        return LocationTab(
          title: artist?.name != null
              ? '${'navigate_to'.tr()} ${artist!.name}'
              : 'location'.tr(),
          subtitle: (() {
            final parts = <String>[];
            if ((artist?.address ?? '').isNotEmpty) parts.add(artist!.address!);
            final cityCountry = [
              artist?.city,
              artist?.country,
            ].where((e) => (e ?? '').isNotEmpty).join(', ');
            if (cityCountry.isNotEmpty) parts.add(cityCountry);
            return parts.isEmpty ? 'live_map_navigation'.tr() : parts.join(' • ');
          })(),
          distanceLabel: 'distance'.tr(),
          destinationLabel: 'to_festival_speakers'.tr(),
          addressLine: artist?.address,
          city: artist?.city,
          country: artist?.country,
          latitude: lat,
          longitude: lon,
          aboutTitle: (() {
            final name = artwork?.name ?? artist?.name;
            return name == null || name.isEmpty ? null : '${'about'.tr()} $name';
          })(),
          aboutDescription: artwork?.description ?? artist?.about,
          onStartNavigation: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('starting_navigation'.tr())),
            );
          },
        );

      case 3: // Chat AI
        if (!_isOnline) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off, size: 64, color: AppColor.gray400),
                SizedBox(height: 16.sH),
                Text(
                  'ai_requires_internet'.tr(),
                  style: TextStyleHelper.instance.title16MediumInter,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final sessionId = SessionManager().currentSessionId ?? 'anonymous';

        return ChatRoute(
          userId: sessionId,
          artworkId: artwork!.id.toString(),
          userName: 'User',
          artwork: artwork,
          artist: artist,
          metadata: {'source': 'landing'},
          modelName: 'gemini-1.5-flash',
        );

      case 4: // Feedback
        final Set<String> preselected = {};
        return BlocConsumer<FeedbackCubit, FeedbackState>(
          listenWhen: (p, c) => p.status != c.status || p.error != c.error,
          listener: (context, state) {
            if (state.status == FeedbackStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20.sW,
                      ),
                      SizedBox(width: 8.sW),
                      Text(_isOnline
                          ? 'thanks_feedback'.tr()
                          : 'feedback_saved_offline'.tr()),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.read<FeedbackCubit>().reset();
            } else if (state.status == FeedbackStatus.error &&
                (state.error ?? '').isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.error, color: Colors.white, size: 20.sW),
                      SizedBox(width: 8.sW),
                      Expanded(child: Text(state.error!)),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state.status == FeedbackStatus.submitting;
            final id = artwork?.id ?? '';

            return FeedbackTab(
              initialRating: 4,
              initialMessage: '',
              preselected: preselected,
              onSubmit: (rating, message, tags) async {
                if (id.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('artwork_not_ready'.tr())),
                  );
                  return;
                }
                if (isSubmitting) return;

                final sessionId = SessionManager().currentSessionId ?? 'anonymous';

                context.read<FeedbackCubit>().submitFeedback(
                  userId: sessionId,
                  artworkId: id,
                  rating: rating,
                  message: message,
                  tags: tags.toList(),
                );
              },
            );
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// ------------------ Mobile Header ------------------
class _MobileHeader extends StatelessWidget {
  const _MobileHeader({required this.searchCtrl});
  final TextEditingController searchCtrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.sW),
      decoration: BoxDecoration(
        color: AppColor.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Iconify(
                  MaterialSymbols.arrow_back_rounded,
                  color: Colors.black,
                  size: 32.sW,
                ),
              ),
              // IconButton(
              //   onPressed: () => Navigator.of(context).pop(),
              //   icon: Icon(Icons.arrow_back, size: 20.sW),
              //   padding: EdgeInsets.zero,
              //   constraints: BoxConstraints(minWidth: 24.sW, minHeight: 24.sH),
              // ),
              BlocBuilder<ArtworkCubit, ArtworkState>(
                builder: (context, state) {
                  final title = state.status == ArtworkStatus.loaded
                      ? (state.artwork?.name ?? 'artwork_details'.tr())
                      : 'artwork_details'.tr();
                  return Text(
                    title,
                    style: TextStyleHelper.instance.headline24BoldInter,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------ Mobile Tab Bar ------------------
class _MobileTabBar extends StatefulWidget {
  const _MobileTabBar({
    required this.selectedIndex,
    required this.onTabSelected,
    required this.categories,
  });

  final int selectedIndex;
  final Function(int) onTabSelected;
  final List<events.CategoryModel> categories;

  @override
  State<_MobileTabBar> createState() => _MobileTabBarState();
}

class _MobileTabBarState extends State<_MobileTabBar> {
  final ScrollController _scrollController = ScrollController();
  final double _tabWidth = 112; // Width of each tab
  final double _tabMargin = 8; // Right margin of each tab

  @override
  void didUpdateWidget(_MobileTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.selectedIndex == 3 || oldWidget.selectedIndex == 4){
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    if (oldWidget.selectedIndex != widget.selectedIndex && !(oldWidget.selectedIndex == 3 || oldWidget.selectedIndex == 4)) {
      _scrollToSelectedTab();
    }
  }

  void _scrollToSelectedTab() {
    if (!_scrollController.hasClients) return;

    final double tabTotalWidth = _tabWidth + _tabMargin;
    final double targetScroll = widget.selectedIndex * tabTotalWidth;

    // Calculate the viewport width to center the tab
    final double viewportWidth = _scrollController.position.viewportDimension;
    final double centeredScroll = targetScroll - (viewportWidth / 2) + (_tabWidth / 2);

    // Clamp the scroll position to valid range
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double finalScroll = centeredScroll.clamp(0.0, maxScroll);

    _scrollController.animateTo(
      finalScroll,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sW, vertical: 8.sH),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border(
          bottom: BorderSide(color: AppColor.gray200, width: 1.sW),
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(widget.categories.length, (index) {
            final category = widget.categories[index];
            final isSelected = index == widget.selectedIndex;

            return GestureDetector(
              onTap: () => widget.onTabSelected(index),
              child: AnimatedContainer(
                width: 112.sW,
                height: 40.sH,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: EdgeInsets.only(right: 8.sW),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColor.primaryColor : AppColor.gray200,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: AppColor.primaryColor.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                      : [],
                ),
                child: Text(
                  category.title!.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                    isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ------------------ Enhanced Loading View ------------------
class _EnhancedLoadingView extends StatelessWidget {
  const _EnhancedLoadingView({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading spinner with gradient
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: animation.value * 2 * 3.14159,
                child: Container(
                  width: 60.sW,
                  height: 60.sH,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        AppColor.primaryColor,
                        AppColor.primaryColor.withOpacity(0.3),
                        AppColor.primaryColor,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 48.sW,
                      height: 48.sH,
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.brush,
                        color: AppColor.primaryColor,
                        size: 24.sW,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24.sH),
          Text(
            'loading_artwork'.tr(),
            style: TextStyleHelper.instance.title16RegularInter.copyWith(
              color: AppColor.gray600,
            ),
          ),
          SizedBox(height: 8.sH),
          // Loading dots animation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final delay = index * 0.3;
                  final opacity =
                  (0.5 +
                      0.5 *
                          ((animation.value + delay) % 1.0 < 0.5
                              ? ((animation.value + delay) % 1.0) * 2
                              : 2 -
                              ((animation.value + delay) % 1.0) *
                                  2))
                      .clamp(0.0, 1.0);

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 2.sW),
                    width: 8.sW,
                    height: 8.sH,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(opacity),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ------------------ Enhanced Error View ------------------
class _EnhancedErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _EnhancedErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(32.sW),
        constraints: BoxConstraints(maxWidth: 420.sW),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with background
            Container(
              width: 80.sW,
              height: 80.sH,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 40.sW, color: Colors.red),
            ),
            SizedBox(height: 24.sH),
            Text(
              'oops_error'.tr(),
              style: TextStyleHelper.instance.headline20BoldInter,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.sH),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.body14RegularInter.copyWith(
                color: AppColor.gray600,
              ),
            ),
            SizedBox(height: 32.sH),
            // Enhanced retry button
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, size: 18.sW),
              label:Text('try_again'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 32.sW,
                  vertical: 16.sH,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
            ),
            SizedBox(height: 16.sH),
            // Secondary action
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back, size: 18.sW),
              label:Text('go_back'.tr()),
              style: TextButton.styleFrom(
                foregroundColor: AppColor.gray600,
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
