import 'package:flutter/material.dart';

import '../../theme.dart';

class PoweredByAppollo extends StatelessWidget {
  const PoweredByAppollo({
    Key key,
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
          style: MyTheme.lightTextTheme.caption.copyWith(
              color: Colors.grey[200],
              fontWeight: FontWeight.w300,
              shadows: [BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 1)]),
        ),
        Text("appollo",
            style: MyTheme.lightTextTheme.subtitle1.copyWith(
                fontFamily: "cocon",
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
