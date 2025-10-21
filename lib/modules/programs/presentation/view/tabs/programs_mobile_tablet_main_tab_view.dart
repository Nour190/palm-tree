import 'package:baseqat/core/components/alerts/custom_loading.dart';
import 'package:baseqat/core/components/connectivity/offline_indicator.dart';
import 'package:baseqat/core/database/image_cache_service.dart';
import 'package:baseqat/core/network/connectivity_service.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/programs/data/datasources/events_local_data_source.dart';
import 'package:baseqat/modules/programs/data/datasources/events_remote_data_source.dart';
import 'package:baseqat/modules/programs/data/datasources/museums_local_data_source.dart';
import 'package:baseqat/modules/programs/data/datasources/museums_remote_data_source.dart';
import 'package:baseqat/modules/programs/data/models/gallery_item.dart';
import 'package:baseqat/modules/programs/data/models/month_data.dart';
import 'package:baseqat/modules/programs/data/repositories/events/events_repository.dart';
import 'package:baseqat/modules/programs/data/repositories/events/events_repository_impl.dart';
import 'package:baseqat/modules/programs/data/repositories/museums/museums_repository.dart';
import 'package:baseqat/modules/programs/data/repositories/museums/museums_repository_impl.dart';
import 'package:baseqat/modules/programs/presentation/manger/events/events_cubit.dart';
import 'package:baseqat/modules/programs/presentation/manger/events/events_state.dart' as events_state;
import 'package:baseqat/modules/programs/presentation/manger/museums/museums_cubit.dart';
import 'package:baseqat/modules/programs/presentation/manger/museums/museums_state.dart' as museums_state;
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:baseqat/modules/programs/presentation/view/tabs/art_works_tab.dart';
import 'package:baseqat/modules/programs/presentation/view/tabs/artist_tab.dart';
import 'package:baseqat/modules/programs/presentation/view/tabs/events_tab.dart';
import 'package:baseqat/modules/programs/presentation/view/tabs/gallery_tav_tab.dart';
import 'package:baseqat/modules/programs/presentation/view/tabs/museum_tab.dart';
import 'package:baseqat/modules/programs/presentation/view/tabs/speakers_tab.dart';
import 'package:baseqat/modules/programs/presentation/view/tabs/virtual_tour_tab.dart';
import 'package:baseqat/modules/tabs/presentation/manger/tabs_cubit.dart';
import 'package:baseqat/modules/tabs/presentation/manger/tabs_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/resourses/style_manager.dart';
import '../../../../../core/utils/rtl_helper.dart';
import '../../../../home/data/models/event_model.dart';
import '../../../../home/data/models/museum_model.dart';
import '../../../../home/data/models/speaker_model.dart';
import '../../../../home/data/models/workshop_model.dart';
import '../more_details_views_tabs/speakers_info_view.dart';
import '../more_details_views_tabs/workshop_info_view.dart';

class EventsMobileTabletView extends StatelessWidget {
  const EventsMobileTabletView({super.key, EventsRepository? repository})
      : _repository = repository;

  final EventsRepository? _repository;

  EventsRepository _resolveRepository() {
    final repo = _repository;
    if (repo != null) return repo;
    final client = Supabase.instance.client;
    return EventsRepositoryImpl(
      EventsRemoteDataSourceImpl(client),
      EventsLocalDataSourceImpl(),
      ConnectivityService(),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("-----------");
    return MultiBlocProvider(
      providers: [
        BlocProvider<EventsCubit>(
          create: (_) => EventsCubit(_resolveRepository())..loadHome(limit: 10),
        ),
        BlocProvider<MuseumsCubit>(
          create: (_) {
            final client = Supabase.instance.client;
            final repo = MuseumsRepositoryImpl(
              MuseumsRemoteDataSourceImpl(client),
              MuseumsLocalDataSourceImpl(),
              ConnectivityService(),
            );
            return MuseumsCubit(repo)..loadMuseums(limit: 10);
          },
        ),
      ],
      child: const _EventsView(),
    );
  }
}

enum ProgramsTab {

