import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'contact_item_widget.dart';

class ContactSectionWidget extends StatelessWidget {
  final String email, phone, address;

  const ContactSectionWidget({
    super.key,
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final spacing = deviceType == DeviceType.mobile ? 12.sH : 16.sH;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContactItemWidget(title: 'email', value: email),
        SizedBox(height: spacing),
        ContactItemWidget(title: 'phone', value: phone),
        SizedBox(height: spacing),
        ContactItemWidget(title: 'address', value: address),
      ],
    );
  }
}
