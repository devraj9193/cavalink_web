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
import '../../../widgets/common_app_bar_widget.dart';
import '../../../widgets/common_search_bar.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/text_field_widgets/common_drop_down.dart';
import 'category_screen.dart';
import 'fence_screen.dart';
import 'results_screen.dart';

class ParticipantsListScreen extends StatefulWidget {
  final Ongoing event;
  final Category categories;
  final AgeGroups ageGroups;
  const ParticipantsListScreen({
    super.key,
    required this.event,
    required this.categories,
    required this.ageGroups,
  });

  @override
  State<ParticipantsListScreen> createState() => _ParticipantsListScreenState();
}

class _ParticipantsListScreenState extends State<ParticipantsListScreen> {
  final searchController = TextEditingController();
  bool isSearching = false;

  bool get isSearchActive => isSearching && searchController.text.isNotEmpty;

  List<Participants> filteredParticipants = [];
  String selectedCompany = "All Clubs";
  String selectedStatus = "All Status";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FenceProvider>(context, listen: false);

      provider
          .fetchParticipants(
        context,
        widget.event.id ?? 0,
        widget.categories.categoryId ?? 0,
      )
          .then((_) {
        setState(() {
          filteredParticipants = List.from(provider.participants ?? []);
        });
      });
    });

    searchController.addListener(applyFilters);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void applyFilters() {
    final provider = Provider.of<FenceProvider>(context, listen: false);

    String query = searchController.text.toLowerCase();
    List<Participants> fullList = provider.participants ?? [];

    setState(() {
      filteredParticipants = fullList.where((p) {
        final matchesSearch =
            (p.clubName ?? "").toLowerCase().contains(query) ||
                (p.riderName ?? "").toLowerCase().contains(query) ||
                (p.horseName ?? "").toLowerCase().contains(query);

        final matchesCompany = selectedCompany == "All Clubs"
            ? true
            : p.clubName == selectedCompany;

        final matchesStatus = selectedStatus == "All Status"
            ? true
            : getStatusLabel(p.status) ==
                selectedStatus; // ✅ compare with label

        return matchesSearch && matchesCompany && matchesStatus;
      }).toList();
    });
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 3.w),
              child: CommonSearchBar(
                controller: searchController,
                onChanged: (val) => applyFilters(),
                width: double.maxFinite,
                onClear: () {
                  searchController.clear();
                  applyFilters();
                },
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => isSearching = false),
            icon: Icon(Icons.close, color: gBlackColor, size: 2.5.h),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    final provider = Provider.of<FenceProvider>(context);

    List<String> companyList = [
      "All Clubs",
      ...{...(provider.participants ?? []).map((e) => e.clubName ?? "")}
    ];

    List<String> statusList = [
      "All Status",
      ...{...(provider.participants ?? []).map((e) => getStatusLabel(e.status))}
    ];

    return PopScope(canPop: false,
      child: Scaffold(
        backgroundColor: gWhiteColor,
        appBar: CommonAppBarWidget(
          onBackTap: () {
            NavigationHelper.push(
              context,
              CategoryScreen(event: widget.event),
            );
          },
          showBack: true,
          elevation: 0,
          title:
              "${widget.categories.categoryName} - ${widget.ageGroups.ageGroupName}",
          showTitleText: !isSearching,
          customTitle: isSearching ? _buildSearchBar() : null,
          customAction: !isSearching
              ? Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 1.w),
                      child: IconButton(
                        onPressed: () => setState(() => isSearching = true),
                        icon: Icon(Icons.search, color: gBlackColor, size: 3.5.h),
                      ),
                    ),
                  ],
                )
              : null,
        ),
        body: provider.isParticipantsLoading
            ? LoadingIndicator()
            : provider.participants == null || provider.participants!.isEmpty
                ? Center(
                    child: Text(
                      "No participants available",
                      style: TextStyle(
                        fontSize: fontSize14,
                        fontFamily: fontMedium,
                        color: gBlackColor,
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: responsive.isMobile ? 40.w : 20.w,
                              child: CommonDropdown(
                                label: "Club",
                                isFullBorder: true,
                                value: selectedCompany,
                                showCheckIcon: false,
                                priority: companyList,
                                onChanged: (value) {
                                  selectedCompany = value!;
                                  applyFilters();
                                },
                                validator: (v) => null,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            SizedBox(
                              width: responsive.isMobile ? 40.w : 20.w,
                              child: CommonDropdown(
                                label: "Status",
                                isFullBorder: true,
                                value: selectedStatus,
                                showCheckIcon: false,
                                priority: statusList,
                                onChanged: (value) {
                                  selectedStatus = value!;
                                  applyFilters();
                                },
                                validator: (v) => null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Expanded(
                          child: filteredParticipants.isEmpty
                              ? Center(
                                  child: Text(
                                    "No participants found",
                                    style: TextStyle(
                                      color: gHintTextColor,
                                      fontSize: fontSize15,
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment: WrapCrossAlignment.start,
                                    spacing: responsive.isMobile ? 2.w : 3.w,
                                    runSpacing: 3.h,
                                    children: List.generate(
                                        filteredParticipants.length, (index) {
                                      final p = filteredParticipants[index];

                                      return GestureDetector(
                                        onTap: () {
                                          if (p.status == "registered") {
                                            NavigationHelper.push(
                                              context,
                                              FenceScreen(
                                                event: widget.event,
                                                categories: widget.categories,
                                                ageGroups: widget.ageGroups,
                                                participants: p,
                                              ),
                                            );
                                          } else {
                                            NavigationHelper.push(
                                              context,
                                              ResultsScreen(
                                                event: widget.event,
                                                categories: widget.categories,
                                                ageGroups: widget.ageGroups,
                                                participants: p,
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          width: responsive.isMobile
                                              ? 100.w
                                              : 45.w, // Responsive size
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border(
                                              left: BorderSide(
                                                color: getStatusColor(p.status),
                                                width: 8,
                                              ),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              )
                                            ],
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.person,
                                                    size: responsive.isMobile
                                                        ? 2.h
                                                        : 3.h,
                                                    color: Colors.green,
                                                  ),
                                                  SizedBox(
                                                      width: responsive.isMobile
                                                          ? 2.w
                                                          : 1.w),
                                                  Expanded(
                                                    child: Text(
                                                      "${p.riderName} | ${p.riderId}",
                                                      style: TextStyle(
                                                        fontSize: fontSize15,
                                                        fontFamily: fontMedium,
                                                        color: gBlackColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 1.h),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.business,
                                                    size: responsive.isMobile
                                                        ? 2.h
                                                        : 3.h,
                                                    color: Colors.blue,
                                                  ),
                                                  SizedBox(
                                                      width: responsive.isMobile
                                                          ? 2.w
                                                          : 1.w),
                                                  Expanded(
                                                    child: Text(
                                                      p.clubName!,
                                                      style: TextStyle(
                                                        fontSize: fontSize14,
                                                        fontFamily: fontBook,
                                                        color: gHintTextColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 1.h),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.pets,
                                                    size: responsive.isMobile
                                                        ? 2.h
                                                        : 3.h,
                                                    color: Colors.brown,
                                                  ),
                                                  SizedBox(
                                                      width: responsive.isMobile
                                                          ? 2.w
                                                          : 1.w),
                                                  Expanded(
                                                    child: Text(
                                                      "${p.horseName} | ${p.horseId}",
                                                      style: TextStyle(
                                                        fontSize: fontSize13,
                                                        fontFamily: fontBook,
                                                        color: gHintTextColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 1.h),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.flag,
                                                    size: responsive.isMobile
                                                        ? 2.h
                                                        : 3.h,
                                                    color: gPrimaryColor,
                                                  ),
                                                  SizedBox(
                                                      width: responsive.isMobile
                                                          ? 2.w
                                                          : 1.w),
                                                  Text(
                                                    getStatusLabel(p.status),
                                                    style: TextStyle(
                                                      fontSize: fontSize14,
                                                      fontFamily: fontMedium,
                                                      color: gBlackColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  String getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case "registered":
        return "New";
      case "withdrawn":
        return "Withdrawn";
      case "eliminated":
        return "Eliminated";
      case "active":
        return "Qualified";
      default:
        return "Unknown";
    }
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "registered":
        return Colors.white;
      case "withdrawn":
        return Colors.yellow;
      case "eliminated":
        return Colors.red;
      case "active":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
