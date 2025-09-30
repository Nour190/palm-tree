// EventDetailsView (Light / White Primary) — mobile, tablet, desktop, web
// Changes from dark version:
//  • Switched to white surfaces / light neutrals
//  • Removed dark decorative background rings
//  • Adjusted text/icon/border colors for light theme
//  • Light chips & details; blue CTA for "Open in Maps"
//
// Dependencies:
//   url_launcher: ^6.3.0
//   geolocator: ^12.0.0 (or your project version)
//
// Notes:
// - This file avoids external color/style helpers so it can drop in.
// - Uses your existing size extensions: .sW, .sH, .sSp and .r.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

// If you keep these, point them to your local paths
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

import 'package:baseqat/modules/events/data/models/gallery_item.dart';
import 'package:baseqat/modules/home/data/models/events_model.dart';

const String kDefaultEventImageUrl =
    'https://picsum.photos/seed/baseqat-event/1200/750';

// Optional max content width for desktop/web
const double _kMaxContentWidth = 1100;

class EventDetailsView extends StatelessWidget {
  const EventDetailsView({
    super.key,
    required this.event,
    this.galleryBlocks = const [],
    this.onBack,
  });

  final Event event;
  final List<GalleryItem> galleryBlocks;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    // Light theme + white primary look
    final background = Colors.white;
    final cardColor = Colors.white;
    final surface = Colors.white;
    final onBackground = Colors.black87;
    final onSecondary = Colors.black54;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Stack(
          children: [
            // Removed dark decorative rings for a clean white background
            ..._buildBackgroundShapes(),

            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.sW, 20.sH, 20.sW, 0),
                    child: _NavigationHeader(
                      title: event.title,
                      onBack: onBack,
                      iconColor: Colors.black87,
                      chipColor: Colors.black12,
                    ),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.sW, 16.sH, 16.sW, 24.sH),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _kMaxContentWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _EventHeroSection(event: event, borderRadius: 20.r),
                            SizedBox(height: 18.sH),
                            _EventInfoSection(
                              event: event,
                              onBackground: onBackground,
                              onSecondary: onSecondary,
                            ),
                            SizedBox(height: 20.sH),

