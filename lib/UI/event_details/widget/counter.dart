import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../../UI/theme.dart';

class Countdown extends StatefulWidget {
  const Countdown({
    Key key,
    @required this.duration,
    this.onFinish,
    this.interval = const Duration(seconds: 1),
    this.width = 400,
    this.height = 150,
  }) : super(key: key);

  final Duration duration;
  final Duration interval;
  final void Function() onFinish;
  final double width;
  final double height;
  @override
  _CountdownState createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Timer _timer;
  Duration _duration;
  @override
  void initState() {
    _duration = widget.duration;
    _timer = Timer.periodic(widget.interval, timerCallback);

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void timerCallback(Timer timer) {
    setState(() {
      if (_duration.inSeconds == 0) {
        timer.cancel();
        if (widget.onFinish != null) widget.onFinish();
      } else {
        _duration = Duration(seconds: _duration.inSeconds - 1);
      }
    });
  }

  Widget type(BuildContext context, String s) => AutoSizeText(s, style: MyTheme.textTheme.bodyText1).paddingBottom(8);

  Widget timer(BuildContext context, String s) {
    return AutoSizeText(
      s.length == 1 ? "0$s" : '${s ?? '00'}',
      style: Theme.of(context).textTheme.headline1.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1.5),
    ).paddingTop(8).paddingBottom(8);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_duration.inDays > 0)
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      timer(context, "${_duration.inDays}"),
                      type(context, 'Days'),
                    ],
                  ).paddingHorizontal(4),
                ).appolloBlurCard(color: MyTheme.appolloGrey.withAlpha(50)).paddingRight(8),
              ),
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    timer(context, "${_duration.inHours % 24}"),
                    type(context, 'Hours'),
                  ],
                ).paddingHorizontal(4),
              )
                  .appolloCard(color: MyTheme.appolloGrey.withAlpha(50), borderRadius: BorderRadius.circular(8))
                  .paddingRight(8),
            ),
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    timer(context, "${_duration.inMinutes % 60}"),
                    type(context, 'Minutes'),
                  ],
                ).paddingHorizontal(4),
              ).appolloCard(color: MyTheme.appolloGrey.withAlpha(50), borderRadius: BorderRadius.circular(8)),
            ),
            if (_duration.inDays == 0)
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      timer(context, "${_duration.inSeconds % 60}"),
                      type(context, 'Seconds'),
                    ],
                  ).paddingHorizontal(4),
                )
                    .appolloCard(color: MyTheme.appolloGrey.withAlpha(50), borderRadius: BorderRadius.circular(8))
                    .paddingLeft(8),
              ),
          ],
        ).paddingAll(8),
      ).appolloBlurCard(color: MyTheme.appolloGrey.withAlpha(50)),
    );
  }
}
