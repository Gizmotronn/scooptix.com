import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ticketapp/UI/event_overview/event_list.dart';
import 'package:ticketapp/UI/event_overview/side_buttons.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/app_bars/persistent_app_bar.dart';
import 'package:ticketapp/model/event.dart';

class EventOverviewPage extends StatefulWidget {
  final List<Event> events;
  const EventOverviewPage({Key key, this.events}) : super(key: key);

  @override
  _EventOverviewPageState createState() => _EventOverviewPageState();
}

class _EventOverviewPageState extends State<EventOverviewPage> {
  List<Menu> _sideMenu = [
    Menu('Monday', true),
    Menu('Tuesday', false),
    Menu('Wednesday', false),
    Menu('Thursday', false),
    Menu('Friday', false),
    Menu('Saturday', false),
    Menu('Sunday', false),
  ];
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: MyTheme.appolloLightGrey,
      body: NestedScrollView(
        body: Row(
          children: [
            _sideNav(screenSize),
            _buildEvents(),
          ],
        ),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                floating: true,
                pinned: true,
                delegate: AppolloPersistentAppBar(
                  appbarHeight: screenSize.height * 0.6,
                  shrinkChild: Container(
                    height: screenSize.height * 0.5,
                    child: _eventOverview(),
                  ),
                  child: _eventOverViewNavBar(),
                ),
              ),
            ),
          ];
        },
      ),
    );
  }

  Widget _buildEvents() {
    return Expanded(
      flex: 8,
      child: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(height: kToolbarHeight * 2),
          AppolloEvents(events: widget.events),
        ],
      )),
    );
  }

  _eventOverview() => Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ExtendedImage.network(
              'https://designshack.net/wp-content/uploads/party-club-flyer-templates.jpg',
              cache: true,
            ).image,
            fit: BoxFit.cover,
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            _topBar(),
            _eventHappening(),
          ],
        ),
      );

  Widget _topBar() => Container();
  Widget _eventHappening() => Container(
        height: 200,
        width: 600,
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor.withOpacity(.4),
          border:
              Border.all(width: 0.5, color: MyTheme.appolloGrey.withAlpha(140)),
          borderRadius: BorderRadius.circular(12),
        ),
      );

  Widget _eventOverViewNavBar() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      color: MyTheme.appolloWhite,
      child: Center(
          child: AutoSizeText(
        'Appollo NavBar Titles and options here',
        style:
            Theme.of(context).textTheme.headline3.copyWith(color: Colors.black),
      )),
    );
  }

  _sideNav(Size screenSize) {
    return Expanded(
      flex: 2,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Container(
          height: screenSize.height,
          child: Container(
            child: Column(
              children: List.generate(
                _sideMenu.length,
                (index) => SideButton(
                  title: _sideMenu[index].title,
                  isTap: _sideMenu[index].isTap,
                  onTap: () {
                    setState(() {
                      for (var i = 0; i < _sideMenu.length; i++) {
                        _sideMenu[i].isTap = false;
                      }
                      _sideMenu[index].isTap = true;
                    });
                  },
                ).paddingAll(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Menu {
  String title;
  bool isTap;
  Menu(this.title, this.isTap);
}
