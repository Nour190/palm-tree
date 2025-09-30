// event_tab.dart
import 'dart:math' as math;

import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/modules/home/data/models/events_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/responsive.dart';

class EventsTab extends StatelessWidget {
  final List<Event> events;
  final void Function(Event)? onOpen;
  final bool showImageUrlsInUI;

  const EventsTab({
    super.key,
    required this.events,
    this.onOpen,
    this.showImageUrlsInUI = false,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final double width = MediaQuery.of(context).size.width;
    final double scale = _calculateUIScale(width);

    final hPad = _clamp(16.0 * scale, 12, 24);
    final vPad = _clamp(14.0 * scale, 10, 22);
    final gap = _clamp(14.0 * scale, 10, 22);

    if (events.isEmpty) {
      return _buildEmptyState();
    }

    if (width >= 1200) {
      return _buildGridView(hPad, vPad, gap, scale);
    }

    return _buildListView(hPad, vPad, gap, scale);
  }

  Widget _buildGridView(double hPad, double vPad, double gap, double scale) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        childAspectRatio: .1,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) => EventCard(
        isLargeDesktop: true,
        event: events[index],
        scale: scale * 1.05,
        onTap: () => onOpen?.call(events[index]),
        showImageUrl: showImageUrlsInUI,
      ),
    );
  }

  Widget _buildListView(double hPad, double vPad, double gap, double scale) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      physics: const BouncingScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (context, index) => SizedBox(height: gap),
      itemBuilder: (context, index) => EventCard(
        isLargeDesktop: false,
        event: events[index],
        scale: scale,
        onTap: () => onOpen?.call(events[index]),
        showImageUrl: showImageUrlsInUI,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 64, color: AppColor.gray400),
          const SizedBox(height: 16),
          Text(
            'No events available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColor.gray600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for upcoming events',
            style: TextStyle(fontSize: 14, color: AppColor.gray500),
          ),
        ],
      ),
    );
  }

  double _calculateUIScale(double width) {
    if (width <= 400) return 1.0;
    if (width <= 800) return 1.08;
    return (width / 1200).clamp(1.10, 1.20);
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final double scale;
  final bool showImageUrl;
  final bool isLargeDesktop;

  const EventCard({
    super.key,
    required this.event,
    required this.scale,
    this.onTap,
    required this.showImageUrl,
    required this.isLargeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dimensions = _calculateDimensions(size, scale, context,isLargeDesktop);

    return Semantics(
      button: true,
      label: 'Open event ${event.title}',
      child: Material(
        color: AppColor.backgroundWhite,
        borderRadius: BorderRadius.circular(dimensions.borderRadius),
        elevation: 2,
        shadowColor: Colors.black12,
        child: InkWell(
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(dimensions.padding),
            child:
    //isLargeDesktop?
    Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBanner(dimensions),
                if (showImageUrl && _hasValidImageUrl(event.bannerImageUrl))
                  _buildImageUrlDisplay(context),
                SizedBox(height: dimensions.spacing),
                _buildEventInfo(dimensions),

              ],
            )
                  //:
            //     Row(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Expanded(child: _buildBanner(dimensions)),
            //         if (showImageUrl && _hasValidImageUrl(event.bannerImageUrl))
            //           _buildImageUrlDisplay(context),
            //         //SizedBox(height: dimensions.spacing),
            //         Expanded(child: _buildEventInfo(dimensions)),
            //       ],
            //     )
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(CardDimensions dimensions) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(dimensions.borderRadius),
      child: Container(
        height: dimensions.bannerHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.gray100,
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
        ),
        child: NetworkImageWidget(
          imageUrl: event.bannerImageUrl,
          fit: BoxFit.cover,
          semanticsLabel: 'Event banner for ${event.title}',
        ),
      ),
    );
  }

  Widget _buildImageUrlDisplay(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppColor.gray50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColor.gray200),
        ),
        child: SelectableText(
          event.bannerImageUrl!.trim(),
          style: TextStyle(
            fontSize: Responsive.responsiveFontSize(context, 10),
            color: AppColor.gray600,
          ),
          maxLines: 2,
        ),
      ),
    );
  }

  Widget _buildEventInfo(CardDimensions dimensions) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        EventAvatar(
          url: event.avatarImageUrl,
          radius: dimensions.avatarRadius,
          initials: _generateInitials(event.title),
        ),
        SizedBox(width: dimensions.avatarSpacing),
        Expanded(child: _buildTitleAndDate(dimensions)),
        SizedBox(width: dimensions.avatarSpacing * 0.8),
        _buildActionButton(dimensions),
      ],
    );
  }

  Widget _buildTitleAndDate(CardDimensions dimensions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          event.title,
          style: dimensions.titleStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: dimensions.tinySpacing),
        Text(
          DateFormatter.formatDateRange(event.startAt, event.endAt),
          style: dimensions.dateStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButton(CardDimensions dimensions) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.black,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: dimensions.actionButtonSize,
            height: dimensions.actionButtonSize,
            child: Icon(
              Icons.north_east_rounded,
              color: AppColor.white,
              size: dimensions.actionIconSize,
            ),
          ),
        ),
      ),
    );
  }

  CardDimensions _calculateDimensions(
    Size size,
    double scale,
    BuildContext context,
      bool isLargeDesktop,
  ) {
    final bannerHeight = _calculateBannerHeight(size, scale);
    final borderRadius = _clamp(12.0 * scale, 10, 16);
    final padding = _clamp(12.0 * scale, 10, 16);
    final spacing = _clamp(12.0 * scale, 8, 16);
    final tinySpacing = _clamp(3.0 * scale, 2, 5);
    final avatarRadius = _clamp(22.0 * scale, 18, 26);
    final avatarSpacing = _clamp(10.0 * scale, 8, 14);
    final actionButtonSize = _clamp(40.0 * scale, 34, 46);
    final actionIconSize = _clamp(20.0 * scale, 16, 24);

    final titleStyle = TextStyleHelper.instance.title16BoldInter;
    // TextStyle(
    //   fontSize:
    //       Responsive.responsiveFontSize(context, 16) * (0.98 + 0.02 * scale),
    //   fontFamily: 'Inter',
    //   fontWeight: FontWeight.w700,
    //   color: AppColor.gray900,
    //   height: 1.12,
    //   letterSpacing: -0.2,
    // );

    final dateStyle = TextStyleHelper.instance.body14RegularInter;
    // TextStyle(
    //   fontSize:
    //       Responsive.responsiveFontSize(context, 12) * (0.98 + 0.02 * scale),
    //   fontFamily: 'Inter',
    //   fontWeight: FontWeight.w400,
    //   color: AppColor.gray400,
    //   height: 1.12,
    // );

    return CardDimensions(
      bannerHeight: bannerHeight,
      borderRadius: borderRadius,
      padding: padding,
      spacing: spacing,
      tinySpacing: tinySpacing,
      avatarRadius: avatarRadius,
      avatarSpacing: avatarSpacing,
      actionButtonSize: actionButtonSize,
      actionIconSize: actionIconSize,
      titleStyle: titleStyle,
      dateStyle: dateStyle,
    );
  }
  double _calculateBannerHeight(Size size, double scale) {
    final aspectRatioHeight = size.width * 9 / 16;
    final maxByViewport = isLargeDesktop?
         size.height * 0.24: size.height * 2;

    final double cappedHeight;
    if (maxByViewport < 130.0) {
      cappedHeight = aspectRatioHeight.clamp(maxByViewport, 130.0);
    } else {
      cappedHeight = aspectRatioHeight.clamp(130.0, maxByViewport);
    }

    final minAllowed = math.min(130.0, maxByViewport);
    return _clamp(cappedHeight * (0.98 + 0.02 * scale), minAllowed, 240);
  }
  // double _calculateBannerHeight(Size size, double scale) {
  //   final aspectRatioHeight = size.width * 9 / 16;
  //   final maxByViewport = size.height * 0.24;
  //   final cappedHeight = aspectRatioHeight.clamp(130.0, maxByViewport);
  //   return _clamp(cappedHeight * (0.98 + 0.02 * scale), 130, 240);
  // }

  String _generateInitials(String title) {
    final words = title.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return 'E';

    final firstChar = words.first.isNotEmpty ? words.first[0] : 'E';
    final lastChar = words.length > 1 && words.last.isNotEmpty
        ? words.last[0]
        : '';

    return (firstChar + lastChar).toUpperCase();
  }

  bool _hasValidImageUrl(String? url) {
    return url != null && url.trim().isNotEmpty;
  }
}

class EventAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  final String initials;

  const EventAvatar({
    super.key,
    required this.url,
    required this.radius,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    final fallbackWidget = InitialsCircle(
      size: diameter,
      text: initials,
      backgroundColor: AppColor.gray100,
      textColor: AppColor.gray700,
    );

    return ClipOval(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: NetworkImageWidget(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: fallbackWidget,
          errorWidget: fallbackWidget,
          semanticsLabel: 'Event host avatar',
        ),
      ),
    );
  }
}

class InitialsCircle extends StatelessWidget {
  final double size;
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const InitialsCircle({
    super.key,
    required this.size,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.4,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class NetworkImageWidget extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? semanticsLabel;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final validUrl = _validateUrl(imageUrl);

    if (validUrl == null) {
      return _buildErrorWidget();
    }

    return Image.network(
      validUrl,
      fit: fit,
      semanticLabel: semanticsLabel,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        final progress = loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
            : null;

        return placeholder ?? _buildLoadingWidget(progress: progress);
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildErrorWidget();
      },
    );
  }

  String? _validateUrl(String? url) {
    if (url?.trim().isEmpty ?? true) return null;

    final trimmedUrl = url!.trim();
    final uri = Uri.tryParse(trimmedUrl);

    if (uri == null ||
        uri.host.isEmpty ||
        (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return null;
    }

    return trimmedUrl;
  }

  Widget _buildLoadingWidget({double? progress}) {
    return Container(
      color: AppColor.gray100,
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            value: progress,
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.gray600),
            backgroundColor: AppColor.gray200,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: AppColor.gray100,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: AppColor.gray400,
          size: 32,
        ),
      ),
    );
  }
}

