import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ticketapp/UI/responsive_table/datatable_header.dart';
import 'package:ticketapp/UI/responsive_table/responsive_datatable.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_bottom_sheet.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/model/birthday_lists/attendee.dart';
import 'package:ticketapp/pages/authentication/authentication_sheet_wrapper.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/utilities/platform_detector.dart';

import '../../main.dart';
import 'bloc/bookings_bloc.dart';

class BookingsSheet extends StatefulWidget {
  BookingsSheet._();

  /// Makes sure the user is logged in before opening the My Ticket Sheet
  static openBookingsSheet() {
    if (UserRepository.instance.isLoggedIn) {
      showAppolloModalBottomSheet(
          context: WrapperPage.navigatorKey.currentContext!,
          backgroundColor: MyTheme.appolloBackgroundColorLight,
          expand: true,
          settings: RouteSettings(name: "bookings_sheet"),
          builder: (context) => BookingsSheet._());
    } else {
      showAppolloModalBottomSheet(
          context: WrapperPage.navigatorKey.currentContext!,
          backgroundColor: MyTheme.appolloBackgroundColorLight,
          expand: true,
          builder: (context) => AuthenticationPageWrapper(
                onAutoAuthenticated: (autoLoggedIn) {
                  Navigator.pop(WrapperPage.navigatorKey.currentContext!);
                  showAppolloModalBottomSheet(
                      context: WrapperPage.navigatorKey.currentContext!,
                      backgroundColor: MyTheme.appolloBackgroundColorLight,
                      expand: true,
                      settings: RouteSettings(name: "authentication_sheet"),
                      builder: (context) => BookingsSheet._());
                },
              ));
    }
  }

  @override
  _BookingsSheetState createState() => _BookingsSheetState();
}

class _BookingsSheetState extends State<BookingsSheet> {
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
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: MyTheme.appolloCardColorLight,
          automaticallyImplyLeading: false,
          title: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: MyTheme.elementSpacing, vertical: MyTheme.elementSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox.shrink(),
                    Text(
                      "Your Bookings",
                      style: MyTheme.textTheme.headline5,
                    ),
                    Text(
                      "Done",
                      style: MyTheme.textTheme.bodyText1!.copyWith(color: MyTheme.appolloGreen),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: MyTheme.elementSpacing),
          height: screenSize.height,
          child: BlocBuilder<BookingsBloc, BookingsState>(
              bloc: bloc,
              builder: (c, state) {
                if (state is StateBookings) {
                  return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText("Invite your friends",
                                style: MyTheme.textTheme.headline5!.copyWith(color: MyTheme.appolloGreen))
                            .paddingBottom(MyTheme.elementSpacing * 2)
                            .paddingTop(MyTheme.elementSpacing),
                        AutoSizeText(
                                "Below you will find your invitation link. Copy the link and give it to anyone you wish to invite")
                            .paddingBottom(MyTheme.elementSpacing),
                        AutoSizeText(
                                "Guests need to open the link and accept your invite by following the instructions.")
                            .paddingBottom(MyTheme.elementSpacing),
                        AutoSizeText("Invitation Link",
                                style: MyTheme.textTheme.headline5!.copyWith(color: MyTheme.appolloOrange))
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
                          color: MyTheme.appolloBackgroundColor,
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
                                style: MyTheme.textTheme.headline5!.copyWith(color: MyTheme.appolloOrange))
                            .paddingBottom(MyTheme.elementSpacing * 0.5),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                          child: ResponsiveDatatable(
                            headers: _headers,
                            useDesktopView: true,
                            source: _buildAttendeeTable(state.bookings[0].attendees),
                            listDecoration: BoxDecoration(color: MyTheme.appolloBackgroundColor),
                            itemPaddingVertical: 8,
                            headerPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            headerDecoration: BoxDecoration(
                                color: MyTheme.appolloPurple,
                                borderRadius:
                                    BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return SizedBox(
                    width: screenSize.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [AppolloProgressIndicator().paddingBottom(8), Text("Loading Bookings ...")],
                    ),
                  );
                }
              }),
        ));
  }

  List<Map<String, dynamic>> _buildAttendeeTable(List<AttendeeTicket> attendees) {
    List<Map<String, dynamic>> tableData = [];
    attendees.forEach((element) {
      tableData.add({"name": element.name, "date": DateFormat("MMM dd.").format(element.dateAccepted!)});
    });
    return tableData;
  }
}
