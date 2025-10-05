import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import '../../../../../core/resourses/style_manager.dart';

class ScheduleTabs extends StatelessWidget {
  final List<String> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  const ScheduleTabs({
    super.key,
    required this.tabs,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final underlineWidth = w / tabs.length;

    return Column(
      children: [
        Row(
          children: List.generate(tabs.length, (i) {
            final selected = i == index;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.sSp),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: (selected
                            ? TextStyleHelper.instance.title14BoldInter
                            : TextStyleHelper.instance.title14BlackRegularInter)
                        .copyWith(color: selected ? AppColor.black : AppColor.gray500),
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
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: underlineWidth * index),
                width: underlineWidth,
                child: Container(height: 2, color: AppColor.black),
              ),
            ],
          ),
        )
      ],
    );
  }
}
