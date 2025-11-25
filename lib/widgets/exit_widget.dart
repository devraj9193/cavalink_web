import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../utils/constants.dart';
import '../utils/responsive_helper.dart';
import 'button_widget.dart';

class ExitWidget extends StatelessWidget {
  const ExitWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text("Hold On!",
            style: TextStyle(
                fontSize: fontSize20,
                fontFamily: fontBold,
                height: 1.4,
              color: gBlackColor
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Divider(
            color: gHintTextColor,
            thickness: 1.2,
          ),
        ),
        SizedBox(height: 3.h),
        Center(
          child: Text(
            'Do you want to exit an App?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: gHintTextColor,
              fontSize: fontSize16,
              fontFamily:fontMedium,
            ),
          ),
        ),
        SizedBox(height: 5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonWidget(
              text: "YES",
              onPressed:() => SystemNavigator.pop(),
              isLoading: false,
              buttonWidth: responsive.isMobile ? 40.w : 10.w ,
              radius: 8,
              color: gSecondaryColor,
              textColor: gWhiteColor,
            ),
            SizedBox(width: 3.w),
            ButtonWidget(
              text: "NO",
              onPressed:() => Navigator.of(context).pop(false),
              isLoading: false,
              buttonWidth: responsive.isMobile ? 40.w : 10.w ,
              radius: 8,
              color: gWhiteColor,
              textColor: gBlackColor,
            ),
          ],
        ),
        SizedBox(height: 3.h)
      ],
    );
  }
}
