import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../../UI/theme.dart';

enum CountDownType { inDays, inHours, inMinutes, inSeconds }

class AppolloCounter extends StatelessWidget {
  final CountDownType countDownType;
  final Duration duration;

  const AppolloCounter({Key key, this.duration, this.countDownType}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Countdown(
        duration: duration,
        builder: (c, countdown) {
          if (countDownType == CountDownType.inDays) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _timer(context, "${countdown.inDays}"),
                _type(context, 'Days'),
              ],
            ).paddingHorizontal(24);
          } else if (countDownType == CountDownType.inHours) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _timer(context, '${countdown.inHours % 24}'),
                _type(context, 'Hours'),
              ],
            ).paddingHorizontal(24);
          } else if (countDownType == CountDownType.inMinutes) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _timer(context, '${countdown.inMinutes % 60}'),
                _type(context, 'Minutes'),
              ],
            ).paddingHorizontal(24);
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _timer(context, '${countdown.inSeconds % 60}'),
              _type(context, 'Seconds'),
            ],
          ).paddingHorizontal(24);
        },
      ),
    ).appolloCard();
  }

  Widget _type(BuildContext context, String s) =>
      AutoSizeText(s, style: Theme.of(context).textTheme.button).paddingBottom(8);

  Widget _timer(BuildContext context, String s) {
    return AutoSizeText(
      s.length == 1 ? "0$s" : '${s ?? '00'}',
      style: Theme.of(context).textTheme.headline1.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1.5),
    ).paddingTop(16).paddingBottom(24);
  }
}

class AppolloSmallCounter extends StatelessWidget {
  final CountDownType countDownType;
  final Duration duration;

  const AppolloSmallCounter({Key key, @required this.duration, this.countDownType}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Countdown(
        duration: duration,
        builder: (c, countdown) {
          if (countDownType == CountDownType.inDays) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _timer(context, "${countdown.inDays}"),
                _type(context, 'Days'),
              ],
            ).paddingHorizontal(4);
          } else if (countDownType == CountDownType.inHours) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _timer(context, '${countdown.inHours % 24}'),
                _type(context, 'Hours'),
              ],
            ).paddingHorizontal(4);
          } else if (countDownType == CountDownType.inMinutes) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _timer(context, '${countdown.inMinutes % 60}'),
                _type(context, 'Minutes'),
              ],
            ).paddingHorizontal(4);
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _timer(context, '${countdown.inSeconds % 60}'),
              _type(context, 'Seconds'),
            ],
          ).paddingHorizontal(4);
        },
      ),
    ).appolloCard();
  }

  Widget _type(BuildContext context, String s) =>
      AutoSizeText(s, style: Theme.of(context).textTheme.caption.copyWith(fontSize: 2)).paddingBottom(8);

  Widget _timer(BuildContext context, String s) {
    return AutoSizeText(
      s.length == 1 ? "0$s" : '${s ?? '00'}',
      style: Theme.of(context).textTheme.headline1.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1.5),
    ).paddingTop(8).paddingBottom(8);
  }
}

class Countdown extends StatefulWidget {
  const Countdown({
    Key key,
    @required this.duration,
    @required this.builder,
    this.onFinish,
    this.interval = const Duration(seconds: 1),
  }) : super(key: key);

  final Duration duration;
  final Duration interval;
  final void Function() onFinish;
  final Widget Function(BuildContext context, Duration remaining) builder;
  @override
  _CountdownState createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Timer _timer;
  Duration _duration;
  @override
  void initState() {
    _duration = widget.duration;
    startTimer();

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(widget.interval, timerCallback);
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

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _duration);
  }
}
