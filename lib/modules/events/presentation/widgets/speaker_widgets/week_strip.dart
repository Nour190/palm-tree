import 'package:flutter/material.dart';
import 'package:baseqat/modules/events/data/models/week_model.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

class WeekStrip extends StatelessWidget {
  final WeekModel week;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  const WeekStrip({
    super.key,
    required this.week,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                    style: TextStyle(
                      fontSize: 12.fSize,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 8.h),

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
                        horizontal: 12.h,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColor.black : Colors.white,
                        borderRadius: BorderRadius.circular(20.h),
                        border: Border.all(
                          color: isSelected
                              ? AppColor.black
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        '${week.dates[i]}',
                        style: TextStyle(
                          fontSize: 12.fSize,
                          fontWeight: FontWeight.w600,
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
