import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:webapp/UI/theme.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/pages/accept_invitation/ticket_page.dart';
import 'package:webapp/repositories/user_repository.dart';

class EventDetailsPage extends StatefulWidget {
  final LinkType linkType;

  const EventDetailsPage(this.linkType, {Key key}) : super(key: key);

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(screenSize),
      body: Stack(
        children: [
          Container(
            width: screenSize.width,
            height: screenSize.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.linkType.event.coverImageURL),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
              child: Container(
                width: screenSize.width,
                height: screenSize.height,
                decoration: BoxDecoration(color: Colors.grey[900].withOpacity(0.2)),
              ),
            ),
          ),
          SingleChildScrollView(child: TicketPage(widget.linkType).paddingAll(8).paddingTop(56)),
        ],
      ),
    );
  }

  Widget _buildAppBar(Size size) {
    return AppBar(
      titleSpacing: 0.0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.grey[900].withAlpha(150),
      title: Container(
        width: MyTheme.maxWidth,
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
            child: SizedBox(
              width: MyTheme.maxWidth,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MyTheme.maxWidth / 1.7,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          SizedBox(
                            width: MyTheme.maxWidth / 1.7,
                            child: AutoSizeText(
                              "${UserRepository.instance.currentUser.firstname} ${UserRepository.instance.currentUser.lastname}",
                              maxLines: 1,
                              style: MyTheme.lightTextTheme.subtitle2,
                            ),
                          ),
                          SizedBox(
                            width: MyTheme.maxWidth / 1.7,
                            child: AutoSizeText(
                              "${UserRepository.instance.currentUser.email}",
                              maxLines: 1,
                              style: MyTheme.lightTextTheme.bodyText2,
                            ),
                          ),
                        ]),
                      ),
                      SizedBox(
                        width: 106,
                        height: 34,
                        child: RaisedButton(
                          onPressed: () async {
                            await auth.FirebaseAuth.instance.signOut();
                            UserRepository.instance.dispose();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Logout",
                            style: MyTheme.lightTextTheme.button,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
