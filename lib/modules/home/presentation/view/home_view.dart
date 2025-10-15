import 'package:baseqat/core/responsive/size_utils.dart' hide DeviceType;
import 'package:easy_localization/easy_localization.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/constants_manager.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:baseqat/core/components/alerts/custom_error_page.dart';
import 'package:baseqat/core/components/alerts/custom_snackbar.dart';
import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/artwork_details_tabs_view.dart';
import 'package:baseqat/modules/home/data/datasources/home_remote_data_source.dart';
import 'package:baseqat/modules/home/data/datasources/home_local_data_source.dart';
import 'package:baseqat/modules/home/data/repositories/home_repository_impl.dart';
import 'package:baseqat/modules/home/presentation/manger/home_cubit.dart';
import 'package:baseqat/modules/home/presentation/manger/home_state.dart';
import 'package:baseqat/modules/home/presentation/widgets/about_info_section.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/section_error_banner.dart';
import 'package:baseqat/modules/home/presentation/widgets/footer/footer_section.dart';
import 'package:baseqat/modules/home/presentation/widgets/speakers_section.dart';
import 'package:baseqat/modules/home/presentation/widgets/textline_banner.dart';
import 'package:baseqat/modules/tabs/presentation/manger/tabs_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/components/alerts/custom_loading.dart';
import '../../../../core/resourses/color_manager.dart';
import '../../../artist_details/presentation/view/artist_details_page.dart';
import '../widgets/common/ithra_welcome_section.dart';
import '../widgets/artists/ithra_artists_section.dart';
import '../widgets/artworks/ithra_artworks_section.dart';
import '../widgets/ithra_gallery_section.dart';
import '../widgets/reviews_section.dart';
import '../widgets/ithra_virtual_tour_section.dart';