                            // Responsive split for desktop: details + overview
                            LayoutBuilder(
                              builder: (context, c) {
                                final isWide = c.maxWidth >= 900;
                                if (!isWide) {
                                  return Column(
                                    children: [
                                      _EventDetailsCard(
                                        event: event,
                                        cardColor: cardColor,
                                        onBackground: onBackground,
                                        onSecondary: onSecondary,
                                      ),
                                      SizedBox(height: 16.sH),
                                      _OverviewSection(
                                        event: event,
                                        cardColor: cardColor,
                                        onBackground: onBackground,
                                        onSecondary: onSecondary,
                                      ),
                                    ],
                                  );
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _OverviewSection(
                                        event: event,
                                        cardColor: cardColor,
                                        onBackground: onBackground,
                                        onSecondary: onSecondary,
                                      ),
                                    ),
                                    SizedBox(width: 16.sW),
                                    Expanded(
                                      flex: 2,
                                      child: _EventDetailsCard(
                                        event: event,
                                        cardColor: cardColor,
                                        onBackground: onBackground,
                                        onSecondary: onSecondary,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            SizedBox(height: 24.sH),
                            _ArtistGallerySection(
                              galleryBlocks: galleryBlocks,
                              cardColor: surface,
                              onBackground: onBackground,
                              onSecondary: onSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundShapes() {
    // Return empty: no dark rings on white background
    return const <Widget>[];
  }
}

// ——————————— Header ———————————

class _NavigationHeader extends StatelessWidget {
  const _NavigationHeader({
    required this.title,
    this.onBack,
    this.iconColor = Colors.black87,
    this.chipColor = Colors.black12,
  });

  final String title;
  final VoidCallback? onBack;
  final Color iconColor;
  final Color chipColor;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 24.sSp,
      color: Colors.black87,
    );

    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 44.sW,
            height: 44.sW,
            decoration: BoxDecoration(
              color: chipColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Transform.rotate(
              angle: -math.pi / 2,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18.sSp,
                color: iconColor,
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: textStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 44.sW),
      ],
    );
  }
}

// ——————————— Event Hero ———————————

class _EventHeroSection extends StatelessWidget {
  const _EventHeroSection({required this.event, required this.borderRadius});

  final Event event;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          _EnhancedImage(
            url: event.bannerImageUrl,
            height: 280.sH,
            width: double.infinity,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          // Subtle gradient for text readability on images
          Container(
            height: 280.sH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
              ),
            ),
          ),
          // Badges
          Positioned(
            left: 16.sW,
            top: 16.sH,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.isFeatured)
                  _StatusBadge(
                    text: 'Featured',
                    color: const Color(0xFF10B981),
                  ),
                if (event.isFeatured && (event.category ?? '').isNotEmpty)
                  SizedBox(height: 8.sH),
                if ((event.category ?? '').isNotEmpty)
                  _StatusBadge(
                    text: event.category!,
                    color: const Color(0xFF6366F1),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ——————————— Info Bar ———————————

class _EventInfoSection extends StatelessWidget {
  const _EventInfoSection({
    required this.event,
    required this.onBackground,
    required this.onSecondary,
  });

  final Event event;
  final Color onBackground;
  final Color onSecondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: _EnhancedImage(
              url: event.avatarImageUrl ?? event.bannerImageUrl,
              height: 72.sW,
              width: 72.sW,
            ),
          ),
        ),
        SizedBox(width: 16.sW),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 22.sSp,
                  fontWeight: FontWeight.w700,
                  color: onBackground,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6.sH),
              Text(
                _formatDateRange(event.startAt, event.endAt, event.timezone),
                style: TextStyle(
                  fontSize: 15.sSp,
                  fontWeight: FontWeight.w400,
                  color: onSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ——————————— Details Card ———————————

class _EventDetailsCard extends StatelessWidget {
  const _EventDetailsCard({
    required this.event,
    required this.cardColor,
    required this.onBackground,
    required this.onSecondary,
  });

  final Event event;
  final Color cardColor;
  final Color onBackground;
  final Color onSecondary;

  @override
  Widget build(BuildContext context) {
    final address = _formatAddress(
      event.venueName,
      event.addressLine,
      event.district,
      event.city,
      event.country,
    );

    final hasCoords = event.latitude != null && event.longitude != null;
    final hasAddress = address.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(20.sW),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Details',
            style: TextStyle(
              fontSize: 20.sSp,
              fontWeight: FontWeight.w700,
              color: onBackground,
            ),
          ),
          SizedBox(height: 16.sH),
          _DetailRow(
            icon: Icons.schedule_outlined,
            label: 'When',
            value: _formatDateRange(event.startAt, event.endAt, event.timezone),
            onTap: null,
            onSecondary: onSecondary,
            onBackground: onBackground,
          ),
          if (hasAddress) ...[
            SizedBox(height: 12.sH),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Where',
              value: address,
              onTap: () =>
                  _openMaps(useCurrentAsOrigin: true, address: address),
              onSecondary: onSecondary,
              onBackground: onBackground,
            ),
          ],
          if (hasCoords) ...[
            SizedBox(height: 12.sH),
            _DetailRow(
              icon: Icons.my_location_outlined,
              label: 'Coordinates',
              value:
                  '${event.latitude!.toStringAsFixed(4)}, ${event.longitude!.toStringAsFixed(4)}',
              onTap: () => _openMaps(
                useCurrentAsOrigin: true,
                lat: event.latitude,
                lng: event.longitude,
              ),
              onSecondary: onSecondary,
              onBackground: onBackground,
            ),
          ],
          if ((event.category ?? '').isNotEmpty || event.tags.isNotEmpty) ...[
            SizedBox(height: 16.sH),
            _TagsSection(
              category: event.category,
              tags: event.tags,
              chipBg: Colors.black12,
              chipBorder: Colors.black26,
              chipText: Colors.black87,
              subColor: onSecondary,
            ),
          ],
          if (hasAddress || hasCoords) ...[
            SizedBox(height: 18.sH),
            _OpenInMapsButton(
              address: hasAddress ? address : null,
              lat: event.latitude,
              lng: event.longitude,
            ),
          ],
        ],
      ),
    );
  }
}

class _OpenInMapsButton extends StatelessWidget {
  const _OpenInMapsButton({this.address, this.lat, this.lng});

  final String? address;
  final double? lat;
  final double? lng;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.sH,
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, // friendly CTA on white
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        onPressed: () => _openMaps(
          useCurrentAsOrigin: true,
          address: address,
          lat: lat,
          lng: lng,
        ),
        icon: const Icon(Icons.map_outlined),
        label: const Text('Open in Maps'),
      ),
    );
  }
}

