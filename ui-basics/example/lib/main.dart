import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:ui_basics/ui_basics.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI Basics Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late FormGroup form;

  @override
  void initState() {
    form = FormGroup({
      'test': FormControl(validators: [Validators.required]),
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF21223B),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ScoopButton(
              onTap: () {

              },
              buttonTheme: ScoopButtonTheme.primary,
              title: "Primary",
              fill: ButtonFill.filled,
            ),
            const SizedBox(height: 20,),
            ScoopButton(
              onTap: () {

              },
              buttonTheme: ScoopButtonTheme.primary,
              title: "Primary",
              fill: ButtonFill.outlined,
            ),
            const SizedBox(height: 20,),
            ScoopButton(
              onTap: () {

              },
              buttonTheme: ScoopButtonTheme.secondary,
              title: "Secondary",
              fill: ButtonFill.filled,
            ),
            const SizedBox(height: 20,),
            ScoopButton(
              onTap: () {

              },
              buttonTheme: ScoopButtonTheme.secondary,
              title: "Secondary",
              fill: ButtonFill.outlined,
            ),
            const SizedBox(height: 20,),
            ScoopButton(
              onTap: () {

              },
              buttonTheme: ScoopButtonTheme.custom,
              title: "Custom",
              fill: ButtonFill.filled,
              color: Colors.red,
              hoverColor: Colors.redAccent,
            ),
            const SizedBox(height: 20,),
            ScoopButton(
              onTap: () {

              },
              buttonTheme: ScoopButtonTheme.custom,
              title: "Custom",
              fill: ButtonFill.outlined,
              color: Colors.red,
              hoverColor: Colors.redAccent,
            ),
            const SizedBox(height: 20,),
            SizedBox(
                width: 400,
                child: ScoopTextField.reactive(labelText: "Reactive Field", formControl: form.controls["test"]))
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
