// lib/modules/home/presentation/views/home_view.dart
import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:baseqat/modules/artist_details/presentation/view/artist_details_page.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/artwork_details_tabs_view.dart';
import 'package:baseqat/modules/home/presentation/widgets/about_info_section.dart';
import 'package:baseqat/modules/home/presentation/widgets/artists_section.dart';
import 'package:baseqat/modules/home/presentation/widgets/artworks_section.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/spacing.dart';
import 'package:baseqat/modules/home/presentation/widgets/footer_section.dart';
import 'package:baseqat/modules/home/presentation/widgets/reviews_section.dart';
import 'package:baseqat/modules/tabs/presentation/manger/tabs_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:baseqat/modules/home/presentation/manger/home_cubit.dart';
import 'package:baseqat/modules/home/presentation/manger/home_state.dart';
import 'package:baseqat/modules/home/data/datasources/home_remote_data_source.dart';
import 'package:baseqat/modules/home/data/repositories/home_repository_impl.dart';

import '../widgets/common/app_section_header.dart';
import '../widgets/highlights_section.dart';
import '../widgets/speakers_section.dart';
import '../widgets/gallery_section.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const double _mobileMax = 600;
  static const double _tabletMax = 1024;

  @override
  Widget build(BuildContext context) {
    final repo = HomeRepositoryImpl(
      HomeRemoteDataSourceImpl(Supabase.instance.client),
    );

    return BlocProvider(
      create: (_) => HomeCubit(repo)..loadAll(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeInitial || state is HomeLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is HomeError) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Error: ${state.failure.message}',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final s = state as HomeLoaded;
          final info = s.info;
          final artists = s.artists;
          final artworks = s.artworks;

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isMobile = width <= _mobileMax;
              final isTablet = width > _mobileMax && width <= _tabletMax;
              final isDesktop = width > _tabletMax;

              final horizontalPad = isDesktop
                  ? 48.0
                  : isTablet
                  ? 32.0
                  : 16.0;
              final verticalGap = isDesktop
                  ? 40.0
                  : isTablet
                  ? 32.0
                  : 24.0;

              return Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPad,
                            vertical: isDesktop ? 32 : 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (info != null) ...[
                                // unified header for the hero section as well
                                AppSectionHeader(
                                  title: info.mainTitle,
                                  subtitle: info.subTitle,
                                  maxTextWidthFraction: isDesktop
                                      ? 0.6
                                      : isTablet
                                      ? 0.75
                                      : 0.9,
                                  emphasize:
                                      true, // slightly bigger for the hero, but same component
                                ),
                                vGap(verticalGap),

                                EnhancedHighlightsSection(images: info.images),
                                vGap(verticalGap),
                              ],

                              if (artists.isNotEmpty) ...[
                                ArtistsSection(
                                  artists: artists,
                                  onSeeMore: () {
                                    context.read<TabsCubit>().selectTop(1);
                                  },
                                  seeMoreButtonText: "Explore More",
                                  onArtistTap: (index) {
                                    print('Tapped artist at index $index');
                                    print(
                                      'Artist details: ${artists[index].name}, ${artists[index].id}',
                                    );
                                    navigateTo(
                                      context,
                                      ArtistDetailsPage(
                                        artistId: artists[index].id,
                                      ),
                                    );
                                  },
                                ),
                                vGap(verticalGap),
                              ],

                              if (artworks.isNotEmpty) ...[
                                ArtworksSection(
                                  artworks: artworks,
                                  showSeeMoreButton: true,
                                  seeMoreButtonText: "Explore More",
                                  onSeeMore: () {
                                    context.read<TabsCubit>().selectTop(1);
                                  },
                                  onCardTap: (index) {
                                    print('Tapped artwork at index $index');
                                    navigateTo(
                                      context,
                                      ArtWorkDetailsScreen(
                                        artworkId: artworks[index].id,
                                        userId:
                                            "d0030cf6-3830-47e8-9ca4-a2d00d51427a",
                                        onBack: () => Navigator.pop(context),
                                      ),
                                    );
                                  },
                                ),
                                vGap(verticalGap),
                              ],

                              // Speakers
                              AppSectionHeader(title: 'Speakers'),
                              vGap(16),
                              SpeakersSection(
                                isMobile: isMobile,
                                isTablet: isTablet,
                                isDesktop: isDesktop,
                                // Pass any dynamic text/images here if you have them
                                pitch:
                                    'A lineup of 300+ voices from industry leaders',
                                description:
                                    'Meet a selection of experts and professionals sharing their knowledge and success stories in the world of dates and palm cultivation during the exhibition.',
                              ),
                              vGap(verticalGap),

                              // Virtual Tour (kept as-is but you can wrap its internal title with AppSectionHeader)
                              // VirtualTour(isMobile: isMobile, isTablet: isTablet, isDesktop: isDesktop),
                              vGap(isMobile ? 16 : 24),

                              if (info != null) ...[
                                ResponsiveGallery(
                                  title: 'Gallery',
                                  seeMoreText: 'View All',
                                  onSeeMore: () {},
                                  imageUrls: info.images,
                                  isMobile: isMobile,
                                  isTablet: isTablet,
                                  isDesktop: isDesktop,
                                ),
                              ],

                              vGap(verticalGap),
                            ],
                          ),
                        ),

                        Reviews(isMobile: isMobile, isTablet: isTablet),

                        if (info != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AboutInfo(
                              info: info,
                              isMobile: isMobile,
                              isTablet: isTablet,
                              isDesktop: isDesktop,
                            ),
                          ),

                        Footer(isMobile: isMobile),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
