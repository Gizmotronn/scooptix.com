import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:ticketapp/UI/widgets/appollo/appolloDivider.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/UI/widgets/textfield/appollo_textfield.dart';
import 'package:ticketapp/main.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/utilities/svg/icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ticketapp/model/discount.dart';
import 'package:ticketapp/pages/payment/bloc/payment_bloc.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/repositories/payment_repository.dart';
import 'package:ticketapp/utilities/alertGenerator.dart';

class PaymentPage extends StatefulWidget {
  final Event event;
  final Map<TicketRelease, int> selectedTickets;
  final Discount discount;
  final double maxHeight;

  const PaymentPage(this.event, {Key key, @required this.selectedTickets, this.discount, @required this.maxHeight})
      : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentBloc bloc;
  TextEditingController _ccnumberController = TextEditingController();
  TextEditingController _monthController = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  TextEditingController _cvcController = TextEditingController();
  FocusNode focusMonth = FocusNode();
  FocusNode focusYear = FocusNode();
  FocusNode focusCVC = FocusNode();

  bool _termsConditions = false;
  bool _saveCreditCard = false;
  bool validateCC = false;
  double subtotal;
  int totalTicketQuantity;
  bool addNewPaymentMethod = false;
  bool cardLoading = false;

  @override
  void initState() {
    bloc = PaymentBloc();
    bloc.add(EventLoadAvailableReleases(widget.selectedTickets, widget.event));
    Future.delayed(Duration(milliseconds: 1)).then((value) {
      if (widget.event.ticketCheckoutMessage != null) {
        AlertGenerator.showAlert(
            context: context,
            title: "Please note",
            content: widget.event.ticketCheckoutMessage,
            buttonText: "I Understand",
            popTwice: false);
      }
    });
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
    Column data = Column(
      children: [
        BlocConsumer<PaymentBloc, PaymentState>(
          cubit: bloc,
          listener: (c, state) {
            if (state is StatePaymentCompleted) {
              AlertGenerator.showAlert(
                      context: WrapperPage.mainScaffold.currentContext,
                      title: "Order successful",
                      content: state.message,
                      buttonText: "Ok",
                      popTwice: true)
                  .then((_) {});
            } else if (state is StateCardUpdated) {
              setState(() {
                addNewPaymentMethod = false;
              });
            }
          },
          builder: (c, state) {
            print(state);
            if (state is StatePaymentError) {
              return Column(
                children: [
                  Text(state.message, style: MyTheme.textTheme.bodyText2).paddingBottom(MyTheme.elementSpacing),
                  SizedBox(
                    height: 34,
                    width: MyTheme.drawerSize,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: MyTheme.appolloGreen,
                      ),
                      onPressed: () {
                        bloc.add(EventCancelPayment());
                      },
                      child: Text("Go back", style: MyTheme.textTheme.bodyText2),
                    ),
                  )
                ],
              );
            } else if (state is StatePaymentCompleted) {
              return Text(
                "Payment Successful",
                style: MyTheme.textTheme.bodyText2,
              );
            } else if (state is StatePaymentOptionAvailable) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPaymentWidgets(state),
                    if (state is! StateFreeTicketSelected) _buildAddPaymentWidget(state),
                    Column(
                      children: [
                        _buildTAndC().paddingBottom(MyTheme.elementSpacing),
                        SizedBox(
                          height: 38,
                          width: MyTheme.drawerSize,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: MyTheme.appolloGreen,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            onPressed: () {
                              if (_termsConditions) {
                                if (state is StateFreeTicketSelected) {
                                  bloc.add(EventRequestFreeTickets(widget.selectedTickets, widget.event));
                                } else {
                                  bloc.add(EventRequestPI(widget.selectedTickets, widget.discount, widget.event));
                                }
                              } else {
                                AlertGenerator.showAlert(
                                    context: WrapperPage.mainScaffold.currentContext,
                                    title: "Please accept our T & C",
                                    content:
                                        "To proceed with your purchase, you have to agree to our terms and conditions",
                                    buttonText: "Ok",
                                    popTwice: false);
                              }
                            },
                            child: Text(
                              "PURCHASE",
                              style: MyTheme.textTheme.button.copyWith(color: MyTheme.appolloBackgroundColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else if (state is StateFreeTicketAlreadyOwned) {
              return Text("You already own a free ticket for this event. Free Tickets are limited to 1 per customer.");
            } else if (state is StateLoadingPaymentMethod) {
              return Column(
                children: [
                  Text("Fetching payment methods", style: MyTheme.textTheme.bodyText2),
                  SizedBox(
                    height: MyTheme.elementSpacing,
                  ),
                  AppolloProgressIndicator(),
                ],
              );
            } else if (state is StateLoadingPaymentIntent) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Finalizing your payment",
                    style: MyTheme.textTheme.bodyText2,
                  ),
                  SizedBox(
                    height: MyTheme.elementSpacing,
                  ),
                  AppolloProgressIndicator(),
                  SizedBox(
                    height: MyTheme.elementSpacing,
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildPriceBreakdown().paddingBottom(MyTheme.elementSpacing),
                  Text(
                    "Setting up secure payment",
                    style: MyTheme.textTheme.bodyText2,
                  ),
                  SizedBox(
                    height: MyTheme.elementSpacing,
                  ),
                  AppolloProgressIndicator(),
                ],
              );
            }
          },
        ),
      ],
    );

    return ResponsiveBuilder(builder: (context, constraints) {
      if (constraints.deviceScreenType == DeviceScreenType.mobile ||
          constraints.deviceScreenType == DeviceScreenType.watch) {
        return data;
      } else {
        return SizedBox(
          width: MyTheme.drawerSize,
          height: widget.maxHeight,
          child: SingleChildScrollView(child: data),
        );
      }
    });
  }

