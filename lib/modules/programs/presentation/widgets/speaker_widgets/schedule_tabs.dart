import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flutter/material.dart';

class ScheduleTabs extends StatelessWidget {
  const ScheduleTabs({
    super.key,
    required this.tabs,
    required this.index,
    required this.onChanged,
  });

  final List<String> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final underlineWidth = MediaQuery.of(context).size.width / tabs.length;
    final verticalPadding = ProgramsLayout.spacingMedium(context);

    return Column(
      children: [
        Row(
          children: List.generate(tabs.length, (i) {
            final selected = i == index;
            final textStyle = selected
                ? ProgramsTypography.headingMedium(context)
                : ProgramsTypography.bodyPrimary(context);

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: verticalPadding),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: textStyle.copyWith(
                      color: selected ? AppColor.black : AppColor.gray500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(
          height: 2,
          child: Stack(
            children: [
              Container(color: AppColor.blueGray100),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: AlignmentDirectional.centerStart,
                margin: EdgeInsetsDirectional.only(
                  start: underlineWidth * index,
                ),
                width: underlineWidth,
                child: Container(height: 2, color: AppColor.black),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
