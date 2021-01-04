import 'package:flutter/material.dart';

class ErrorPage extends StatefulWidget {
  final String message;

  const ErrorPage(this.message, {Key key}) : super(key: key);

  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(widget.message),
      ),
    );
  }
}
