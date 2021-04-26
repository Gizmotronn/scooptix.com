import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/pages/authentication/bloc/authentication_bloc.dart';

/// In the desktop view, most of the functionality is displayed in the end drawer.
class DesktopViewDrawer extends StatefulWidget {
  final AuthenticationBloc bloc;
  final LinkType linkType;

  final Widget child;

  const DesktopViewDrawer({Key key, @required this.bloc, @required this.linkType, this.child}) : super(key: key);

  @override
  _DesktopViewDrawerState createState() => _DesktopViewDrawerState();
}

class _DesktopViewDrawerState extends State<DesktopViewDrawer> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MyTheme.cardPadding),
      width: MyTheme.drawerSize,
      height: screenSize.height,
      decoration: ShapeDecoration(
          color: MyTheme.appolloBackgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)))),
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(minHeight: screenSize.height),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) => widget.child ?? SizedBox(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Events Powered By", style: MyTheme.darkTextTheme.bodyText2.copyWith(color: Colors.grey))
                      .paddingRight(4),
                  Text("appollo",
                      style: MyTheme.darkTextTheme.subtitle1.copyWith(
                        fontFamily: "cocon",
                        color: MyTheme.appolloPurple,
                        fontSize: 18,
                      ))
                ],
              ).paddingBottom(MyTheme.elementSpacing).paddingTop(MyTheme.elementSpacing),
            ],
          ),
        ),
      ),
    );
  }
}