  double _calculateDiscount() {
    if (widget.discount == null) {
      return 0.0;
    }
    if (widget.discount.appliesToReleases.isEmpty) {
      if (widget.discount.type == DiscountType.value) {
        return widget.discount.amount.toDouble() * totalTicketQuantity / 100;
      } else {
        return subtotal * widget.discount.amount / 100 / 100;
      }
    } else {
      double disc = 0.0;
      widget.selectedTickets.forEach((key, value) {
        if (widget.discount.appliesToReleases.contains(key.docId)) {
          if (widget.discount.type == DiscountType.value) {
            disc += widget.discount.amount.toDouble() * value / 100;
          } else {
            disc += (widget.discount.amount / 100 * key.price) * value;
          }
        }
      });
      return disc;
    }
  }

  int _discountAppliesTo() {
    if (widget.discount.appliesToReleases.isEmpty) {
      return totalTicketQuantity;
    } else {
      int counter = 0;
      widget.selectedTickets.forEach((key, value) {
        if (widget.discount.appliesToReleases.contains(key.docId)) {
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

  Widget _buildPaymentWidgets(StatePaymentOptionAvailable state) {
    if (state is StateFreeTicketSelected) {
      return Text(
        "This ticket is free!",
        style: MyTheme.textTheme.headline6,
      ).paddingBottom(MyTheme.elementSpacing);
    } else if (state is StatePaidTickets) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPriceBreakdown().paddingBottom(MyTheme.elementSpacing),
              Text(
                "Select Payment Method",
                style: MyTheme.textTheme.subtitle1.copyWith(color: MyTheme.appolloOrange),
              ).paddingBottom(MyTheme.elementSpacing),
              PaymentRepository.instance.last4 != null
                  ? AppolloCard(
                      color: MyTheme.appolloBackgroundColor,
                      child: SizedBox(
                          width: MyTheme.drawerSize,
                          height: 38,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(AppolloSvgIcon.creditCard, color: MyTheme.appolloWhite, height: 26)
                                      .paddingLeft(8),
                                  Text("Credit Card").paddingLeft(8),
                                ],
                              ),
                              Expanded(
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(PaymentRepository.instance.last4).paddingRight(8)))
                            ],
                          )),
                    ).paddingBottom(MyTheme.elementSpacing)
                  : SizedBox.shrink(),
            ],
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _buildPriceBreakdown() {
    return Column(
      children: [
        Text(
          "Order Confirmation",
          style: MyTheme.textTheme.headline6.copyWith(color: MyTheme.appolloGreen),
        ).paddingBottom(MyTheme.elementSpacing),
        _buildSelectedTickets(),
        AppolloDivider(),
        SizedBox(
          width: MyTheme.drawerSize,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Subtotal", style: MyTheme.textTheme.bodyText2.copyWith(fontWeight: FontWeight.w600)),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("\$${(subtotal / 100 - _calculateDiscount()).toStringAsFixed(2)}",
                          style: MyTheme.textTheme.bodyText2.copyWith(fontWeight: FontWeight.w600))))
            ],
          ),
        ).paddingBottom(MyTheme.elementSpacing),
        if (widget.discount != null && widget.discount.enoughLeft(totalTicketQuantity))
          SizedBox(
            width: MyTheme.drawerSize,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Discount (${widget.discount.type == DiscountType.value ? "\$" + (widget.discount.amount / 100).toStringAsFixed(2) + " x ${_discountAppliesTo()}" : widget.discount.amount.toString() + "%"})",
                  style: MyTheme.textTheme.bodyText2.copyWith(fontWeight: FontWeight.w600),
                ),
                Text("-\$${_calculateDiscount().toStringAsFixed(2)}",
                    style: MyTheme.textTheme.bodyText2.copyWith(fontWeight: FontWeight.w600))
              ],
            ),
          ).paddingBottom(MyTheme.elementSpacing),
        SizedBox(
          width: MyTheme.drawerSize,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Booking Fee",
                style: MyTheme.textTheme.bodyText2.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("\$${_calculateAppolloFees().toStringAsFixed(2)}",
                          style: MyTheme.textTheme.bodyText2.copyWith(fontWeight: FontWeight.w600))))
            ],
          ),
        ).paddingBottom(MyTheme.elementSpacing),
        AppolloDivider(),
        SizedBox(
          width: MyTheme.drawerSize,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: MyTheme.textTheme.bodyText2.copyWith(fontWeight: FontWeight.w600)),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                          "\$${(subtotal / 100 - _calculateDiscount() + _calculateAppolloFees()).toStringAsFixed(2)}",
                          style: MyTheme.textTheme.bodyText2.copyWith(fontWeight: FontWeight.w600))))
            ],
          ),
        ).paddingBottom(8),
      ],
    );
  }

  Widget _buildTAndC() {
    return SizedBox(
      width: MyTheme.drawerSize,
      child: Row(
        children: [
          Checkbox(
            value: _termsConditions,
            onChanged: (v) {
              setState(() {
                _termsConditions = v;
              });
            },
          ).paddingRight(4),
          InkWell(
              onTap: () {
                AlertGenerator.showAlertWithChoice(
                        context: context,
                        title: "View Terms & Conditions",
                        content: "The Terms & Conditions will be shown on a new page, do you want to continue?",
                        buttonText1: "Show T&C",
                        buttonText2: "Cancel")
                    .then((value) async {
                  if (value != null && value) {
                    const url = 'https://appollo.io/terms-of-service.html';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  }
                });
              },
              child: Text(
                "I accept the terms & conditions",
                style: MyTheme.textTheme.bodyText2.copyWith(decoration: TextDecoration.underline),
              )),
        ],
      ),
    );
  }

  Column _buildSelectedTickets() {
    List<Widget> tickets = [];

    widget.selectedTickets.forEach((key, value) {
      tickets.add(SizedBox(
        width: MyTheme.drawerSize,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(key.ticketName + " x $value",
                style: MyTheme.textTheme.bodyText2.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(
                width: 70,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text("\$${(key.price * value / 100).toStringAsFixed(2)}",
                        style: MyTheme.textTheme.bodyText2.copyWith(fontWeight: FontWeight.w600))))
          ],
        ),
      ).paddingBottom(8));
    });

    return Column(
      children: tickets,
    );
  }

  Widget _buildAddPaymentWidget(StatePaymentOptionAvailable state) {
    return InkWell(
      onTap: () {
        setState(() {
          addNewPaymentMethod = true;
        });
      },
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: addNewPaymentMethod
            ? Container(
                width: MyTheme.drawerSize,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 40,
                        ),
                        Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              "Add a Payment Method",
                              style: MyTheme.textTheme.headline6,
                            )),
                        InkWell(
                          onTap: () {
                            setState(() {
                              addNewPaymentMethod = false;
                            });
                          },
                          child: Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                "close",
                                style: MyTheme.textTheme.bodyText1.copyWith(color: MyTheme.appolloRed),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MyTheme.elementSpacing,
                    ),
                    SizedBox(
                      width: MyTheme.drawerSize,
                      child: AppolloTextfield(
                        textfieldType: TextFieldType.regular,
                        labelText: "Credit Card Number",
                        validator: (v) => v.length != 16 ? "Please enter a valid credit card number" : null,
                        autovalidateMode: validateCC ? AutovalidateMode.always : AutovalidateMode.disabled,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
                        controller: _ccnumberController,
                        onChanged: (v) {
                          if (v.length == 16) {
                            focusMonth.requestFocus();
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: MyTheme.elementSpacing * 0.5,
                    ),
                    SizedBox(
                      width: MyTheme.drawerSize,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: AppolloTextfield(
                              textfieldType: TextFieldType.regular,
                              labelText: "MM",
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2)
                              ],
                              onChanged: (v) {
                                if (v.length == 2) {
                                  focusYear.requestFocus();
                                }
                              },
                              controller: _monthController,
                              focusNode: focusMonth,
                              validator: (v) => int.tryParse(v) < 1 || int.tryParse(v) > 12 ? "Invalid month" : null,
                              autovalidateMode: validateCC ? AutovalidateMode.always : AutovalidateMode.disabled,
                            ).paddingRight(MyTheme.elementSpacing),
                          ),
                          Expanded(
                            child: AppolloTextfield(
                              textfieldType: TextFieldType.regular,
                              labelText: "YY",
                              onChanged: (v) {
                                if (v.length == 2) {
                                  focusCVC.requestFocus();
                                }
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2)
                              ],
                              controller: _yearController,
                              focusNode: focusYear,
                              autovalidateMode: validateCC ? AutovalidateMode.always : AutovalidateMode.disabled,
                              validator: (v) => int.tryParse(v) < 20 || int.tryParse(v) > 99 ? "Invalid year" : null,
                            ).paddingRight(MyTheme.elementSpacing),
                          ),
                          Expanded(
                            child: AppolloTextfield(
                              textfieldType: TextFieldType.regular,
                              labelText: "CVC",
                              focusNode: focusCVC,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4)
                              ],
                              controller: _cvcController,
                              validator: (v) => v.length < 3 || v.length > 4 ? "Please enter a valid CVC number" : null,
                              autovalidateMode: validateCC ? AutovalidateMode.always : AutovalidateMode.disabled,
                            ),
                          ),
                        ],
                      ),
                    ).paddingBottom(MyTheme.elementSpacing),
                    SizedBox(
                      width: MyTheme.drawerSize,
                      child: Row(
                        children: [
                          Checkbox(
                            value: _saveCreditCard,
                            onChanged: (v) {
                              setState(() {
                                _saveCreditCard = v;
                              });
                            },
                          ),
                          Text(
                            "Save my credit card details",
                            style: MyTheme.textTheme.bodyText2,
                          ),
                        ],
                      ),
                    ).paddingBottom(MyTheme.elementSpacing),
                    ResponsiveBuilder(builder: (context, constraints) {
                      if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                          constraints.deviceScreenType == DeviceScreenType.watch) {
                        return SizedBox(
                          width: MyTheme.drawerSize,
                          child: Column(
                            children: [
                              SizedBox(
                                width: MyTheme.drawerSize,
                                height: 38,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: MyTheme.appolloGreen,
                                  ),
                                  onPressed: () async {
                                    try {
                                      setState(() {
                                        cardLoading = true;
                                      });
                                      StripeCard card = StripeCard(
                                          number: _ccnumberController.text,
                                          cvc: _cvcController.text,
                                          last4: _ccnumberController.text.substring(12),
                                          expMonth: int.tryParse(_monthController.text),
                                          expYear: int.tryParse(_yearController.text));
                                      Map<String, dynamic> data =
                                          await Stripe.instance.api.createPaymentMethodFromCard(card);
                                      PaymentMethod pm =
                                          PaymentMethod(data["id"], data["card"]["last4"], data["card"]["brand"]);
                                      bloc.add(EventConfirmSetupIntent(pm, _saveCreditCard, widget.event));
                                    } catch (_) {
                                      setState(() {
                                        validateCC = true;
                                      });
                                    } finally {
                                      setState(() {
                                        cardLoading = false;
                                      });
                                    }
                                  },
                                  child: state is StateLoadingPaymentMethod || cardLoading
                                      ? AppolloButtonProgressIndicator()
                                      : Text(
                                          "Add Card",
                                          style: MyTheme.textTheme.button,
                                        ),
                                ),
                              ).paddingBottom(8),
                            ],
                          ),
                        );
                      } else {
                        return SizedBox(
                          width: MyTheme.drawerSize,
                          height: 38,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: MyTheme.appolloGreen,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            onPressed: () async {
                              try {
                                StripeCard card = StripeCard(
                                    number: _ccnumberController.text,
                                    cvc: _cvcController.text,
                                    last4: _ccnumberController.text.substring(12),
                                    expMonth: int.tryParse(_monthController.text),
                                    expYear: int.tryParse(_yearController.text));
                                Map<String, dynamic> data = await Stripe.instance.api.createPaymentMethodFromCard(card);
                                PaymentMethod pm =
                                    PaymentMethod(data["id"], data["card"]["last4"], data["card"]["brand"]);
                                print(pm.id);
                                bloc.add(EventConfirmSetupIntent(pm, _saveCreditCard, widget.event));
                              } catch (_) {
                                setState(() {
                                  validateCC = true;
                                });
                              }
                            },
                            child: Text(
                              "Add Card",
                              style: MyTheme.textTheme.button.copyWith(color: MyTheme.appolloBackgroundColor),
                            ),
                          ),
                        );
                      }
                    }),
                  ],
                ).paddingAll(MyTheme.elementSpacing),
              ).appolloCard(color: MyTheme.appolloBackgroundColor).paddingBottom(MyTheme.elementSpacing)
            : Container(
                    child: Center(
                        child: Text(
                "Add a Payment Method",
                style: MyTheme.textTheme.subtitle1.copyWith(color: MyTheme.appolloGreen),
              ).paddingAll(8)))
                .appolloCard(color: MyTheme.appolloBackgroundColorLight.withAlpha(120)),
      ),
    ).paddingBottom(MyTheme.elementSpacing);
  }
}