// ——————————— Overview ———————————

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({
    required this.event,
    required this.cardColor,
    required this.onBackground,
    required this.onSecondary,
  });

  final Event event;
  final Color cardColor;
  final Color onBackground;
  final Color onSecondary;

  @override
  Widget build(BuildContext context) {
    final description = (event.description ?? 'No description provided.')
        .trim();

    return Container(
      padding: EdgeInsets.all(20.sW),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: TextStyle(
              fontSize: 20.sSp,
              fontWeight: FontWeight.w700,
              color: onBackground,
            ),
          ),
          SizedBox(height: 12.sH),
          Text(
            description,
            style: TextStyle(
              fontSize: 16.sSp,
              fontWeight: FontWeight.w400,
              height: 1.6,
              color: onSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ——————————— Gallery ———————————

class _ArtistGallerySection extends StatelessWidget {
  const _ArtistGallerySection({
    required this.galleryBlocks,
    required this.cardColor,
    required this.onBackground,
    required this.onSecondary,
  });

  final List<GalleryItem> galleryBlocks;
  final Color cardColor;
  final Color onBackground;
  final Color onSecondary;

  @override
  Widget build(BuildContext context) {
    final items = galleryBlocks.isNotEmpty
        ? galleryBlocks
        : _getDefaultGallery();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Artist Gallery',
          style: TextStyle(
            fontSize: 22.sSp,
            fontWeight: FontWeight.w700,
            color: onBackground,
          ),
        ),
        SizedBox(height: 12.sH),
        LayoutBuilder(
          builder: (context, c) {
            final is3 = c.maxWidth >= 1100;
            final is2 = c.maxWidth >= 720 && c.maxWidth < 1100;

            if (is3) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final chunk in _chunk(items, 3))
                    Expanded(
                      child: Column(
                        children: [
                          for (final item in chunk)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 16.sH,
                                right: 8.sW,
                                left: 8.sW,
                              ),
                              child: _ArtistGalleryItem(
                                item: item,
                                cardColor: cardColor,
                                onBackground: onBackground,
                                onSecondary: onSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            } else if (is2) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final chunk in _chunk(items, 2))
                    Expanded(
                      child: Column(
                        children: [
                          for (final item in chunk)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 16.sH,
                                right: 8.sW,
                                left: 8.sW,
                              ),
                              child: _ArtistGalleryItem(
                                item: item,
                                cardColor: cardColor,
                                onBackground: onBackground,
                                onSecondary: onSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            }

            // 1-column fallback
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in items)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.sH),
                    child: _ArtistGalleryItem(
                      item: item,
                      cardColor: cardColor,
                      onBackground: onBackground,
                      onSecondary: onSecondary,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  List<GalleryItem> _getDefaultGallery() {
    return [
      GalleryItem(
        artistId: 'g1',
        imageUrl: kDefaultEventImageUrl,
        artistName: 'Whispers of Color',
        artistProfileImage: kDefaultEventImageUrl,
      ),
      GalleryItem(
        artistId: 'g2',
        imageUrl: kDefaultEventImageUrl,
        artistName: 'Amazing B.O',
        artistProfileImage: kDefaultEventImageUrl,
      ),
      GalleryItem(
        artistId: 'g3',
        imageUrl: kDefaultEventImageUrl,
        artistName: 'Echoes of the Soul',
        artistProfileImage: kDefaultEventImageUrl,
      ),
    ];
  }

  List<List<GalleryItem>> _chunk(List<GalleryItem> list, int parts) {
    final result = <List<GalleryItem>>[];
    for (int i = 0; i < parts; i++) {
      result.add([]);
    }
    for (int i = 0; i < list.length; i++) {
      result[i % parts].add(list[i]);
    }
    return result;
  }
}

// ——————————— Small UI Parts ———————————

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.sW, vertical: 6.sH),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12.sSp,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onBackground,
    required this.onSecondary,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color onBackground;
  final Color onSecondary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.sW,
          height: 40.sW,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 20.sSp, color: Colors.black87),
        ),
        SizedBox(width: 12.sW),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sSp,
                  fontWeight: FontWeight.w600,
                  color: onSecondary,
                ),
              ),
              SizedBox(height: 2.sH),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sSp,
                  fontWeight: FontWeight.w400,
                  color: onBackground,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap == null) return row;

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.sH),
        child: row,
      ),
    );
  }
}

class _TagsSection extends StatelessWidget {
  const _TagsSection({
    required this.category,
    required this.tags,
    required this.chipBg,
    required this.chipBorder,
    required this.chipText,
    required this.subColor,
  });

