import 'package:baseqat/core/components/alerts/custom_loading.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/programs/data/datasources/events_remote_data_source.dart';
import 'package:baseqat/modules/programs/data/models/gallery_item.dart';
import 'package:baseqat/modules/programs/data/models/month_data.dart';
import 'package:baseqat/modules/programs/data/repositories/events/events_repository.dart';
import 'package:baseqat/modules/programs/data/repositories/events/events_repository_impl.dart';
import 'package:baseqat/modules/programs/presentation/manger/events/events_cubit.dart';
import 'package:baseqat/modules/programs/presentation/manger/events/events_state.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:baseqat/modules/programs/presentation/view/tabs/art_works_tab.dart';
import 'package:baseqat/modules/programs/presentation/view/tabs/artist_tab.dart';
import 'package:baseqat/modules/programs/presentation/view/tabs/gallery_tav_tab.dart';
import 'package:baseqat/modules/programs/presentation/view/tabs/speakers_tab.dart';
import 'package:baseqat/modules/programs/presentation/view/tabs/virtual_tour_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsMobileTabletView extends StatelessWidget {
  const EventsMobileTabletView({
    super.key,
    EventsRepository? repository,
  }) : _repository = repository;

  final EventsRepository? _repository;

  EventsRepository _resolveRepository() {
    final repo = _repository;
    if (repo != null) return repo;
    final client = Supabase.instance.client;
    return EventsRepositoryImpl(EventsRemoteDataSourceImpl(client));
  }

  @override
  Widget build(BuildContext context) {
    print("-----------");
    return BlocProvider<EventsCubit>(
      create: (_) => EventsCubit(_resolveRepository())..loadHome(limit: 10),
      child: const _EventsView(),
    );
  }
}

enum ProgramsTab {
  artworks('programs.tabs.artworks', Icons.palette_outlined),
  artists('programs.tabs.artists', Icons.people_alt_outlined),
  schedule('programs.tabs.schedule', Icons.event_available_outlined),
  gallery('programs.tabs.gallery', Icons.photo_library_outlined),
  virtualTour('programs.tabs.virtual_tour', Icons.explore_outlined);

  const ProgramsTab(this.labelKey, this.icon);
  final String labelKey;
  final IconData icon;
}

class _EventsView extends StatefulWidget {
  const _EventsView();

  @override
  State<_EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<_EventsView> {
  final TextEditingController _searchController = TextEditingController();
  ProgramsTab _tab = ProgramsTab.artworks;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        return Container(
          color: AppColor.white,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: ProgramsLayout.pagePadding(context),
                  child: Column(
                    children: [
                      _ProgramsHeader(
                        controller: _searchController,
                        onChanged: context.read<EventsCubit>().setSearchQuery,
                      ),
                      SizedBox(height: ProgramsLayout.spacingLarge(context)),
                      _ProgramsTabBar(
                        selected: _tab,
                        onSelected: (tab) => setState(() => _tab = tab),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ProgramsLayout.spacingMedium(context)),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _buildBody(_tab),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(ProgramsTab tab) {
    switch (tab) {
      case ProgramsTab.artworks:
        return const _ArtworksSection();
      case ProgramsTab.artists:
        return const _ArtistsSection();
      case ProgramsTab.schedule:
        return const _ScheduleSection();
      case ProgramsTab.gallery:
        return const _GallerySection();
      case ProgramsTab.virtualTour:
        return const _VirtualTourSection();
    }
  }
}

class _ProgramsHeader extends StatelessWidget {
  const _ProgramsHeader({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'programs.header.title'.tr(),
              style: ProgramsTypography.headingLarge(context)
                  .copyWith(color: AppColor.black),
            ),
            SizedBox(width: ProgramsLayout.spacingSmall(context)),

        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.gray50,
              borderRadius:
                  BorderRadius.circular(ProgramsLayout.radius20(context)),
              border: Border.all(color: AppColor.gray200),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: ProgramsLayout.pagePadding(context).left * 0.25,
            ),
            child: TextField(
            
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'programs.header.search_placeholder'.tr(),
                hintStyle: ProgramsTypography.bodySecondary(context)
                    .copyWith(color: AppColor.gray500),
                border: InputBorder.none,
                icon: Image.asset(
                  AppAssetsManager.imgSearch,
                  width: ProgramsLayout.size(context, 20),
                  height: ProgramsLayout.size(context, 25),
                  color: AppColor.gray500,
                ),
              ),
            ),
          ),
        ),
               ],
        ),
        SizedBox(height: ProgramsLayout.spacingLarge(context)), ],
    );
  }
}

class _ProgramsTabBar extends StatelessWidget {
  const _ProgramsTabBar({required this.selected, required this.onSelected});

