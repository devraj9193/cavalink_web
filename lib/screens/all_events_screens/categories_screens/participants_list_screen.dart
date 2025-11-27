import 'package:cavalink_web/utils/opacity_to_alpha.dart';
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
import '../../../widgets/status_info.dart';
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

  List<Participants> filteredParticipants = [];
  String selectedCompany = "All Clubs";
  String selectedStatus = "All Status";

  bool get isSearchActive =>
      isSearching && searchController.text.trim().isNotEmpty;

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
          List<Participants> filtered = List.from(provider.participants ?? []);
          filteredParticipants = [
            ...filtered.where((p) => p.status == "registered"),
            ...filtered.where((p) => p.status != "registered"),
          ];
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

    final query = searchController.text.toLowerCase();
    final list = provider.participants ?? [];

    setState(() {
      filteredParticipants = list.where((p) {
        final matchesSearch =
            (p.clubName ?? "").toLowerCase().contains(query) ||
                (p.riderName ?? "").toLowerCase().contains(query) ||
                (p.horseName ?? "").toLowerCase().contains(query);

        final matchesCompany = selectedCompany == "All Clubs"
            ? true
            : p.clubName == selectedCompany;

        final matchesStatus = selectedStatus == "All Status"
            ? true
            : StatusHelper.getStatus(p.status).label == selectedStatus;

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
                width: double.infinity,
                autoFocus: true,
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
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FenceProvider>(context);
    final responsive = ResponsiveHelper(context);

    List<String> companyList = [
      "All Clubs",
      ...{...(provider.participants ?? []).map((e) => e.clubName ?? "")}
    ];

    List<String> statusList = [
      "All Status",
      ...{
        ...(provider.participants ?? [])
            .map((e) => StatusHelper.getStatus(e.status).label)
      }
    ];

    return PopScope(
      canPop: false,
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
                        icon:
                            Icon(Icons.search, color: gBlackColor, size: 3.5.h),
                      ),
                    )
                  ],
                )
              : null,
        ),
        body: provider.isParticipantsLoading
            ? LoadingIndicator()
            : (provider.participants ?? []).isEmpty
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
                                value: selectedCompany,
                                priority: companyList,
                                isFullBorder: true,
                                showCheckIcon: false,
                                onChanged: (v) {
                                  selectedCompany = v!;
                                  applyFilters();
                                },
                              ),
                            ),
                            SizedBox(width: 2.w),
                            SizedBox(
                              width: responsive.isMobile ? 40.w : 20.w,
                              child: CommonDropdown(
                                label: "Status",
                                value: selectedStatus,
                                priority: statusList,
                                isFullBorder: true,
                                showCheckIcon: false,
                                onChanged: (v) {
                                  selectedStatus = v!;
                                  applyFilters();
                                },
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
                              : responsive.isMobile
                                  ? buildMobileListView()
                                  : buildWebTableView(),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  // -------------------------------
  // WEB TABLE VIEW
  // -------------------------------
  Widget buildWebTableView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: MediaQuery.of(context).size.height *
              0.70, // 👈 give height for vertical scroll
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: SingleChildScrollView(
                // 👈 vertical scroll added
                scrollDirection: Axis.vertical,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DataTable(
                    showCheckboxColumn: false,
                    headingRowColor: WidgetStateProperty.all(
                      Colors.blueGrey.shade50,
                    ),
                    headingTextStyle: TextStyle(
                      color: gHintTextColor,
                      fontFamily: fontBold,
                      fontSize: fontSize18,
                    ),
                    dataTextStyle: TextStyle(
                      color: gBlackColor,
                      fontFamily: fontMedium,
                      fontSize: fontSize14,
                    ),
                    // dataRowMinHeight: 60,
                    columnSpacing: 30,
                    border: TableBorder.all(
                      color: gHintTextColor.withAlpha(
                        AlphaHelper.fromOpacity(0.3),
                      ),
                      width: 1,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    columns: const [
                      DataColumn(label: Text("Rider")),
                      DataColumn(label: Text("Club")),
                      DataColumn(label: Text("Horse")),
                      DataColumn(label: Text("Status")),
                    ],
                    rows: filteredParticipants.map((p) {
                      return DataRow(
                        onSelectChanged: (_) {
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
                        cells: [
                          DataCell(Text("${p.riderName} | ${p.riderId}")),
                          DataCell(Text(p.clubName ?? "")),
                          DataCell(Text("${p.horseName} | ${p.horseId}")),
                          DataCell(
                            Text(
                              StatusHelper.getStatus(p.status).label,
                              style: TextStyle(
                                fontFamily: fontBold,
                                color: StatusHelper.getStatus(p.status,
                                        isNew: true)
                                    .color,
                                fontSize: fontSize14,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // -------------------------------
  // MOBILE LIST VIEW
  // -------------------------------
  Widget buildMobileListView() {
    return ListView.builder(
      itemCount: filteredParticipants.length,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      itemBuilder: (context, index) {
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
            padding: const EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 2.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: StatusHelper.getStatus(p.status).color,
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
              color: gWhiteColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 2.h,
                      color: Colors.green,
                    ),
                    SizedBox(width: 2.w),
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
                      size: 2.h,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 2.w),
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
                      size: 2.h,
                      color: Colors.brown,
                    ),
                    SizedBox(width: 2.w),
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
                      size: 2.h,
                      color: gPrimaryColor,
                    ),
                    SizedBox(width: 2.w),
                    // Text(
                    //   "Status : ",
                    //   style: TextStyle(
                    //     fontSize: fontSize13,
                    //     fontFamily: fontBook,
                    //     color: gHintTextColor,
                    //   ),
                    // ),
                    Text(
                      StatusHelper.getStatus(p.status).label,
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
      },
    );
  }
}
