import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/pages/bookings/bookings_sheet.dart';
import 'package:ticketapp/pages/event_details/event_detail_page.dart';
import 'package:ticketapp/pages/events_overview/events_overview_page.dart';
import 'package:ticketapp/pages/landing_page/landing_page.dart';
import 'package:ticketapp/pages/my_ticktes/my_tickets_sheet.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/utilities/route/on_generated_route.dart';
import 'UI/event_overview/tabs/for_me.dart';
import 'UI/services/bugsnag_wrapper.dart';
import 'pages/reward_center/reward_center_sheet.dart';
import 'UI/icons.dart';
import 'dart:js' as js;

void main() {
  ResponsiveSizingConfig.instance.setCustomBreakpoints(
    ScreenBreakpoints(desktop: 1200, tablet: 1000, watch: 370),
  );
  WidgetsFlutterBinding.ensureInitialized();
  BugsnagNotifier.instance.init('1f1b3215263ed87f7e83c4927e7ba05b');

  FlutterError.onError = (FlutterErrorDetails details) {
    print(details.exception);
    print(details.stack);
    print(details.summary);
    /*BugsnagNotifier.instance.notify(details.exception, details.stack);
    BugsnagNotifier.instance.notify("Additional error output: ${details.summary}", StackTrace.empty);*/
  };

  Firebase.initializeApp(
    // Replace with actual values
    options: FirebaseOptions(
        apiKey: "AIzaSyBZZn5-LUOhdjgXWWffhiV_zyT9Pt8X6TU",
        appId: "1:325355278765:web:070f1fcb14372231db9124",
        databaseURL: "https://appollo-devops.firebaseio.com",
        messagingSenderId: "325355278765",
        projectId: "appollo-devops",
        authDomain: "appollo-devops.firebaseapp.com",
        storageBucket: "appollo-devops.appspot.com"),
  ).then((_) {
    runZonedGuarded(() {
      runApp(MyApp());
    }, (error, stackTrace) {
      print(error);
      print(stackTrace);
      /*BugsnagNotifier.instance.notify(error, stackTrace);*/
    });
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    Intl.defaultLocale = 'en_AU';
    initializeDateFormatting('en_AU', null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      title: 'ScoopTix - Patron Engagement Technologies',
      theme: MyTheme.theme,
      home: WrapperPage(),
    );
  }
}

class WrapperPage extends StatefulWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static bool drawerOpen = false;
  static ValueNotifier<Widget?> endDrawer = ValueNotifier<Widget?>(null);
  static GlobalKey<ScaffoldState> mainScaffold = GlobalKey<ScaffoldState>();

  @override
  _WrapperPageState createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  int selectedIndex = 0;

  @override
  void initState() {
    // Used to sign in current user session
    UserRepository.instance.signInCurrentUser();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    MyTheme.maxWidth = getValueForScreenType(
        context: context,
        watch: screenSize.width,
        mobile: screenSize.width,
        desktop:
            screenSize.width * 0.625 < 1150 ? 1150 : screenSize.width * 0.625,
        tablet:
            screenSize.width * 0.625 < 1150 ? 1150 : screenSize.width * 0.625);
    MyTheme.textTheme = getValueForScreenType(
        context: context,
        watch: MyTheme.mobileTextTheme,
        mobile: MyTheme.mobileTextTheme,
        tablet: MyTheme.textTheme,
        desktop: MyTheme.textTheme);
    return Scaffold(
        bottomNavigationBar: _buildBottomNavBar(),
        key: WrapperPage.mainScaffold,
        onEndDrawerChanged: (d) {
          setState(() {
            WrapperPage.drawerOpen = d;
          });
        },
        endDrawerEnableOpenDragGesture: false,
        endDrawer: ValueListenableBuilder(
            valueListenable: WrapperPage.endDrawer,
            builder: (context, value, child) {
              if (value != null) {
                return value as Widget;
              } else {
                return SizedBox.shrink();
              }
            }),
        body: Stack(
          children: [
            WillPopScope(
              onWillPop: () async {
                WrapperPage.navigatorKey.currentState!.maybePop();
                return false;
              },
              child: Navigator(
                key: WrapperPage.navigatorKey,
                initialRoute: LandingPage.routeName,
                onGenerateRoute: GeneratedRoute.onGenerateRoute,
              ),
            ),
            WrapperPage.drawerOpen ? BlurBackground() : SizedBox(),
          ],
        ));
  }

  Widget _buildBottomNavBar() {
    return ResponsiveBuilder(
      builder: (context, size) {
        if (size.isDesktop || size.isTablet) {
          return SizedBox.shrink();
        } else {
          return Container(
            color: MyTheme.scoopBottomBarColor,
            height: MyTheme.bottomNavBarHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 64,
                  color: Colors.transparent,
                  child: Align(
                    alignment: Alignment.center,
                    child: BottomNavigationBar(
                      elevation: 0,
                      selectedItemColor: MyTheme.scoopGreen,
                      items: _navBarsItems(),
                      selectedFontSize: 11,
                      unselectedFontSize: 11,
                      type: BottomNavigationBarType.fixed,
                      currentIndex: selectedIndex,
                      backgroundColor: Colors.transparent,
                      iconSize: 24,
                      showSelectedLabels: true,
                      showUnselectedLabels: true,
                      onTap: (index) {
                        setState(() {
                          selectedIndex = index;
                        });
                        switch (selectedIndex) {
                          case 0:
                            Navigator.of(
                                    WrapperPage.navigatorKey.currentContext!)
                                .popUntil((route) =>
                                    route.settings.name ==
                                    EventOverviewPage.routeName);
                            break;
                          case 1:
                            Navigator.of(
                                    WrapperPage.navigatorKey.currentContext!)
                                .push(MaterialPageRoute(
                                    builder: (context) => EventsForMe()));
                            break;
                          case 2:
                            Navigator.of(
                                    WrapperPage.navigatorKey.currentContext!)
                                .popUntil((route) =>
                                    route.settings.name ==
                                        EventOverviewPage.routeName ||
                                    route.settings.name == null ||
                                    route.settings.name!.startsWith(
                                        EventDetailPage.routeName + "?"));
                            BookingsSheet.openBookingsSheet();
                            break;
                          case 3:
                            Navigator.of(
                                    WrapperPage.navigatorKey.currentContext!)
                                .popUntil((route) =>
                                    route.settings.name ==
                                        EventOverviewPage.routeName ||
                                    route.settings.name == null ||
                                    route.settings.name!.startsWith(
                                        EventDetailPage.routeName + "?"));
                            MyTicketsSheet.openMyTicketsSheet();
                            break;
                          case 4:
                            Navigator.of(
                                    WrapperPage.navigatorKey.currentContext!)
                                .popUntil((route) =>
                                    route.settings.name ==
                                        EventOverviewPage.routeName ||
                                    route.settings.name == null ||
                                    route.settings.name!.startsWith(
                                        EventDetailPage.routeName + "?"));
                            RewardCenterSheet.openRewardCenterSheet();
                            break;
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: MyTheme.scoopBottomBarColor,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  List<BottomNavigationBarItem> _navBarsItems() {
    bool isCanvas = js.context['flutterCanvasKit'] != null;
    print(isCanvas);
    return [
      BottomNavigationBarItem(
          icon: isCanvas
              ? SvgPicture.asset(AppolloIcons.home,
                  color: MyTheme.scoopWhite, width: 24, height: 24)
              : Image.network("assets/" + AppolloIcons.home,
                  color: MyTheme.scoopWhite, width: 24, height: 24),
          activeIcon: isCanvas
              ? SvgPicture.asset(AppolloIcons.home,
                  color: MyTheme.scoopGreen, width: 24, height: 24)
              : Image.network("assets/" + AppolloIcons.home,
                  color: MyTheme.scoopGreen, width: 24, height: 24),
          label: "Home"),
      BottomNavigationBarItem(
          icon: isCanvas
              ? SvgPicture.asset(AppolloIcons.heartOutline,
                  color: MyTheme.scoopWhite, width: 24, height: 24)
              : Image.network("assets/" + AppolloIcons.heartOutline,
                  color: MyTheme.scoopWhite, width: 24, height: 24),
          activeIcon: isCanvas
              ? SvgPicture.asset(AppolloIcons.heartOutline,
                  color: MyTheme.scoopGreen, width: 24, height: 24)
              : Image.network("assets/" + AppolloIcons.heartOutline,
                  color: MyTheme.scoopGreen, width: 24, height: 24),
          label: "For Me"),
      BottomNavigationBarItem(
          icon: isCanvas
              ? SvgPicture.asset(AppolloIcons.calenderOutline,
                  color: MyTheme.scoopWhite, width: 24, height: 24)
              : Image.network("assets/" + AppolloIcons.calenderOutline,
                  color: MyTheme.scoopWhite, width: 24, height: 24),
          activeIcon: isCanvas
              ? SvgPicture.asset(AppolloIcons.calenderOutline,
                  color: MyTheme.scoopGreen, width: 24, height: 24)
              : Image.network("assets/" + AppolloIcons.calenderOutline,
                  color: MyTheme.scoopGreen, width: 24, height: 24),
          label: "My Bookings"),
      BottomNavigationBarItem(
          icon: isCanvas
              ? SvgPicture.asset(AppolloIcons.ticket,
                  color: MyTheme.scoopWhite, width: 24, height: 24)
              : Image.network("assets/" + AppolloIcons.ticket,
                  color: MyTheme.scoopWhite, width: 24, height: 24),
          activeIcon: isCanvas
              ? SvgPicture.asset(AppolloIcons.ticket,
                  color: MyTheme.scoopGreen, width: 24, height: 24)
              : Image.network("assets/" + AppolloIcons.ticket,
                  color: MyTheme.scoopGreen, width: 24, height: 24),
          label: "My Tickets"),
      BottomNavigationBarItem(
          icon: isCanvas
              ? SvgPicture.asset(AppolloIcons.reward,
                  color: MyTheme.scoopWhite, width: 24, height: 24)
              : Image.network("assets/" + AppolloIcons.reward,
                  color: MyTheme.scoopWhite, width: 24, height: 24),
          activeIcon: isCanvas
              ? SvgPicture.asset(AppolloIcons.reward,
                  color: MyTheme.scoopGreen, width: 24, height: 24)
              : Image.network("assets/" + AppolloIcons.reward,
                  color: MyTheme.scoopGreen, width: 24, height: 24),
          label: "Rewards"),
    ];
  }
}
