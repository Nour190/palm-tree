import 'package:baseqat/modules/artist_details/presentation/widgets/network_image_smart.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

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

  bool get _isMobile => MediaQuery.of(context).size.width < 768;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;

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
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _slideController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: _isMobile
                  ? _text.headline32BoldInter.copyWith(fontSize: 28)
                  : _text.headline32BoldInter.copyWith(fontSize: 40),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              height: 4,
              width: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.gray900, AppColor.gray600],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: _isMobile ? 20 : 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_isMobile ? 20 : 28),
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
                borderRadius: BorderRadius.circular(_isMobile ? 20 : 28),
                child: SizedBox(
                  width: double.infinity,
                  height: _isMobile
                      ? 280
                      : _isTablet
                      ? 380
                      : 420,
                  child: NetworkImageSmart(
                    path: widget.image,
                    fit: BoxFit.cover,
                    radius: BorderRadius.circular(_isMobile ? 20 : 28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
