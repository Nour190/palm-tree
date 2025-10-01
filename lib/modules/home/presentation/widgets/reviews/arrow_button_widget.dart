import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:flutter/material.dart';

class ArrowButtonWidget extends StatelessWidget {
  const ArrowButtonWidget({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label =
        icon == Icons.chevron_left ? 'Previous review' : 'Next review';
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColor.gray700,
        borderRadius: BorderRadius.circular(12.sH),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12.sH),
          child: Padding(
            padding: EdgeInsets.all(8.sH),
            child: Icon(icon, color: AppColor.whiteCustom, size: 28.sSp),
          ),
        ),
      ),
    );
  }
}
