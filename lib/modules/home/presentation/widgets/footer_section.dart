import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:url_launcher/url_launcher.dart';

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
          _buildHeader(context, isMobile),
          SizedBox(height: isMobile ? 16.sH : 24.sH),
          _buildContent(context, deviceType),
          SizedBox(height: isMobile ? 24.sH : 32.sH),
          _buildBrandName(context, isMobile),
        ],
      ),
    );
  }

  double _getHorizontalPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 20.sW;
      case DeviceType.tablet:
        return 32.sW;
      case DeviceType.desktop:
        return 48.sW;
    }
  }

  double _getVerticalPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 28.sH;
      case DeviceType.tablet:
        return 36.sH;
      case DeviceType.desktop:
        return 44.sH;
    }
  }

  double _getBottomPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 64.sH;
      case DeviceType.tablet:
        return 80.sH;
      case DeviceType.desktop:
        return 96.sH;
    }
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final styles = TextStyleHelper.instance;
    return Text(
      'Contact & Updates',
      style: isMobile
          ? styles.headline24BoldInter.copyWith(
              color: AppColor.whiteCustom,
              fontSize: Responsive.responsiveFontSize(context, 24),
            )
          : styles.headline32BoldInter.copyWith(
              color: AppColor.whiteCustom,
              fontSize: Responsive.responsiveFontSize(context, 32),
            ),
    );
  }

  Widget _buildContent(BuildContext context, DeviceType deviceType) {
    final isDesktop = deviceType == DeviceType.desktop;

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ContactSection(
                  email: widget.email,
                  phone: widget.phone,
                  address: widget.address,
                ),
              ),
              SizedBox(width: 32.sW),
              Expanded(
                child: _FollowSection(
                  controller: _subscribeController,
                  onSubscribe: _handleSubscribe,
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ContactSection(
                email: widget.email,
                phone: widget.phone,
                address: widget.address,
              ),
              SizedBox(height: deviceType == DeviceType.mobile ? 24.sH : 28.sH),
              _FollowSection(
                controller: _subscribeController,
                onSubscribe: _handleSubscribe,
              ),
            ],
          );
  }

  Widget _buildBrandName(BuildContext context, bool isMobile) {
    final styles = TextStyleHelper.instance;

    final baseStyle = isMobile
        ? styles.display40BoldInter.copyWith(
            color: AppColor.whiteCustom,
            letterSpacing: -0.5,
            fontSize: Responsive.responsiveFontSize(context, 28), // reduced
          )
        : styles.display56BoldInter.copyWith(
            color: AppColor.whiteCustom,
            letterSpacing: 1.5,
            fontSize: Responsive.responsiveFontSize(context, 44), // reduced
          );

    return Text(widget.brandName, style: baseStyle);
  }

  void _handleSubscribe() {
    final email = _subscribeController.text.trim();
    final isValid = _isValidEmail(email);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isValid
              ? 'Subscribed with $email'
              : 'Please enter a valid email address',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // If you want to deep-link to mail or a web form, do it here.
    // Example (commented): mailto:
    // if (isValid) {
    //   launchUrl(Uri.parse('mailto:$email?subject=Subscribe%20me'));
    // }
  }

  bool _isValidEmail(String input) {
    // Lightweight, pragmatic email check
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(input);
  }
}

class _ContactSection extends StatelessWidget {
  final String email, phone, address;

  const _ContactSection({
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
        _ContactItem(title: 'Email', value: email),
        SizedBox(height: spacing),
        _ContactItem(title: 'Phone', value: phone),
        SizedBox(height: spacing),
        _ContactItem(title: 'Address', value: address),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  final String title, value;

  const _ContactItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final isMobile = Responsive.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: isMobile
              ? styles.title16MediumInter.copyWith(
                  color: AppColor.gray400,
                  fontSize: Responsive.responsiveFontSize(context, 14),
                )
              : styles.headline20MediumInter.copyWith(
                  color: AppColor.gray400,
                  fontSize: Responsive.responsiveFontSize(context, 18),
                ),
        ),
        SizedBox(height: 4.sH),
        SelectableText(
          value,
          style: isMobile
              ? styles.body14RegularInter.copyWith(
                  color: AppColor.whiteCustom,
                  fontSize: Responsive.responsiveFontSize(context, 12),
                )
              : styles.title16RegularInter.copyWith(
                  color: AppColor.whiteCustom,
                  fontSize: Responsive.responsiveFontSize(context, 14),
                ),
        ),
      ],
    );
  }
}

