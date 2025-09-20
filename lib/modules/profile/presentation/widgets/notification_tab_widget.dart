import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';

class NotificationTabWidget extends StatefulWidget {
  const NotificationTabWidget({super.key});

  @override
  State<NotificationTabWidget> createState() => _NotificationTabWidgetState();
}

class _NotificationTabWidgetState extends State<NotificationTabWidget> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _artworkUpdates = true;
  bool _exhibitionReminders = true;
  bool _auctionAlerts = false;
  bool _messageNotifications = true;
  bool _followNotifications = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16.sH),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.sW, vertical: 8.sH),
            padding: EdgeInsets.all(16.sW),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.sW),
              border: Border.all(
                color: AppColor.primaryColor.withOpacity(0.1),
                width: 1.sW,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: AppColor.primaryColor,
                      size: 24.sSp,
                    ),
                    SizedBox(width: 12.sW),
                    Text(
                      'Notification Settings',
                      style: TextStyleHelper.instance.title18BoldInter.copyWith(
                        color: AppColor.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.sH),

                _buildNotificationToggle(
                  'Push Notifications',
                  'Receive notifications on your device',
                  _pushNotifications,
                      (value) => setState(() => _pushNotifications = value),
                ),

                _buildNotificationToggle(
                  'Email Notifications',
                  'Get updates via email',
                  _emailNotifications,
                      (value) => setState(() => _emailNotifications = value),
                ),

                _buildNotificationToggle(
                  'Artwork Updates',
                  'New artworks from followed artists',
                  _artworkUpdates,
                      (value) => setState(() => _artworkUpdates = value),
                ),

                _buildNotificationToggle(
                  'Exhibition Reminders',
                  'Upcoming exhibitions and events',
                  _exhibitionReminders,
                      (value) => setState(() => _exhibitionReminders = value),
                ),

                _buildNotificationToggle(
                  'Auction Alerts',
                  'Bidding updates and auction starts',
                  _auctionAlerts,
                      (value) => setState(() => _auctionAlerts = value),
                ),

                _buildNotificationToggle(
                  'Messages',
                  'New messages and chat updates',
                  _messageNotifications,
                      (value) => setState(() => _messageNotifications = value),
                ),

                _buildNotificationToggle(
                  'Follow Activity',
                  'New followers and follow requests',
                  _followNotifications,
                      (value) => setState(() => _followNotifications = value),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.sH),

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

  Widget _buildNotificationToggle(
      String title,
      String description,
      bool value,
      Function(bool) onChanged,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.sH),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleHelper.instance.title14BoldInter.copyWith(
                    color: AppColor.black,
                  ),
                ),
                SizedBox(height: 2.sH),
                Text(
                  description,
                  style: TextStyleHelper.instance.body12MediumInter.copyWith(
                    color: AppColor.gray600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.sW),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColor.primaryColor,
            inactiveThumbColor: AppColor.gray400,
            inactiveTrackColor: AppColor.gray200,
          ),
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
          // Notification Icon
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

          // Notification Details
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
