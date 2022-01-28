import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ticketapp/UI/widgets/textfield/appollo_textfield.dart';

import 'package:ticketapp/main.dart' as app;
import 'package:ticketapp/pages/authentication/authentication_drawer.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Login',
            (WidgetTester tester) async {
          app.main();
          GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
          await tester.pumpWidget(Scaffold(key: scaffoldKey, drawer: AuthenticationDrawer(),));

          scaffoldKey.currentState?.openDrawer();

          await tester.pump(const Duration(milliseconds: 200));

          // findig the widget
          var textFind = find.widgetWithText(AppolloTextField, "email");

          // checking widget present or not
          expect(textFind, findsOneWidget);

          await tester.tap(textFind);

          tester.enterText(textFind, "alexanderschneider@gmx.com");

        });
  });
}