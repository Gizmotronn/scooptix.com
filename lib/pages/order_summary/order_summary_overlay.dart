import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appolloDivider.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/UI/widgets/textfield/discount_textfield.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/model/discount.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/pages/event_details/checkout_drawer.dart';

import 'bloc/ticket_bloc.dart';

class OrderSummaryOverlay extends StatefulWidget {
  final Event event;
  final Map<TicketRelease, int> selectedTickets;
  final double maxWidth;

  const OrderSummaryOverlay(this.event, {Key key, @required this.selectedTickets, @required this.maxWidth})
      : super(key: key);

  @override
  _OrderSummaryOverlayState createState() => _OrderSummaryOverlayState();
}

class _OrderSummaryOverlayState extends State<OrderSummaryOverlay> {
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
          style: MyTheme.textTheme.headline4.copyWith(fontWeight: FontWeight.w600),
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
                      event: widget.event,
                      discount: discount,
                      selectedTickets: widget.selectedTickets,
                    );
                    WrapperPage.mainScaffold.currentState.openEndDrawer();
                  }
                },
                child: Text(
                  "CHECKOUT",
                  style: MyTheme.textTheme.button.copyWith(color: MyTheme.appolloBackgroundColor),
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
          if (widget.selectedTickets.isEmpty) {
            return Center(
              child: Text("No Tickets Selected"),
            ).paddingTop(250);
          } else {
            return _buildPriceBreakdown();
          }
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
              Text("Subtotal", style: MyTheme.textTheme.bodyText1),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("\$${(subtotal / 100).toStringAsFixed(2)}",
                          style: MyTheme.textTheme.bodyText1.copyWith(fontWeight: FontWeight.w600))))
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
                  "Discount (${discount.type == DiscountType.value ? "\$" + (discount.amount / 100).toStringAsFixed(2) + " x ${_discountAppliesTo()}" : discount.amount.toString() + "%"})",
                  style: MyTheme.textTheme.bodyText1,
                ),
                SizedBox(
                    child: Text("-\$${_calculateDiscount().toStringAsFixed(2)}",
                        style: MyTheme.textTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)))
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
                style: MyTheme.textTheme.bodyText1,
              ),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("\$${_calculateAppolloFees().toStringAsFixed(2)}",
                          style: MyTheme.textTheme.bodyText1.copyWith(fontWeight: FontWeight.w600))))
            ],
          ),
        ),
        AppolloDivider(),
        SizedBox(
          width: widget.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: MyTheme.textTheme.bodyText1),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                          "\$${(subtotal / 100 - _calculateDiscount() + _calculateAppolloFees()).toStringAsFixed(2)}",
                          style: MyTheme.textTheme.bodyText1.copyWith(fontWeight: FontWeight.w600))))
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
            Text(key.ticketName + " x $value", style: MyTheme.textTheme.bodyText1),
            SizedBox(
                width: 70,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text("\$${(key.price * value / 100).toStringAsFixed(2)}",
                        style: MyTheme.textTheme.bodyText1.copyWith(fontWeight: FontWeight.w600))))
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
    }
    if (discount.appliesToReleases.isEmpty) {
      if (discount.type == DiscountType.value) {
        return discount.amount.toDouble() * totalTicketQuantity / 100;
      } else {
        return subtotal * discount.amount / 100 / 100;
      }
    } else {
      double disc = 0.0;
      widget.selectedTickets.forEach((key, value) {
        if (discount.appliesToReleases.contains(key.docId)) {
          if (discount.type == DiscountType.value) {
            disc += discount.amount.toDouble() * value / 100;
          } else {
            disc += (discount.amount / 100 * key.price) * value;
          }
        }
      });
      return disc;
    }
  }

  int _discountAppliesTo() {
    if (discount.appliesToReleases.isEmpty) {
      return totalTicketQuantity;
    } else {
      int counter = 0;
      widget.selectedTickets.forEach((key, value) {
        if (discount.appliesToReleases.contains(key.docId)) {
          counter++;
        }
      });
      return counter;
    }
  }

  double _calculateAppolloFees() {
    if (subtotal == 0) {
      return 0.0;
    } else {
      double fee = subtotal / 100 * widget.event.feePercent / 100;
      if (fee < 1.0) {
        fee = 1.0;
      }
      return fee;
    }
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
          if (widget.selectedTickets.isEmpty) {
            return SizedBox.shrink();
          } else {
            return Column(
              children: [
                DiscountTextField(
                  discountController: _discountController,
                  bloc: bloc,
                  state: state,
                  width: widget.maxWidth,
                  event: widget.event,
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
                                style: MyTheme.textTheme.caption
                                    .copyWith(color: MyTheme.appolloTeal, fontWeight: FontWeight.w400),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  discount = null;
                                  bloc.add(EventRemoveDiscount());
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: MyTheme.appolloLightBlue,
                                size: 14,
                              ).paddingLeft(4).paddingRight(8),
                            )
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
                                style: MyTheme.textTheme.caption.copyWith(fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        )),
                  ),
              ],
            );
          }
        });
  }
}
