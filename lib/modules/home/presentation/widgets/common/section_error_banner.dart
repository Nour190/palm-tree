import 'package:flutter/material.dart';

import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';

class SectionErrorBanner extends StatelessWidget {
  const SectionErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.accentColor,
    this.margin,
    this.padding,
    this.actionLabel = 'Retry',
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? accentColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? Colors.redAccent;
    final effectiveMargin =
        margin ?? EdgeInsets.symmetric(horizontal: 16.sW, vertical: 10.sH);
    final effectivePadding =
        padding ?? EdgeInsets.symmetric(horizontal: 16.sW, vertical: 12.sH);

    return Container(
      margin: effectiveMargin,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.sSp),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon ?? Icons.error_outline_rounded, color: color, size: 22.sSp),
          SizedBox(width: 12.sW),
          Expanded(
            child: Text(
              message,
              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: 12.sW),
            TextButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: 18.sSp, color: color),
              label: Text(
                actionLabel,
                style: TextStyleHelper.instance.body14MediumInter.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: color,
                padding: EdgeInsets.symmetric(
                  horizontal: 12.sW,
                  vertical: 8.sH,
                ),
                minimumSize: Size(0, 36.sH),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
