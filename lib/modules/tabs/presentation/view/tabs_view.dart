import 'package:baseqat/core/components/custom_widgets/custom_top_bar.dart';
import 'package:baseqat/core/components/custom_widgets/desktop_top_bar.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/responsive/size_utils.dart' hide DeviceType;
import 'package:baseqat/modules/events/presentation/view/events_view.dart';
import 'package:baseqat/modules/home/presentation/view/home_view.dart';
import 'package:baseqat/modules/tabs/presentation/manger/tabs_cubit.dart';
import 'package:baseqat/modules/tabs/presentation/manger/tabs_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../events/presentation/view/events_screen_responsive.dart';
import '../../../profile/presentation/view/profile_screen.dart';

class TabsViewScreen extends StatelessWidget {
  const TabsViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TabsViewBody();
  }
}

class _TabsViewBody extends StatelessWidget {
  const _TabsViewBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: Responsive.deviceTypeOf(context) == DeviceType.desktop ? 0 : 16.h),

            // ---------------- Top element in the view ----------------
            BlocBuilder<TabsCubit, TabsState>(
              buildWhen: (p, c) => p.topIndex != c.topIndex,
              builder: (context, state) {
                final devType = Responsive.deviceTypeOf(context);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    devType == DeviceType.desktop
                        ? DesktopTopBar(
                      items: const ['Home', 'Events', 'Maps', 'Language',"Profile"],
                      selectedIndex: state.topIndex,
                      onItemTap: context.read<TabsCubit>().selectTop,
                      onLoginTap: () {},
                      showScanButton: true,
                      onScanTap: () {},
                    )
                        : Padding(
                          padding:  EdgeInsets.symmetric(horizontal: 8.0.sW),
                          child: TopBar(
                                                items: const ['Home', 'Events', 'Maps', 'Language'],
                                                selectedIndex: state.topIndex,
                                                onItemTap: context.read<TabsCubit>().selectTop,
                                                onLoginTap: () {},
                                                showScanButton: true,
                                                onScanTap: () {},
                                              ),
                        ),
                    if (devType != DeviceType.desktop)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                      ),
                  ],
                );
              },
            ),

            // ---------------- Body switches by topIndex ----------------
            Expanded(
              child: BlocBuilder<TabsCubit, TabsState>(
                buildWhen: (p, c) => p.topIndex != c.topIndex,
                builder: (context, state) {
                  return _bodyForTopIndex(state.topIndex);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _bodyForTopIndex(int topIndex) {
  switch (topIndex) {
    case 0: // Home
      return HomeView();
    case 1: // Events
      return const EventsScreenResponsive();
    case 2: // Maps
      return const SizedBox.shrink();
    case 3: // Language
      return const SizedBox.shrink();
    case 4: // Language
      return const ProfileScreen();
    default:
      return const HomeView();
  }
}
