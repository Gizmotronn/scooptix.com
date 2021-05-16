import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/model/link_type/overview.dart';
import 'package:ticketapp/pages/event_details/authentication_drawer.dart';
import 'package:ticketapp/pages/event_details/birthday_list/birthday_drawer.dart';
import 'package:ticketapp/pages/event_details/birthday_list/birthday_sheet.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import '../../../UI/theme.dart';
import '../../../UI/widgets/buttons/apollo_button.dart';
import '../../../UI/widgets/cards/booking_card.dart';
import '../../../model/event.dart';
import '../../../utilities/svg/icon.dart';

class MakeBooking extends StatelessWidget {
  const MakeBooking({
    Key key,
    @required this.event,
  }) : super(key: key);

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          /* AutoSizeText(
            'Make A Booking',
            style: MyTheme.lightTextTheme.headline2.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
          ).paddingBottom(32),
          _vipBoothPackages(context).paddingBottom(32),
          _privateRoomPackages(context).paddingBottom(32),*/
          _birthdayListBookings(context).paddingBottom(32),
          _createBookingList(context).paddingBottom(32),
        ],
      ),
    );
  }

  Widget _vipBoothPackages(BuildContext context) {
    return Column(
      children: [
        _subtitle(context, 'VIP Booth Packages').paddingBottom(16),
        AutoSizeText(
                "If you wish to book a VIP Booth for the event please choose from one of the packages available below and follow the instructions to secure your booth.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w500))
            .paddingBottom(32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BookingCard(
              type: 'Stardard',
              price: '1,000',
              textIcons: [
                IconText(
                  text: 'VIP Tickets for all Guests',
                  icon: AppolloSvgIcon.dot,
                  iconSize: 8,
                ),
                IconText(
                  text: 'Private Room & Bar',
                  icon: AppolloSvgIcon.dot,
                  iconSize: 8,
                ),
              ],
            ),
            BookingCard(
              type: 'Premium',
              price: '1,500',
              textIcons: [
                IconText(
                  text: 'VIP Tickets for all Guests',
                  iconSize: 8,
                  icon: AppolloSvgIcon.dot,
                ),
                IconText(
                  text: 'Private Room & Bar',
                  icon: AppolloSvgIcon.dot,
                  iconSize: 8,
                ),
              ],
            ).paddingHorizontal(MyTheme.cardPadding),
            BookingCard(
              type: 'Platinum',
              price: '2,000',
              textIcons: [
                IconText(
                  text: 'VIP Tickets for all Guests',
                  iconSize: 8,
                  icon: AppolloSvgIcon.dot,
                ),
                IconText(
                  text: 'Private Room & Bar',
                  iconSize: 8,
                  icon: AppolloSvgIcon.dot,
                ),
              ],
            ),
          ],
        ),
      ],
    ).paddingHorizontal(32);
  }

  Widget _privateRoomPackages(BuildContext context) {
    return Column(
      children: [
        _subtitle(context, 'Private Room Packages').paddingBottom(16),
        AutoSizeText(
                "If you wish to book a Private Room please choose from one of the packages available below and follow the instructions to secure your booking.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w500))
            .paddingBottom(32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BookingCard(
              type: 'Small Room',
              price: '1,000',
              textIcons: List.generate(
                5,
                (index) => IconText(
                  text: 'Private Room & Bar',
                  icon: AppolloSvgIcon.dot,
                  iconSize: 8,
                ),
              ),
            ).paddingRight(MyTheme.cardPadding),
            BookingCard(
              type: 'Large Room',
              price: '1,500',
              textIcons: List.generate(
                4,
                (index) => IconText(
                  text: 'VIP Tickets for all Guests',
                  iconSize: 8,
                  icon: AppolloSvgIcon.dot,
                ),
              ),
            ),
          ],
        ),
      ],
    ).paddingHorizontal(32);
  }

  Widget _birthdayListBookings(BuildContext context) {
    return Column(
      children: [
        _subtitle(context, 'Birthday List Bookings').paddingBottom(16),
        AutoSizeText(
            "If you wish to create a birthday list for the event please choose from one of the packages available below and follow the instructions.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w500)),
      ],
    ).paddingHorizontal(32);
  }

  Widget _subtitle(BuildContext context, String title) {
    return AutoSizeText(
      title,
      style: Theme.of(context).textTheme.headline4.copyWith(color: MyTheme.appolloOrange, fontWeight: FontWeight.w600),
    );
  }

  Widget _createBookingList(BuildContext context) => SizedBox(
        height: 320,
        child: Container(
          child: Row(
            children: [
              Expanded(
                  flex: 7,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            AutoSizeText('Create A Birthday List',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4
                                        .copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w500))
                                .paddingBottom(32),
                            AutoSizeText(
                                    "Celebrate your birthday in style by creating a Birthday List for you and your closest friends and get the VIP experience.",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w500))
                                .paddingBottom(16),
                            Column(children: [
                              IconText(
                                text: 'VIP Entry for each Guest',
                                iconSize: 8,
                                icon: AppolloSvgIcon.dot,
                              ),
                              IconText(
                                text: 'Valid from 8pm - 10pm',
                                iconSize: 8,
                                icon: AppolloSvgIcon.dot,
                              ),
                            ])
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /*Align(
                              alignment: Alignment.center,
                              child: AutoSizeText.rich(
                                      TextSpan(text: '\$500', children: [
                                        TextSpan(text: '  +BF', style: Theme.of(context).textTheme.caption)
                                      ]),
                                      style:
                                          Theme.of(context).textTheme.headline2.copyWith(fontWeight: FontWeight.w600))
                                  .paddingBottom(MyTheme.cardPadding),
                            ),*/
                            Align(
                              alignment: Alignment.center,
                              child: AutoSizeText("Free of charge!", style: Theme.of(context).textTheme.headline4)
                                  .paddingBottom(MyTheme.elementSpacing),
                            ),
                            AppolloButton.regularButton(
                              color: MyTheme.appolloGreen,
                              child: AutoSizeText(
                                'CREATE BIRTHDAY LIST',
                                style:
                                    Theme.of(context).textTheme.button.copyWith(color: MyTheme.appolloBackgroundColor),
                              ),
                              onTap: () {
                                if (getValueForScreenType(
                                    context: context, watch: false, mobile: false, tablet: true, desktop: true)) {
                                  if (UserRepository.instance.isLoggedIn) {
                                    WrapperPage.endDrawer.value = BirthdayDrawer(
                                      linkType: OverviewLinkType(event),
                                    );
                                    WrapperPage.mainScaffold.currentState.openEndDrawer();
                                  } else {
                                    WrapperPage.endDrawer.value = AuthenticationDrawer();
                                    WrapperPage.mainScaffold.currentState.openEndDrawer();
                                    UserRepository.instance.currentUserNotifier.addListener(_tryOpenBirthdayDrawer());
                                  }
                                } else {
                                  BirthdaySheet.openMyTicketsSheet(OverviewLinkType(event));
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ).paddingAll(MyTheme.cardPadding),
                  )),
              /*Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                  ),
                  child: SvgPicture.asset(AppolloSvgIcon.cakewithbg, fit: BoxFit.cover),
                ),
              ),*/
            ],
          ),
        ).appolloCard().paddingHorizontal(MyTheme.elementSpacing),
      );

  VoidCallback _tryOpenBirthdayDrawer() {
    return () {
      if (UserRepository.instance.isLoggedIn) {
        WrapperPage.endDrawer.value = BirthdayDrawer(
          linkType: OverviewLinkType(event),
        );
        WrapperPage.mainScaffold.currentState.openEndDrawer();
      }
      UserRepository.instance.currentUserNotifier.removeListener(_tryOpenBirthdayDrawer());
    };
  }
}
