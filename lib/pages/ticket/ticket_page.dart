import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appolloDivider.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/model/discount.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/pages/event_details/checkout_drawer.dart';
import 'package:ticketapp/pages/ticket/bloc/ticket_bloc.dart';
import 'package:ticketapp/repositories/user_repository.dart';

class TicketPage extends StatefulWidget {
  final LinkType linkType;
  final bool forwardToPayment;
  final Map<TicketRelease, int> selectedTickets;
  final double maxWidth;

  const TicketPage(this.linkType,
      {Key key, @required this.forwardToPayment, @required this.selectedTickets, @required this.maxWidth})
      : super(key: key);

  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  TicketBloc bloc = TicketBloc();
  double subtotal;
  int totalTicketQuantity;
  Discount discount;
  TextEditingController _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    subtotal = 0;
    totalTicketQuantity = 0;
    widget.selectedTickets.forEach((release, quantity) {
      subtotal += release.price * quantity;
    });
    if (widget.selectedTickets.isNotEmpty) {
      totalTicketQuantity = widget.selectedTickets.values.reduce((a, b) => a + b);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          "Order Summary",
          style: MyTheme.lightTextTheme.headline2,
        ).paddingBottom(MyTheme.elementSpacing),
        _buildMainContent().paddingBottom(MyTheme.elementSpacing),
        _buildDiscountCode().paddingBottom(MyTheme.elementSpacing),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: widget.maxWidth,
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: MyTheme.appolloGreen,
                ),
                onPressed: () {
                  if (widget.selectedTickets.isNotEmpty) {
                    WrapperPage.endDrawer.value = CheckoutDrawer(
                      linkType: widget.linkType,
                      discount: discount,
                      selectedTickets: widget.selectedTickets,
                    );
                    WrapperPage.mainScaffold.currentState.openEndDrawer();
                  }
                },
                child: Text(
                  "CHECKOUT",
                  style: MyTheme.lightTextTheme.button.copyWith(color: MyTheme.appolloBackgroundColor),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return BlocBuilder<TicketBloc, TicketState>(
        cubit: bloc,
        builder: (c, state) {
          return _buildPriceBreakdown();
        });
  }

  Widget _buildPriceBreakdown() {
    return Column(
      children: [
        _buildSelectedTickets(),
        AppolloDivider(),
        SizedBox(
          width: widget.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Subtotal", style: MyTheme.lightTextTheme.bodyText2),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("\$${(subtotal / 100).toStringAsFixed(2)}", style: MyTheme.lightTextTheme.bodyText2)))
            ],
          ),
        ).paddingBottom(MyTheme.elementSpacing),
        if (discount != null && discount.enoughLeft(totalTicketQuantity))
          SizedBox(
            width: widget.maxWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Discount (${discount.type == DiscountType.value ? "\$" + (discount.amount / 100).toStringAsFixed(2) + " x $totalTicketQuantity" : discount.amount.toString() + "%"})",
                  style: MyTheme.lightTextTheme.bodyText2,
                ),
                SizedBox(
                    child:
                        Text("-\$${_calculateDiscount().toStringAsFixed(2)}", style: MyTheme.lightTextTheme.bodyText2))
              ],
            ),
          ).paddingBottom(MyTheme.elementSpacing),
        SizedBox(
          width: widget.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Booking Fee",
                style: MyTheme.lightTextTheme.bodyText2,
              ),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("\$${_calculateAppolloFees().toStringAsFixed(2)}",
                          style: MyTheme.lightTextTheme.bodyText2)))
            ],
          ),
        ).paddingBottom(MyTheme.elementSpacing),
        AppolloDivider(),
        SizedBox(
          width: widget.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: MyTheme.lightTextTheme.bodyText2),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                          "\$${(subtotal / 100 - _calculateDiscount() + _calculateAppolloFees()).toStringAsFixed(2)}",
                          style: MyTheme.lightTextTheme.bodyText2)))
            ],
          ),
        ).paddingBottom(8),
      ],
    );
  }

  Column _buildSelectedTickets() {
    List<Widget> tickets = [];

    widget.selectedTickets.forEach((key, value) {
      tickets.add(SizedBox(
        width: widget.maxWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(key.ticketName + " x $value", style: MyTheme.lightTextTheme.bodyText2),
            SizedBox(
                width: 70,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text("\$${(key.price * value / 100).toStringAsFixed(2)}",
                        style: MyTheme.lightTextTheme.bodyText2)))
          ],
        ),
      ).paddingBottom(8));
    });

    return Column(
      children: tickets,
    );
  }

  double _calculateDiscount() {
    if (discount == null) {
      return 0.0;
    } else if (discount.type == DiscountType.value) {
      return discount.amount.toDouble() * totalTicketQuantity / 100;
    } else {
      return subtotal * discount.amount / 100 / 100;
    }
  }

  double _calculateAppolloFees() {
    if (subtotal == 0) {
      return 0.0;
    } else {
      double fee = subtotal / 100 * widget.linkType.event.feePercent / 100;
      if (fee < 1.0) {
        fee = 1.0;
      }
      return fee;
    }
  }

  VoidCallback _updateAfterLogin() {
    return () {
      if (UserRepository.instance.isLoggedIn) {
        setState(() {});
      }
      UserRepository.instance.currentUserNotifier.removeListener(_updateAfterLogin());
    };
  }

  Widget _buildDiscountCode() {
    return BlocConsumer<TicketBloc, TicketState>(
        cubit: bloc,
        listener: (c, state) {
          if (state is StateDiscountApplied) {
            setState(() {
              discount = state.discount;
            });
          } else if (state is StateDiscountCodeInvalid) {
            setState(() {
              discount = null;
            });
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              AppolloCard(
                color: MyTheme.appolloLightCardColor,
                child: SizedBox(
                  height: 38,
                  width: widget.maxWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          decoration: InputDecoration(
                              fillColor: Colors.transparent,
                              enabledBorder: InputBorder.none,
                              border: InputBorder.none,
                              hintText: "Discount Code",
                              isDense: true),
                          controller: _discountController,
                        ).paddingRight(8),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              primary: MyTheme.appolloGreen,
                            ),
                            onPressed: () {
                              if (_discountController.text != "") {
                                bloc.add(EventApplyDiscount(widget.linkType.event, _discountController.text));
                              }
                            },
                            child: state is StateDiscountCodeLoading
                                ? Transform.scale(scale: 0.5, child: CircularProgressIndicator())
                                : Text(
                                    "Apply",
                                    style: MyTheme.lightTextTheme.caption,
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ).paddingBottom(8),
              if (state is StateDiscountApplied)
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppolloCard(
                      color: MyTheme.appolloGreen.withAlpha(90),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                            child: AutoSizeText(
                              state.discount.code,
                              style: MyTheme.lightTextTheme.caption
                                  .copyWith(color: MyTheme.appolloTeal, fontWeight: FontWeight.w400),
                            ),
                          ),
                          Icon(
                            Icons.close,
                            color: MyTheme.appolloLightBlue,
                            size: 14,
                          ).paddingLeft(4).paddingRight(8)
                        ],
                      )),
                ),
              if (state is StateDiscountCodeInvalid)
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppolloCard(
                      color: MyTheme.appolloRed.withAlpha(90),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                            child: AutoSizeText(
                              "This code is invalid",
                              style: MyTheme.lightTextTheme.caption.copyWith(fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      )),
                ),
            ],
          );
        });
  }
}
