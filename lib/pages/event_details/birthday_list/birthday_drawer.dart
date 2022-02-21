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
import 'package:ticketapp/UI/widgets/textfield/appollo_textfield.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/model/birthday_lists/attendee.dart';
import 'package:ticketapp/model/bookings/booking_data.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/authentication/authentication_drawer.dart';
import 'package:ticketapp/pages/event_details/birthday_list/bloc/birthday_list_bloc.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/utilities/platform_detector.dart';

/// In the desktop view, most of the functionality is displayed in the end drawer.
class BirthdayDrawer extends StatefulWidget {
  final Event event;
  final BookingData booking;

  const BirthdayDrawer({Key? key, required this.event, required this.booking}) : super(key: key);

  static openBookingsDrawer(Event event, BookingData booking) {
    if (!UserRepository.instance.isLoggedIn) {
      WrapperPage.endDrawer.value = AuthenticationDrawer(
        onAutoAuthenticated: () {
          WrapperPage.endDrawer.value = BirthdayDrawer(event: event, booking: booking);
          WrapperPage.mainScaffold.currentState!.openEndDrawer();
        },
      );
      WrapperPage.mainScaffold.currentState!.openEndDrawer();
    } else {
      WrapperPage.endDrawer.value = BirthdayDrawer(event: event, booking: booking);
      WrapperPage.mainScaffold.currentState!.openEndDrawer();
    }
  }

  @override
  _BirthdayDrawerState createState() => _BirthdayDrawerState();
}

