import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/buttons/navbutton.dart';
import '../theme.dart';
import 'event_overview_home.dart';

class EventOverviewNavigationBar extends StatefulWidget {
  @override
  _EventOverviewNavigationBarState createState() =>
      _EventOverviewNavigationBarState();
}

class _EventOverviewNavigationBarState
    extends State<EventOverviewNavigationBar> {
  List<Menu> _menu = [
    Menu('All', true),
    Menu('Free', false),
    Menu('For me', false),
    Menu('Today', false),
    Menu('This Weekend', false),
    Menu('This Week', false),
    Menu('Music', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      color: MyTheme.appolloBlack,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              _menu.length,
              (index) => NavbarButton(
                  title: _menu[index].title,
                  onTap: () {},
                  isTap: _menu[index].isTap),
            ),
          ),
        ),
      ),
    );
  }
}
