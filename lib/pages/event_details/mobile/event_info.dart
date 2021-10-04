import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticketapp/model/organizer.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';
import '../../../UI/theme.dart';
import '../../../UI/widgets/cards/booking_card.dart';
import '../../../model/event.dart';
import '../../../UI/icons.dart';

class EventInfoMobile extends StatefulWidget {
  const EventInfoMobile({Key? key, required this.event, required this.organizer}) : super(key: key);

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
              style: MyTheme.textTheme.headline2!.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
            ).paddingBottom(8),
            AutoSizeText.rich(
                TextSpan(
                  text: 'Organised by',
                  children: [
                    TextSpan(
                        text: ' ${widget.organizer.organizationName}',
                        style: MyTheme.textTheme.subtitle1!
                            .copyWith(color: MyTheme.appolloWhite, fontWeight: FontWeight.w500))
                  ],
                ),
                style: MyTheme.textTheme.subtitle1!.copyWith(color: MyTheme.appolloWhite, fontWeight: FontWeight.w400)),
          ],
        ).paddingBottom(MyTheme.elementSpacing),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              'Event Details',
              style: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
            ).paddingBottom(MyTheme.elementSpacing),
            IconText(text: DateFormat("MMMM dd. yyy").format(widget.event.date), icon: AppolloIcons.calenderOutline)
                .paddingBottom(8),
            IconText(text: widget.event.address.trimLeft(), icon: AppolloIcons.pin).paddingBottom(8),
            IconText(
                    text:
                        '${time(widget.event.date)} - ${widget.event.endTime != null ? time(widget.event.endTime!) : ""}',
                    icon: AppolloIcons.clock)
                .paddingBottom(8),
            IconText(
                text:
                    'Ticket Price: ${money(widget.event.getAllReleases().isEmpty ? 0 : widget.event.getAllReleases().first.price! / 100)} + BF',
                icon: AppolloIcons.ticket),
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
