import 'package:cavalink_web/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../controllers/models/club_models/events_model.dart';
import '../../utils/constants.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/opacity_to_alpha.dart';
import '../../widgets/web_image.dart';
import '../all_events_screens/event_details_screen.dart';

class MyEvents extends StatefulWidget {
  final List<Ongoing> ongoing;
  final List<Ongoing> upcoming;
  final List<Ongoing> completed;

  const MyEvents(
      {super.key,
      required this.ongoing,
      required this.upcoming,
      required this.completed});

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  final List<Map<String, dynamic>> events = [
    {
      "title": "Music Fiesta Night",
      "date": "Nov 20, 2025",
      "location": "Downtown Arena",
      "status": "New",
      "image":
          "https://images.unsplash.com/photo-1518972559570-7cc1309f3229?auto=format&fit=crop&w=800&q=60",
      "colors": [Color(0xFFff7e5f), Color(0xFFfeb47b)],
    },
    {
      "title": "Art & Soul Exhibition",
      "date": "Nov 22, 2025",
      "location": "City Art Hall",
      "status": "Upcoming",
      "image":
          "https://images.unsplash.com/photo-1529101091764-c3526daf38fe?auto=format&fit=crop&w=800&q=60",
      "colors": [Color(0xFF43cea2), Color(0xFF185a9d)],
    },
    {
      "title": "Food Carnival",
      "date": "Nov 25, 2025",
      "location": "Sunshine Park",
      "status": "Ongoing",
      "image":
          "https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?auto=format&fit=crop&w=800&q=60",
      "colors": [Color(0xFFe96443), Color(0xFF904e95)],
    },
    {
      "title": "Online Tech Innovation Summit",
      "date": "Nov 30, 2025",
      "location": "Virtual Event",
      "status": "Upcoming",
      "image":
          "https://images.unsplash.com/photo-1556761175-5973dc0f32e7?auto=format&fit=crop&w=800&q=60",
      "colors": [Color(0xFF4facfe), Color(0xFF00f2fe)],
    },
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.transparent),
              ),
            ),
            child: TabBar(
              controller: tabController,
              labelColor: gBlackColor,
              unselectedLabelColor: gHintTextColor,
              tabAlignment: TabAlignment.start,
              labelStyle: TextStyle(
                fontFamily: fontMedium,
                fontSize: fontSize18,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: fontBook,
                fontSize: fontSize15,
              ),
              indicator: const BoxDecoration(), // no underline
              dividerColor: Colors.transparent, // no divider
              isScrollable: true,
              tabs: const [
                Tab(text: "Ongoing"),
                Tab(text: "Upcoming"),
                Tab(text: "Completed"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _buildEventList(widget.ongoing, responsive, isOngoing: true),
                _buildEventList(widget.upcoming, responsive),
                _buildEventList(widget.completed, responsive),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(
      List<Ongoing> filteredEvents, ResponsiveHelper responsive,
      {bool isOngoing = false}) {
    if (filteredEvents.isEmpty) {
      return const Center(
        child: Text(
          "No events found.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(responsive.isMobile ? 4.w : 0),
      itemCount: filteredEvents.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return _buildEventRow(event, responsive,isOngoing: isOngoing);
      },
    );
  }

  Widget _buildEventRow(Ongoing event, ResponsiveHelper responsive,
      {bool isOngoing = false}) {
    final gradient = LinearGradient(
      colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isOngoing)
            Container(
              width: responsive.isMobile ? 25.w : 10.w,
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 1.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: responsive.isMobile ? 2.w : 1.w,
                        vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(event.status.toString()),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      event.status?.toUpperCase() ?? '',
                      style: TextStyle(
                        color: gWhiteColor,
                        fontSize: fontSize12,
                        fontFamily: fontMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    event.eventStartDate ?? '',
                    style: TextStyle(
                      color: gHintTextColor,
                      fontSize: fontSize12,
                      fontFamily: fontBook,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          SizedBox(width: responsive.isMobile ? 3.w : 1.5.w),

          // RIGHT SIDE (image + details)
          Expanded(
            child: InkWell(
              onTap: () {
                NavigationHelper.push(
                  context,
                  EventDetailsScreen(event: event),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          gBlackColor.withAlpha(AlphaHelper.fromOpacity(0.2)),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      webImage(
                        "https://www.indiafilings.com/learn/wp-content/uploads/2019/12/GST-on-Horse-Racing.jpg",
                        height: responsive.isMobile ? 30.h : 40.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        onTap: () {
                          NavigationHelper.push(
                            context,
                            EventDetailsScreen(event: event),
                          );
                        },
                      ),
                      // ImageNetwork(
                      //   image:
                      //       "https://www.indiafilings.com/learn/wp-content/uploads/2019/12/GST-on-Horse-Racing.jpg",
                      //   height: 40.h,
                      //   fitWeb: BoxFitWeb.fill,
                      //   width: responsive.isMobile ? 70.w : 35.w,
                      //   onTap: () {
                      //     NavigationHelper.push(
                      //       context,
                      //       EventDetailsScreen(event: event),
                      //     );
                      //   },
                      // ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: gBlackColor
                                .withAlpha(AlphaHelper.fromOpacity(0.5)),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                          ),
                          padding:
                              EdgeInsets.all(responsive.isMobile ? 3.w : 1.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.name ?? '',
                                style: TextStyle(
                                  color: gWhiteColor,
                                  fontSize: fontSize18,
                                  fontFamily: fontMedium,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: gWhiteColor.withAlpha(
                                        AlphaHelper.fromOpacity(0.8)),
                                    size: responsive.isMobile ? 3.h : 3.h,
                                  ),
                                  SizedBox(
                                      width: responsive.isMobile ? 2.w : 0.5.w),
                                  Expanded(
                                    child: Text(
                                      event.location ?? '',
                                      style: TextStyle(
                                        color: gWhiteColor.withAlpha(
                                            AlphaHelper.fromOpacity(0.8)),
                                        fontSize: fontSize13,
                                        fontFamily: fontBook,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.5.h),
                              if(!isOngoing)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.date_range_outlined,
                                    color: gWhiteColor.withAlpha(
                                        AlphaHelper.fromOpacity(0.8)),
                                    size: responsive.isMobile ? 3.h : 3.h,
                                  ),
                                  SizedBox(
                                      width: responsive.isMobile ? 2.w : 0.5.w),
                                  Expanded(
                                    child: Text(
                                      event.eventStartDate ?? '',
                                      style: TextStyle(
                                        color: gWhiteColor.withAlpha(
                                            AlphaHelper.fromOpacity(0.8)),
                                        fontSize: fontSize13,
                                        fontFamily: fontBook,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "active":
        return Colors.green;
      case "upcoming":
        return Colors.orange;
      case "completed":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