ErrorType _mapFailureToErrorType(Failure failure) {
  if (failure is OfflineFailure) return ErrorType.noInternet;
  if (failure is TimeoutFailure) return ErrorType.timeout;
  if (failure is NotFoundFailure) return ErrorType.notFound;
  if (failure is NetworkFailure) return ErrorType.network;
  return ErrorType.generic;
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = HomeRepositoryImpl(
      HomeRemoteDataSourceImpl(Supabase.instance.client),
      local: HomeLocalDataSourceImpl(),
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
          if (state is HomeError) {
            context.showErrorSnackBar(
              state.failure.message,
              onRetry: () => context.read<HomeCubit>().loadAll(force: true),
            );
          }

          if (state is HomeLoaded) {
            final msgs = <String>[];
            if (state.artistsError != null) {
              msgs.add(
                '${'home.label_artists'.tr()}: ${state.artistsError!.message}',
              );
            }
            if (state.artworksError != null) {
              msgs.add(
                '${'home.label_artworks'.tr()}: ${state.artworksError!.message}',
              );
            }
            if (state.reviewsError != null) {
              msgs.add(
                '${'home.label_reviews'.tr()}: ${state.reviewsError!.message}',
              );
            }
            if (state.infoError != null) {
              msgs.add(
                '${'home.label_info'.tr()}: ${state.infoError!.message}',
              );
            }
            if (msgs.isNotEmpty) {
              context.showWarningSnackBar(
                msgs.map((msg) => '- ' + msg).join('\n'),
                title: 'common.partial_content_loaded'.tr(),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is HomeInitial || state is HomeLoading) {
            final loadingMessage = state is HomeLoading ? state.message : null;
            return LoadingPage(
              message:
              loadingMessage ?? 'home.curating_experience'.tr(),
              subtitle: 'home.curating_subtitle'.tr(),
            );
          }

          if (state is HomeError) {
            final failure = state.failure;
            return ErrorPage(
              errorType: _mapFailureToErrorType(failure),
              customMessage: failure.message,
              details: failure.cause?.toString(),
              showDetails: failure.cause != null,
              onRetry: () => context.read<HomeCubit>().loadAll(force: true),
              canContactSupport: false,
            );
          }

          final loaded = state as HomeLoaded;

          final info = loaded.info;

          final deviceType = Responsive.deviceTypeOf(context);
          final bool isTablet = deviceType == DeviceType.tablet;
          final bool isDesktop = deviceType == DeviceType.desktop;

          return Scaffold(
            backgroundColor: Colors.white,
            body: LoadingOverlay(
              isLoading: loaded.isRefreshing,
              message: loaded.isRefreshing
                  ? 'home.refreshing_collection'.tr()
                  : null,
              overlayColor: Colors.white.withOpacity(0.85),
              child: RefreshIndicator(
                onRefresh: () =>
                    context.read<HomeCubit>().loadAll(force: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (info != null) ...[
                        IthraWelcomeSection(
                          title: info.mainTitle,
                          subtitle: info.subTitle,
                          titleAr: info.mainTitleAr,
                          highlightsLabel: 'Highlights',
                          highlightsLabelAr: 'المختارات',
                          subtitleAr: info.subTitleAr,
                          images: info.images,
                        ),
                        if (loaded.infoError != null)
                          SectionErrorBanner(
                            message: loaded.infoError!.message,
                            onRetry: () => context.read<HomeCubit>().loadAll(
                              force: true,
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal:
                              isDesktop ? 48.sW : isTablet ? 32.sW : 18.sW,
                              vertical: 12.sH,
                            ),
                          ),
                      ] else ...[
                        if (loaded.isRefreshing)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: LinearProgressIndicator(),
                          ),
                      ],

                      BlocSelector<HomeCubit, HomeState,
                          ({List artists, Object? error, bool refreshing})>(
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
                                SectionErrorBanner(
                                  message: (errSel as dynamic).message,
                                  onRetry: () =>
                                      context.read<HomeCubit>().reloadArtists(),
                                  margin: EdgeInsets.symmetric(
                                    horizontal:
                                    isDesktop ? 48.sW : isTablet ? 32.sW : 18.sW,
                                    vertical: 12.sH,
                                  ),
                                ),
                              IthraArtistsSection(
                                artists: List.from(artistsSel),
                                isLoading: isRefreshingSel,
                                onSeeMore: () {
                                  context.read<TabsCubit>().changeSelectedIndex(1);
                                  context.read<TabsCubit>().changeSelectedSubIndex(1);
                                },
                                onArtistTap: (index) {
                                  navigateTo(
                                    context,
                                    ArtistDetailsPage(
                                      artistId: (artistsSel[index] as dynamic).id,
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),

                      BlocSelector<HomeCubit, HomeState,
                          ({List artworks, Object? error, bool refreshing})>(
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
                                SectionErrorBanner(
                                  message: (errSel as dynamic).message,
                                  onRetry: () =>
                                      context.read<HomeCubit>().reloadArtworks(),
                                  margin: EdgeInsets.symmetric(
                                    horizontal:
                                    isDesktop ? 48.sW : isTablet ? 32.sW : 18.sW,
                                    vertical: 12.sH,
                                  ),
                                ),
                              IthraArtworksSection(
                                artworks: List.from(artworksSel),
                                isLoading: isRefreshingSel,
                                onSeeMore: () {
                                  context.read<TabsCubit>().changeSelectedIndex(1);
                                  context.read<TabsCubit>().changeSelectedSubIndex(0);
                                },
                                onArtworkTap: (index) {
                                  navigateTo(
                                    context,
                                    ArtWorkDetailsScreen(
                                      artworkId:
                                      (artworksSel[index] as dynamic).id,
                                      userId: AppConstants.userIdValue ?? "",
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.0.sH,
                          horizontal: 8.sW,
                        ),
                        child: TextLineBanner(
                          text: 'home.textline_banner'.tr(),
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

                      Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 16.sW,),
                        child: SpeakersSection(
                          onSeeMore: () {
                            context.read<TabsCubit>().changeSelectedIndex(1);
                            context.read<TabsCubit>().changeSelectedSubIndex(2);
                          },
                          onJoinNow: () {
                            context.read<TabsCubit>().changeSelectedIndex(1);
                            context.read<TabsCubit>().changeSelectedSubIndex(2);
                          },
                        ),
                      ),

                      // IthraVirtualTourSection(
                      //   onTryNow: () => context.read<TabsCubit>().changeSelectedIndex(1),
                      //   virtualTourImage: AppAssetsManager.imgImage,
                      //   peopleImage: AppAssetsManager.imgUsers,
                      // ),

                      BlocSelector<HomeCubit, HomeState, List<String>>(
                        selector: (state) {
                          if (state is HomeLoaded && state.info != null) {
                            return state.info!.images;
                          }
                          return const <String>[];
                        },
                        builder: (context, imagesSel) {
                          if (imagesSel.isEmpty) return const SizedBox.shrink();
                          return IthraGallerySection(
                            imageUrls: imagesSel,
                            onSeeMore: () {
                              context.read<TabsCubit>().changeSelectedIndex(1);
                              context.read<TabsCubit>().changeSelectedSubIndex(3);
                            },
                            onImageTap: (index) {
                              // Handle image tap - could open lightbox
                            },
                          );
                        },
                      ),

                      BlocSelector<HomeCubit, HomeState,
                          ({List reviews, Object? error, bool refreshing})>(
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
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (errSel != null)
                                SectionErrorBanner(
                                  message: (errSel as dynamic).message,
                                  onRetry: () => context.read<HomeCubit>().reloadReviews(),
                                  margin: EdgeInsets.symmetric(
                                    horizontal:
                                    isDesktop ? 48.sW : isTablet ? 32.sW : 18.sW,
                                    vertical: 12.sH,
                                  ),
                                ),
                              Reviews(
                                isLoading: isRefreshingSel,
                                reviewsData: List.from(reviewsSel),
                              ),
                            ],
                          );
                        },
                      ),

                      BlocSelector<HomeCubit, HomeState, dynamic>(
                        selector: (state) => state is HomeLoaded ? state.info : null,
                        builder: (context, infoSel) {
                          if (infoSel == null) return const SizedBox.shrink();
                          return AboutInfo(
                            info: infoSel,
                            deviceTypeOverride: deviceType,
                          );
                        },
                      ),

                      // Footer
                      Footer(),
                      Transform.translate(
                        offset: const Offset(0, -1), // remove 1px seam
                        child: Container(
                          color: AppColor.gray900,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 25.sW),
                          child: Image.asset(
                            AppAssetsManager.footerBackground,
                            alignment: Alignment.bottomCenter,
                            fit: BoxFit.cover,
                            // width: double.infinity,
                            // height: deviceType == DeviceType.mobile
                            //     ? 180.sH
                            //     : deviceType == DeviceType.tablet
                            //     ? 260.sH
                            //     : 340.sH,
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
    );
  }
}
