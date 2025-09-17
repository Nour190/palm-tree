import 'package:baseqat/core/components/custom_widgets/custom_top_bar.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/modules/events/presentation/view/events_view.dart';
import 'package:baseqat/modules/home/presentation/view/home_view.dart';
import 'package:baseqat/modules/tabs/presentation/manger/tabs_cubit.dart';
import 'package:baseqat/modules/tabs/presentation/manger/tabs_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            SizedBox(height: 16.h),

            // ---------------- Top element in the view ----------------
            BlocBuilder<TabsCubit, TabsState>(
              buildWhen: (p, c) => p.topIndex != c.topIndex,
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TopBar(
                      items: const ['Home', 'Events', 'Maps', 'Language'],
                      selectedIndex: state.topIndex,
                      onItemTap: context.read<TabsCubit>().selectTop,
                      onLoginTap: () {},
                      showScanButton: true,
                      onScanTap: () {},
                    ),
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
      return const EventsScreen();
    case 2: // Maps
      return const SizedBox.shrink();
    case 3: // Language
      return const SizedBox.shrink();
    default:
      return const HomeView();
  }
}
