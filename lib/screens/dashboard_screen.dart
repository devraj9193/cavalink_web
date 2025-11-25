import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../controllers/models/auth_models/login_model.dart';
import '../controllers/providers/fence_providers.dart';
import '../utils/app_config.dart';
import '../utils/opacity_to_alpha.dart';
import '../utils/responsive_helper.dart';
import '../widgets/common_app_bar_widget.dart';
import '../widgets/exit_widget.dart';
import '../widgets/loading_indicator.dart';
import 'my_event_screens/my_events.dart';
import 'profile_screens/logout_screens/logout_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;
  final int? tapIndex;

  const DashboardScreen({
    super.key,
    this.initialIndex = 0,
    this.tapIndex,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  UserDetails? userDetails;
  final pref = AppConfig().preferences;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    loadUser();
  }

  void loadUser() async {
    final prefs = pref; // or await SharedPreferences.getInstance()

    final userString = prefs?.getString(AppConfig.isUser);

    if (userString == null) return;

    try {
      final Map<String, dynamic> userMap =
          jsonDecode(userString) as Map<String, dynamic>;

      userDetails = UserDetails.fromJson(userMap);

      // Call provider AFTER build() is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<FenceProvider>(context, listen: false)
            .fetchEvents(context, userDetails?.clubId ?? 0);
      });

      setState(() {});
    } catch (e) {
      print("User parse error: $e");
    }
  }

  void _onDrawerItemTapped(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    final eventProv = Provider.of<FenceProvider>(context);

    final screens = [
      // My Events Screen
      MyEvents(
        ongoing: eventProv.myOngoing,
        upcoming: eventProv.myUpcoming,
        completed: eventProv.myCompleted,
      ),

      // All Events Screen (Other Events)
      MyEvents(
        ongoing: eventProv.otherOngoing,
        upcoming: eventProv.otherUpcoming,
        completed: eventProv.otherCompleted,
      ),

      LogoutScreen(userDetails: userDetails),
    ];

    return PopScope(
      canPop: false,
      // onPopInvoked: (didPop) {
      //   if (!didPop) {
      //     showLogoutDialog();
      //   }
      // },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: gWhiteColor,
        appBar: CommonAppBarWidget(
          showBack: false,
          showLogo: true,
          showDrawer: true,
          appBarHeight: 8,
          onDrawerTap: () => _scaffoldKey.currentState?.openDrawer(),
          elevation: 0,
        ),
        drawer: SizedBox(
          width: responsive.isMobile ? 60.w : 25.w,
          child: Drawer(
            backgroundColor: gWhiteColor,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                    left: responsive.isMobile ? 3.w : 1.w, top: 3.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Logo and close button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset("assets/images/logo1.png",
                            height: responsive.isMobile ? 5.h : 7.h
                            // color: gBlackColor,
                            ),
                        Padding(
                          padding: EdgeInsets.only(
                              right: responsive.isMobile ? 0.w : 1.w),
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),

                    /// Drawer items
                    _buildDrawerItem('My Events', 0,responsive),
                    _buildDrawerItem('All Events', 1,responsive),
                    _buildDrawerItem('Logout', 2,responsive),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: eventProv.isEventsLoading
            ? LoadingIndicator()
            : Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: responsive.isMobile ? 0 : 28.w),
                child: screens[_selectedIndex],
              ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, int index,ResponsiveHelper responsive) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: responsive.isMobile ?1.w : 1.w),
      child: GestureDetector(
        onTap: () => _onDrawerItemTapped(index),
        child: Row(
          children: [
            if (isSelected)
              Container(
                width:  responsive.isMobile ? 1.w : .3.w,
                height:  responsive.isMobile ? 2.5.h : 3.h,
                color: gBlackColor,
                margin: EdgeInsets.only(right: responsive.isMobile ? 1.5.w : 0.3.w),
              ),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? gBlackColor : gHintTextColor,
                fontFamily: isSelected ? kFontMedium : kFontBook,
                fontSize: isSelected ? fontSize16 : fontSize15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showLogoutDialog() {
    showDialog(
      barrierDismissible: false,
      barrierColor: gWhiteColor.withAlpha(AlphaHelper.fromOpacity(0.8)),
      context: context,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: gWhiteColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: lightTextColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                ExitWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
