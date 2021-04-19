import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ticketapp/pages/event_details/widget/event_title.dart';

import '../../../UI/theme.dart';
import '../../../UI/widgets/appollo/appolloDivider.dart';
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
          EventDetailTitle('Make A Booking').paddingBottom(32),
          _vipBoothPackages(context).paddingBottom(32),
          _privateRoomPackages(context).paddingBottom(32),
          _birthdayListBookings(context).paddingBottom(32),
          _createBookingList(context).paddingBottom(32),
          AppolloDivider(),
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
                            AutoSizeText('Create A Booking List',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4
                                        .copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600))
                                .paddingBottom(32),
                            AutoSizeText(
                                    "Celebrate your birthday in style by creating a Birthday List for you and your closest friends and get the VIP experience.",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w500))
                                .paddingBottom(16),
                            Column(
                              children: List.generate(
                                4,
                                (index) => IconText(
                                  text: 'VIP Tickets for each Guests',
                                  iconSize: 8,
                                  icon: AppolloSvgIcon.dot,
                                ),
                              ),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: AutoSizeText.rich(
                                      TextSpan(text: '\$500', children: [
                                        TextSpan(text: '  +BF', style: Theme.of(context).textTheme.caption)
                                      ]),
                                      style:
                                          Theme.of(context).textTheme.headline2.copyWith(fontWeight: FontWeight.w600))
                                  .paddingBottom(MyTheme.cardPadding),
                            ),
                            AppolloButton.wideButton(
                              heightMax: 40,
                              heightMin: 40,
                              color: MyTheme.appolloGreen,
                              child: AutoSizeText(
                                'CREATE BIRTHDAY LIST',
                                style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.appolloDarkBlue),
                              ),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ).paddingAll(MyTheme.cardPadding),
                  )),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                  ),
                  child: SvgPicture.asset(AppolloSvgIcon.cakewithbg, fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ).appolloCard().paddingHorizontal(32),
      );
}
