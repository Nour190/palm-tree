import 'package:baseqat/core/components/custom_widgets/custom_top_bar.dart';
import 'package:baseqat/modules/artwork_details/data/datasources/artwork_details_remote_data_source.dart';
import 'package:baseqat/modules/artwork_details/data/repositories/artwork_repository.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/manger/artist/artist_states.dart';

// Cubits
import 'package:baseqat/modules/artwork_details/presentation/view/manger/artwork/artwork_cubit.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/manger/artwork/artwork_state.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/manger/artist/artist_cubit.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/manger/chat/chat_cubit.dart';

// ✅ Feedback cubit/states
import 'package:baseqat/modules/artwork_details/presentation/view/manger/feedback/feedback_cubit.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/manger/feedback/feedback_states.dart';

import 'package:baseqat/modules/artwork_details/presentation/view/tabs/feedback_tab.dart';
import 'package:baseqat/modules/tabs/presentation/manger/tabs_cubit.dart';
import 'package:baseqat/modules/tabs/presentation/manger/tabs_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';

// Tabs
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/about_tab.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/gallery_tab.dart';

// Widgets
import 'package:baseqat/modules/artwork_details/presentation/widgets/header_title.dart';
import 'package:baseqat/modules/artwork_details/presentation/widgets/hero_image.dart';
import 'package:baseqat/modules/artwork_details/presentation/widgets/category_chips.dart';

// Location helper
import 'package:baseqat/core/location/location_service.dart';

class ArtWorkDetailsScreen extends StatefulWidget {
  const ArtWorkDetailsScreen({
    super.key,
    required this.artworkId,
    required this.userId,
    this.initialTabIndex = 0,
    this.showBack = true,
    this.onBack,
  });

  final String artworkId;
  final String userId;
  final int initialTabIndex;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  State<ArtWorkDetailsScreen> createState() => _ArtistDetailsScreenState();
}

class _ArtistDetailsScreenState extends State<ArtWorkDetailsScreen> {
  int _selectedTabIndex = 0;

