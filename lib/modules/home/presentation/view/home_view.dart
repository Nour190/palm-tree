// lib/modules/home/presentation/views/home_view.dart
import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:baseqat/modules/artist_details/presentation/view/artist_details_page.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/artwork_details_tabs_view.dart';
import 'package:baseqat/modules/home/data/datasources/home_remote_data_source.dart';
import 'package:baseqat/modules/home/data/repositories/home_repository_impl.dart';
import 'package:baseqat/modules/home/presentation/manger/home_cubit.dart';
import 'package:baseqat/modules/home/presentation/manger/home_state.dart';
import 'package:baseqat/modules/home/presentation/widgets/about_info_section.dart';
import 'package:baseqat/modules/home/presentation/widgets/artists_section.dart';
import 'package:baseqat/modules/home/presentation/widgets/artworks_section.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/app_section_header.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/section_header_with_highlights.dart';
import 'package:baseqat/modules/home/presentation/widgets/footer_section.dart';
import 'package:baseqat/modules/home/presentation/widgets/gallery_section.dart';
import 'package:baseqat/modules/home/presentation/widgets/reviews_section.dart';
import 'package:baseqat/modules/home/presentation/widgets/speakers_section.dart';
import 'package:baseqat/modules/home/presentation/widgets/textline_banner.dart';
import 'package:baseqat/modules/home/presentation/widgets/home_skeleton.dart';
import 'package:baseqat/modules/tabs/presentation/manger/tabs_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Optional small helper
Widget _errorRow({required String message, required VoidCallback onRetry}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.redAccent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Colors.redAccent),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    ),
  );
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = HomeRepositoryImpl(
      HomeRemoteDataSourceImpl(Supabase.instance.client),
    );

    return BlocProvider(
      create: (_) => HomeCubit(repo)..loadAll(),
      child: BlocConsumer<HomeCubit, HomeState>(
        listenWhen: (prev, curr) =>
            curr is HomeError ||
            (curr is HomeLoaded &&
                (curr.artistsError != null ||
                    curr.artworksError != null ||
                    curr.reviewsError != null ||
                    curr.infoError != null)),
        listener: (context, state) {
          // Show lightweight snackbars for section-level failures without killing the whole page
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          if (state is HomeLoaded) {
            final msgs = <String>[];
            if (state.artistsError != null) {
              msgs.add('Artists: ${state.artistsError!.message}');
            }
            if (state.artworksError != null) {
              msgs.add('Artworks: ${state.artworksError!.message}');
            }
            if (state.reviewsError != null) {
              msgs.add('Reviews: ${state.reviewsError!.message}');
            }
            if (state.infoError != null) {
              msgs.add('Info: ${state.infoError!.message}');
            }
            if (msgs.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msgs.join(' | ')),
                  backgroundColor: Colors.orange.shade700,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          // Initial or first hard load → full screen spinner
          if (state is HomeInitial ||
              (state is HomeLoading &&
                  !(state.message?.contains('Refreshing') ?? false))) {
            return const HomeSkeleton();
          }

          // Fatal top-level error with no data at all
          if (state is HomeError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 36,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.failure.message,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<HomeCubit>().loadAll(force: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Loaded or refreshing with last-good-data
          final loaded = state as HomeLoaded;

          final info = loaded.info;
          final artists = loaded.artists;
          final artworks = loaded.artworks;
          final reviews = loaded.reviews;

          final deviceType = Responsive.deviceTypeOf(context);
          final bool isTablet = deviceType == DeviceType.tablet;
          final bool isDesktop = deviceType == DeviceType.desktop;

          final double horizontalPad = isDesktop
              ? 48.sW
              : isTablet
              ? 32.sW
              : 18.sW;
          final double topPad = isDesktop
              ? 40.sH
              : isTablet
              ? 32.sH
              : 24.sH;
          final double sectionGap = isDesktop
              ? 40.sH
              : isTablet
              ? 32.sH
              : 24.sH;
          final double blockGap = isDesktop
              ? 32.sH
              : isTablet
              ? 28.sH
              : 24.sH;

          return Scaffold(
            backgroundColor: Colors.white,
            // Small top bar to indicate background refresh in progress
            appBar: loaded.isRefreshing
                ? AppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    toolbarHeight: 6,
                    bottom: const PreferredSize(
                      preferredSize: Size.fromHeight(2),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  )
                : null,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => context.read<HomeCubit>().loadAll(force: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header + Highlights
                      if (info != null) ...[
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPad,
                            topPad,
                            horizontalPad,
                            12,
                          ),
                          child: SectionHeaderWithHighlights(
                            title: info.mainTitle,
                            subtitle: info.subTitle,
                            images: info.images,
                            sectionGap: sectionGap,
                            emphasize: true,
                            webRowMinWidth: 900.0,
                          ),
                        ),
                        if (loaded.infoError != null)
                          _errorRow(
                            message: loaded.infoError!.message,
                            onRetry: () =>
                                context.read<HomeCubit>().loadAll(force: true),
                          ),
                        SizedBox(height: sectionGap),
                      ] else ...[
                        // If no info yet but we’re refreshing, show lightweight placeholder
                        if (loaded.isRefreshing)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: LinearProgressIndicator(),
                          ),
                      ],

                      // Artists Section (selective rebuild)
                      BlocSelector<
                        HomeCubit,
                        HomeState,
                        ({List artists, Object? error, bool refreshing})
                      >(
                        selector: (state) {
                          if (state is HomeLoaded) {
                            return (
                              artists: state.artists,
                              error: state.artistsError,
                              refreshing: state.isRefreshingArtists,
                            );
                          }
                          return (
                            artists: const <dynamic>[],
                            error: null,
                            refreshing: false,
                          );
                        },
                        builder: (context, sel) {
                          final artistsSel = sel.artists;
                          final errSel = sel.error;
                          final isRefreshingSel = sel.refreshing;
                          if (artistsSel.isEmpty && errSel == null) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (errSel != null)
                                _errorRow(
                                  message: (errSel as dynamic).message,
                                  onRetry: () =>
                                      context.read<HomeCubit>().reloadArtists(),
                                ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPad,
                                  vertical: 12,
                                ),
                                child: ArtistsSection(
                                  artists: List.from(artistsSel),
                                  isLoading: isRefreshingSel,
                                  onSeeMore: () =>
                                      context.read<TabsCubit>()
                                          .changeSelectedIndex(1),
                                  //.selectTop(1),
                                  seeMoreButtonText: 'Explore More',
                                  onArtistTap: (index) {
                                    navigateTo(
                                      context,
                                      ArtistDetailsPage(
                                        artistId:
                                            (artistsSel[index] as dynamic).id,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: sectionGap),
                            ],
                          );
                        },
                      ),

                      // Artworks Section (selective rebuild)
                      BlocSelector<
                        HomeCubit,
                        HomeState,
                        ({List artworks, Object? error, bool refreshing})
                      >(
                        selector: (state) {
                          if (state is HomeLoaded) {
                            return (
                              artworks: state.artworks,
                              error: state.artworksError,
                              refreshing: state.isRefreshingArtworks,
                            );
                          }
                          return (
                            artworks: const <dynamic>[],
                            error: null,
                            refreshing: false,
                          );
                        },
                        builder: (context, sel) {
                          final artworksSel = sel.artworks;
                          final errSel = sel.error;
                          final isRefreshingSel = sel.refreshing;
                          if (artworksSel.isEmpty && errSel == null) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (errSel != null)
                                _errorRow(
                                  message: (errSel as dynamic).message,
                                  onRetry: () => context
                                      .read<HomeCubit>()
                                      .reloadArtworks(),
                                ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPad,
                                  vertical: 12,
                                ),
                                child: ArtworksSection(
                                  artworks: List.from(artworksSel),
                                  isLoading: isRefreshingSel,
                                  showSeeMoreButton: true,
                                  seeMoreButtonText: 'Explore More',
                                  onSeeMore: () =>
                                      context.read<TabsCubit>()
                                      .changeSelectedIndex(1),
                                          //.selectTop(1),
                                  onCardTap: (index) {
                                    navigateTo(
                                      context,
                                      ArtWorkDetailsScreen(
                                        artworkId:
                                            (artworksSel[index] as dynamic).id,
                                        userId:
                                            'd0030cf6-3830-47e8-9ca4-a2d00d51427a',
                                        //onBack: () => Navigator.pop(context),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: sectionGap),
                            ],
                          );
                        },
                      ),

                      // Speakers
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPad,
                        ),
                        child: const AppSectionHeader(title: 'Speakers'),
                      ),
                      SizedBox(height: 16.sH),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPad,
                        ),
                        child: SpeakersSection(
                          onSeeMore: () =>
                              context.read<TabsCubit>()
                                  .changeSelectedIndex(1),
                                  //.selectTop(1),
                          onJoinNow: () =>
                              context.read<TabsCubit>()
                                  .changeSelectedIndex(1),
                                  //.selectTop(1),
                          sideImagePath: AppAssetsManager.imgInfo,
                          topEmblemPath: AppAssetsManager.imgVectorWhiteA700,
                          leftEmblemPath: AppAssetsManager.imgGroup,
                          badgeAssetPaths: [
                            AppAssetsManager.imgVectorWhiteA70050x66,
                            AppAssetsManager.imgVectorWhiteA70050x66,
                            AppAssetsManager.imgVectorWhiteA70050x66,
                            AppAssetsManager.imgVectorWhiteA70050x66,
                          ],
                        ),
                      ),
                      SizedBox(height: blockGap),
                      // Fancy banner
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: TextLineBanner(
                          text: 'FINEST DATES  *  YOUR DATE WITH THE  *',
                          enableMarquee: true,
                          speed: 50.0,
                          gap: 50.0,
                          height: 80.0.sH,
                          backgroundColor: Colors.black,
                          showGlow: true,
                          showShimmer: true,
                          showEntryAnimation: true,
                        ),
                      ),
                      SizedBox(height: blockGap),

                      // Gallery (selective rebuild)
                      BlocSelector<HomeCubit, HomeState, List<String>>(
                        selector: (state) {
                          if (state is HomeLoaded && state.info != null) {
                            return state.info!.images;
                          }
                          return const <String>[];
                        },
                        builder: (context, imagesSel) {
                          if (imagesSel.isEmpty) return const SizedBox.shrink();
                          return Column(
                            children: [
                              ResponsiveGallery(
                                title: 'Gallery',
                                onSeeMore: () =>
                                    context.read<TabsCubit>()
                                        .changeSelectedIndex(1),
                                        //.selectTop(1),
                                imageUrls: imagesSel,
                              ),
                              SizedBox(height: sectionGap),
                            ],
                          );
                        },
                      ),

                      // Reviews (selective rebuild)
                      BlocSelector<
                        HomeCubit,
                        HomeState,
                        ({List reviews, Object? error, bool refreshing})
                      >(
                        selector: (state) {
                          if (state is HomeLoaded) {
                            return (
                              reviews: state.reviews,
                              error: state.reviewsError,
                              refreshing: state.isRefreshingReviews,
                            );
                          }
                          return (
                            reviews: const <dynamic>[],
                            error: null,
                            refreshing: false,
                          );
                        },
                        builder: (context, sel) {
                          final reviewsSel = sel.reviews;
                          final errSel = sel.error;
                          final isRefreshingSel = sel.refreshing;
                          if (reviewsSel.isEmpty && errSel == null) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (errSel != null)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPad,
                                  ),
                                  child: _errorRow(
                                    message: (errSel as dynamic).message,
                                    onRetry: () => context
                                        .read<HomeCubit>()
                                        .reloadReviews(),
                                  ),
                                ),
                              Reviews(
                                reviewsData: List.from(reviewsSel),
                                isLoading: isRefreshingSel,
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: sectionGap),

                      // About (selective rebuild)
                      BlocSelector<HomeCubit, HomeState, dynamic>(
                        selector: (state) =>
                            state is HomeLoaded ? state.info : null,
                        builder: (context, infoSel) {
                          if (infoSel == null) return const SizedBox.shrink();
                          return AboutInfo(
                            info: infoSel,
                            deviceTypeOverride: deviceType,
                          );
                        },
                      ),

                      // Footer
                      const Footer(),
                    ],
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
