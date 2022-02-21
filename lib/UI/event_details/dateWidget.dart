import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticketapp/UI/theme.dart';

class DateWidget extends StatelessWidget {
  final DateTime date;

  const DateWidget({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        color: Colors.grey[900]!.withAlpha(150),
        child: AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(builder: (context, constraints) {
            return Column(
              children: [
                SizedBox(
                  height: constraints.maxHeight / 3,
                  child: Container(
                    color: MyTheme.scoopRed,
                    width: MyTheme.maxWidth,
                    child: Center(child: Text(DateFormat.MMM().format(date), style: MyTheme.textTheme.subtitle2)),
                  ),
                ),
                SizedBox(
                  height: constraints.maxHeight / 3 * 2,
                  child: Center(
                    child: Text(
                      DateFormat.d().format(date),
                      style: MyTheme.textTheme.headline4,
                    ),
                  ),
                )
              ],
            );
          }),
        ),
      ),
    );
  }
}
