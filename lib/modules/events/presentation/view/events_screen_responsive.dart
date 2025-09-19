import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive.dart';
import '../widgets/events_desktop_view.dart';
import '../widgets/events_mobile_tablet_view.dart';

class EventsScreenResponsive extends StatelessWidget {
  const EventsScreenResponsive({super.key});

  @override
  Widget build(BuildContext context) {
    final devType = Responsive.deviceTypeOf(context);
    return devType == DeviceType.desktop
        ? const EventsDesktopView()
        : const EventsMobileTabletView();
  }
}
