import 'dart:async'; // (you can remove this import now)
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/presentation/widgets/section_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

class ArtistsSection extends StatelessWidget {
  final List<Artist> artists;
  final String title;
  final EdgeInsetsGeometry? headerPadding;
  final double? itemSize;
  final VoidCallback? onSeeMore;

  /// Callback with tapped artist index
  final void Function(int index)? onArtistTap;

  final bool isLoading;
  final bool showSeeMoreButton;
  final String seeMoreButtonText;
  final bool showFollowButton;

  const ArtistsSection({
    super.key,
    required this.artists,
    this.title = 'Artists',
    this.headerPadding,
    this.itemSize,
    this.onSeeMore,
    this.onArtistTap,
    this.isLoading = false,
    this.showSeeMoreButton = true,
    this.seeMoreButtonText = 'See All Artists',
    this.showFollowButton = true,
  });

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 24.0;
    final cardSize = itemSize ?? 140.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeaderWidget(
          title: title,
          padding:
              headerPadding ??
              const EdgeInsets.symmetric(horizontal: horizontalPadding),
          showSeeMore:
              showSeeMoreButton && onSeeMore != null && artists.isNotEmpty,
          onSeeMore: onSeeMore,
          seeMoreButtonText: seeMoreButtonText,
        ),
        const SizedBox(height: 24),

        if (isLoading)
          ArtistLoadingState(itemSize: cardSize)
        else if (artists.isEmpty)
          ArtistEmptyState(itemSize: cardSize)
        else
          _buildArtistsList(context, cardSize, horizontalPadding),
      ],
    );
  }

  Widget _buildArtistsList(
    BuildContext context,
    double cardSize,
    double horizontalPadding,
  ) {
    return SizedBox(
      height: cardSize + 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: artists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (_, index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOutBack,
            child: ArtistCardWidget(
              artist: artists[index],
              index: index, // <- pass index
              size: cardSize,
              onTap: onArtistTap, // <- callback(int)
              showFollowButton: showFollowButton,
            ),
          );
        },
      ),
    );
  }
}

class ArtistLoadingState extends StatelessWidget {
  final double? itemSize;

  const ArtistLoadingState({super.key, this.itemSize});

  @override
  Widget build(BuildContext context) {
    final cardSize = itemSize ?? 140.0;

    return SizedBox(
      height: cardSize + 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (_, index) => _buildSkeletonArtistCard(index, cardSize),
      ),
    );
  }

  Widget _buildSkeletonArtistCard(int index, double cardSize) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      child: Column(
        children: [
          Container(
            height: cardSize,
            width: cardSize,
            decoration: const BoxDecoration(
              color: AppColor.gray200,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.gray400),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 16,
            width: 80,
            decoration: BoxDecoration(
              color: AppColor.gray200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 60,
            decoration: BoxDecoration(
              color: AppColor.gray200,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

class ArtistEmptyState extends StatelessWidget {
  final double? itemSize;

  const ArtistEmptyState({super.key, this.itemSize});

  @override
  Widget build(BuildContext context) {
    final cardSize = itemSize ?? 140.0;

    return Container(
      height: cardSize + 80,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColor.gray50, AppColor.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.gray200, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColor.gray100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_outlined,
                size: 40,
                color: AppColor.gray400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No artists available',
              style: TextStyleHelper.instance.title16MediumInter.copyWith(
                color: AppColor.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Discover talented artists soon',
              style: TextStyleHelper.instance.body14RegularInter.copyWith(
                color: AppColor.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArtistCardWidget extends StatefulWidget {
  final Artist artist;
  final int index; // <- index of this card
  final double? size;
  final void Function(int index)? onTap; // <- callback with index
  final VoidCallback? onFollow;
  final bool isFollowing;
  final bool showFollowButton;

  const ArtistCardWidget({
    super.key,
    required this.artist,
    required this.index,
    this.size,
    this.onTap,
    this.onFollow,
    this.isFollowing = false,
    this.showFollowButton = true,
  });

  @override
  State<ArtistCardWidget> createState() => _ArtistCardWidgetState();
}

class _ArtistCardWidgetState extends State<ArtistCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();

    // Call immediately (no loading delay)
    widget.onTap?.call(widget.index);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cardSize = widget.size ?? 140.0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: SizedBox(
              width: cardSize,
              child: Column(
                children: [
                  _buildAvatarSection(cardSize),
                  const SizedBox(height: 12),
                  Text(
                    widget.artist.name,
                    style: TextStyleHelper.instance.title16MediumInter.copyWith(
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection(double cardSize) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor.withOpacity(0.3),
            AppColor.primaryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(_isPressed ? 0.15 : 0.1),
            blurRadius: _isPressed ? 8 : 12,
            offset: Offset(0, _isPressed ? 2 : 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColor.white, width: 3),
        ),
        child: CustomImageView(
          imagePath: widget.artist.profileImage ?? '',
          height: cardSize - 8,
          width: cardSize - 8,
          radius: BorderRadius.circular((cardSize - 8) / 2),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
