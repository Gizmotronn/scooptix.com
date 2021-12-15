import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ticketapp/UI/responsive_table/responsive_table.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/model/birthday_lists/attendee.dart';
import 'package:ticketapp/pages/authentication/authentication_drawer.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/utilities/platform_detector.dart';
import '../../main.dart';
import 'bloc/bookings_bloc.dart';

/// In the desktop view, most of the functionality is displayed in the end drawer.
class BookingsDrawer extends StatefulWidget {
  const BookingsDrawer({Key? key}) : super(key: key);

  static openBookingsDrawer() {
    if (!UserRepository.instance.isLoggedIn) {
      WrapperPage.endDrawer.value = AuthenticationDrawer(
        onAutoAuthenticated: () {
          WrapperPage.endDrawer.value = BookingsDrawer();
          WrapperPage.mainScaffold.currentState!.openEndDrawer();
        },
      );
      WrapperPage.mainScaffold.currentState!.openEndDrawer();
    } else {
      WrapperPage.endDrawer.value = BookingsDrawer();
      WrapperPage.mainScaffold.currentState!.openEndDrawer();
    }
  }

  @override
  _BookingsDrawerState createState() => _BookingsDrawerState();
}

class _BookingsDrawerState extends State<BookingsDrawer> {
  late BookingsBloc bloc;
  late FormGroup form;
  List<DatatableHeader> _headers = [];

  @override
  void initState() {
    form = FormGroup({
      'numGuests': FormControl<int>(validators: [Validators.required, Validators.number]),
    });
    _headers = [
      DatatableHeader(
          text: "Name",
          value: "name",
          show: true,
          sortable: true,
          flex: 4,
          textAlign: TextAlign.left,
          sourceBuilder: (value, data) {
            return AutoSizeText(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MyTheme.textTheme.bodyText2,
            );
          }),
      DatatableHeader(
          text: "Date Accepted", value: "date", show: true, sortable: true, flex: 3, textAlign: TextAlign.left),
    ];
    bloc = BookingsBloc();
    bloc.add(EventLoadBookings());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      width: MyTheme.drawerSize,
      height: screenSize.height,
      decoration: ShapeDecoration(
          color: MyTheme.appolloBackgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)))),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.close,
                size: 34,
                color: MyTheme.appolloRed,
              ),
            ),
          ).paddingRight(16).paddingTop(8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: MyTheme.cardPadding),
            height: screenSize.height - 58,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenSize.height - 58, maxHeight: double.infinity),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BlocBuilder<BookingsBloc, BookingsState>(
                        bloc: bloc,
                        builder: (c, state) {
                          if (state is StateBookings) {
                            return Container(
                              height: screenSize.height - 120,
                              child: ConstrainedBox(
                                constraints:
                                    BoxConstraints(minHeight: screenSize.height - 120, maxHeight: double.infinity),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText("Booking Created", style: MyTheme.textTheme.headline2)
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText("Invite your friends",
                                            style: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.appolloGreen))
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText(
                                            "Below you will find your invitation link. Copy the link and give it to anyone you wish to invite")
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText(
                                            "Guests need to open the link and accept your invite by following the instructions.")
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText("Invitation Link",
                                            style: MyTheme.textTheme.headline6!.copyWith(color: MyTheme.appolloOrange))
                                        .paddingBottom(MyTheme.elementSpacing * 0.5),
                                    OnTapAnimationButton(
                                      fill: true,
                                      border: true,
                                      width: screenSize.width,
                                      onTapColor: MyTheme.appolloGreen,
                                      onTapContent: Text(
                                        "LINK COPIED",
                                        style: MyTheme.textTheme.headline6,
                                      ),
                                      color: MyTheme.appolloBackgroundColorLight,
                                      onTap: () {
                                        if (PlatformDetector.isMobile()) {
                                          Share.share("scooptix.com/?id=${state.bookings[0].uuid}",
                                              subject: 'ScoopTix Event Invitation');
                                        } else {
                                          FlutterClipboard.copy("scooptix.com/?id=${state.bookings[0].uuid}");
                                        }
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: AutoSizeText(
                                          "scooptix.com/?id=${state.bookings[0].uuid}",
                                          style: MyTheme.textTheme.bodyText2,
                                        ),
                                      ),
                                    ).paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText("RSVP's",
                                            style: MyTheme.textTheme.headline6!.copyWith(color: MyTheme.appolloOrange))
                                        .paddingBottom(MyTheme.elementSpacing * 0.5),
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                                      child: ResponsiveDatatable(
                                        headers: _headers,
                                        source: _buildAttendeeTable(state.bookings[0].attendees),
                                        listDecoration: BoxDecoration(color: MyTheme.appolloBackgroundColorLight),
                                        itemPaddingVertical: 8,
                                        headerPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        headerDecoration: BoxDecoration(
                                            color: MyTheme.appolloPurple,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: AppolloButton.regularButton(
                                              fill: true,
                                              color: MyTheme.appolloGreen,
                                              child: Text(
                                                "Back",
                                                style: MyTheme.textTheme.button!
                                                    .copyWith(color: MyTheme.appolloBackgroundColor),
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                              })),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (state is StateNoBookings) {
                            return Center(
                              child: Text("You don't have any upcoming bookings"),
                            );
                          } else {
                            return SizedBox(
                              height: screenSize.height,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [AppolloProgressIndicator().paddingBottom(8), Text("Loading Bookings ...")],
                              ),
                            );
                          }
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Events Powered By", style: MyTheme.textTheme.bodyText2!.copyWith(color: Colors.grey))
                            .paddingRight(4),
                        Text("ScoopTix",
                            style: MyTheme.textTheme.subtitle1!.copyWith(
                              color: MyTheme.appolloPurple,
                              fontSize: 18,
                            ))
                      ],
                    ).paddingBottom(MyTheme.elementSpacing).paddingTop(MyTheme.elementSpacing),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildAttendeeTable(List<AttendeeTicket> attendees) {
    List<Map<String, dynamic>> tableData = [];
    attendees.forEach((element) {
      tableData.add({"name": element.name, "date": DateFormat("MMM dd.").format(element.dateAccepted!)});
    });
    return tableData;
  }
}
