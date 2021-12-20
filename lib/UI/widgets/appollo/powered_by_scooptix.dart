import 'package:flutter/material.dart';

import '../../theme.dart';

class PoweredByScoopTix extends StatelessWidget {
  const PoweredByScoopTix({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: MyTheme.elementSpacing,
        ),
        Text(
          "Powered by",
          style: MyTheme.textTheme.caption!.copyWith(
              color: Colors.grey[200],
              fontWeight: FontWeight.w300,
              shadows: [BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 1)]),
        ),
        Text("ScoopTix",
            style: MyTheme.textTheme.subtitle1!.copyWith(
                color: Colors.white,
                fontSize: 20,
                shadows: [BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 1)])),
        SizedBox(
          height: MyTheme.elementSpacing,
        ),
      ],
    );
  }
}
