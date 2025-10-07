import 'package:baseqat/core/components/alerts/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'footer/contact_section_widget.dart';
import 'footer/follow_section_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class Footer extends StatefulWidget {
  final String email;
  final String phone;
  final String address;
  final String brandName;

  const Footer({
    super.key,
    this.email = 'press@ithra.com',
    this.phone = '+966 13 816 9799',
    this.address = '8386 Ring Rd, Gharb Al Dhahran, Dhahran 34461',
    this.brandName = 'ithra',
  });

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  final TextEditingController _subscribeController = TextEditingController();

  @override
  void dispose() {
    _subscribeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final isMobile = deviceType == DeviceType.mobile;

    return Container(
      width: double.infinity,
      color: AppColor.gray900,
      padding: EdgeInsets.fromLTRB(
        _getHorizontalPadding(deviceType),
        _getVerticalPadding(deviceType),
        _getHorizontalPadding(deviceType),
        _getBottomPadding(deviceType),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isMobile ? 16.sH : 24.sH),
          _buildContent(context, deviceType),
        ],
      ),
    );
  }

  double _getHorizontalPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 20.sW;
      case DeviceType.tablet:
        return 48.sW;
      case DeviceType.desktop:
        return 48.sW;
    }
  }

  double _getVerticalPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 28.sH;
      case DeviceType.tablet:
        return 44.sH;
      case DeviceType.desktop:
        return 44.sH;
    }
  }

  double _getBottomPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 64.sH;
      case DeviceType.tablet:
        return 96.sH;
      case DeviceType.desktop:
        return 96.sH;
    }
  }

  Widget _buildContent(BuildContext context, DeviceType deviceType) {
    final isDesktop = deviceType == DeviceType.desktop;
    final isTablet = deviceType == DeviceType.tablet;
    return isDesktop || isTablet
        ? Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ContactSectionWidget(
            email: widget.email,
            phone: widget.phone,
            address: widget.address,
          ),
        ),
        SizedBox(width: 32.sW),
        Expanded(
          child: FollowSectionWidget(
            controller: _subscribeController,
            onSubscribe: _handleSubscribe,
          ),
        ),
      ],
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContactSectionWidget(
          email: widget.email,
          phone: widget.phone,
          address: widget.address,
        ),
        SizedBox(height: deviceType == DeviceType.mobile ? 24.sH : 28.sH),
        FollowSectionWidget(
          controller: _subscribeController,
          onSubscribe: _handleSubscribe,
        ),
      ],
    );
  }

  void _handleSubscribe() {
    final email = _subscribeController.text.trim();
    final isValid = _isValidEmail(email);

    if (isValid) {
      context.showSuccessSnackBar(tr('footer.subscribed_success', args: [email]));
    } else {
      context.showErrorSnackBar(tr('footer.invalid_email'));
    }
  }

  bool _isValidEmail(String input) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(input);
  }
}
