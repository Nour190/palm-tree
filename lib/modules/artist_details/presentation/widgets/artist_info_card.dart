import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

class ArtistInfoCard extends StatelessWidget {
  final int? age;
  final String? country;
  final String? city;
  const ArtistInfoCard({super.key, this.age, this.country, this.city});

  bool get hasInfo =>
      age != null ||
      (country?.isNotEmpty ?? false) ||
      (city?.isNotEmpty ?? false);

  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  @override
  Widget build(BuildContext context) {
    if (!hasInfo) return const SizedBox.shrink();
    final isMobile = _isMobile(context);

    return _card(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, 'Details', Icons.person_outline_rounded),
          SizedBox(height: isMobile ? 16 : 20),
          isMobile
              ? Column(children: _items(context))
              : Wrap(spacing: 32, runSpacing: 16, children: _items(context)),
        ],
      ),
    );
  }

  List<Widget> _items(BuildContext context) {
    final text = TextStyleHelper.instance;
    final isMobile = _isMobile(context);
    final widgets = <Widget>[];

    Widget item(IconData icon, String label, String value) {
      return Container(
        constraints: isMobile ? null : const BoxConstraints(minWidth: 200),
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AppColor.gray600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: text.title16MediumInter.copyWith(
                      color: AppColor.gray500,
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: text.title16Inter.copyWith(
                      color: AppColor.gray900,
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (age != null)
      widgets.add(item(Icons.cake_outlined, 'Age', '$age years'));
    if (country?.isNotEmpty ?? false)
      widgets.add(item(Icons.public_rounded, 'Country', country!));
    if (city?.isNotEmpty ?? false)
      widgets.add(item(Icons.location_on_outlined, 'City', city!));

    return widgets;
  }

  Widget _card({required BuildContext context, required Widget child}) {
    final isMobile = _isMobile(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        border: Border.all(color: AppColor.gray200.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon) {
    final text = TextStyleHelper.instance;
    final isMobile = _isMobile(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.gray100, AppColor.gray50],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColor.gray700),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: text.headline24BoldInter.copyWith(
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.w700,
            color: AppColor.gray900,
          ),
        ),
      ],
    );
  }
}
