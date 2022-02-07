import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/textfield/appollo_textfield.dart';
import 'package:ticketapp/pages/authentication/authentication_drawer.dart';
import 'package:ticketapp/pages/authentication/authentication_page.dart';
import 'package:ticketapp/pages/authentication/bloc/authentication_bloc.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding = IntegrationTestWidgetsFlutterBinding();


    testWidgets('Login',
            (WidgetTester tester) async {

          await tester.pumpWidget(MaterialApp(home: Scaffold(body: AuthenticationPage(bloc: AuthenticationBloc(),))));

          await Future.delayed(Duration(milliseconds: 3000));

      // finding the widget
          var textFind = find.widgetWithText(AppolloTextField, "Email");

          // checking widget present or not
          expect(textFind, findsOneWidget);

          await tester.tap(textFind);

          // fails here
          tester.enterText(textFind, "alexanderschneider@gmx.com");

          //var buttonFind = find.byType(AppolloButton);

          // finding the widget
          var buttonFind = find.text("Next");

          // checking widget present or not
         // expect(buttonFind, findsOneWidget);

          /*tester.tap(buttonFind);

          await tester.pump(const Duration(milliseconds: 1000));

          // finding the widget
          var passwordFind = find.widgetWithText(AppolloTextField, "Password");

          // checking widget present or not
          expect(passwordFind, findsOneWidget);*/
        });

}