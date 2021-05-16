import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appolloDivider.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/UI/widgets/textfield/discount_textfield.dart';
import 'package:ticketapp/model/discount.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/pages/authentication/authentication_page.dart';
import 'package:ticketapp/pages/payment/payment_sheet_wrapper.dart';
import 'package:ticketapp/repositories/user_repository.dart';
import 'bloc/ticket_bloc.dart';

class OrderSummarySheet extends StatefulWidget {
  final bool collapsed;
  final LinkType linkType;
  final Map<TicketRelease, int> selectedTickets;

  const OrderSummarySheet({Key key, this.collapsed = false, @required this.linkType, @required this.selectedTickets})
      : super(key: key);
  @override
  _OrderSummarySheetState createState() => _OrderSummarySheetState();
}

class _OrderSummarySheetState extends State<OrderSummarySheet> {
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
    if (widget.collapsed) {
      return InkWell(
        onTap: () {
          showCupertinoModalBottomSheet(
              context: context,
              backgroundColor: MyTheme.appolloBackgroundColor,
              builder: (c) => OrderSummarySheet(
                    selectedTickets: widget.selectedTickets,
                    linkType: widget.linkType,
                    collapsed: false,
                  ));
        },
        child: Container(
          decoration: ShapeDecoration(
              color: MyTheme.appolloCardColorLight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft: Radius.circular(8)))),
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: MyTheme.elementSpacing * 1.5, vertical: MyTheme.elementSpacing * 1.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("\$${(subtotal / 100).toStringAsFixed(2)}", style: MyTheme.lightTextTheme.bodyText1),
                Text(
                  "Order Summary",
                  style: MyTheme.lightTextTheme.headline5,
                ),
                Text(
                  "Open",
                  style: MyTheme.lightTextTheme.bodyText1.copyWith(color: MyTheme.appolloGreen),
                )
              ],
            ),
          ),
        ),
      );
    }
    return Material(
      child: Navigator(
        onGenerateRoute: (_) {
          return MaterialPageRoute(builder: (sheetContext) {
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
                      padding:
                          EdgeInsets.symmetric(horizontal: MyTheme.elementSpacing, vertical: MyTheme.elementSpacing),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("\$${(subtotal / 100).toStringAsFixed(2)}", style: MyTheme.lightTextTheme.bodyText1),
                          Text(
                            "Order Summary",
                            style: MyTheme.lightTextTheme.headline5,
                          ),
                          Text(
                            "Close",
                            style: MyTheme.lightTextTheme.bodyText1.copyWith(color: MyTheme.appolloGreen),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    "Order Summary",
                    style: MyTheme.lightTextTheme.headline5.copyWith(color: MyTheme.appolloGreen),
                  ).paddingBottom(MyTheme.elementSpacing),
                  _buildMainContent().paddingBottom(MyTheme.elementSpacing),
                  _buildDiscountCode().paddingBottom(MyTheme.elementSpacing),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 38,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: MyTheme.appolloGreen,
                          ),
                          onPressed: () {
                            if (!UserRepository.instance.isLoggedIn) {
                              showCupertinoModalBottomSheet(
                                  context: context,
                                  backgroundColor: MyTheme.appolloBackgroundColor,
                                  expand: true,
                                  builder: (c) => AuthenticationPage(
                                        onAutoAuthenticated: (autoLoggedIn) {
                                          Navigator.pop(context);
                                          Navigator.push(
                                              sheetContext,
                                              MaterialPageRoute(
                                                  builder: (c) => PaymentSheetWrapper(
                                                        linkType: widget.linkType,
                                                        discount: discount,
                                                        selectedTickets: widget.selectedTickets,
                                                        maxHeight: MediaQuery.of(context).size.height,
                                                        parentContext: context,
                                                      )));
                                        },
                                      ));
                            } else if (widget.selectedTickets.isNotEmpty) {
                              Navigator.push(
                                  sheetContext,
                                  MaterialPageRoute(
                                      builder: (c) => PaymentSheetWrapper(
                                            linkType: widget.linkType,
                                            discount: discount,
                                            selectedTickets: widget.selectedTickets,
                                            maxHeight: MediaQuery.of(context).size.height,
                                            parentContext: context,
                                          )));
                            }
                          },
                          child: Text(
                            "PROCEED TO CHECKOUT",
                            style: MyTheme.lightTextTheme.button.copyWith(color: MyTheme.appolloBackgroundColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ).paddingAll(MyTheme.elementSpacing),
            );
          });
        },
      ),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Subtotal", style: MyTheme.lightTextTheme.bodyText2.copyWith(fontWeight: FontWeight.w600)),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("\$${(subtotal / 100).toStringAsFixed(2)}",
                          style: MyTheme.lightTextTheme.bodyText2.copyWith(fontWeight: FontWeight.w600))))
            ],
          ),
        ).paddingBottom(MyTheme.elementSpacing),
        if (discount != null && discount.enoughLeft(totalTicketQuantity))
          SizedBox(
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Booking Fee",
                style: MyTheme.lightTextTheme.bodyText2.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("\$${_calculateAppolloFees().toStringAsFixed(2)}",
                          style: MyTheme.lightTextTheme.bodyText2.copyWith(fontWeight: FontWeight.w600))))
            ],
          ),
        ).paddingBottom(MyTheme.elementSpacing),
        AppolloDivider(),
        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: MyTheme.lightTextTheme.bodyText2.copyWith(fontWeight: FontWeight.w600)),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                          "\$${(subtotal / 100 - _calculateDiscount() + _calculateAppolloFees()).toStringAsFixed(2)}",
                          style: MyTheme.lightTextTheme.bodyText2.copyWith(fontWeight: FontWeight.w600))))
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(key.ticketName + " x $value",
                style: MyTheme.lightTextTheme.bodyText2.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(
                width: 70,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text("\$${(key.price * value / 100).toStringAsFixed(2)}",
                        style: MyTheme.lightTextTheme.bodyText2.copyWith(fontWeight: FontWeight.w600))))
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
              DiscountTextField(
                discountController: _discountController,
                bloc: bloc,
                state: state,
                width: MediaQuery.of(context).size.width,
                linkType: widget.linkType,
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
