import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/popups/appollo_popup.dart';
import 'package:ticketapp/utilities/svg/icon.dart';
import 'package:websafe_svg/websafe_svg.dart';

class EventOverviewAppbar extends StatefulWidget {
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
        height: kToolbarHeight + 20,
        color: MyTheme.appolloBlack.withAlpha(160),
        width: screenSize.width,
        child: Row(
          children: [
            _appolloLogo(),
            Expanded(
              child:
                  _appolloSearchBar(context, screenSize).paddingHorizontal(18),
            ),
            Container(
              child: Row(children: [
                _appolloCreateEventDropDown(context).paddingRight(18),
                _appolloHelpDropDown(context).paddingRight(18),
                _signInButton(context),
              ]),
            ),
          ],
        ).paddingHorizontal(50).paddingTop(8).paddingBottom(8),
      ),
    ));
  }

  Widget _appolloSearchBar(BuildContext context, Size screenSize) {
    return InkWell(
      onTap: () {},
      onHover: (v) {
        setState(() => isHoverSearchBar = v);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Container(
            height: 30,
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: MyTheme.appolloWhite.withOpacity(.4),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(4)),
                color: Theme.of(context).canvasColor.withOpacity(.5)),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        height: 22,
                        child: WebsafeSvg.asset(AppolloSvgIcon.searchOutline,
                            color: MyTheme.appolloWhite)),
                    Container(
                      child: Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding:
                                const EdgeInsets.only(bottom: 14, left: 12),
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
              child: Container(
                height: 30,
                color: MyTheme.appolloWhite.withAlpha(120),
                child: Row(
                  children: [
                    Container(
                            height: 16,
                            child: WebsafeSvg.asset(AppolloSvgIcon.perthGps,
                                color: MyTheme.appolloWhite))
                        .paddingRight(4),
                    AutoSizeText('Perth, Australie',
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(fontSize: 12)),
                  ],
                ).paddingHorizontal(8),
              ),
            ),
            Expanded(
              child: Container(
                height: 30,
                color: MyTheme.appolloGreen,
                child: Center(
                  child: AutoSizeText('Search',
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(fontSize: 12))
                      .paddingHorizontal(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _appolloLogo() => Text("appollo",
      style: MyTheme.lightTextTheme.subtitle1.copyWith(
          fontFamily: "cocon",
          color: Colors.white,
          fontSize: 25,
          shadows: [
            BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 1)
          ]));

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
            style: Theme.of(context)
                .textTheme
                .button
                .copyWith(fontWeight: FontWeight.w500),
          ),
          icon: Container(
              height: 20,
              child: WebsafeSvg.asset(AppolloSvgIcon.arrowdown,
                  color: MyTheme.appolloWhite)),
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
            style: Theme.of(context)
                .textTheme
                .button
                .copyWith(fontWeight: FontWeight.w500),
          ),
          icon: Container(
              height: 20,
              child: WebsafeSvg.asset(AppolloSvgIcon.arrowdown,
                  color: MyTheme.appolloWhite)),
        ),
      ));

  Widget _signInButton(context) => AppolloButton.smallButton(
      width: 100,
      color: MyTheme.appolloYellow,
      fill: false,
      border: true,
      child: Center(
        child: Text(
          'Sign In',
          style: Theme.of(context).textTheme.button.copyWith(
              fontWeight: FontWeight.w500, color: MyTheme.appolloYellow),
        ),
      ),
      onTap: () {});
}