class _BirthdayDrawerState extends State<BirthdayDrawer> {
  late BirthdayListBloc bloc;
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
    bloc = BirthdayListBloc();
    bloc.add(EventLoadExistingList(widget.event));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      width: MyTheme.drawerSize,
      height: screenSize.height,
      decoration: ShapeDecoration(
          color: MyTheme.scoopBackgroundColor,
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
                color: MyTheme.scoopRed,
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
                    BlocBuilder<BirthdayListBloc, BirthdayListState>(
                        bloc: bloc,
                        builder: (c, state) {
                          if (state is StateExistingList) {
                            return Container(
                              height: screenSize.height - 120,
                              child: ConstrainedBox(
                                constraints:
                                    BoxConstraints(minHeight: screenSize.height - 120, maxHeight: double.infinity),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText("Birthday list created.", style: MyTheme.textTheme.headline2)
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText("Invite your friends",
                                            style: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.scoopGreen))
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText(
                                            "Below you will find your invitation link. Copy the link and give it to anyone you wish to invite")
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText(
                                            "Guests need to open the link and accept your invite by following the instructions.")
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText("Invitation Link",
                                            style: MyTheme.textTheme.headline6!.copyWith(color: MyTheme.scoopOrange))
                                        .paddingBottom(MyTheme.elementSpacing * 0.5),
                                    OnTapAnimationButton(
                                      fill: true,
                                      border: true,
                                      width: screenSize.width,
                                      onTapColor: MyTheme.scoopGreen,
                                      onTapContent: Text(
                                        "LINK COPIED",
                                        style: MyTheme.textTheme.headline6,
                                      ),
                                      color: MyTheme.scoopBackgroundColorLight,
                                      onTap: () {
                                        if (PlatformDetector.isMobile()) {
                                          Share.share("scooptix.com/?id=${state.birthdayList.uuid}",
                                              subject: 'ScoopTix Event Invitation');
                                        } else {
                                          FlutterClipboard.copy("scooptix.com/?id=${state.birthdayList.uuid}");
                                        }
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: AutoSizeText(
                                          "scooptix.com/?id=${state.birthdayList.uuid}",
                                          style: MyTheme.textTheme.bodyText2,
                                        ),
                                      ),
                                    ).paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText("RSVP's",
                                            style: MyTheme.textTheme.headline6!.copyWith(color: MyTheme.scoopOrange))
                                        .paddingBottom(MyTheme.elementSpacing * 0.5),
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                                      child: ResponsiveDatatable(
                                        headers: _headers,
                                        source: _buildAttendeeTable(state.birthdayList.attendees),
                                        listDecoration: BoxDecoration(color: MyTheme.scoopBackgroundColorLight),
                                        itemPaddingVertical: 8,
                                        headerPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        headerDecoration: BoxDecoration(
                                            color: MyTheme.scoopPurple,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: AppolloButton.regularButton(
                                              fill: true,
                                              color: MyTheme.scoopGreen,
                                              child: Text(
                                                "Back",
                                                style: MyTheme.textTheme.button!
                                                    .copyWith(color: MyTheme.scoopBackgroundColor),
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                              })),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (state is StateNoList) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText("Create your birthday list.",
                                        maxLines: 2, style: MyTheme.textTheme.headline2)
                                    .paddingBottom(MyTheme.elementSpacing),
                                AutoSizeText("Celebrate in style!",
                                        style: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.scoopGreen))
                                    .paddingBottom(MyTheme.elementSpacing),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: widget.event.birthdayEventData!.benefits.length,
                                  itemBuilder: (context, index) {
                                    return Row(
                                      children: [
                                        Center(
                                          child: Container(
                                            decoration:
                                                ShapeDecoration(shape: CircleBorder(), color: MyTheme.scoopGreen),
                                            height: 12,
                                            width: 12,
                                          ).paddingRight(MyTheme.elementSpacing),
                                        ),
                                        Center(
                                            child: Text(
                                          widget.event.birthdayEventData!.benefits[index],
                                          style: MyTheme.textTheme.bodyText1,
                                        )),
                                      ],
                                    ).paddingBottom(8);
                                  },
                                ).paddingBottom(MyTheme.elementSpacing),
                                AutoSizeText("How many guests are you inviting?",
                                        style: MyTheme.textTheme.headline6!.copyWith(color: MyTheme.scoopOrange))
                                    .paddingBottom(MyTheme.elementSpacing),
                                ReactiveForm(
                                  formGroup: form,
                                  child: AppolloTextField.reactive(
                                    formControl: form.controls["numGuests"],
                                    validationMessages: (control) => {
                                      ValidationMessage.required: 'Please provide an estimate',
                                      ValidationMessage.number: 'Please provide an estimate',
                                    },
                                    labelText: "Guests",
                                  ).paddingBottom(MyTheme.elementSpacing),
                                ),
                                _buildOrderSummary().paddingBottom(MyTheme.elementSpacing),
                                Align(
                                    alignment: Alignment.bottomRight,
                                    child: AppolloButton.regularButton(
                                        fill: true,
                                        color: MyTheme.scoopGreen,
                                        child: Text(
                                          "Create",
                                          style:
                                              MyTheme.textTheme.button!.copyWith(color: MyTheme.scoopBackgroundColor),
                                        ),
                                        onTap: () {
                                          if (form.valid) {
                                            bloc.add(EventCreateList(
                                                widget.event, form.value["numGuests"] as int, widget.booking));
                                          } else {
                                            form.markAllAsTouched();
                                          }
                                        })),
                              ],
                            );
                          } else if (state is StateTooFarAway) {
                            return Container(
                              height: screenSize.height - 120,
                              child: ConstrainedBox(
                                constraints:
                                    BoxConstraints(minHeight: screenSize.height - 120, maxHeight: double.infinity),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText("Unable to create your birthday list.",
                                            maxLines: 2, style: MyTheme.textTheme.headline2)
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText("Your birthday is too far away!",
                                            style: MyTheme.textTheme.headline4!.copyWith(color: MyTheme.scoopGreen))
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText(
                                        "To qualify for a birthday list your birthday must fall within two weeks either side of the event date.\nPlease choose an event or date closer to your birthday."),
                                    Expanded(
                                      child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: AppolloButton.regularButton(
                                              fill: true,
                                              color: MyTheme.scoopGreen,
                                              child: Text(
                                                "Back",
                                                style: MyTheme.textTheme.button!
                                                    .copyWith(color: MyTheme.scoopBackgroundColor),
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                              })),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (state is StateCreatingList) {
                            return SizedBox(
                              height: screenSize.height,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AppolloProgressIndicator().paddingBottom(8),
                                  Text("Creating your birthday list ...")
                                ],
                              ),
                            );
                          } else if (state is StateError) {
                            return Center(
                              child: Text(state.message),
                            );
                          } else {
                            return SizedBox(
                              height: screenSize.height,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AppolloProgressIndicator().paddingBottom(8),
                                  Text("Loading Birthday List Data ...")
                                ],
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
                              color: MyTheme.scoopPurple,
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

  Widget _buildOrderSummary() {
    if (widget.event.birthdayEventData!.price == 0) {
      return AutoSizeText(
        "You can create this birhtday list free of charge!",
        style: MyTheme.textTheme.bodyText1,
      );
    } else {
      return Column(
        children: [
          AutoSizeText(
            "Order Summary",
            style: MyTheme.textTheme.headline4,
          ),
        ],
      );
    }
  }

  List<Map<String, dynamic>> _buildAttendeeTable(List<AttendeeTicket> attendees) {
    List<Map<String, dynamic>> tableData = [];
    attendees.forEach((element) {
      tableData.add({"name": element.name, "date": DateFormat("MMM dd.").format(element.dateAccepted!)});
    });
    return tableData;
  }
}
