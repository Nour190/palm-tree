import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/artist_details/presentation/widgets/network_image_smart.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_utils.dart' hide DeviceType;

class ArtistHeader extends StatefulWidget {
  final String name;
  final String? image;
  const ArtistHeader({super.key, required this.name, this.image});

  @override
  State<ArtistHeader> createState() => _ArtistHeaderState();
}

class _ArtistHeaderState extends State<ArtistHeader>
    with SingleTickerProviderStateMixin {
  final _text = TextStyleHelper.instance;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final isDesktop = deviceType == DeviceType.desktop;
    final isMobile = deviceType == DeviceType.mobile;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _slideController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: isMobile
                  ? _text.headline32BoldInter.copyWith(fontSize: 28.h)
                  : isDesktop
                  ? _text.headline32BoldInter.copyWith(fontSize: 25.h)
                  : _text.headline32BoldInter.copyWith(fontSize: 26.h),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Container(
              height: 4.h,
              width: 60.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.gray900, AppColor.gray600],
                ),
                borderRadius: BorderRadius.circular(2.h),
              ),
            ),
            SizedBox(height: isMobile ? 20.h : isDesktop ? 40.h : 32.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isMobile ? 20.h : 28.h),
                 boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: -5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isMobile ? 20.h : 28.h),
                child: isDesktop
                ? SizedBox(
                height: 750.sH,
                width: double.infinity,
                child: NetworkImageSmart(
                  path: widget.image,
                  fit: BoxFit.cover,
                  radius: BorderRadius.circular(20.h ),
                ),
              )
                  : AspectRatio(
            aspectRatio: isMobile ? 4 / 2 :  3/ 2,
                  child: NetworkImageSmart(
                    path: widget.image,
                    fit: BoxFit.cover,
                    radius: BorderRadius.circular(isMobile ? 20.h : 28.h),
                  ),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
