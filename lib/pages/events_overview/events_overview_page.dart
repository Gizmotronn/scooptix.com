import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ticketapp/UI/event_overview/even_top_nav.dart';
import 'package:ticketapp/UI/event_overview/event_list.dart';
import 'package:ticketapp/UI/event_overview/side_buttons.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/apollo_button.dart';
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

  List<Menu> _menu = [
    Menu('All', true),
    Menu('From', false),
    Menu('For me', false),
    Menu('Today', false),
    Menu('This Weekend', false),
    Menu('This Week', false),
    Menu('Music', false),
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: MyTheme.appolloWhite,
      body: Container(
        color: MyTheme.appolloPurple.withAlpha(20),
        width: screenSize.width,
        height: screenSize.height,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          _eventOverview(screenSize),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // _sideNav(screenSize),
                              _buildEvents(),
                            ],
                          ),
                          Container(
                            width: screenSize.width,
                            height: screenSize.height * 0.3,
                            color: MyTheme.appolloBlack,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 16,
                  sigmaY: 16,
                ),
                child: Container(
                  height: 80,
                  color: MyTheme.appolloBlack.withAlpha(160),
                  width: screenSize.width,
                  child: OverViewTopNavBar(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvents() {
    return Column(
      children: [
        SizedBox(height: kToolbarHeight),
        AppolloEvents(events: widget.events),
      ],
    );
  }

  _eventOverview(Size screenSize) => Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: ExtendedImage.network(
                  'https://media.istockphoto.com/vectors/abstract-pop-art-line-and-dots-color-pattern-background-vector-liquid-vector-id1017781486?k=6&m=1017781486&s=612x612&w=0&h=nz4YljNqJ0xjxcdVVJge3dW3cqNakWjG7u2oFqW4tjs=',
                  cache: true,
                ).image,
                fit: BoxFit.cover,
              ),
            ),
            height: screenSize.height * 0.55,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: kToolbarHeight + 20),
                FeaturedEvent(),
              ],
            ),
          ),
          _eventOverViewNavBar(),
        ],
      );

  Widget _eventOverViewNavBar() {
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
                    (index) => InkWell(
                          onTap: () {},
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(_menu[index].title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                            fontSize: 12,
                                            color: _menu[index].isTap
                                                ? MyTheme.appolloGreen
                                                : MyTheme.appolloWhite)),
                                Container(
                                  height: 1.5,
                                  width: 20,
                                  color: _menu[index].isTap
                                      ? MyTheme.appolloGreen
                                      : Colors.transparent,
                                )
                              ],
                            ),
                          ),
                        ))),
          ),
        ));
  }

  _sideNav(Size screenSize) {
    return Wrap(
      children: [
        Container(
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
      ],
    ).paddingTop(32);
  }
}

class FeaturedEvent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16,
            sigmaY: 16,
          ),
          child: Container(
              height: 300,
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor.withOpacity(.4),
                border: Border.all(
                  width: 0.5,
                  color: MyTheme.appolloWhite.withOpacity(.4),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AutoSizeText('Humble ─  ',
                                style: Theme.of(context).textTheme.headline1),
                            Expanded(
                              child: AutoSizeText('90 ABERDEEN ST. NBR',
                                  style: Theme.of(context).textTheme.caption),
                            ),
                          ],
                        ).paddingBottom(4),
                        AutoSizeText('Every Saturday Night.',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(fontWeight: FontWeight.bold))
                            .paddingBottom(8),
                        AutoSizeText(
                          'Every Sat - Till\' Phase 5 Door from 6pm doors',
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        child: AppolloButton.mediumButton(
                            border: false,
                            color: MyTheme.appolloYellow,
                            child: Text('GET YOUR TICKETS',
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(color: MyTheme.appolloBlack)),
                            onTap: () {})),
                  )
                ],
              ).paddingAll(16)),
        ));
  }
}

class Menu {
  String title;
  bool isTap;
  Menu(this.title, this.isTap);
}
