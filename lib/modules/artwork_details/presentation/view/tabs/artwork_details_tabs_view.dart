// lib/modules/artwork_details/presentation/view/artwork_details_screen.dart

import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/chat_route.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/chat_tab_view.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/location_tab.dart';
import 'package:baseqat/modules/artwork_details/presentation/widgets/artwork_desktop_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---- Core / Design
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';

// ---- Shared widgets
import 'package:baseqat/core/components/custom_widgets/custom_search_view.dart';

// ---- Repos & Data Sources
import 'package:baseqat/modules/artwork_details/data/datasources/artwork_details_remote_data_source.dart';
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
import 'package:baseqat/modules/artwork_details/presentation/widgets/hero_image.dart';

// ---- Events desktop nav reused for "same style"
import 'package:baseqat/modules/events/presentation/widgets/desktop_navigation_bar.dart';
import 'package:baseqat/modules/events/data/models/category_model.dart'
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

  // Left nav categories (same component & style as EventsDesktopView)
  late List<events.CategoryModel> _categories;

  // Optional distance computation
  double? _distanceKm;
  String? _distanceError;
  bool _isRefreshingDistance = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;

    // Initialize loading animation
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _loadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.linear),
    );

    _categories = [
      events.CategoryModel(title: 'About', isSelected: _selectedIndex == 0),
      events.CategoryModel(title: 'Gallery', isSelected: _selectedIndex == 1),
      events.CategoryModel(title: 'Location', isSelected: _selectedIndex == 2),
      events.CategoryModel(title: 'Chat AI', isSelected: _selectedIndex == 3),
      events.CategoryModel(title: 'Feedback', isSelected: _selectedIndex == 4),
    ];
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _loadingController.dispose();
    super.dispose();
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
        _distanceError = 'Artist location unavailable';
        _isRefreshingDistance = false;
      });
      return;
    }

    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos == null) {
        setState(() {
          _distanceError = 'Location permission denied';
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
            'Failed to get location: ${e.toString().split(':').last.trim()}';
        _isRefreshingDistance = false;
      });
    }
  }

  bool get _isMobile => MediaQuery.of(context).size.width < 768;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final repo = ArtworkDetailsRepositoryImpl(
      remote: ArtworkDetailsRemoteDataSourceImpl(client),
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<ArtworkCubit>(
          create: (_) => ArtworkCubit(repo)..getArtworkById(widget.artworkId),
        ),
        BlocProvider<ArtistCubit>(create: (_) => ArtistCubit(repo)),
        BlocProvider<FeedbackCubit>(create: (_) => FeedbackCubit(repo)),
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
            child: _isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Mobile Header
        _MobileHeader(searchCtrl: _searchCtrl),
        // Mobile Tab Bar
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
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Sidebar
        Container(
          width: _isTablet ? 240.sW : 280.sW,
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

  Widget _buildTabBody({required int index, Artwork? artwork, Artist? artist}) {
    switch (index) {
      case 0: // About
        final String? hero = (artwork?.gallery.isNotEmpty ?? false)
            ? artwork!.gallery.first
            : artist?.profileImage;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if (hero != null && hero.isNotEmpty) ...[
              //   HeroImage(height: _isMobile ? 200 : 320, path: hero),
              //   SizedBox(height: 16.sH),
              // ],
              Text(
                artwork?.name ?? artist?.name ?? 'Artwork',
                style: _isMobile
                    ? TextStyleHelper.instance.headline20BoldInter
                    : TextStyleHelper.instance.headline24BoldInter,
              ),
              SizedBox(height: 8.sH),
              AboutTab(
                title: artwork?.name ?? '—',
                about: artwork?.description ?? '—',
                materials: artwork?.materials ?? '—',
                vision: artwork?.vision ?? '—',
                galleryImages: artwork?.gallery ?? const [],
              ),
            ],
          ),
        );

      case 1: // Gallery
        final images = artist?.gallery ?? artwork?.gallery ?? const [];
        return GalleryTab(images: images);

      case 2: // Location
        final lat = artist?.latitude;
        final lon = artist?.longitude;

        return LocationTab(
          title: artist?.name != null
              ? 'Navigate to ${artist!.name}'
              : 'Location',
          subtitle: (() {
            final parts = <String>[];
            if ((artist?.address ?? '').isNotEmpty) parts.add(artist!.address!);
            final cityCountry = [
              artist?.city,
              artist?.country,
            ].where((e) => (e ?? '').isNotEmpty).join(', ');
            if (cityCountry.isNotEmpty) parts.add(cityCountry);
            return parts.isEmpty ? 'Live map & navigation' : parts.join(' • ');
          })(),
          // These two are just initial labels; the widget will compute live values
          distanceLabel: 'Distance',
          destinationLabel: 'Destination',
          addressLine: artist?.address,
          city: artist?.city,
          country: artist?.country,
          latitude: lat,
          longitude: lon,
          onStartNavigation: () {
            // Optional: analytics / toast
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Starting navigation…')),
            );
          },
        );

      case 3: // Chat AI
        return ChatRoute(
          userId: "031af91c-319d-4ef4-bec8-7d14a3d68dde",
          artworkId: artwork!.id.toString(),
          userName: 'AbdelRahman Karawia',
          artwork: artwork, // or null
          artist: artist, // or null
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
                      const Text('Thanks for your feedback!'),
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
                    const SnackBar(content: Text('Artwork not ready yet.')),
                  );
                  return;
                }
                if (isSubmitting) return;

                context.read<FeedbackCubit>().submitFeedback(
                  userId: widget.userId,
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
        border: Border(
          bottom: BorderSide(color: AppColor.gray200, width: 1.sW),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_ios, size: 20.sW),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 24.sW, minHeight: 24.sH),
              ),
              SizedBox(width: 8.sW),
              Expanded(
                child: BlocBuilder<ArtworkCubit, ArtworkState>(
                  builder: (context, state) {
                    final title = state.status == ArtworkStatus.loaded
                        ? (state.artwork?.name ?? 'Artwork Details')
                        : 'Artwork Details';
                    return Text(
                      title,
                      style: TextStyleHelper.instance.headline20BoldInter,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------ Mobile Tab Bar ------------------
class _MobileTabBar extends StatelessWidget {
  const _MobileTabBar({
    required this.selectedIndex,
    required this.onTabSelected,
    required this.categories,
  });

  final int selectedIndex;
  final Function(int) onTabSelected;
  final List<events.CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.sH,
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border(
          bottom: BorderSide(color: AppColor.gray200, width: 1.sW),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.sW),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onTabSelected(index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.sW, vertical: 12.sH),
              margin: EdgeInsets.only(right: 8.sW),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColor.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? AppColor.primaryColor
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  categories[index].title ?? "",
                  style: TextStyleHelper.instance.title14BlackRegularInter
                      .copyWith(
                        color: isSelected
                            ? AppColor.primaryColor
                            : AppColor.gray600,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                ),
              ),
            ),
          );
        },
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
            'Loading artwork...',
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
              'Oops! Something went wrong',
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
              label: const Text('Try Again'),
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
              label: const Text('Go Back'),
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
