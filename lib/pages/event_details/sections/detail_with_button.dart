import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticketapp/model/organizer.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';
import '../../../UI/theme.dart';
import '../../../UI/widgets/buttons/card_button.dart';
import '../../../UI/widgets/cards/booking_card.dart';
import '../../../model/event.dart';
import '../../../utilities/svg/icon.dart';

class EventInfo extends StatelessWidget {
  const EventInfo({Key key, @required this.event, this.buttons, this.organizer}) : super(key: key);

  final Event event;
  final Organizer organizer;
  final List<CardButton> buttons;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Row(
            children: [
              _buildImage(),
              SizedBox(width: MyTheme.cardPadding),
              _buildContent(context),
            ],
          ).paddingBottom(MyTheme.cardPadding),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: buttons,
        ).paddingBottom(MyTheme.cardPadding),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                event.name,
                style:
                    MyTheme.lightTextTheme.headline2.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
              ).paddingBottom(8),
              AutoSizeText.rich(
                  TextSpan(
                    text: 'Organised by',
                    children: [
                      TextSpan(
                          text: ' ${organizer?.getFullName() ?? ''}',
                          style: MyTheme.lightTextTheme.bodyText2
                              .copyWith(color: MyTheme.appolloWhite, fontWeight: FontWeight.w500))
                    ],
                  ),
                  style: MyTheme.lightTextTheme.bodyText2
                      .copyWith(color: MyTheme.appolloWhite, fontWeight: FontWeight.w400)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                'Event Details',
                style:
                    MyTheme.lightTextTheme.headline2.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
              ).paddingBottom(MyTheme.cardPadding),
              IconText(text: event.address ?? '', icon: AppolloSvgIcon.pin).paddingBottom(8),
              IconText(text: DateFormat("MMMM dd. yyy").format(event.date), icon: AppolloSvgIcon.calenderOutline)
                  .paddingBottom(8),
              IconText(text: '${time(event?.date) ?? ''} - ${time(event?.endTime) ?? ''}', icon: AppolloSvgIcon.clock)
                  .paddingBottom(8),
              IconText(
                  text:
                      'Ticket Price: ${money(event.getAllReleases().isEmpty ? 0 : event.getAllReleases().first.price)} - BF',
                  icon: AppolloSvgIcon.ticket),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
              image: ExtendedImage.network(event.coverImageURL, cache: true).image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}