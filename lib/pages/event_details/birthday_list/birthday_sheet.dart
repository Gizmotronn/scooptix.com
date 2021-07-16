import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ticketapp/UI/responsive_table/DatatableHeader.dart';
import 'package:ticketapp/UI/responsive_table/ResponsiveDatatable.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_bottom_sheet.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/textfield/appollo_textfield.dart';
import 'package:ticketapp/model/birthday_lists/attendee.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/authentication/authentication_sheet_wrapper.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'package:ticketapp/utilities/platform_detector.dart';

import '../../../main.dart';
import 'bloc/birthday_list_bloc.dart';

class BirthdaySheet extends StatefulWidget {
  final Event event;
  BirthdaySheet._(this.event);

  /// Makes sure the user is logged in before opening the My Ticket Sheet
  static openBirthdaySheet(Event event) {
    if (UserRepository.instance.isLoggedIn) {
      showAppolloModalBottomSheet(
          context: WrapperPage.navigatorKey.currentContext,
          backgroundColor: MyTheme.appolloBackgroundColorLight,
          expand: true,
          settings: RouteSettings(name: "birthday_sheet"),
          builder: (context) => BirthdaySheet._(event));
    } else {
      showAppolloModalBottomSheet(
          context: WrapperPage.navigatorKey.currentContext,
          backgroundColor: MyTheme.appolloBackgroundColorLight,
          expand: true,
          builder: (context) => AuthenticationPageWrapper(
                onAutoAuthenticated: (autoLoggedIn) {
                  Navigator.pop(WrapperPage.navigatorKey.currentContext);
                  showAppolloModalBottomSheet(
                      context: WrapperPage.navigatorKey.currentContext,
                      backgroundColor: MyTheme.appolloBackgroundColorLight,
                      expand: true,
                      settings: RouteSettings(name: "authentication_sheet"),
                      builder: (context) => BirthdaySheet._(event));
                },
              ));
    }
  }

  @override
  _BirthdaySheetState createState() => _BirthdaySheetState();
}

class _BirthdaySheetState extends State<BirthdaySheet> {
  BirthdayListBloc bloc;
  FormGroup form;
  TextEditingController guestController = TextEditingController();
  List<DatatableHeader> _headers = [];

