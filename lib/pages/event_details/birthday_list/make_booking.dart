import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_divider.dart';
import 'package:ticketapp/model/bookings/booking_data.dart';
import 'package:ticketapp/pages/event_details/birthday_list/bloc/birthday_list_bloc.dart';
import 'package:ticketapp/pages/event_details/birthday_list/birthday_drawer.dart';
import 'package:ticketapp/pages/event_details/birthday_list/birthday_sheet.dart';
import '../../../UI/theme.dart';
import '../../../UI/widgets/buttons/apollo_button.dart';
import '../../../UI/widgets/cards/booking_card.dart';
import '../../../model/event.dart';
import '../../../UI/icons.dart';

class MakeBooking extends StatefulWidget {
  const MakeBooking({
    Key? key,
    required this.event,
  }) : super(key: key);

  final Event event;

  @override
  _MakeBookingState createState() => _MakeBookingState();
}

class _MakeBookingState extends State<MakeBooking> {
  late BirthdayListBloc bloc;

  @override
  void initState() {
    bloc = BirthdayListBloc();
    bloc.add(EventLoadBookingData(widget.event));
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BirthdayListBloc, BirthdayListState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is StateBookingData) {
          return Container(
            child: Column(
              children: [
                /* AutoSizeText(
            'Make A Booking',
            style: MyTheme.lightTextTheme.headline2!.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
          ).paddingBottom(32),
          _vipBoothPackages(context).paddingBottom(32),
          _privateRoomPackages(context).paddingBottom(32),*/
                _birthdayListBookings(context).paddingBottom(MyTheme.elementSpacing),
                _createBookingList(state.booking),
                AppolloDivider(),
              ],
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _vipBoothPackages(BuildContext context) {
    return Column(
      children: [
        _subtitle(context, 'VIP Booth Packages').paddingBottom(16),
        AutoSizeText(
                "If you wish to book a VIP Booth for the event please choose from one of the packages available below and follow the instructions to secure your booth.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption!.copyWith(fontWeight: FontWeight.w500))
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
                  icon: AppolloIcons.dot,
                  iconSize: 8,
                ),
                IconText(
                  text: 'Private Room & Bar',
                  icon: AppolloIcons.dot,
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
                  icon: AppolloIcons.dot,
                ),
                IconText(
                  text: 'Private Room & Bar',
                  icon: AppolloIcons.dot,
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
                  icon: AppolloIcons.dot,
                ),
                IconText(
                  text: 'Private Room & Bar',
                  iconSize: 8,
                  icon: AppolloIcons.dot,
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
                style: Theme.of(context).textTheme.caption!.copyWith(fontWeight: FontWeight.w500))
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
                  icon: AppolloIcons.dot,
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
                  icon: AppolloIcons.dot,
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
            style: MyTheme.textTheme.bodyText1),
      ],
    ).paddingHorizontal(32);
  }

  Widget _subtitle(BuildContext context, String title) {
    return AutoSizeText(
      title,
      style: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.appolloOrange, fontWeight: FontWeight.w600),
    );
  }

  Widget _createBookingList(BookingData booking) => SizedBox(
        height: 320,
        width: 1040,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  AutoSizeText('Create A Birthday List',
                          style: MyTheme.textTheme.headline4!
                              .copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w500))
                      .paddingBottom(MyTheme.elementSpacing * 2),
                  AutoSizeText(
                          "Celebrate your birthday in style by creating a Birthday List for you and your closest friends and get the VIP experience.",
                          textAlign: TextAlign.center,
                          style: MyTheme.textTheme.caption!.copyWith(fontWeight: FontWeight.w500))
                      .paddingBottom(MyTheme.elementSpacing),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (c, index) {
                        return IconText(
                          text: booking.benefits[index],
                          iconSize: 8,
                          icon: AppolloIcons.dot,
                        );
                      },
                      itemCount: booking.benefits.length)
                ],
              ),
              Column(
                children: [
                  if (booking.price != 0)
                    Align(
                      alignment: Alignment.center,
                      child: AutoSizeText.rich(
                              TextSpan(
                                  text: '\$${(booking.price / 100).toStringAsFixed(2)}',
                                  children: [TextSpan(text: '  +BF', style: Theme.of(context).textTheme.caption)]),
                              style: Theme.of(context).textTheme.headline2!.copyWith(fontWeight: FontWeight.w600))
                          .paddingBottom(MyTheme.cardPadding),
                    ),
                  if (booking.price == 0)
                    Align(
                      alignment: Alignment.center,
                      child: AutoSizeText("Free of charge!",
                              style: MyTheme.textTheme.headline4!.copyWith(fontWeight: FontWeight.w600))
                          .paddingBottom(MyTheme.elementSpacing),
                    ),
                  AppolloButton.regularButton(
                    width: 400,
                    color: MyTheme.appolloGreen,
                    child: AutoSizeText(
                      'CREATE BIRTHDAY LIST',
                      style: MyTheme.textTheme.button,
                    ),
                    onTap: () {
                      if (getValueForScreenType(
                          context: context, watch: false, mobile: false, tablet: true, desktop: true)) {
                        BirthdayDrawer.openBookingsDrawer(
                          widget.event,
                          booking,
                        );
                      } else {
                        BirthdaySheet.openBirthdaySheet(widget.event, booking);
                      }
                    },
                  ),
                ],
              ),
            ],
          ).paddingAll(MyTheme.elementSpacing),
        )
            .appolloCard(color: MyTheme.appolloCardColor, borderRadius: BorderRadius.circular(16))
            .paddingHorizontal(MyTheme.elementSpacing),
      );
}
