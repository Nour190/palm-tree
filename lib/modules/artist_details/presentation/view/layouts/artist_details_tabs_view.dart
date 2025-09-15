import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

// Header + hero + chips
import 'package:baseqat/modules/artist_details/presentation/widgets/header_title.dart';
import 'package:baseqat/modules/artist_details/presentation/widgets/hero_image.dart';
import 'package:baseqat/modules/artist_details/presentation/widgets/category_chips.dart';

// Tabs (keep these as your existing widgets)
import 'package:baseqat/modules/artist_details/presentation/view/tabs/about_tab.dart';
import 'package:baseqat/modules/artist_details/presentation/view/tabs/gallery_tab.dart';
import 'package:baseqat/modules/artist_details/presentation/view/tabs/location_tab_view.dart';
import 'package:baseqat/modules/artist_details/presentation/view/tabs/chat_tab_view.dart';
import 'package:baseqat/modules/artist_details/presentation/view/tabs/feedback_tab_view.dart';

class ArtistDetailsScreen extends StatefulWidget {
  const ArtistDetailsScreen({
    super.key,
    this.initialTabIndex = 0,
    this.title = 'Clay Whispers',
    this.heroImagePath,
    this.showBack = true,
    this.onBack,
  });

  final int initialTabIndex;
  final String title;
  final String? heroImagePath;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  State<ArtistDetailsScreen> createState() => _ArtistDetailsScreenState();
}

class _ArtistDetailsScreenState extends State<ArtistDetailsScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
  }

  void _goToTab(int i) => setState(() => _selectedTabIndex = i);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, _) {
        final w = SizeUtils.width;
        final bool isDesktop = w >= 1200;
        final bool isTablet = w >= 840 && w < 1200;

        final double hPad = isDesktop ? 64.h : (isTablet ? 32.h : 16.h);
        final double betweenHeaderHero = 16.h;
        final double betweenChipsTab = isDesktop
            ? 24.h
            : (isTablet ? 20.h : 16.h);
        final EdgeInsets scrollPad = EdgeInsets.symmetric(
          horizontal: hPad,
          vertical: 32.h,
        );

        return Scaffold(
          backgroundColor: AppColor.backgroundWhite,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: SingleChildScrollView(
                  padding: scrollPad,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final bool sideBySide = constraints.maxWidth >= 840;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),

                          // Header + Chips + Hero (responsive in one tree)
                          if (sideBySide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: isDesktop ? 5 : 6,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      HeaderTitle(
                                        title: widget.title,
                                        showBack: false,
                                      ),
                                      SizedBox(height: betweenHeaderHero),
                                      CategoryChipsAdaptive(
                                        items: const [
                                          'About',
                                          'Gallery',
                                          'Location',
                                          'Chat Ai',
                                          'Feedback',
                                        ],
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
                                    height: isDesktop ? 340 : 304,
                                    path: widget.heroImagePath,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            HeaderTitle(
                              title: widget.title,
                              showBack: widget.showBack,
                              onBack: widget.onBack,
                            ),
                            SizedBox(height: betweenHeaderHero),
                            HeroImage(height: 304, path: widget.heroImagePath),
                            SizedBox(height: 16.h),
                            CategoryChipsAdaptive(
                              items: const [
                                'About',
                                'Gallery',
                                'Location',
                                'Chat Ai',
                                'Feedback',
                              ],
                              selectedIndex: _selectedTabIndex,
                              onSelected: _goToTab,
                            ),
                          ],

                          SizedBox(height: betweenChipsTab),

                          // Tabs: each tab owns its data; the Screen passes nothing heavy
                          _buildTab(_selectedTabIndex),

                          SizedBox(height: isDesktop ? 40.h : 32.h),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        // AboutTab owns its content (no data passed from the screen)
        return AboutTab(
          title: 'Aerial Minimalism',
          about:
              'A study in lightweight composites and endurance-centric geometry. '
              'Built for everyday reliability without aesthetic compromise.',
          materials:
              'Carbon fiber skins over honeycomb core; titanium fasteners; '
              'ceramic-coated leading edges; eco-friendly resin system.',
          vision:
              'Durable objects should age gracefully. The goal is long-term service with minimal maintenance.',
          galleryImages: [
            AppAssetsManager.imgRectangle1,
            AppAssetsManager.imgRectangle2,
            AppAssetsManager.imgRectangle4,
          ],
        );

      case 1:
        // GalleryTab: provide its own images (or let it fetch via repo/provider)
        return GalleryTab(
          images: [
            AppAssetsManager.imgRectangle1,
            AppAssetsManager.imgRectangle2,
            AppAssetsManager.imgRectangle4,
          ],
        );

      case 2:
        // LocationTab: configure here; the screen doesn’t carry these props
        return LocationTab(
          title: 'Roots Entrance',
          subtitle: 'B1 • Section 3',
          distanceLabel: '3 min (0.4 miles)',
          destinationLabel: 'To Festival Speakers',
          addressLine: '123 Art Park Blvd',
          city: 'Dhahran',
          country: 'Saudi Arabia',
          latitude: 26.3045,
          longitude: 50.1115,
          mapImage: AppAssetsManager.imgRectangle1,
          // onStartNavigation: yourNavigationCallback, // optional
        );

      case 3:
        // AI chat: seed inside the tab usage here
        return AIChatView(
          botName: 'ithra Ai',
          botAvatarIcon: Icons.smart_toy_outlined,
          // onSendText / onTapMic / onTapAdd can be wired here if needed
        );

      case 4:
        // FeedbackTab: defaults set here, not on the screen
        return FeedbackTab(
          chips: const [
            'Over Service',
            'Product',
            'Artist Support',
            'Quality',
            'Accessibility',
            'Clear Information',
            'Artwork Story',
            'Material Uniqueness',
          ],
          initialRating: 3,
          initialMessage: '',
          preselected: const {'Quality'},
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