  artworks('programs.tabs.artworks', Icons.palette_outlined),
  artists('programs.tabs.artists', Icons.people_alt_outlined),
  schedule('programs.tabs.schedule', Icons.event_available_outlined),
  gallery('programs.tabs.gallery', Icons.photo_library_outlined),
  events('programs.tabs.events', Icons.event_outlined),
  museum('programs.tabs.museum', Icons.museum_outlined);

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tabsCubit = context.read<TabsCubit>();
      final initialTabIndex = tabsCubit.selectedSubIndex;
      if (initialTabIndex >= 0 && initialTabIndex < ProgramsTab.values.length) {
        setState(() {
          _tab = ProgramsTab.values[initialTabIndex];
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TabsCubit, TabsState>(
      listener: (context, state) {
        if (state is SelectedSubIndexChanged) {
          final newIndex = state.selectedSubIndex;
          if (newIndex >= 0 && newIndex < ProgramsTab.values.length) {
            setState(() {
              _tab = ProgramsTab.values[newIndex];
            });
          }
        }
      },
      child: BlocBuilder<EventsCubit, events_state.EventsState>(
        builder: (context, state) {
          return OfflineIndicator(
            child: Container(
              color: AppColor.white,
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: ProgramsLayout.pagePadding(context),
                        child: Column(
                          children: [
                            _ProgramsHeader(
                              controller: _searchController,
                              onChanged: context
                                  .read<EventsCubit>()
                                  .setSearchQuery,
                            ),
                            SizedBox(
                              height: ProgramsLayout.spacingSmall(context),
                            ),
                            _ProgramsTabBar(
                              selected: _tab,
                              onSelected: (tab) => setState(() => _tab = tab),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: ProgramsLayout.spacingSmall(context)),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _buildBody(_tab),
                      ),
                      SizedBox(height: ProgramsLayout.spacingMedium(context)),
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

  Widget _buildBody(ProgramsTab tab) {
    switch (tab) {
      case ProgramsTab.events:
        return const _EventsSection();
      case ProgramsTab.artworks:
        return const _ArtworksSection();
      case ProgramsTab.artists:
        return const _ArtistsSection();
      case ProgramsTab.schedule:
        return const _ScheduleSection();
      case ProgramsTab.gallery:
        return const _GallerySection();
      case ProgramsTab.museum:
        return const _MuseumSection();
    }
  }
}

class _EventsSection extends StatelessWidget {
  const _EventsSection();

  @override
  Widget build(BuildContext context) {
    return _DataSection<Event, events_state.EventsState, EventsCubit>(
      selector: (state) => _SliceData(
        items: state.events,
        status: state.eventsStatus,
        errorMessage: state.eventsError,
      ),
      errorKey: 'programs.errors.events',
      onRetry: () =>
          context.read<EventsCubit>().loadEvents(limit: 10, force: true),
      builder: (context, events) => EventsTabContent(
        artworks:context.read<EventsCubit>().state.artworks ,
        events: events,
        artists: context.read<EventsCubit>().state.artists,
        languageCode: context.locale.languageCode,
      ),
    );
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
            Expanded(
              flex: 3,
              child: Container(
                height: ProgramsLayout.size(context, 44),
                decoration: BoxDecoration(
                  color: AppColor.gray50,
                  borderRadius: BorderRadius.circular(
                    ProgramsLayout.radius20(context),
                  ),
                  border: Border.all(color: AppColor.gray200),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: ProgramsLayout.pagePadding(context).left * 0.25,
                ),
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,

                  // centers the text/hint vertically
                  textAlignVertical: TextAlignVertical.center,

                  style: ProgramsTypography.bodyPrimary(context)
                      .copyWith(fontSize: ProgramsLayout.size(context, 14), height: 1),

                  decoration: InputDecoration(
                    isDense: true,
                    // contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),

                    hintText: 'programs.header.search_placeholder'.tr(),
                    hintStyle: ProgramsTypography.bodySecondary(context)
                        .copyWith(fontSize: ProgramsLayout.size(context, 14), color: AppColor.gray500),

                    border: InputBorder.none,

                    // use prefixIcon so the icon doesn't push the hint off-center.
                    prefixIcon: Icon(
                      Icons.search,
                      size: ProgramsLayout.size(context, 20),
                      color: AppColor.primaryColor,
                    ),
                    // control the prefix icon constraints (keeps layout tight)
                    prefixIconConstraints: BoxConstraints(
                      minWidth: ProgramsLayout.size(context, 36),
                      minHeight: ProgramsLayout.size(context, 36),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: ProgramsLayout.spacingSmall(context)),
            Text(
              'programs.header.title'.tr(),
              style: ProgramsTypography.headingLarge(
                context,
              ).copyWith(color: AppColor.black),
            ),
          ],
        ),
        SizedBox(height: ProgramsLayout.spacingLarge(context)),
      ],
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
            .map(
              (tab) => Padding(
            padding: EdgeInsetsDirectional.only(
              end: ProgramsLayout.spacingMedium(context),
            ),
            child: _TabChip(
              label: tab.labelKey.tr(),
              icon: tab.icon,
              isSelected: tab == selected,
              onTap: () => onSelected(tab),
            ),
          ),
        )
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
    return InkWell(
      borderRadius: BorderRadius.circular(ProgramsLayout.radius16(context)),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primaryColor : AppColor.transparent,
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : AppColor.gray200,
          ),
          borderRadius: BorderRadius.circular(ProgramsLayout.radius16(context)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ProgramsLayout.size(context, 18),
            vertical: ProgramsLayout.spacingMedium(context),
          ),
          child: Text(
            label,
            style: ProgramsTypography.labelSmall(context).copyWith(
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColor.white : AppColor.gray600,
            ),
          ),
        ),
      ),
    );
  }
}

// Generic Section Widget
class _DataSection<T, S, C extends Cubit> extends StatelessWidget {
  const _DataSection({
    required this.selector,
    required this.builder,
    required this.onRetry,
    required this.errorKey,
  });

  final _SliceData<T> Function(S) selector;
  final Widget Function(BuildContext, List<T>) builder;
  final VoidCallback onRetry;
  final String errorKey;

  @override
  Widget build(BuildContext context) {
    if (C == EventsCubit) {
      return BlocSelector<EventsCubit, events_state.EventsState, _SliceData<T>>(
        selector: (state) => selector(state as S),
        builder: (context, slice) {
          if (slice.status == events_state.SliceStatus.error) {
            return _InlineError(
              title: slice.errorMessage ?? errorKey.tr(),
              onRetry: onRetry,
            );
          }
          return builder(context, slice.items);
        },
      );
    } else if (C == MuseumsCubit) {
      return BlocSelector<MuseumsCubit, museums_state.MuseumsState, _SliceData<T>>(
        selector: (state) => selector(state as S),
        builder: (context, slice) {
          if (slice.status == museums_state.SliceStatus.error) {
            return _InlineError(
              title: slice.errorMessage ?? errorKey.tr(),
              onRetry: onRetry,
            );
          }
          return builder(context, slice.items);
        },
      );
    }
    return const SizedBox.shrink();
  }
}

class _ArtworksSection extends StatelessWidget {
  const _ArtworksSection();

  @override
  Widget build(BuildContext context) {
    return _DataSection<Artwork, events_state.EventsState, EventsCubit>(
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
    return _DataSection<Artist, events_state.EventsState, EventsCubit>(
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

class _ScheduleSection extends StatefulWidget {
  const _ScheduleSection();

  @override
  State<_ScheduleSection> createState() => _ScheduleSectionState();
}

class _ScheduleSectionState extends State<_ScheduleSection> {
  String? _currentView;
  Speaker? _selectedSpeaker;
  Workshop? _selectedWorkshop;

  void _showSpeakerDetail(Speaker speaker) {
    setState(() {
      _currentView = 'speaker';
      _selectedSpeaker = speaker;
    });
  }

  void _showWorkshopDetail(Workshop workshop) {
    setState(() {
      _currentView = 'workshop';
      _selectedWorkshop = workshop;
    });
  }

  void _backToSchedule() {
    setState(() {
      _currentView = null;
      _selectedSpeaker = null;
      _selectedWorkshop = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentView == 'speaker' && _selectedSpeaker != null) {
      return Column(
        children: [
          _BackButton(onBack: _backToSchedule, title: _selectedSpeaker!.name),
          SizedBox(height: ProgramsLayout.spacingMedium(context)),
          Padding(
            padding: ProgramsLayout.pagePadding(context),
            child: SpeakersInfoScreen(
              speaker: _selectedSpeaker!,
              userId: "",
              isEmbedded: true,
            ),
          ),
        ],
      );
    }

    if (_currentView == 'workshop' && _selectedWorkshop != null) {
      return Column(
        children: [
          _BackButton(onBack: _backToSchedule, title:RTLHelper.isRTL(context)? _selectedWorkshop!.nameAr:_selectedWorkshop!.name),
          //SizedBox(height: ProgramsLayout.spacingMedium(context)),
          Padding(
            padding: ProgramsLayout.pagePadding(context),
            child: WorkshopInfoScreen(
              workshop: _selectedWorkshop!,
              userId: "",
              isEmbedded: true,
            ),
          ),
        ],
      );
    }

    return BlocBuilder<EventsCubit, events_state.EventsState>(
      builder: (context, state) {
        final hasError =
            state.speakersError != null || state.workshopsError != null;

        if (hasError) {
          return _InlineError(
            title:
            state.speakersError ??
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
              onSpeakerTap: _showSpeakerDetail,
              onWorkshopTap: _showWorkshopDetail,
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
    return _DataSection<GalleryItem, events_state.EventsState, EventsCubit>(
      selector: (state) => _SliceData(
        items: state.gallery,
        status: state.galleryStatus,
        errorMessage: state.galleryError,
      ),
      errorKey: 'programs.errors.gallery',
      onRetry: () => context.read<EventsCubit>().loadGallery(
        limitArtworks: 50,
        force: true,
      ),
      builder: (context, gallery) => GalleryGrid(items: gallery, onTap: (_) {}),
    );
  }
}

class _MuseumSection extends StatelessWidget {
  const _MuseumSection();

  @override
  Widget build(BuildContext context) {
    return _DataSection<Museum, museums_state.MuseumsState, MuseumsCubit>(
      selector: (state) => _SliceData(
        items: state.museums,
        status: state.museumsStatus,
        errorMessage: state.museumsError,
      ),
      errorKey: 'programs.errors.museums',
      onRetry: () =>
          context.read<MuseumsCubit>().loadMuseums(limit: 10, force: true),
      builder: (context, museums) => MuseumTabContent(
        museums: museums,
        artists: context.read<EventsCubit>().state.artists,
        languageCode: context.locale.languageCode,
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onBack, this.title});

  final VoidCallback onBack;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final displayTitle = title ?? 'Back to Schedule';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.sW),
      decoration: BoxDecoration(color: AppColor.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: onBack,
            child: Iconify(
              RTLHelper.isRTL(context)
                  ? MaterialSymbols.arrow_forward_rounded
                  : MaterialSymbols.arrow_back_rounded,
              color: Colors.black,
              size: 32.sW,
            ),
          ),
          Text(
            displayTitle,
            style: TextStyleHelper.instance.headline24BoldInter,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.title, required this.onRetry});

  final String title;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ConnectivityService().hasConnection(),
      builder: (context, snapshot) {
        final isOffline = snapshot.data == false;

        return Center(
          child: Container(
            margin: ProgramsLayout.sectionPadding(context),
            padding: EdgeInsets.all(ProgramsLayout.size(context, 20)),
            decoration: BoxDecoration(
              color: AppColor.gray50,
              borderRadius: BorderRadius.circular(
                ProgramsLayout.radius16(context),
              ),
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
                SizedBox(height: ProgramsLayout.spacingLarge(context)),
                Text(
                  isOffline ? 'programs.offline.no_cached_data'.tr() : title,
                  style: ProgramsTypography.headingMedium(
                    context,
                  ).copyWith(color: AppColor.gray900),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ProgramsLayout.spacingSmall(context)),
                Text(
                  isOffline
                      ? 'programs.offline.connect_to_load'.tr()
                      : 'programs.errors.generic_subtitle'.tr(),
                  style: ProgramsTypography.bodySecondary(
                    context,
                  ).copyWith(color: AppColor.gray600),
                  textAlign: TextAlign.center,
                ),
                if (!isOffline) ...[
                  SizedBox(height: ProgramsLayout.spacingMedium(context)),
                  OutlinedButton(
                    onPressed: onRetry,
                    child: Text('programs.actions.retry'.tr()),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
  final dynamic status;
  final String? errorMessage;
}
