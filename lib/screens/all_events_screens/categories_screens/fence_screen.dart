import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:provider/provider.dart';

import '../../../controllers/models/club_models/categories_model.dart';
import '../../../controllers/models/club_models/events_model.dart';
import '../../../controllers/models/club_models/paricipants_model.dart';
import '../../../controllers/providers/fence_providers.dart';
import '../../../utils/constants.dart';
import '../../../utils/navigation_helper.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/button_widget.dart';
import '../../../widgets/common_app_bar_widget.dart';
import 'total_points_screen.dart';

class FenceAnswers {
  int? id;
  String? name;
  String? resultCode;
  String? faultPenalty;
  String? notes;

  FenceAnswers({
    this.id,
    this.name,
    this.resultCode,
    this.faultPenalty,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "result_code": resultCode,
        "fault_penalty": faultPenalty,
        "notes": notes,
      };
}

class FenceScreen extends StatefulWidget {
  final Ongoing event;
  final Category categories;
  final AgeGroups ageGroups;
  final Participants participants;

  const FenceScreen({
    super.key,
    required this.ageGroups,
    required this.event,
    required this.categories,
    required this.participants,
  });

  @override
  State<FenceScreen> createState() => _FenceScreenState();
}

class _FenceScreenState extends State<FenceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FenceProvider>(context, listen: false)
          .loadFences(widget.participants.ageGroups?.fences ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    final fences = widget.ageGroups.fences ?? [];

    return PopScope(canPop: false,
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
        body: Consumer<FenceProvider>(
          builder: (context, provider, _) {
            final currentFenceData = fences[provider.currentFence];
            final fenceName = currentFenceData.name ?? "Fence";

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.isMobile ? 3.w : 35.w,vertical: 2.h),
              child: Column(
                children: [
                  // Rider | Horse (dummy now)
                  Center(
                    child: Text(
                      "Rider : ${widget.participants.riderName} | Horse : ${widget.participants.horseName}",
                      style: TextStyle(
                        fontSize: fontSize16,
                        fontFamily: fontMedium,
                        color: gBlackColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),

                  // Fence title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsive.isMobile ? 2.w : 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "FENCE : $fenceName",
                          style: TextStyle(
                            fontSize: fontSize20,
                            fontFamily: fontMedium,
                            color: gHintTextColor,
                          ),
                        ),
                        ButtonWidget(
                          text: "Withdrawn",
                          onPressed: () {
                            provider.withdrawn(context, onYes: () {
                              goToTotal(status: "withdrawn");
                            });
                          },
                          isLoading: false,
                          buttonWidth: responsive.isMobile ? 25.w : 10.w,
                          radius: 8,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Options
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      buildOption(provider, "PASS",responsive),
                      buildOption(provider, "R1",responsive),
                      buildOption(provider, "R2",responsive),
                      buildOption(provider, "4",responsive),
                    ],
                  ),
                  const Spacer(),

                  if (provider.r1SelectedForFence[provider.currentFence])
                    Text(
                      "Second Attempt",
                      style: TextStyle(
                        color: gSecondaryColor,
                        fontSize: fontSize14,
                        fontFamily: fontMedium,
                      ),
                    ),

                  const Spacer(),

                  // Navigation + Submit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // BACK + Counter + NEXT
                      Row(
                        children: [
                          IconButton(
                            onPressed: provider.currentFence > 0
                                ? provider.goBack
                                : null,
                            icon: Icon(Icons.arrow_back_ios, size: 2.5.h),
                          ),
                          Text(
                            "${provider.currentFence + 1} / ${provider.totalFences}",
                            style: TextStyle(
                              fontSize: fontSize13,
                              fontFamily: fontMedium,
                              color: gBlackColor,
                            ),
                          ),
                          IconButton(
                            onPressed:
                                provider.answers[provider.currentFence] != null &&
                                        !provider.isLastFence()
                                    ? provider.goNext
                                    : null,
                            icon: Icon(Icons.arrow_forward_ios, size: 2.5.h),
                          ),
                        ],
                      ),

                      // NEXT / SUBMIT BUTTON
                      ButtonWidget(
                        text: provider.isLastFence() ? "Submit" : "Next",
                        onPressed: provider.isLastFence()
                            ? (provider.allAnswered
                                ? () => goToTotal(status: "active")
                                : null)
                            : (provider.canGoNext(provider.currentFence)
                                ? () => checkMaxPenalty(provider)
                                : null),
                        isLoading: false,
                        radius: 8,
                        buttonWidth: responsive.isMobile ? 20.w : 8.w,
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Summary
                  Center(
                    child: Text(
                      "Pass points : ${provider.passPoints}   |   Penalty Points : ${provider.penaltyPoints}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildOption(FenceProvider provider, String text,ResponsiveHelper responsive) {
    final int index = provider.currentFence;
    final selections = provider.selections[index];
    final bool isSelected = selections.contains(text);

    bool isDisabled = false;

    // 1️⃣ Only ONE fence can use R1
    if (text == "R1") {
      if (provider.r1Used && !provider.r1SelectedForFence[index]) {
        isDisabled = true;
      }
    }

    // 2️⃣ R2 allowed ONLY after R1 is used anywhere
    if (text == "R2") {
      if (!provider.r1Used && !provider.r1SelectedForFence[index]) {
        isDisabled = true;
      }
    }

    // ❌ DO NOT DISABLE ANYTHING ELSE
    // PASS always enabled
    // 4 always enabled

    // COLORS
    Color bgColor = Colors.white;
    Color textColor = mainColor;

    if (isSelected) {
      switch (text) {
        case "PASS":
          bgColor = Colors.green;
          textColor = Colors.white;
          break;
        case "R1":
          bgColor = Colors.orange;
          textColor = Colors.white;
          break;
        case "R2":
        case "4":
          bgColor = Colors.red;
          textColor = Colors.white;
          break;
      }
    } else if (isDisabled) {
      bgColor = Colors.grey.shade300;
      textColor = Colors.grey;
    }

    return GestureDetector(
      onTap: isDisabled ? null : () => provider.selectAnswer(text),
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1,
        child: Container(
          width: responsive.isMobile ? 40.w : 13.w,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.transparent : mainColor,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontFamily: isSelected ? fontMedium : fontBook,
              fontSize: isSelected ? fontSize15 : fontSize13,
            ),
          ),
        ),
      ),
    );
  }

  void checkMaxPenalty(FenceProvider provider) {
    final maxPenalty =
        int.parse("${widget.participants.ageGroups?.maxPenalty}");

    if (provider.penaltyPoints > maxPenalty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Max Penalty Exceeded"),
          content: Text(
            "Your total penalty (${provider.penaltyPoints}) exceeds max allowed ($maxPenalty).",
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
                goToTotal(status: "eliminated");
              },
            ),
          ],
        ),
      );
    } else {
      provider.goNext();
    }
  }

  void goToTotal({required String status}) {
    NavigationHelper.push(
      context,
      TotalPointsScreen(
        event: widget.event,
        categories: widget.categories,
        ageGroups: widget.ageGroups,
        participants: widget.participants,
        status: status,
      ),
    );
  }
}
