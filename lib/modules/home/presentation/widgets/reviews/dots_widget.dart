import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:flutter/material.dart';

class DotsWidget extends StatelessWidget {
  const DotsWidget({
    super.key,
    required this.length,
    required this.current,
    required this.onTap,
  });

  final int length;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.sW,
      children: List.generate(length, (i) {
        final bool active = current == i;
        final double w = active
            ? (Responsive.isDesktop(context) ? 28.sW : 22.sW)
            : 8.sW;
        return Semantics(
          button: true,
          label: 'Go to review ${i + 1}',
          child: GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              height: 8.sH,
              width: w,
              decoration: BoxDecoration(
                color: active ? AppColor.whiteCustom : AppColor.gray600,
                borderRadius: BorderRadius.circular(4.sH),
              ),
            ),
          ),
        );
      }),
    );
  }
}
