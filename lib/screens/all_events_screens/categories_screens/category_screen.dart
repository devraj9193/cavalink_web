import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:provider/provider.dart';

import '../../../controllers/models/club_models/events_model.dart';
import '../../../controllers/providers/fence_providers.dart';
import '../../../utils/constants.dart';
import '../../../utils/navigation_helper.dart';
import '../../../utils/opacity_to_alpha.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/common_app_bar_widget.dart';
import '../../../widgets/loading_indicator.dart';
import '../event_details_screen.dart';
import 'participants_list_screen.dart';

class CategoryScreen extends StatefulWidget {
  final Ongoing event;
  const CategoryScreen({super.key, required this.event});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int expandedIndex = -1; // Only one expanded at a time
  Map<int, String?> selectedByCategory = {}; // Selected subcategories

  @override
  void initState() {
    super.initState();

    // Fetch Categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FenceProvider>(context, listen: false)
          .fetchCategories(context, widget.event.id ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    final provider = Provider.of<FenceProvider>(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: gWhiteColor,
        appBar: CommonAppBarWidget(
          onBackTap: () {
            NavigationHelper.push(
              context,
              EventDetailsScreen(event: widget.event),
            );
          },
          showBack: true,
          elevation: 0,
          title: widget.event.name,
          showTitleText: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          child: provider.isCategoriesLoading
              ? LoadingIndicator()
              : provider.categories == null || provider.categories!.isEmpty
                  ? Center(
                      child: Text(
                        "No categories available",
                        style: TextStyle(
                          fontSize: fontSize14,
                          fontFamily: fontMedium,
                          color: gBlackColor,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Wrap(
                        spacing: responsive.isMobile ? 2.w : 1.w,
                        runSpacing: 2.h,
                        children: List.generate(
                          provider.categories!.length,
                          (index) {
                            final category = provider.categories![index];
                            final subCategories = category.ageGroups ?? [];
                            final isExpanded = expandedIndex == index;

                            return Container(
                              width: responsive.isMobile ? 100.w : 30.w,
                              padding: EdgeInsets.symmetric(
                                  horizontal: responsive.isMobile ? 4.w : 2.w,
                                  vertical: 2.h),
                              decoration: BoxDecoration(
                                color: gWhiteColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: gBlackColor
                                        .withAlpha(AlphaHelper.fromOpacity(0.2)),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  //----------- TITLE ROW -----------
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        expandedIndex = isExpanded ? -1 : index;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.flag_outlined,
                                            color: secondaryColor, size: 3.h),
                                        SizedBox(
                                            width:
                                                responsive.isMobile ? 3.w : 1.w),
                                        Expanded(
                                          child: Text(
                                            category.categoryName ?? "",
                                            style: TextStyle(
                                              fontSize: fontSize15,
                                              fontFamily: fontMedium,
                                              color: gHintTextColor,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          isExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: gHintTextColor,
                                        ),
                                      ],
                                    ),
                                  ),

                                  //----------- EXPANDED GRID -----------
                                  if (isExpanded)
                                    Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 2.h,
                                          top: 3.h),
                                      child: Wrap(
                                        alignment: WrapAlignment.start,   // <<<  LEFT ALIGN FIX
                                        crossAxisAlignment: WrapCrossAlignment.start,
                                        spacing: responsive.isMobile ? 3.w : 1.w,
                                        runSpacing: 1.5.h,
                                        children: List.generate(
                                            subCategories.length, (i) {
                                          final sub = subCategories[i];
                                          final isSelected =
                                              selectedByCategory[index] ==
                                                  sub.ageGroupName;

                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedByCategory[index] =
                                                    sub.ageGroupName;
                                              });

                                              NavigationHelper.push(
                                                context,
                                                ParticipantsListScreen(
                                                  event: widget.event,
                                                  categories: category,
                                                  ageGroups: sub,
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: responsive.isMobile ? 40.w : 13.w,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 1.h),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? mainColor.withAlpha(AlphaHelper.fromOpacity(0.5))
                                                    : gWhiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? mainColor
                                                      : gGreyColor
                                                          .withAlpha(AlphaHelper.fromOpacity(0.3)),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: gGreyColor
                                                        .withAlpha(AlphaHelper.fromOpacity(0.12)),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  sub.ageGroupName ?? "",
                                                  style: TextStyle(
                                                    fontSize: fontSize13,
                                                    fontFamily: isSelected
                                                        ? fontMedium
                                                        : fontBook,
                                                    color: isSelected
                                                        ? gWhiteColor
                                                        : gHintTextColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