class _FollowSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubscribe;

  const _FollowSection({required this.controller, required this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final deviceType = Responsive.deviceTypeOf(context);
    final isMobile = deviceType == DeviceType.mobile;
    final spacing = isMobile ? 16.sH : 20.sH;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow us',
          style: isMobile
              ? styles.title16MediumInter.copyWith(
                  color: AppColor.gray400,
                  fontSize: Responsive.responsiveFontSize(context, 14),
                )
              : styles.headline20MediumInter.copyWith(
                  color: AppColor.gray400,
                  fontSize: Responsive.responsiveFontSize(context, 18),
                ),
        ),
        SizedBox(height: 8.sH),
        _buildSocialIcons(context),
        SizedBox(height: spacing),
        Text(
          'Subscribe for updates',
          style: isMobile
              ? styles.title16MediumInter.copyWith(
                  color: AppColor.gray400,
                  fontSize: Responsive.responsiveFontSize(context, 14),
                )
              : styles.headline20MediumInter.copyWith(
                  color: AppColor.gray400,
                  fontSize: Responsive.responsiveFontSize(context, 18),
                ),
        ),
        SizedBox(height: 8.sH),
        _buildSubscribeForm(context),
      ],
    );
  }

  Widget _buildSocialIcons(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Wrap(
      spacing: isMobile ? 12.sW : 16.sW,
      children: const [
        _SocialIcon(icon: Icons.facebook, label: 'Facebook'),
        _SocialIcon(icon: Icons.business_center, label: 'LinkedIn'),
        _SocialIcon(icon: Icons.alternate_email, label: 'X (Twitter)'),
      ],
    );
  }

  Widget _buildSubscribeForm(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final deviceType = Responsive.deviceTypeOf(context);
    final isMobile = deviceType == DeviceType.mobile;

    final textFieldHeight = isMobile ? 44.sH : 52.sH;
    final borderRadius = isMobile ? 8.sH : 12.sH;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: textFieldHeight,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              style: isMobile
                  ? styles.body14RegularInter.copyWith(
                      color: AppColor.gray900,
                      fontSize: Responsive.responsiveFontSize(context, 12),
                    )
                  : styles.title16RegularInter.copyWith(
                      color: AppColor.gray900,
                      fontSize: Responsive.responsiveFontSize(context, 14),
                    ),
              decoration: InputDecoration(
                hintText: 'Enter your email',
                filled: true,
                fillColor: AppColor.whiteCustom,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12.sW : 16.sW,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide.none,
                ),
                hintStyle: isMobile
                    ? styles.body14RegularInter.copyWith(
                        color: AppColor.gray400,
                        fontSize: Responsive.responsiveFontSize(context, 12),
                      )
                    : styles.title16RegularInter.copyWith(
                        color: AppColor.gray400,
                        fontSize: Responsive.responsiveFontSize(context, 14),
                      ),
              ),
              onSubmitted: (_) => onSubscribe(),
            ),
          ),
        ),
        SizedBox(width: 8.sW),
        _buildSubscribeButton(context),
      ],
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final deviceType = Responsive.deviceTypeOf(context);
    final isMobile = deviceType == DeviceType.mobile;

    final buttonHeight = isMobile ? 44.sH : 52.sH;
    final borderRadius = isMobile ? 8.sH : 12.sH;
    final horizontalPadding = isMobile ? 16.sW : 24.sW;

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColor.whiteCustom,
        foregroundColor: AppColor.gray900,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 8.sH,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        minimumSize: Size(0, buttonHeight),
      ),
      onPressed: onSubscribe,
      child: Text(
        'Subscribe',
        style: isMobile
            ? styles.title14MediumInter.copyWith(
                fontSize: Responsive.responsiveFontSize(context, 12),
              )
            : styles.title16MediumInter.copyWith(
                fontSize: Responsive.responsiveFontSize(context, 14),
              ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SocialIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final isMobile = deviceType == DeviceType.mobile;

    final iconSize = isMobile ? 36.sW : 48.sW;
    final iconInnerSize = isMobile ? 18.sW : 22.sW;

    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: () => _handleSocialTap(label),
        borderRadius: BorderRadius.circular(iconSize / 2),
        child: Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: AppColor.gray900, size: iconInnerSize),
        ),
      ),
    );
  }

  void _handleSocialTap(String platform) async {
    final urls = {
      'Facebook':
          'https://www.facebook.com/KingAbdulazizCenterForWorldCulture/',
      'LinkedIn':
          'https://www.linkedin.com/company/kingabdulazizcenterforworldculture',
      'X (Twitter)':
          'https://x.com/Ithra?ref_src=twsrc%5Egoogle%7Ctwcamp%5Eserp%7Ctwgr%5Eauthor',
    };

    final url = urls[platform];
    if (url == null) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
