import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:provider/provider.dart';
import '../../../controllers/models/auth_models/login_model.dart';
import '../../../controllers/providers/auth_provider.dart';
import '../../../utils/app_config.dart';
import '../../../utils/constants.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/button_widget.dart';
import '../../auth_screens/auth_screen.dart';
import '../../dashboard_screen.dart';

class LogoutScreen extends StatefulWidget {
  final UserDetails? userDetails;
  const LogoutScreen({super.key, this.userDetails});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {

  final pref = AppConfig().preferences!;
  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: const AssetImage("assets/images/logo1.png"),
            height: 15.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h),
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: fontSize20,
                fontFamily: fontBold,
                color: gBlackColor,
              ),
            ),
          ),
          Text(
            'Hi ${widget.userDetails?.name},',
            style: TextStyle(
              fontSize: fontSize18,
              fontFamily: fontMedium,
              color: gBlackColor,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Are you sure you want to log out from My App?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize15,
              fontFamily: fontBook,
              color: gBlackColor,
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ButtonWidget(
                text: "No",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardScreen(initialIndex: 0,tapIndex: 0,),
                    ),
                  );
                },
                isLoading: false,
                buttonWidth: responsive.isMobile ? 40.w : 10.w ,
                radius: 8,
                color: gWhiteColor,
                textColor: gBlackColor,
              ),
              SizedBox(width: 3.w),
              ButtonWidget(
                text: "Yes",
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false)
                      .logout(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AuthScreen(),
                    ),
                  );
                },
                isLoading: false,
                buttonWidth:responsive.isMobile ? 40.w : 10.w ,
                radius: 8,
                color: mainColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
