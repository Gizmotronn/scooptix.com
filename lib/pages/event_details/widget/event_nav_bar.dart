import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/model/event.dart';

class EventDetailNavbar extends StatelessWidget {
  const EventDetailNavbar({
    Key key,
    @required this.event,
  }) : super(key: key);

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: MyTheme.maxWidth,
        height: kToolbarHeight + 20,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                        image: ExtendedImage.network(
                          event.coverImageURL ??
                              'https://designshack.net/wp-content/uploads/party-club-flyer-templates.jpg',
                          cache: true,
                        ).image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).paddingRight(16),
                  AutoSizeText(
                    event.name,
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              AppolloButton.wideButton(
                heightMax: 40,
                heightMin: 40,
                child: Center(
                  child: Text(
                    'GET YOUR TICKETS',
                    style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.appolloDarkBlue),
                  ),
                ),
                onTap: () {},
                color: MyTheme.appolloGreen,
              ),
            ],
          ).paddingAll(8),
        ).appolloCard(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
          color: MyTheme.appolloDarkBlue.withAlpha(190),
        ),
      ),
    );
  }
}
