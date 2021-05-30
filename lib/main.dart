import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/pages/event_details/event_detail_page.dart';
import 'package:ticketapp/pages/events_overview/events_overview_page.dart';
import 'package:ticketapp/pages/landing_page/landing_page.dart';
import 'package:ticketapp/pages/my_ticktes/my_tickets_sheet.dart';
import 'package:ticketapp/utilities/route/onGeneratedRoute.dart';
import 'UI/event_overview/tabs/for_me.dart';
import 'pages/reward_center/reward_center_sheet.dart';
import 'services/bugsnag_wrapper.dart';
import 'utilities/svg/icon.dart';
import 'dart:html' as js;

void main() {
  ResponsiveSizingConfig.instance.setCustomBreakpoints(
    ScreenBreakpoints(desktop: 900, tablet: 600, watch: 370),
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

  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    print(error);
    print(stackTrace);
    /*BugsnagNotifier.instance.notify(error, stackTrace);*/
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
      title: 'appollo - Patron Engagement Technologies',
      theme: MyTheme.theme,
      home: WrapperPage(),
    );
  }
}

class WrapperPage extends StatefulWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static bool drawerOpen = false;
  static ValueNotifier<Widget> endDrawer = ValueNotifier<Widget>(null);
  static GlobalKey<ScaffoldState> mainScaffold = GlobalKey<ScaffoldState>();

  @override
  _WrapperPageState createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  int selectedIndex = 0;

  @override
  void initState() {
    // Used to sign in current user session
    // Disbaled for DEV, doesn't work with hot reload
    //UserRepository.instance.signInCurrentUser();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    MyTheme.elementSpacing = getValueForScreenType(context: context, watch: 12, mobile: 12, desktop: 20, tablet: 20);
    MyTheme.maxWidth = screenSize.width * 0.625 < 880 ? 880 : screenSize.width * 0.625;
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
        endDrawer: ValueListenableBuilder(
            valueListenable: WrapperPage.endDrawer,
            builder: (context, value, child) {
              if (value != null) {
                return value;
              } else {
                return SizedBox.shrink();
              }
            }),
        body: Stack(
          children: [
            WillPopScope(
              onWillPop: () async {
                WrapperPage.navigatorKey.currentState.maybePop();
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
          MyTheme.bottomNavBarHeight = js.window.navigator.userAgent.contains("iPhone") ? 80 : 64;
          return Container(
            color: MyTheme.appolloBottomBarColor,
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
                      selectedItemColor: MyTheme.appolloGreen,
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
                            Navigator.of(WrapperPage.navigatorKey.currentContext)
                                .popUntil((route) => route.settings.name == EventOverviewPage.routeName);
                            break;
                          case 1:
                            Navigator.of(WrapperPage.navigatorKey.currentContext)
                                .push(MaterialPageRoute(builder: (context) => EventsForMe()));
                            break;
                          case 2:
                            Navigator.of(WrapperPage.navigatorKey.currentContext).popUntil((route) =>
                                route.settings.name == EventOverviewPage.routeName ||
                                route.settings.name.startsWith(EventDetailPage.routeName + "?"));
                            MyTicketsSheet.openMyTicketsSheet();
                            break;
                          case 3:
                            Navigator.of(WrapperPage.navigatorKey.currentContext).popUntil((route) =>
                                route.settings.name == EventOverviewPage.routeName ||
                                route.settings.name.startsWith(EventDetailPage.routeName + "?"));
                            RewardCenterSheet.openRewardCenterSheet();
                            break;
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: MyTheme.appolloBottomBarColor,
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
    return [
      BottomNavigationBarItem(
          icon: SvgPicture.asset(AppolloSvgIcon.home, color: MyTheme.appolloWhite, width: 24, height: 24),
          activeIcon: SvgPicture.asset(AppolloSvgIcon.home, color: MyTheme.appolloGreen, width: 24, height: 24),
          label: "Home"),
      BottomNavigationBarItem(
          icon: SvgPicture.asset(AppolloSvgIcon.heartOutline, color: MyTheme.appolloWhite, width: 24, height: 24),
          activeIcon: SvgPicture.asset(AppolloSvgIcon.heartOutline, color: MyTheme.appolloGreen, width: 24, height: 24),
          label: "For Me"),
      BottomNavigationBarItem(
          icon: SvgPicture.asset(AppolloSvgIcon.ticket, color: MyTheme.appolloWhite, width: 24, height: 24),
          activeIcon: SvgPicture.asset(AppolloSvgIcon.ticket, color: MyTheme.appolloGreen, width: 24, height: 24),
          label: "My Tickets"),
      BottomNavigationBarItem(
          icon: SvgPicture.asset(AppolloSvgIcon.reward, color: MyTheme.appolloWhite, width: 24, height: 24),
          activeIcon: SvgPicture.asset(AppolloSvgIcon.reward, color: MyTheme.appolloGreen, width: 24, height: 24),
          label: "Rewards"),
    ];
  }
}
