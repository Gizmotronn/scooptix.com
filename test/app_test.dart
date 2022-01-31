import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/textfield/appollo_textfield.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding = IntegrationTestWidgetsFlutterBinding();


    testWidgets('Login',
            (WidgetTester tester) async {

         /* GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
          await tester.pumpWidget(MaterialApp(home: Scaffold(key: scaffoldKey, drawer: AuthenticationDrawer(),)));

          scaffoldKey.currentState?.openDrawer();

          await tester.pump(const Duration(milliseconds: 2000));*/
                  expect(2 + 2, equals(5));
          // finding the widget
          var textFind = find.widgetWithText(AppolloTextField, "email");

          // checking widget present or not
          expect(textFind, findsOneWidget);

          await tester.tap(textFind);

          tester.enterText(textFind, "alexanderschneider@gmx.com");

          // finding the widget
          var buttonFind = find.widgetWithText(AppolloButton, "jftf");

          // checking widget present or not
          expect(buttonFind, findsOneWidget);

          tester.tap(buttonFind);

          await tester.pump(const Duration(milliseconds: 1000));

          // finding the widget
          var passwordFind = find.widgetWithText(AppolloTextField, "password");

          // checking widget present or not
          expect(passwordFind, findsOneWidget);
        });

}