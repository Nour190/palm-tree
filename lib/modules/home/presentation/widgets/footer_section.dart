import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

import 'common/app_section_header.dart';

class Footer extends StatelessWidget {
  final bool isMobile;
  final String email;
  final String phone;
  final String address;
  final String brandName;

  const Footer({
    super.key,
    required this.isMobile,
    this.email = 'press@ithra.com',
    this.phone = '+966 13 816 9799',
    this.address = '8386 Ring Rd, Gharb Al Dhahran, Dhahran 34461',
    this.brandName = 'ithra',
  });

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;

    final contacts = _FooterContacts(
      email: email,
      phone: phone,
      address: address,
    );
    final follow = const _FooterFollowAndSubscribe();

    return Container(
      width: double.infinity,
      color: AppColor.gray900,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional: add a header if you want the same header treatment here
          const AppSectionHeader(title: 'Contact & Updates'),
          const SizedBox(height: 16),

          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [contacts, const SizedBox(height: 24), follow],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: contacts),
                    const SizedBox(width: 24),
                    const Expanded(child: _FooterFollowAndSubscribe()),
                  ],
                ),

          const SizedBox(height: 24),
          Text(
            brandName,
            style: styles.display48BoldInter.copyWith(
              color: AppColor.whiteCustom,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterContacts extends StatelessWidget {
  final String email, phone, address;
  const _FooterContacts({
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FooterField(title: 'Email', value: email),
        const SizedBox(height: 8),
        _FooterField(title: 'Phone', value: phone),
        const SizedBox(height: 8),
        _FooterField(title: 'Address', value: address),
      ],
    );
  }
}

class _FooterFollowAndSubscribe extends StatelessWidget {
  const _FooterFollowAndSubscribe();

  @override
  Widget build(BuildContext context) {
    final s = TextStyleHelper.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow us',
          style: s.title16Inter.copyWith(color: AppColor.gray400),
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            _SocialIcon(icon: Icons.facebook),
            SizedBox(width: 16),
            _SocialIcon(icon: Icons.alternate_email),
            SizedBox(width: 16),
            _SocialIcon(icon: Icons.camera_alt),
            SizedBox(width: 16),
            _SocialIcon(icon: Icons.work),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Subscribe for more',
          style: s.title16Inter.copyWith(color: AppColor.gray400),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColor.whiteCustom,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter your Email',
                  style: s.title16Inter.copyWith(color: AppColor.gray400),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColor.whiteCustom,
                foregroundColor: AppColor.gray900,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {},
              child: Text('Subscribe', style: s.title16MediumInter),
            ),
          ],
        ),
      ],
    );
  }
}

class _FooterField extends StatelessWidget {
  final String title, value;
  const _FooterField({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: styles.headline24MediumInter.copyWith(color: AppColor.gray400),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: styles.title16Inter.copyWith(color: AppColor.whiteCustom),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  const _SocialIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColor.gray900),
    );
  }
}