  @override
  void initState() {
    form = FormGroup({
      'numGuests': FormControl(validators: [Validators.required, Validators.number]),
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
                    BlocBuilder<BirthdayListBloc, BirthdayListState>(
                        cubit: bloc,
                        builder: (c, state) {
                          if (state is StateExistingList) {
                            return Text(
                              "Booking Created",
                              style: MyTheme.textTheme.headline5,
                            );
                          } else if (state is StateNoList) {
                            return Text(
                              "Create Your Booking",
                              style: MyTheme.textTheme.headline5,
                            );
                          } else if (state is StateTooFarAway) {
                            return Text(
                              "Unable To Create Booking",
                              style: MyTheme.textTheme.headline5,
                            );
                          } else {
                            return Text(
                              "Birthday Booking",
                              style: MyTheme.textTheme.headline5,
                            );
                          }
                        }),
                    Text(
                      "Done",
                      style: MyTheme.textTheme.bodyText1.copyWith(color: MyTheme.appolloGreen),
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
          child: BlocBuilder<BirthdayListBloc, BirthdayListState>(
              cubit: bloc,
              builder: (c, state) {
                if (state is StateExistingList) {
                  return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText("Invite your friends",
                                style: MyTheme.textTheme.headline5.copyWith(color: MyTheme.appolloGreen))
                            .paddingBottom(MyTheme.elementSpacing * 2)
                            .paddingTop(MyTheme.elementSpacing),
                        AutoSizeText(
                                "Below you will find your invitation link. Copy the link and give it to anyone you wish to invite")
                            .paddingBottom(MyTheme.elementSpacing),
                        AutoSizeText(
                                "Guests need to open the link and accept your invite by following the instructions.")
                            .paddingBottom(MyTheme.elementSpacing),
                        AutoSizeText("Invitation Link",
                                style: MyTheme.textTheme.headline5.copyWith(color: MyTheme.appolloOrange))
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
                              Share.share("appollo.io/?id=${state.birthdayList.uuid}",
                                  subject: 'Appollo Event Invitation');
                            } else {
                              FlutterClipboard.copy("appollo.io/?id=${state.birthdayList.uuid}");
                            }
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AutoSizeText(
                              "appollo.io/?id=${state.birthdayList.uuid}",
                              style: MyTheme.textTheme.bodyText2,
                            ),
                          ),
                        ).paddingBottom(MyTheme.elementSpacing),
                        AutoSizeText("RSVP's",
                                style: MyTheme.textTheme.headline5.copyWith(color: MyTheme.appolloOrange))
                            .paddingBottom(MyTheme.elementSpacing * 0.5),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                          child: ResponsiveDatatable(
                            headers: _headers,
                            useDesktopView: true,
                            source: _buildAttendeeTable(state.birthdayList.attendees),
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
                } else if (state is StateNoList) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText("Celebrate in style!",
                              style: MyTheme.textTheme.headline5.copyWith(color: MyTheme.appolloGreen))
                          .paddingBottom(MyTheme.elementSpacing * 2)
                          .paddingTop(MyTheme.elementSpacing),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.event.birthdayEventData.benefits.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Center(
                                child: Container(
                                  decoration: ShapeDecoration(shape: CircleBorder(), color: MyTheme.appolloGreen),
                                  height: 12,
                                  width: 12,
                                ).paddingRight(MyTheme.elementSpacing),
                              ),
                              Center(
                                  child: Text(
                                widget.event.birthdayEventData.benefits[index],
                                style: MyTheme.textTheme.bodyText1,
                              )),
                            ],
                          ).paddingBottom(8);
                        },
                      ).paddingBottom(MyTheme.elementSpacing),
                      AutoSizeText("How many guests are you inviting?",
                              style: MyTheme.textTheme.headline5.copyWith(color: MyTheme.appolloOrange))
                          .paddingBottom(MyTheme.elementSpacing),
                      ReactiveForm(
                        formGroup: form,
                        child: AppolloTextField(
                                controller: guestController,
                                formControlName: "numGuests",
                                validator: (v) => v.isEmpty ? "Please enter an estimate of the number of guests" : null,
                                labelText: "Guests",
                                textFieldType: TextFieldType.reactive)
                            .paddingBottom(MyTheme.elementSpacing),
                      ),
                      _buildOrderSummary().paddingBottom(MyTheme.elementSpacing),
                      Expanded(
                        child: Align(
                            alignment: Alignment.bottomRight,
                            child: AppolloButton.regularButton(
                                width: screenSize.width,
                                fill: true,
                                color: MyTheme.appolloGreen,
                                child: Text(
                                  "Create",
                                  style: MyTheme.textTheme.button.copyWith(color: MyTheme.appolloBackgroundColor),
                                ),
                                onTap: () {
                                  if (form.valid) {
                                    bloc.add(EventCreateList(widget.event, int.tryParse(guestController.text)));
                                  } else {
                                    form.markAllAsTouched();
                                  }
                                })).paddingBottom(MyTheme.elementSpacing * 2),
                      ),
                    ],
                  );
                } else if (state is StateTooFarAway) {
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText("Unable to create your birthday list.",
                                maxLines: 2, style: MyTheme.textTheme.headline2)
                            .paddingBottom(MyTheme.elementSpacing * 2),
                        AutoSizeText("Your birthday is too far away!",
                                style: MyTheme.textTheme.headline4.copyWith(color: MyTheme.appolloGreen))
                            .paddingBottom(MyTheme.elementSpacing),
                        AutoSizeText(
                            "To qualify for a birthday list your birthday must fall within two weeks either side of the event date.\nPlease choose an event or date closer to your birthday."),
                      ],
                    ).paddingTop(MyTheme.elementSpacing),
                  );
                } else if (state is StateCreatingList) {
                  return SizedBox(
                    width: screenSize.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [AppolloProgressIndicator().paddingBottom(8), Text("Creating your birthday list ...")],
                    ),
                  );
                } else {
                  return SizedBox(
                    width: screenSize.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [AppolloProgressIndicator().paddingBottom(8), Text("Loading Birthday List Data ...")],
                    ),
                  );
                }
              }),
        ));
  }

  Widget _buildOrderSummary() {
    if (widget.event.birthdayEventData.price == 0) {
      return AutoSizeText(
        "You can create this birthday list free of charge!",
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
      tableData.add({"name": element.name, "date": DateFormat("MMM dd.").format(element.dateAccepted)});
    });
    return tableData;
  }
}
