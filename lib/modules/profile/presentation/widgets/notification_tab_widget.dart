import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';

class NotificationTabWidget extends StatelessWidget {
  const NotificationTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16.sH),
      child: Column(
        children: notifications.map((notification) => _buildNotificationItem(notification)).toList(),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.sH),
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
