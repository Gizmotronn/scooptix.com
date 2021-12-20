import 'package:flutter/material.dart';
import 'package:ticketapp/UI/images.dart';

class ScooptixLogo extends StatelessWidget {
  const ScooptixLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          AppolloImages.logo,
          height: 32,
        )
      ],
    );
  }
}
