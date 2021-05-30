import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticketapp/model/organizer.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';
import '../../../UI/theme.dart';
import '../../../UI/widgets/cards/booking_card.dart';
import '../../../model/event.dart';
import '../../../utilities/svg/icon.dart';

class EventInfoMobile extends StatefulWidget {
  const EventInfoMobile({Key key, @required this.event, this.organizer}) : super(key: key);

  final Event event;
  final Organizer organizer;

  @override
  _EventInfoMobileState createState() => _EventInfoMobileState();
}

class _EventInfoMobileState extends State<EventInfoMobile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: Scaffold.of(context).appBarMaxHeight,
        ),
        _buildImage().paddingBottom(MyTheme.elementSpacing),
        _buildContent(context),
      ],
    ).paddingBottom(MyTheme.elementSpacing);
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              widget.event.name,
              style: MyTheme.textTheme.headline2.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
            ).paddingBottom(8),
            AutoSizeText.rich(
                TextSpan(
                  text: 'Organised by',
                  children: [
                    TextSpan(
                        text: ' ${widget.organizer?.getFullName() ?? ''}',
                        style: MyTheme.textTheme.bodyText2
                            .copyWith(color: MyTheme.appolloWhite, fontWeight: FontWeight.w500))
                  ],
                ),
                style: MyTheme.textTheme.bodyText2.copyWith(color: MyTheme.appolloWhite, fontWeight: FontWeight.w400)),
          ],
        ).paddingBottom(MyTheme.elementSpacing),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              'Event Details',
              style: MyTheme.textTheme.headline4.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
            ).paddingBottom(MyTheme.cardPadding),
            IconText(text: DateFormat("MMMM dd. yyy").format(widget.event.date), icon: AppolloSvgIcon.calenderOutline)
                .paddingBottom(8),
            IconText(text: widget.event.address.trimLeft() ?? '', icon: AppolloSvgIcon.pin).paddingBottom(8),
            IconText(
                    text: '${time(widget.event?.date) ?? ''} - ${time(widget.event?.endTime) ?? ''}',
                    icon: AppolloSvgIcon.clock)
                .paddingBottom(8),
            IconText(
                text:
                    'Ticket Price: ${money(widget.event.getAllReleases().isEmpty ? 0 : widget.event.getAllReleases().first.price / 100)} + BF',
                icon: AppolloSvgIcon.ticket),
          ],
        )
      ],
    );
  }

  Widget _buildImage() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AspectRatio(
        aspectRatio: 1.9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
              image: ExtendedImage.network(widget.event.coverImageURL, cache: true).image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
