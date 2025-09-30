import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/notification_settings_cubit.dart';
import '../cubit/notification_settings_state.dart';
import 'package:flutter/material.dart';
import '../service/notification_settings_service.dart';
import '../view/notification_settings_screen.dart';

class NotificationTabWidget extends StatelessWidget {
  const NotificationTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationSettingsCubit(NotificationSettingsService.instance),
      child: const _NotificationTabView(),
    );
  }
}

class _NotificationTabView extends StatelessWidget {
  const _NotificationTabView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationSettingsCubit, NotificationSettingsState>(
      builder: (context, state) {
        if (state.status == NotificationSettingsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!state.isPushEnabled) {
          return _buildNotificationsDisabledView(context);
        }

        bool hasNotifications = false; // This would come from your notification data

        if (!hasNotifications) {
          return _buildNoNotificationsView();
        }

        return _buildNotificationsView();
      },
    );
  }

  Widget _buildNotificationsDisabledView(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(15.sW),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 70.sSp,
              color: AppColor.gray400,
            ),
            SizedBox(height: 18.sH),
            Text(
              'Notifications are turned off',
              style: TextStyleHelper.instance.headline20BoldInter.copyWith(
                color: AppColor.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.sH),
            Text(
              'Enable notifications in your profile settings to receive \nupdates about artworks, events, and more.',
              style: TextStyleHelper.instance.title16RegularInter.copyWith(
                color: AppColor.gray400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.sH),
            // ElevatedButton(
            //   onPressed: () {
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(
            //     //     builder: (context) => const NotificationSettingsScreen(),
            //     //   ),
            //     // );
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => BlocProvider.value(
            //           value: context.read<NotificationSettingsCubit>(),
            //           child: const NotificationSettingsScreen(),
            //         ),
            //       ),
            //     );
            //
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: AppColor.primaryColor,
            //     padding: EdgeInsets.symmetric(horizontal: 24.sW, vertical: 12.sH),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8.r),
            //     ),
            //   ),
            //   child: Text(
            //     'Turn on notifications',
            //     style: TextStyleHelper.instance.title14BoldInter.copyWith(
            //       color: AppColor.white,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoNotificationsView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(15.sW),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 70.sSp,
              color: AppColor.gray400,
            ),
            SizedBox(height: 15.sH),
            Text(
              'No notifications yet',
              style: TextStyleHelper.instance.title18BoldInter.copyWith(
                color: AppColor.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.sH),
            Text(
              'When you receive notifications about artworks, events, \nand updates, they\'ll appear here.',
              style: TextStyleHelper.instance.title14MediumInter.copyWith(
                color: AppColor.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsView() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16.sH),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sW),
            child: Row(
              children: [
                Text(
                  'Recent Notifications',
                  style: TextStyleHelper.instance.title16BoldInter.copyWith(
                    color: AppColor.black,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Handle mark all as read
                  },
                  child: Text(
                    'Mark all as read',
                    style: TextStyleHelper.instance.body14RegularInter.copyWith(
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.sH),

          ...notifications.map((notification) => _buildNotificationItem(notification)).toList(),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get notifications => [
    {
      'title': 'New Artwork Added',
      'message': 'Laila Hassan has just showcased her latest painting "Reflections on the Nile". The piece explores the relationship between nature and memory. Visit the gallery to experience it in detail.',
      'time': 'Now',
      'icon': Icons.palette,
    },
    {
      'title': 'Exhibition Reminder',
      'message': 'Your saved exhibition "Colors of Cairo" will open in 3 days at the Downtown Art Hall. Make sure to confirm your attendance to secure your entry and enjoy the full guided tour.',
      'time': '1 hour ago',
      'icon': Icons.campaign,
    },
    {
      'title': 'Artist Appreciation',
      'message': 'Your ticket for "Contemporary Abstract Art" has been successfully booked. Keep your QR code safe to enter the event, which will feature more than 40 international artists.',
      'time': '3 hour ago',
      'icon': Icons.person,
    },
    {
      'title': 'Auction Starting Soon',
      'message': 'The live auction for the painting "Eastern Dream" will start in one hour. Join early to follow the bidding process and make sure you don\'t miss your chance.',
      'time': '1 day ago',
      'icon': Icons.gavel,
    },
    {
      'title': 'Event Near You',
      'message': 'A new event has been added near your location: "Art Night at Zamalek Gallery". The evening includes live performances, interactive installations, and open discussions with artists',
      'time': '1 week ago',
      'icon': Icons.event,
    },
  ];

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.sH, left: 16.sW, right: 16.sW),
      padding: EdgeInsets.all(16.sW),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12.sW),
        border: Border.all(color: AppColor.gray400.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.sW,
            height: 48.sW,
            decoration: BoxDecoration(
              color: AppColor.black,
              shape: BoxShape.circle,
            ),
            child: Icon(
              notification['icon'] as IconData,
              color: AppColor.white,
              size: 24.sSp,
            ),
          ),

          SizedBox(width: 12.sW),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification['title'] as String,
                      style: TextStyleHelper.instance.title16BoldInter.copyWith(
                        color: AppColor.black,
                      ),
                    ),
                    Text(
                      notification['time'] as String,
                      style: TextStyleHelper.instance.body12LightInter.copyWith(
                        color: AppColor.gray400,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.sH),

                Text(
                  notification['message'] as String,
                  style: TextStyleHelper.instance.body12LightInter.copyWith(
                    color: AppColor.gray700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
