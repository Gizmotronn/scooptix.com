import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/widgets/buttons/navbutton.dart';
import 'package:ticketapp/pages/events_overview/bloc/events_overview_bloc.dart';
import 'event_overview_home.dart';
import 'package:ticketapp/UI/theme.dart';

class EventOverviewNavigationBar extends StatefulWidget {
  final EventsOverviewBloc bloc;

  const EventOverviewNavigationBar({Key key, this.bloc}) : super(key: key);
  @override
  _EventOverviewNavigationBarState createState() => _EventOverviewNavigationBarState();
}

class _EventOverviewNavigationBarState extends State<EventOverviewNavigationBar> {
  List<Menu> _menu = [
    Menu('All', true),
    Menu('Free', false),
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
    // Only add for me on desktop
    Future.delayed(Duration(milliseconds: 1)).then((value) {
      if (getValueForScreenType(context: context, watch: false, mobile: false, tablet: true, desktop: true)) {
        setState(() {
          _menu.insert(2, Menu('For me', false));
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      height: 50,
      child: ResponsiveBuilder(
        builder: (c, size) {
          if (size.isDesktop || size.isTablet) {
            return Center(
              child: SizedBox(
                width: screenSize.width * 0.8 - MyTheme.elementSpacing * 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                            widget.bloc.add(TabberNavEvent(index: index, title: _menu[index].title));
                          },
                          isTap: _menu[index].isTap)),
                ),
              ),
            );
          } else {
            return Container(
              width: screenSize.width,
              child: Center(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(left: MyTheme.elementSpacing),
                  scrollDirection: Axis.horizontal,
                  itemCount: _menu.length,
                  itemBuilder: (context, index) => NavbarButton(
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

                            widget.bloc.add(TabberNavEvent(index: index, title: _menu[index].title));
                          },
                          isTap: _menu[index].isTap)
                      .paddingRight(MyTheme.elementSpacing),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
