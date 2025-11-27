import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

import '../../../controllers/models/club_models/categories_model.dart';
import '../../../controllers/models/club_models/events_model.dart';
import '../../../controllers/models/club_models/paricipants_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/opacity_to_alpha.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/common_app_bar_widget.dart';
import '../../../widgets/status_info.dart';

class ResultsScreen extends StatefulWidget {
  final Ongoing event;
  final Category categories;
  final AgeGroups ageGroups;
  final Participants participants;
  const ResultsScreen(
      {super.key,
      required this.event,
      required this.categories,
      required this.ageGroups,
      required this.participants});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: gWhiteColor,
        appBar: CommonAppBarWidget(
          onBackTap: () => Navigator.pop(context),
          showBack: true,
          elevation: 0,
          title:
              "${widget.categories.categoryName} - ${widget.ageGroups.ageGroupName}",
          showTitleText: true,
        ),
        body: responsive.isMobile
            ? buildMobileView(responsive)
            : buildWebView(responsive),
      ),
    );
  }

  buildWebView(ResponsiveHelper responsive) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              SizedBox(height: 5.h),
              riderDetails(responsive),
              SizedBox(height: 5.h),
              pointsDetails(responsive),
            ],
          ),
        ),
        Container(
          width: 1,
          height: double.infinity,
          color: Colors.grey.shade300,
          margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
        ),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              fenceDetails(responsive),
            ],
          ),
        ),
      ],
    );
  }

  buildMobileView(ResponsiveHelper responsive) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          riderDetails(responsive),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Divider(),
          ),
          pointsDetails(responsive),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Divider(),
          ),
          fenceDetails(responsive),
        ],
      ),
    );
  }

  riderDetails(ResponsiveHelper responsive) {
    return Center(
      child: Text(
        "Rider : ${widget.participants.riderName} | Horse : ${widget.participants.horseName}",
        style: TextStyle(
          fontSize: fontSize16,
          fontFamily: fontMedium,
          color: gBlackColor,
        ),
      ),
    );
  }

  pointsDetails(ResponsiveHelper responsive) {
    return Column(
      children: [
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: 1.5.h, horizontal: responsive.isMobile ? 5.w : 2.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(2, 0),
                )
              ],
              color: StatusHelper.getStatus(widget.participants.status).color,
            ),
            child: Text(
              StatusHelper.getStatus(widget.participants.status).label,
              style: TextStyle(
                fontSize: fontSize15,
                fontFamily: fontMedium,
                color: gWhiteColor,
              ),
            ),
          ),
        ),
        SizedBox(height: responsive.isMobile ? 2.h : 5.h),
        Padding(
          padding: responsive.isMobile
              ? EdgeInsets.symmetric(horizontal: 5.w)
              : EdgeInsets.only(right: 1.w, left: 3.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              statusBox(
                  "Jumping Penalty", widget.participants.jumpingPenalty ?? ''),
              SizedBox(width: 3.w),
              statusBox("Time Seconds", widget.participants.timeSeconds ?? ''),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: responsive.isMobile
              ? EdgeInsets.symmetric(horizontal: 5.w)
              : EdgeInsets.only(right: 1.w, left: 3.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              statusBox("Time Penalty", widget.participants.timePenalty ?? ''),
              SizedBox(width: 3.w),
              statusBox(
                  "Total Penalty", widget.participants.totalPenalty ?? ''),
            ],
          ),
        ),
      ],
    );
  }

  fenceDetails(ResponsiveHelper responsive) {
    final validFences = widget.participants.ageGroups?.fences
            ?.where((f) =>
                (f.resultCode != "null" && f.resultCode!.trim().isNotEmpty))
            .toList() ??
        [];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: responsive.isMobile ? 5.w : 1.w),
            child: Text(
              "Fence Details",
              style: TextStyle(
                fontSize: fontSize15,
                fontFamily: fontMedium,
                color: gBlackColor,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            itemCount: validFences.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
                horizontal: responsive.isMobile ? 5.w : 1.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: responsive.isMobile ? 3 : 5,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final f = validFences[index];
              return fenceBox(f.resultCode ?? '', f.name ?? '');
            },
          ),
        ],
      ),
    );
  }

  /// STATUS BOX WIDGET
  Widget statusBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(
                color: gHintTextColor.withAlpha(AlphaHelper.fromOpacity(0.3)),
                width: 1.3),
            borderRadius: BorderRadius.circular(12),
            color: gHintTextColor.withAlpha(AlphaHelper.fromOpacity(0.1))),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: fontSize15,
                fontFamily: kFontMedium,
                color: gHintTextColor,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              value,
              style: TextStyle(
                fontSize: fontSize18,
                fontFamily: kFontMedium,
                color: gBlackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FENCE BOX WIDGET
  Widget fenceBox(String resultCode, String fenceNo) {
    Color getColor() {
      switch (resultCode.toUpperCase()) {
        case "P":
          return Colors.green;
        case "R1":
          return Colors.orange;
        case "R2":
        case "4":
          return Colors.red;
        default:
          return gHintTextColor;
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border(
          bottom: BorderSide(
            color: getColor(),
            width: 8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 0),
          )
        ],
        color: Colors.white,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: resultCode.toUpperCase() == "P"
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: fontSize18 + 4, // slightly larger for visibility
                    )
                  : Text(
                      resultCode,
                      style: TextStyle(
                        fontSize: fontSize18,
                        fontFamily: fontMedium,
                        color: getColor(),
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: gHintTextColor.withAlpha(AlphaHelper.fromOpacity(0.1)),
                border: Border(
                  top: BorderSide(
                    color:
                        gHintTextColor.withAlpha(AlphaHelper.fromOpacity(0.1)),
                    width: 1,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                fenceNo,
                style: TextStyle(
                  fontSize: fontSize15,
                  fontFamily: fontMedium,
                  color: gHintTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
