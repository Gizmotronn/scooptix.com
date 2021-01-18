import 'dart:async';

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:webapp/UI/theme.dart';
import 'package:webapp/pages/eventSelectionPage/eventSelectionPage.dart';

import 'services/bugsnag_wrapper.dart';

void main() {
  ResponsiveSizingConfig.instance.setCustomBreakpoints(
    ScreenBreakpoints(desktop: 900, tablet: 600, watch: 370),
  );
  WidgetsFlutterBinding.ensureInitialized();
  BugsnagNotifier.instance.init('1f1b3215263ed87f7e83c4927e7ba05b');

  FlutterError.onError = (FlutterErrorDetails details) {
    BugsnagNotifier.instance.notify(details.exception, details.stack);
  };

  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    print('runZonedGuarded: Caught error in my root zone.');
    BugsnagNotifier.instance.notify(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'appollo - Patron Engagement Technologies',
      theme: MyTheme.theme,
      home: EventSelectionPage(),
    );
  }
}
