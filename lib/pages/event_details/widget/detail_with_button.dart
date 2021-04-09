import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/card_button.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

class EventDetailWithButtons extends StatelessWidget {
  const EventDetailWithButtons({
    Key key,
    @required this.event,
    this.buttons,
  }) : super(key: key);

  final Event event;
  final List<CardButton> buttons;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
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
              AutoSizeText(event.name,
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          .copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600))
                  .paddingBottom(8),
              AutoSizeText.rich(
                  TextSpan(
                    text: 'Organised by',
                    children: [
                      TextSpan(
                          text: ' Bank & Co',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(color: MyTheme.appolloWhite, fontWeight: FontWeight.w500))
                    ],
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: MyTheme.appolloWhite, fontWeight: FontWeight.w400)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText('Event Details',
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600))
                  .paddingBottom(MyTheme.cardPadding),
              _iconText(context, text: event.address, icon: AppolloSvgIcon.pin).paddingBottom(8),
              _iconText(context, text: '8 PM - 4 AM', icon: AppolloSvgIcon.clock).paddingBottom(8),
              _iconText(context, text: 'Ticket Price: \$00 - BF', icon: AppolloSvgIcon.ticket),
            ],
          )
        ],
      ),
    );
  }

  Widget _iconText(BuildContext context, {String text, String icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SvgPicture.asset(icon, height: 18, width: 18).paddingRight(4),
        Expanded(child: AutoSizeText('$text', style: Theme.of(context).textTheme.caption)),
      ],
    );
  }

  Widget _buildImage() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          image: DecorationImage(
            image: ExtendedImage.network(
              event.coverImageURL ?? 'https://designshack.net/wp-content/uploads/party-club-flyer-templates.jpg',
              cache: true,
            ).image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
