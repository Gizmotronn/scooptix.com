import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_bottom_sheet.dart';
import 'package:ticketapp/UI/widgets/buttons/heart.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/user.dart';
import 'package:ticketapp/pages/authentication/authentication_sheet_wrapper.dart';
import 'package:ticketapp/pages/event_details/event_detail_page.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/services/navigator_services.dart';
import 'package:ticketapp/utilities/format_date/full_date_time.dart';
import '../../UI/theme.dart';

class EventCardMobile extends StatelessWidget {
  final Event event;

  const EventCardMobile({Key key, this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // NavigationService.navigateTo(EventDetail.routeName);
        NavigationService.navigateTo(EventDetailPage.routeName, arg: event.docID, queryParams: {'id': event.docID});
      },
      child: Container(
          height: MediaQuery.of(context).size.width / 1.9 / 2,
          width: MediaQuery.of(context).size.width - MyTheme.elementSpacing * 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: MyTheme.appolloCardColor,
            boxShadow: [
              BoxShadow(
                color: MyTheme.appolloBackgroundColorLight.withOpacity(.2),
                spreadRadius: 5,
                blurRadius: 10,
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _cardContent(context),
                  _cardImage(),
                ],
              ),
              _buildTag()
            ],
          )),
    );
  }

  Widget _buildTag() {
    return Positioned(
      right: 3,
      top: 3,
      child: ValueListenableBuilder<User>(
          valueListenable: UserRepository.instance.currentUserNotifier,
          builder: (context, user, child) {
            return FavoriteHeartButton(
              onTap: (v) {
                if (!v) {
                  if (user == null) {
                    showAppolloModalBottomSheet(
                        context: context,
                        backgroundColor: MyTheme.appolloBackgroundColor,
                        expand: true,
                        builder: (context) => AuthenticationPageWrapper());
                  } else {
                    ///TODO Add event as favorite to user
                    print('Event added to favorite');
                    user.toggleFavourite(event.docID);
                  }
                }
              },
              enable: user != null ? true : false,
              //TODO if event is favorited, should pass true
              isFavorite: _checkFavorite(user),
            );
          }),
    );
  }

  Widget _cardContent(BuildContext context) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  fullDate(event.date) ?? '',
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  style: MyTheme.textTheme.subtitle2.copyWith(color: MyTheme.appolloRed),
                ).paddingBottom(8),
              ),
            ],
          ),
          AutoSizeText(
            event.name ?? '',
            textAlign: TextAlign.start,
            maxLines: 3,
            overflow: TextOverflow.clip,
            style: MyTheme.textTheme.headline5,
          ),
        ],
      ).paddingAll(MyTheme.elementSpacing / 2),
    );
  }

  Widget _cardImage() {
    return AspectRatio(
      aspectRatio: 1.9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: event.coverImageURL == null
            ? SizedBox()
            : ClipPath(
                clipper: ImageClipper(),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: ExtendedImage.network(
                        event.coverImageURL,
                        cache: true,
                        loadStateChanged: (state) {
                          switch (state.extendedImageLoadState) {
                            case LoadState.loading:
                              return Container(color: Colors.white);
                            case LoadState.completed:
                              return state.completedWidget;
                            case LoadState.failed:
                              return Container(color: Colors.white);
                            default:
                              return Container(color: Colors.white);
                          }
                        },
                      ).image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
      ),
    ).paddingAll(MyTheme.elementSpacing / 2);
  }

  bool _checkFavorite(User user) {
    if (user != null) {
      return user.favourites.contains(event.docID) ?? false;
    } else {
      return false;
    }
  }
}

class ImageClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    Path path = Path();

    path.lineTo(size.width - 30, 0);
    path.arcToPoint(Offset(size.width, 30));
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return false;
  }
}
