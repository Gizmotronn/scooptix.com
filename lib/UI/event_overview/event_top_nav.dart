import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../pages/authentication/bloc/authentication_bloc.dart';
import '../../utilities/svg/icon.dart';
import '../theme.dart';
import '../widgets/icons/svgicon.dart';
import '../widgets/popups/appollo_popup.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/icons/svgicon.dart';
import 'package:ticketapp/UI/widgets/popups/appollo_popup.dart';
import 'package:ticketapp/pages/authentication/bloc/authentication_bloc.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

class EventOverviewAppbar extends StatefulWidget {
  final AuthenticationBloc bloc;

  final Color color;

  const EventOverviewAppbar({Key key, this.bloc, this.color}) : super(key: key);
  @override
  _EventOverviewAppbarState createState() => _EventOverviewAppbarState();
}

class _EventOverviewAppbarState extends State<EventOverviewAppbar> {
  bool isHoverSearchBar = false;
  final List<String> createEventOptions = ['Overview', 'Pricing', 'Blog'];

  final List<String> helpOptions = [
    'How do I connect event organizers',
    'Cost for creating event with us',
    'Where do I find my tickets',
    'Support Center'
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return ClipRRect(
        child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 16,
        sigmaY: 16,
      ),
      child: Container(
          height: kToolbarHeight,
          color: widget.color ?? MyTheme.appolloDarkBlue,
          width: screenSize.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _appolloLogo().paddingHorizontal(50),
                  _appolloSearchBar(context, screenSize),
                ],
              ).paddingVertical(4),
              Row(children: [
                _appolloCreateEventDropDown(context).paddingRight(16).paddingVertical(4),
                _appolloHelpDropDown(context).paddingRight(16).paddingVertical(4),
                _signInButton(context),
              ]),
            ],
          )),
    ));
  }

  Widget _appolloSearchBar(BuildContext context, Size screenSize) {
    return InkWell(
      onTap: () {},
      onHover: (v) {
        setState(() => isHoverSearchBar = v);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: 25,
            width: screenSize.width * 0.4,
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isHoverSearchBar ? MyTheme.appolloWhite.withOpacity(.8) : Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4)),
                color: isHoverSearchBar ? MyTheme.appolloGrey.withOpacity(.5) : MyTheme.appolloDarkBlue),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(height: 22, child: SvgIcon(AppolloSvgIcon.searchOutline, color: MyTheme.appolloWhite)),
                    Container(
                      child: Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.only(bottom: 14, left: 12),
                            focusedBorder: InputBorder.none,
                            hintText: 'Search Events',
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ).paddingBottom(8),
                      ),
                    ),
                  ],
                ).paddingHorizontal(4),
                isHoverSearchBar ? _searchAction(context) : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Align _searchAction(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        height: 30,
        width: 300,
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                height: 25,
                color: MyTheme.appolloWhite.withAlpha(120),
                child: Row(
                  children: [
                    Container(height: 16, child: SvgIcon(AppolloSvgIcon.perthGps, color: MyTheme.appolloWhite))
                        .paddingRight(4),
                    AutoSizeText('Perth, Australie', style: Theme.of(context).textTheme.button.copyWith(fontSize: 12)),
                  ],
                ).paddingHorizontal(8),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                height: 25,
                color: MyTheme.appolloGreen,
                child: Center(
                  child: AutoSizeText('Search', style: Theme.of(context).textTheme.button.copyWith(fontSize: 12))
                      .paddingHorizontal(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appolloLogo() => Text("appollo",
      style: MyTheme.lightTextTheme.subtitle1.copyWith(
          fontFamily: "cocon",
          color: Colors.white,
          fontSize: 25,
          shadows: [BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 1)]));

  Widget _appolloCreateEventDropDown(BuildContext context) => Container(
          child: AppolloPopup(
        item: List.generate(
          createEventOptions.length,
          (index) => PopupMenuItem(
            value: createEventOptions[index],
            child: Stack(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10,
                        sigmaY: 10,
                      ),
                      child: Container(
                        width: kMinInteractiveDimension,
                      ),
                    )),
                Text(createEventOptions[index]).paddingLeft(8)
              ],
            ),
          ),
        ),
        child: PopupButton(
          title: Text(
            'Create Event',
            style: Theme.of(context).textTheme.button.copyWith(fontWeight: FontWeight.w500),
          ),
          icon: Container(height: 20, child: SvgIcon(AppolloSvgIcon.arrowdown, color: MyTheme.appolloWhite)),
        ),
      ));

  Widget _appolloHelpDropDown(BuildContext context) => Container(
          child: AppolloPopup(
        item: List.generate(
          helpOptions.length,
          (index) => PopupMenuItem(
            value: helpOptions[index],
            child: Stack(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10,
                        sigmaY: 10,
                      ),
                      child: Container(
                        width: kMinInteractiveDimension,
                      ),
                    )),
                Text(helpOptions[index]).paddingLeft(8)
              ],
            ),
          ),
        ),
        child: PopupButton(
          title: Text(
            'Help',
            style: Theme.of(context).textTheme.button.copyWith(fontWeight: FontWeight.w500),
          ),
          icon: Container(height: 20, child: SvgIcon(AppolloSvgIcon.arrowdown, color: MyTheme.appolloWhite)),
        ),
      ));

  Widget _signInButton(context) => InkWell(
        onTap: () {
          widget.bloc.add(OnTapSignEvent());
          Scaffold.of(context).openEndDrawer();
        },
        child: Container(
          height: kToolbarHeight,
          color: MyTheme.appolloGreen,
          child: Center(
            child: Text('Login Or Sign Up',
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(fontWeight: FontWeight.w500, color: MyTheme.appolloDarkBlue))
                .paddingHorizontal(16),
          ),
        ),
      );
}