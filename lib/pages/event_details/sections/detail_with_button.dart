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
  const EventInfo({Key? key, required this.event, required this.buttons, required this.organizer}) : super(key: key);

  final Event event;
  final Organizer organizer;
  final List<CardButton> buttons;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Row(
            children: [
              _buildImage(),
              SizedBox(width: MyTheme.elementSpacing),
              _buildContent(context),
            ],
          ).paddingBottom(MyTheme.elementSpacing),
        ),
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: buttons,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: MyTheme.maxWidth / 2 / 1.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  event.name,
                  style:
                      MyTheme.textTheme.headline2!.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
                ).paddingBottom(8),
                AutoSizeText.rich(
                    TextSpan(
                      text: 'Organised by',
                      children: [
                        TextSpan(
                            text: ' ${organizer.organizationName}',
                            style: MyTheme.textTheme.subtitle1!
                                .copyWith(color: MyTheme.appolloWhite, fontWeight: FontWeight.w500))
                      ],
                    ),
                    style: MyTheme.textTheme.subtitle1!
                        .copyWith(color: MyTheme.appolloWhite, fontWeight: FontWeight.w400)),
              ],
            ).paddingBottom(MyTheme.elementSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    'Event Details',
                    style:
                        MyTheme.textTheme.headline4!.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
                  ).paddingBottom(MyTheme.elementSpacing / 2),
                  IconText(text: event.address.trimLeft(), icon: AppolloSvgIcon.pin).paddingBottom(8),
                  IconText(text: DateFormat("MMMM dd. yyy").format(event.date), icon: AppolloSvgIcon.calenderOutline)
                      .paddingBottom(8),
                  IconText(
                          text: '${time(event.date)} - ${event.endTime != null ? time(event.endTime!) : ""}',
                          icon: AppolloSvgIcon.clock)
                      .paddingBottom(8),
                  IconText(
                      text:
                          'Ticket Price: ${money(event.getAllReleases().isEmpty ? 0 : event.getAllReleases().first.price! / 100)} + BF',
                      icon: AppolloSvgIcon.ticket),
                ],
              ),
            )
          ],
        ).paddingVertical(4),
      ),
    );
  }

  Widget _buildImage() {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1.9,
          child: FittedBox(
            fit: BoxFit.cover,
            child:
                ExtendedImage.network(event.coverImageURL, cache: true, loadStateChanged: (ExtendedImageState state) {
              switch (state.extendedImageLoadState) {
                case LoadState.loading:
                  return Container(
                    color: Colors.white,
                  );
                case LoadState.completed:
                  return state.completedWidget;
                default:
                  return Container(
                    color: Colors.white,
                  );
              }
            }),
          ),
        ),
      ),
    );
  }
}
