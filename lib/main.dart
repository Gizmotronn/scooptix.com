import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/pages/events_overview/events_overview_page.dart';
import 'package:ticketapp/pages/landing_page/landing_page.dart';
import 'package:ticketapp/utilities/route/onGeneratedRoute.dart';

import 'repositories/user_repository.dart';
import 'services/bugsnag_wrapper.dart';

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
  @override
  void initState() {
    // Used to sign in current user session
    // Disbaled for DEV, doesn't work with hot reload
    UserRepository.instance.signInCurrentUser();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Navigator(
              key: WrapperPage.navigatorKey,
              initialRoute: LandingPage.routeName,
              onGenerateRoute: GeneratedRoute.onGenerateRoute,
            ),
            WrapperPage.drawerOpen ? BlurBackground() : SizedBox(),
          ],
        ));
  }
}
