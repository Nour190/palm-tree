import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'arrow_button_widget.dart';
import 'dots_widget.dart';

class BottomBarWidget extends StatelessWidget {
  const BottomBarWidget({
    super.key,
    required this.length,
    required this.current,
    required this.onDotTap,
    required this.onPrev,
    required this.onNext,
  });

  final int length;
  final int current;
  final ValueChanged<int> onDotTap;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isDesktop)
          ArrowButtonWidget(icon: Icons.chevron_left, onPressed: onPrev),
        SizedBox(width: isDesktop ? 16.sW : 0),
        DotsWidget(length: length, current: current, onTap: onDotTap),
        SizedBox(width: isDesktop ? 16.sW : 0),
        if (isDesktop)
          ArrowButtonWidget(icon: Icons.chevron_right, onPressed: onNext),
      ],
    );
  }
}
