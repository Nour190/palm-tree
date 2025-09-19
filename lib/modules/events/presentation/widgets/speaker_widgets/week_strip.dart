import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/modules/events/data/models/week_model.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

import '../../../../../core/resourses/style_manager.dart';

class WeekStrip extends StatelessWidget {
  final WeekModel week;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;
  final bool isDesktop;

  const WeekStrip({
    super.key,
    required this.week,
    required this.selectedIndex,
    required this.onDaySelected,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20.sSp : 8.sSp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        border: Border.all(color: AppColor.blueGray100),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Weekday labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              return Expanded(
                child: Center(
                  child: Text(
                    week.weekdays[i],
                    style: TextStyleHelper.instance.body12MediumInter.copyWith(
                      //fontSize: isDesktop ? 14 : 12,
                      color: AppColor.gray600,
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: isDesktop ? 12 : 8),

          // Date pills (tappable)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final isSelected = i == selectedIndex;
              return Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () => onDaySelected(i),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 16 : 12,
                        vertical: isDesktop ? 12 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColor.black : Colors.white,
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
                        border: Border.all(
                          color: isSelected
                              ? AppColor.black
                              : AppColor.blueGray100,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColor.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Text(
                        '${week.dates[i]}',
                        style: TextStyleHelper.instance.body14MediumInter.copyWith(
                         // fontSize: isDesktop ? 16 : 14,
                          color: isSelected ? Colors.white : AppColor.black,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
