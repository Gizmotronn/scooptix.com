import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/buttons/navbutton.dart';
import 'package:ticketapp/pages/events_overview/bloc/events_overview_bloc.dart';
import '../theme.dart';
import 'event_overview_home.dart';

class EventOverviewNavigationBar extends StatefulWidget {
  final EventsOverviewBloc bloc;

  const EventOverviewNavigationBar({Key key, this.bloc}) : super(key: key);
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
    Menu('Upcoming', false),
  ];

  @override
  void initState() {
    if (widget.bloc != null) {
      widget.bloc.add(TabberNavEvent(index: 0, title: 'All'));
    }
    super.initState();
  }

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
                  onTap: () {
                    for (var i = 0; i < _menu.length; i++) {
                      setState(() {
                        _menu[i].isTap = false;
                      });
                    }

                    setState(() {
                      _menu[index].isTap = true;
                    });

                    widget.bloc.add(TabberNavEvent(
                        index: index, title: _menu[index].title));
                  },
                  isTap: _menu[index].isTap),
            ),
          ),
        ),
      ),
    );
  }
}
