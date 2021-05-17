import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ticketapp/UI/responsive_table/responsive_table.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/buttons/apollo_button.dart';
import 'package:ticketapp/UI/widgets/textfield/appollo_textfield.dart';
import 'package:ticketapp/model/birthday_lists/attendee.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/event_details/birthday_list/bloc/birthday_list_bloc.dart';
import 'package:ticketapp/utilities/platform_detector.dart';

/// In the desktop view, most of the functionality is displayed in the end drawer.
class BirthdayDrawer extends StatefulWidget {
  final Event event;

  const BirthdayDrawer({Key key, @required this.event}) : super(key: key);

  @override
  _BirthdayDrawerState createState() => _BirthdayDrawerState();
}

class _BirthdayDrawerState extends State<BirthdayDrawer> {
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
              style: MyTheme.lightTextTheme.bodyText2,
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
          ).paddingTop(16).paddingRight(16).paddingTop(8),
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
                        cubit: bloc,
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
                                    AutoSizeText("Birthday list created.", style: MyTheme.lightTextTheme.headline2)
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText("Invite your friends",
                                            style:
                                                MyTheme.lightTextTheme.headline4.copyWith(color: MyTheme.appolloGreen))
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText(
                                            "Below you will find your invitation link. Copy the link and give it to anyone you wish to invite")
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText(
                                            "Guests need to open the link and accept your invite by following the instructions.")
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText("Invitation Link",
                                            style:
                                                MyTheme.lightTextTheme.headline6.copyWith(color: MyTheme.appolloOrange))
                                        .paddingBottom(MyTheme.elementSpacing * 0.5),
                                    OnTapAnimationButton(
                                      fill: true,
                                      border: true,
                                      width: screenSize.width,
                                      onTapColor: MyTheme.appolloGreen,
                                      onTapContent: Text(
                                        "LINK COPIED",
                                        style: MyTheme.lightTextTheme.headline6,
                                      ),
                                      color: MyTheme.appolloBackgroundColor,
                                      onTap: () {
                                        if (PlatformDetector.isMobile()) {
                                          Share.share("appollo.io/invite?id=${state.birthdayList.uuid}",
                                              subject: 'Appollo Event Invitation');
                                        } else {
                                          FlutterClipboard.copy("appollo.io/invite?id=${state.birthdayList.uuid}");
                                        }
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: AutoSizeText(
                                          "appollo.io/invite?id=${state.birthdayList.uuid}",
                                          style: MyTheme.lightTextTheme.bodyText2,
                                        ),
                                      ),
                                    ).paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText("RSVP's",
                                            style:
                                                MyTheme.lightTextTheme.headline6.copyWith(color: MyTheme.appolloOrange))
                                        .paddingBottom(MyTheme.elementSpacing * 0.5),
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                                      child: ResponsiveDatatable(
                                        headers: _headers,
                                        source: _buildAttendeeTable(state.birthdayList.attendees),
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
                                                style: MyTheme.lightTextTheme.button
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
                          } else if (state is StateNoList) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText("Create your birthday list.",
                                        maxLines: 2, style: MyTheme.lightTextTheme.headline2)
                                    .paddingBottom(MyTheme.elementSpacing),
                                AutoSizeText("Celebrate in style!",
                                        style: MyTheme.lightTextTheme.headline4.copyWith(color: MyTheme.appolloGreen))
                                    .paddingBottom(MyTheme.elementSpacing),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: widget.event.birthdayEventData.benefits.length,
                                  itemBuilder: (context, index) {
                                    return Row(
                                      children: [
                                        Center(
                                          child: Container(
                                            decoration:
                                                ShapeDecoration(shape: CircleBorder(), color: MyTheme.appolloGreen),
                                            height: 12,
                                            width: 12,
                                          ).paddingRight(MyTheme.elementSpacing),
                                        ),
                                        Center(
                                            child: Text(
                                          widget.event.birthdayEventData.benefits[index],
                                          style: MyTheme.lightTextTheme.bodyText1,
                                        )),
                                      ],
                                    ).paddingBottom(8);
                                  },
                                ).paddingBottom(MyTheme.elementSpacing),
                                AutoSizeText("How many guests are you inviting?",
                                        style: MyTheme.lightTextTheme.headline6.copyWith(color: MyTheme.appolloOrange))
                                    .paddingBottom(MyTheme.elementSpacing),
                                ReactiveForm(
                                  formGroup: form,
                                  child: AppolloTextfield(
                                          controller: guestController,
                                          formControlName: "numGuests",
                                          validator: (v) =>
                                              v.isEmpty ? "Please enter an estimate of the number of guests" : null,
                                          labelText: "Guests",
                                          textfieldType: TextFieldType.reactive)
                                      .paddingBottom(MyTheme.elementSpacing),
                                ),
                                _buildOrderSummary().paddingBottom(MyTheme.elementSpacing),
                                Align(
                                    alignment: Alignment.bottomRight,
                                    child: AppolloButton.regularButton(
                                        fill: true,
                                        color: MyTheme.appolloGreen,
                                        child: Text(
                                          "Create",
                                          style: MyTheme.lightTextTheme.button
                                              .copyWith(color: MyTheme.appolloBackgroundColor),
                                        ),
                                        onTap: () {
                                          if (form.valid) {
                                            bloc.add(EventCreateList(widget.event, int.tryParse(guestController.text)));
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
                                            maxLines: 2, style: MyTheme.lightTextTheme.headline2)
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText("Your birthday is too far away!",
                                            style:
                                                MyTheme.lightTextTheme.headline4.copyWith(color: MyTheme.appolloGreen))
                                        .paddingBottom(MyTheme.elementSpacing),
                                    AutoSizeText(
                                        "To qualify for a birthday list your birthday must fall within two weeks either side of the event date.\nPlease choose an event or date closer to your birthday."),
                                    Expanded(
                                      child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: AppolloButton.regularButton(
                                              fill: true,
                                              color: MyTheme.appolloGreen,
                                              child: Text(
                                                "Back",
                                                style: MyTheme.lightTextTheme.button
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
                          } else if (state is StateCreatingList) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircularProgressIndicator().paddingBottom(8),
                                Text("Creating your birthday list ...")
                              ],
                            );
                          } else {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircularProgressIndicator().paddingBottom(8),
                                Text("Loading Birthday List Data ...")
                              ],
                            );
                          }
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Events Powered By", style: MyTheme.lightTextTheme.bodyText2.copyWith(color: Colors.grey))
                            .paddingRight(4),
                        Text("appollo",
                            style: MyTheme.lightTextTheme.subtitle1.copyWith(
                              fontFamily: "cocon",
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

  Widget _buildOrderSummary() {
    if (widget.event.birthdayEventData.price == 0) {
      return AutoSizeText(
        "You can create this birhtday list free of charge!",
        style: MyTheme.lightTextTheme.bodyText1,
      );
    } else {
      return Column(
        children: [
          AutoSizeText(
            "Order Summary",
            style: MyTheme.lightTextTheme.headline4,
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