  final ProgramsTab selected;
  final ValueChanged<ProgramsTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ProgramsTab.values
            .map((tab) => Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: ProgramsLayout.spacingMedium(context),
                  ),
                  child: _TabChip(
                    label: tab.labelKey.tr(),
                    icon: tab.icon,
                    isSelected: tab == selected,
                    onTap: () => onSelected(tab),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColor.primaryColor : AppColor.gray100,
      borderRadius: BorderRadius.circular(ProgramsLayout.radius20(context)),
      child: InkWell(
        borderRadius: BorderRadius.circular(ProgramsLayout.radius20(context)),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ProgramsLayout.size(context, 18),
            vertical: ProgramsLayout.spacingMedium(context),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: ProgramsLayout.size(context, 18),
                color: isSelected ? AppColor.white : AppColor.gray600,
              ),
              SizedBox(width: ProgramsLayout.spacingSmall(context)),
              Text(
                label,
                style: ProgramsTypography.bodyPrimary(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColor.white : AppColor.gray600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Generic Section Widget
class _DataSection<T> extends StatelessWidget {
  const _DataSection({
    required this.selector,
    required this.builder,
    required this.onRetry,
    required this.errorKey,
  });

  final _SliceData<T> Function(EventsState) selector;
  final Widget Function(BuildContext, List<T>) builder;
  final VoidCallback onRetry;
  final String errorKey;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<EventsCubit, EventsState, _SliceData<T>>(
      selector: selector,
      builder: (context, slice) {
        if (slice.status == SliceStatus.error) {
          return _InlineError(
            title: slice.errorMessage ?? errorKey.tr(),
            onRetry: onRetry,
          );
        }
        return builder(context, slice.items);
      },
    );
  }
}

class _ArtworksSection extends StatelessWidget {
  const _ArtworksSection();

  @override
  Widget build(BuildContext context) {
    return _DataSection<Artwork>(
      selector: (state) => _SliceData(
        items: state.artworks,
        status: state.artworksStatus,
        errorMessage: state.artworksError,
      ),
      errorKey: 'programs.errors.artworks',
      onRetry: () =>
          context.read<EventsCubit>().loadArtworks(limit: 10, force: true),
      builder: (context, artworks) => ArtWorksGalleryContent(
        artworks: artworks,
        languageCode: context.locale.languageCode,
      ),
    );
  }
}

class _ArtistsSection extends StatelessWidget {
  const _ArtistsSection();

  @override
  Widget build(BuildContext context) {
    return _DataSection<Artist>(
      selector: (state) => _SliceData(
        items: state.artists,
        status: state.artistsStatus,
        errorMessage: state.artistsError,
      ),
      errorKey: 'programs.errors.artists',
      onRetry: () =>
          context.read<EventsCubit>().loadArtists(limit: 10, force: true),
      builder: (context, artists) => ArtistTabContent(
        artists: artists,
        languageCode: context.locale.languageCode,
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        final hasError =
            state.speakersError != null || state.workshopsError != null;

        if (hasError) {
          return _InlineError(
            title: state.speakersError ??
                state.workshopsError ??
                'programs.errors.schedule'.tr(),
            onRetry: () {
              context.read<EventsCubit>().loadSpeakers(limit: 10, force: true);
              context.read<EventsCubit>().loadWorkshops(limit: 10, force: true);
            },
          );
        }

        return MonthWidget(
          builder: (context, data) {
            return SpeakersWorkshopsTabContent(
              headerTitle: 'programs.schedule.header'.tr(),
              monthLabel: data.monthLabel,
              currentMonth: data.currentMonth,
              speakers: state.speakers,
              workshops: state.workshops,
              languageCode: context.locale.languageCode,
              ctaSubtitle: 'programs.schedule.cta_subtitle'.tr(),
              ctaTitle: 'programs.schedule.cta_title'.tr(),
              onNextMonth: data.nextMonth,
              onPrevMonth: data.prevMonth,
            );
          },
        );
      },
    );
  }
}

class _GallerySection extends StatelessWidget {
  const _GallerySection();

  @override
  Widget build(BuildContext context) {
    return _DataSection<GalleryItem>(
      selector: (state) => _SliceData(
        items: state.gallery,
        status: state.galleryStatus,
        errorMessage: state.galleryError,
      ),
      errorKey: 'programs.errors.gallery',
      onRetry: () => context
          .read<EventsCubit>()
          .loadGallery(limitArtists: 10, force: true),
      builder: (context, gallery) => GalleryGrid(items: gallery, onTap: (_) {}),
    );
  }
}

class _VirtualTourSection extends StatelessWidget {
  const _VirtualTourSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ProgramsLayout.pagePadding(context),
      child: const VirtualTourView(),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.title, required this.onRetry});

  final String title;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: ProgramsLayout.sectionPadding(context),
        padding: EdgeInsets.all(ProgramsLayout.size(context, 20)),
        decoration: BoxDecoration(
          color: AppColor.gray50,
          borderRadius:
              BorderRadius.circular(ProgramsLayout.radius16(context)),
          border: Border.all(color: AppColor.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColor.gray700,
              size: ProgramsLayout.size(context, 36),
            ),
            SizedBox(height: ProgramsLayout.spacingLarge(context)),
            Text(
              title,
              style: ProgramsTypography.headingMedium(context)
                  .copyWith(color: AppColor.gray900),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ProgramsLayout.spacingMedium(context)),
            OutlinedButton(
              onPressed: onRetry,
              child: Text('programs.actions.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliceData<T> {
  const _SliceData({
    required this.items,
    required this.status,
    required this.errorMessage,
  });

  final List<T> items;
  final SliceStatus status;
  final String? errorMessage;
}