  final String? category;
  final List<String> tags;
  final Color chipBg;
  final Color chipBorder;
  final Color chipText;
  final Color subColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: TextStyle(
            fontSize: 14.sSp,
            fontWeight: FontWeight.w700,
            color: subColor,
          ),
        ),
        SizedBox(height: 8.sH),
        Wrap(
          spacing: 8.sW,
          runSpacing: 8.sH,
          children: [
            if ((category ?? '').isNotEmpty)
              _TagChip(category!, chipBg, chipBorder, chipText, false),
            ...tags.map(
              (t) => _TagChip(t, chipBg, chipBorder, chipText, false),
            ),
          ],
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip(this.text, this.bg, this.border, this.textColor, this.primary);

  final String text;
  final Color bg;
  final Color border;
  final Color textColor;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = primary ? Colors.blue.shade600 : bg;
    final effectiveText = primary
        ? Colors.white
        : textColor; // not used in this light build

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.sW, vertical: 8.sH),
      decoration: BoxDecoration(
        color: effectiveBg, // bg for normal, blue for primary if ever used
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: primary ? Colors.white : textColor,
          fontSize: 13.sSp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ArtistGalleryItem extends StatelessWidget {
  const _ArtistGalleryItem({
    required this.item,
    required this.cardColor,
    required this.onBackground,
    required this.onSecondary,
  });

  final GalleryItem item;
  final Color cardColor;
  final Color onBackground;
  final Color onSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EnhancedImage(
            url: item.imageUrl,
            height: 240.sH,
            width: double.infinity,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.sW),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _EnhancedImage(
                      url: item.artistProfileImage,
                      height: 48.sW,
                      width: 48.sW,
                    ),
                  ),
                ),
                SizedBox(width: 12.sW),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (item.artistName ?? 'Unknown Artist').trim(),
                        style: TextStyle(
                          fontSize: 18.sSp,
                          fontWeight: FontWeight.w700,
                          color: onBackground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.sH),
                      Text(
                        'Artist',
                        style: TextStyle(
                          fontSize: 14.sSp,
                          fontWeight: FontWeight.w400,
                          color: onSecondary,
                        ),
                      ),
                    ],
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

class _DecorativeShape extends StatelessWidget {
  const _DecorativeShape({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.angleDeg,
    this.mirror = false,
    this.color = const Color.fromRGBO(0, 0, 0, 0.06),
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final double angleDeg;
  final bool mirror;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateZ(angleDeg * math.pi / 180)
          ..scale(mirror ? -0.83 : 0.83, 0.83),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 3),
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
      ),
    );
  }
}

class _EnhancedImage extends StatelessWidget {
  const _EnhancedImage({
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = _isValidUrl(url) ? url! : kDefaultEventImageUrl;

    Widget imageWidget = Image.network(
      effectiveUrl,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingState();
      },
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.black38,
        size: 32,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
        ),
      ),
    );
  }

  bool _isValidUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final uri = Uri.tryParse(url.trim());
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }
}

// ——————————— Utilities ———————————

String _formatDateRange(DateTime? start, DateTime? end, String timezone) {
  if (start == null && end == null) return 'Date TBD';

  final startDate = start?.toLocal();
  final endDate = end?.toLocal();

  if (startDate != null && endDate != null) {
    if (_isSameDay(startDate, endDate)) {
      return '${_formatDate(startDate)} • $timezone';
    }

    if (startDate.year == endDate.year) {
      if (startDate.month == endDate.month) {
        return '${_monthName(startDate.month)} ${startDate.day}–${endDate.day}, ${startDate.year} • $timezone';
      }
      return '${_formatDate(startDate)} – ${_formatDate(endDate)} • $timezone';
    }

    return '${_formatDate(startDate)} – ${_formatDate(endDate)} • $timezone';
  }

  final singleDate = startDate ?? endDate!;
  return '${_formatDate(singleDate)} • $timezone';
}

String _formatDate(DateTime date) {
  return '${_monthName(date.month)} ${date.day}, ${date.year}';
}

String _monthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[(month - 1).clamp(0, 11)];
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatAddress(
  String? venue,
  String? line,
  String? district,
  String? city,
  String? country,
) {
  final addressParts = <String>[
    if ((venue ?? '').trim().isNotEmpty) venue!.trim(),
    if ((line ?? '').trim().isNotEmpty) line!.trim(),
    if ((district ?? '').trim().isNotEmpty) district!.trim(),
    if ((city ?? '').trim().isNotEmpty) city!.trim(),
    if ((country ?? '').trim().isNotEmpty) country!.trim(),
  ];
  return addressParts.join(', ');
}

Future<void> _openMaps({
  String? address,
  double? lat,
  double? lng,
  bool useCurrentAsOrigin = false,
}) async {
  Uri uri;

  String? destination;
  if (lat != null && lng != null) {
    destination = '$lat,$lng';
  } else if (address != null && address.trim().isNotEmpty) {
    destination = address.trim();
  }

  if (useCurrentAsOrigin && destination != null) {
    String originParam = 'Current+Location';
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      var permission = await Geolocator.checkPermission();
      if (serviceEnabled) {
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
          );
          originParam = '${pos.latitude},${pos.longitude}';
        }
      }
    } catch (_) {
      // Ignore and fall back to 'Current+Location'
    }

    final destParam = Uri.encodeComponent(destination);
    uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$originParam&destination=$destParam',
    );
  } else if (destination != null) {
    final q = Uri.encodeComponent(destination);
    uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
  } else {
    return;
  }

  if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else if (address != null && address.trim().isNotEmpty) {
    final q = Uri.encodeComponent(address.trim());
    uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
  } else {
    return;
  }

  if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
    // Fallback: try external application explicitly
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