class DateFormatter {
  static String formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return 'Date TBA';

    if (start != null && end == null) {
      return DateFormat('MMMM d, yyyy').format(start.toLocal());
    }

    if (start == null && end != null) {
      return 'Until ${DateFormat('MMMM d, yyyy').format(end.toLocal())}';
    }

    final startLocal = start!.toLocal();
    final endLocal = end!.toLocal();

    if (_isSameDay(startLocal, endLocal)) {
      return DateFormat('MMMM d, yyyy').format(startLocal);
    }

    if (startLocal.year == endLocal.year &&
        startLocal.month == endLocal.month) {
      return '${DateFormat('MMMM').format(startLocal)} ${startLocal.day}–${endLocal.day}, ${endLocal.year}';
    }

    if (startLocal.year == endLocal.year) {
      return '${DateFormat('MMM').format(startLocal)} ${startLocal.day} – ${DateFormat('MMM').format(endLocal)} ${endLocal.day}, ${endLocal.year}';
    }

    return '${DateFormat('MMM d, yyyy').format(startLocal)} – ${DateFormat('MMM d, yyyy').format(endLocal)}';
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class CardDimensions {
  final double bannerHeight;
  final double borderRadius;
  final double padding;
  final double spacing;
  final double tinySpacing;
  final double avatarRadius;
  final double avatarSpacing;
  final double actionButtonSize;
  final double actionIconSize;
  final TextStyle titleStyle;
  final TextStyle dateStyle;

  const CardDimensions({
    required this.bannerHeight,
    required this.borderRadius,
    required this.padding,
    required this.spacing,
    required this.tinySpacing,
    required this.avatarRadius,
    required this.avatarSpacing,
    required this.actionButtonSize,
    required this.actionIconSize,
    required this.titleStyle,
    required this.dateStyle,
  });
}

// Utility function
double _clamp(double value, double min, double max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}
