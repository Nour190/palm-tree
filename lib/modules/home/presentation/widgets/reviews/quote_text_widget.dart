import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:flutter/material.dart';

class QuoteTextWidget extends StatelessWidget {
  const QuoteTextWidget({
    super.key,
    required this.text,
    this.alignLeft = false,
    this.maxLines = 4,
  });

  final String text;
  final bool alignLeft;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final desktop = Responsive.isDesktop(context);

    final base = styles.body14MediumInter;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quotation accent
        Padding(
          padding: EdgeInsets.only(top: 2.sH, right: 8.sW),
          child: Icon(
            Icons.format_quote,
            size: 20.sSp,
            color: AppColor.gray200,
          ),
        ),
        Expanded(
          child: Text(
            text,
            textAlign: alignLeft ? TextAlign.left : TextAlign.center,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: base.copyWith(
              color: AppColor.gray200,
              height: desktop ? 1.5 : 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