  // Distance state
  double? _distanceKm;
  String? _distanceError;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
  }

  void _goToTab(int i) => setState(() => _selectedTabIndex = i);

  Future<void> _computeDistanceIfPossible({required Artist? artist}) async {
    _distanceKm = null;
    _distanceError = null;

    final lat = artist?.latitude;
    final lon = artist?.longitude;
    if (lat == null || lon == null) {
      setState(() {
        _distanceError = 'Destination coordinates unavailable';
      });
      return;
    }

    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos == null) {
        setState(() {
          _distanceError = 'Location permission denied or service off';
        });
        return;
      }
      final km = LocationService.distanceKm(
        startLat: pos.latitude,
        startLon: pos.longitude,
        endLat: lat,
        endLon: lon,
      );
      setState(() => _distanceKm = km);
    } catch (e) {
      setState(() => _distanceError = 'Failed to get location: $e');
    }
  }

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
        BlocProvider<ChatCubit>(create: (_) => ChatCubit(repo)),
        // ✅ Provide FeedbackCubit here so Feedback tab can use it
        BlocProvider<FeedbackCubit>(create: (_) => FeedbackCubit(repo)),
      ],
      child: Sizer(
        builder: (context, orientation, _) {
          final w = SizeUtils.width;
          final bool isDesktop = w >= 1200;
          final bool isTablet = w >= 840 && w < 1200;
          final bool sideBySide = w >= 840;

          final double padH = isDesktop ? 64.h : (isTablet ? 32.h : 16.h);
          final double heroHeight = isDesktop ? 340 : 304;

          return Scaffold(
            backgroundColor: AppColor.backgroundWhite,
            body: SafeArea(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1500),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: padH,
                    vertical: 32.h,
                  ),
                  child: MultiBlocListener(
                    listeners: [
                      // When artwork loads, fetch artist
                      BlocListener<ArtworkCubit, ArtworkState>(
                        listenWhen: (p, c) =>
                            p.status != ArtworkStatus.loaded &&
                            c.status == ArtworkStatus.loaded,
                        listener: (context, state) {
                          final artistId = state.artwork?.artistId;
                          if (artistId != null && artistId.isNotEmpty) {
                            context.read<ArtistCubit>().getArtistById(artistId);
                          }
                        },
                      ),
                      // When artist loads, compute distance
                      BlocListener<ArtistCubit, ArtistState>(
                        listenWhen: (p, c) =>
                            p.artist?.id != c.artist?.id &&
                            c.status == ArtistStatus.loaded,
                        listener: (context, state) {
                          _computeDistanceIfPossible(artist: state.artist);
                        },
                      ),
                    ],
                    child: BlocBuilder<ArtworkCubit, ArtworkState>(
                      builder: (context, artState) {
                        if (artState.status == ArtworkStatus.idle ||
                            artState.status == ArtworkStatus.loading) {
                          return _loading();
                        }

                        if (artState.status == ArtworkStatus.error &&
                            (artState.error ?? '').isNotEmpty) {
                          return _error(artState.error!, () {
                            context.read<ArtworkCubit>().getArtworkById(
                              widget.artworkId,
                            );
                          });
                        }

                        final artwork = artState.artwork;

                        return BlocBuilder<ArtistCubit, ArtistState>(
                          builder: (context, artistState) {
                            final artist = artistState.artist;

                            final title =
                                artwork?.name ?? artist?.name ?? 'Artwork';
                            final hero = (artwork?.gallery.isNotEmpty ?? false)
                                ? artwork!.gallery.first
                                : artist?.profileImage;

                            // Removed "Location" tab; chips are now: About, Gallery, Chat Ai, Feedback
                            final chips = const [
                              'About',
                              'Gallery',
                              'Chat Ai',
                              'Feedback',
                            ];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (sideBySide)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: isDesktop ? 5 : 6,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            HeaderTitle(
                                              title: title,
                                              showBack: false,
                                            ),
                                            SizedBox(height: 16.h),
                                            CategoryChipsAdaptive(
                                              items: chips,
                                              selectedIndex: _selectedTabIndex,
                                              onSelected: _goToTab,
                                              centerWhenFits: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 24.h),
                                      Expanded(
                                        flex: isDesktop ? 7 : 7,
                                        child: HeroImage(
                                          height: heroHeight,
                                          path: hero,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      HeaderTitle(
                                        title: title,
                                        showBack: widget.showBack,
                                        onBack: widget.onBack,
                                      ),
                                      SizedBox(height: 16.h),
                                      HeroImage(height: heroHeight, path: hero),
                                      SizedBox(height: 16.h),
                                      CategoryChipsAdaptive(
                                        items: chips,
                                        selectedIndex: _selectedTabIndex,
                                        onSelected: _goToTab,
                                      ),
                                    ],
                                  ),
                                SizedBox(height: isDesktop ? 24.h : 20.h),

                                // Tabs (without Location tab). Location data is shown in About section via LocationInfoCard.
                                _buildTab(
                                  index: _selectedTabIndex,
                                  userId: widget.userId,
                                  artwork: artwork,
                                  artist: artist,
                                ),

                                SizedBox(height: isDesktop ? 40.h : 32.h),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required String userId,
    Artwork? artwork,
    Artist? artist,
  }) {
    switch (index) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AboutTab(
              title: artwork?.name ?? '—',
              about: artwork?.description ?? '—',
              materials: artwork?.materials ?? '—',
              vision: artwork?.vision ?? '—',
              galleryImages: artwork?.gallery ?? const [],
            ),
          ],
        );
      case 1:
        return GalleryTab(
          images: artist?.gallery ?? artwork?.gallery ?? const [],
        );
      case 2:
        return const SizedBox.shrink();
      case 3:
        // ✅ Feedback tab powered by FeedbackCubit
        final Set<String> preselected = {};
        return BlocConsumer<FeedbackCubit, FeedbackState>(
          listenWhen: (p, c) => p.status != c.status || p.error != c.error,
          listener: (context, state) {
            if (state.status == FeedbackStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thanks for your feedback!')),
              );
              context.read<FeedbackCubit>().reset();
            } else if (state.status == FeedbackStatus.error &&
                (state.error ?? '').isNotEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
          builder: (context, state) {
            // Optionally gate the button in your FeedbackTab (if it supports it).
            final isSubmitting = state.status == FeedbackStatus.submitting;

            return FeedbackTab(
              initialRating: 4,
              initialMessage: '',
              preselected: preselected,
              // If FeedbackTab exposes an `isSubmitting` or `enabled` prop, pass it here.
              // isSubmitting: isSubmitting, // <-- uncomment if available
              onSubmit: (rating, message, tags) async {
                final id = artwork?.id ?? '';
                if (id.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Artwork not ready yet.')),
                  );
                  return;
                }
                if (isSubmitting) return;

                context.read<FeedbackCubit>().submitFeedback(
                  userId: userId,
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

  Widget _loading() => Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 64.h),
      child: const CircularProgressIndicator(),
    ),
  );

  Widget _error(String message, VoidCallback onRetry) => Padding(
    padding: EdgeInsets.all(16.h),
    child: Column(
      children: [
        const Icon(Icons.error_outline, color: Colors.red),
        SizedBox(height: 8.h),
        Text(message, textAlign: TextAlign.center),
        SizedBox(height: 8.h),
        ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
