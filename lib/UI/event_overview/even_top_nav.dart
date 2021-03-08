import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/apollo_button.dart';
import 'package:ticketapp/UI/widgets/popups/appollo_popup.dart';
import 'package:ticketapp/utilities/svg/icon.dart';
import 'package:websafe_svg/websafe_svg.dart';

class OverViewTopNavBar extends StatelessWidget {
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

    return Container(
      width: screenSize.width,
      child: Row(
        children: [
          _appolloLogo(),
          Expanded(
            child: _appolloSearchBar(context).paddingHorizontal(18),
          ),
          Container(
            child: Row(children: [
              _appolloCreateEventDropDown(context).paddingRight(18),
              _appolloHelpDropDown(context).paddingRight(18),
              _signInButton(context),
            ]),
          ),
        ],
      ),
    ).paddingHorizontal(50).paddingTop(12).paddingBottom(32);
  }

  Widget _appolloSearchBar(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(200),
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
                    color: MyTheme.appolloPurple.withOpacity(.7),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(200)),
              color: Theme.of(context).canvasColor.withOpacity(.5)),
          child: Row(
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
