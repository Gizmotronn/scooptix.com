import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webapp/model/discount.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/release_manager.dart';
import 'package:webapp/pages/ticket/bloc/ticket_bloc.dart' as ticket;
import 'package:webapp/pages/payment/bloc/payment_bloc.dart';
import 'package:webapp/UI/theme.dart';
import 'package:webapp/repositories/payment_repository.dart';
import 'package:webapp/repositories/user_repository.dart';
import 'package:webapp/utilities/alertGenerator.dart';
import 'package:websafe_svg/websafe_svg.dart';

class PaymentPage extends StatefulWidget {
  final LinkType linkType;
  final ticket.TicketBloc ticketBloc;
  final TextTheme textTheme;
  final double maxWidth;

  const PaymentPage(this.linkType, this.ticketBloc, {Key key, @required this.textTheme, @required this.maxWidth})
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
  TextEditingController _discountController = TextEditingController();
  FocusNode focusMonth = FocusNode();
  FocusNode focusYear = FocusNode();
  FocusNode focusCVC = FocusNode();

  bool _termsConditions = false;
  bool _saveCreditCard = false;
  int selectedQuantity = 1;
  ReleaseManager selectedManager;
  Discount discount;
  bool validateCC = false;

  @override
  void initState() {
    bloc = PaymentBloc();
    bloc.add(EventLoadAvailableReleases(widget.linkType.event));
    Future.delayed(Duration(milliseconds: 1)).then((value) {
      if (widget.linkType.event.ticketCheckoutMessage != null) {
        AlertGenerator.showAlert(
            context: context,
            title: "Please note",
            content: widget.linkType.event.ticketCheckoutMessage,
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
    Column data = Column(
      children: [
        BlocConsumer<PaymentBloc, PaymentState>(
          cubit: bloc,
          listener: (c, state) {
            if (state is StatePaymentCompleted) {
              AlertGenerator.showAlert(
                      context: context,
                      title: "Payment successful",
                      content: state.message,
                      buttonText: "Ok",
                      popTwice: false)
                  .then((_) {
                widget.ticketBloc.add(ticket.EventPaymentSuccessful(
                    widget.linkType, selectedManager.getActiveRelease(), selectedQuantity, discount));
              });
            } else if (state is StateDiscountCodeInvalid) {
              AlertGenerator.showAlert(
                  context: context,
                  title: "Invalid code",
                  content: "Sorry, this code does not exist",
                  buttonText: "Ok",
                  popTwice: false);
            } else if (state is StatePaymentOptionAvailable) {
              if (state.discount != null) {
                discount = state.discount;
              }
              if (selectedManager == null) {
                selectedManager = state.managers[0];
              }
            }
          },
          buildWhen: (c, state) {
            if (state is StateDiscountCodeLoading || state is StateDiscountCodeInvalid) {
              return false;
            } else {
              return true;
            }
          },
          builder: (c, state) {
            if (state is StatePaymentError) {
              return Column(
                children: [
                  Text(state.message, style: widget.textTheme.bodyText2).paddingBottom(MyTheme.elementSpacing),
                  SizedBox(
                    height: 34,
                    width: widget.maxWidth,
                    child: RaisedButton(
                      color: MyTheme.appolloGreen,
                      onPressed: () {
                        bloc.add(EventCancelPayment());
                      },
                      child: Text("Go back", style: widget.textTheme.bodyText2),
                    ),
                  )
                ],
              );
            } else if (state is StatePaymentCompleted) {
              return Text(
                "Payment Successful",
                style: widget.textTheme.bodyText2,
              );
            } else if (state is StateFinalizePayment) {
              return Column(
                children: [
                  Text("Please confirm this payment with your credit card ending in ${state.last4}",
                      style: widget.textTheme.bodyText2),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "You are buying ${selectedQuantity} ticket(s) and will be charged \$${(state.price / 100).toStringAsFixed(2)}",
                    style: widget.textTheme.bodyText2,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RaisedButton(
                        onPressed: () {
                          bloc.add(EventCancelPayment());
                        },
                        child: Text(
                          "Cancel",
                          style: widget.textTheme.button,
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          bloc.add(EventChangePaymentMethod());
                        },
                        child: Text(
                          "Change Payment Method",
                          style: widget.textTheme.button,
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          bloc.add(EventConfirmPayment(state.clientSecret, state.paymentMethodId));
                        },
                        child: Text(
                          "Pay",
                          style: widget.textTheme.button,
                        ),
                      ),
                    ],
                  )
                ],
              );
            } else if (state is StateAddPaymentMethod) {
              return SizedBox(
                width: widget.maxWidth,
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Add a Payment Method",
                          style: widget.textTheme.headline6,
                        )),
                    SizedBox(
                      height: MyTheme.elementSpacing,
                    ),
                    SizedBox(
                      width: widget.maxWidth,
                      child: TextFormField(
                        validator: (v) => v.length != 16 ? "Please enter a valid credit card number" : null,
                        autovalidateMode: validateCC ? AutovalidateMode.always : AutovalidateMode.disabled,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
                        controller: _ccnumberController,
                        onChanged: (v) {
                          if (v.length == 16) {
                            focusMonth.requestFocus();
                          }
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            prefixIcon: WebsafeSvg.asset("icons/credit_card.svg", width: 20),
                            hintText: "Credit Card Number"),
                      ),
                    ),
                    SizedBox(
                      height: MyTheme.elementSpacing * 0.5,
                    ),
                    SizedBox(
                      width: widget.maxWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: getValueForScreenType(
                                context: context,
                                desktop: widget.maxWidth * 0.5 - 28,
                                tablet: widget.maxWidth * 0.5 - 28,
                                mobile: widget.maxWidth * 0.6 - 16,
                                watch: widget.maxWidth * 0.6 - 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: getValueForScreenType(
                                      context: context,
                                      desktop: widget.maxWidth * 0.25 - 18,
                                      tablet: widget.maxWidth * 0.25 - 18,
                                      mobile: widget.maxWidth * 0.3 - 12,
                                      watch: widget.maxWidth * 0.3 - 12),
                                  child: TextFormField(
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
                                    validator: (v) =>
                                        int.tryParse(v) < 1 || int.tryParse(v) > 12 ? "Invalid month" : null,
                                    autovalidateMode: validateCC ? AutovalidateMode.always : AutovalidateMode.disabled,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        hintText: "MM",
                                        suffixIcon: WebsafeSvg.asset("icons/calendar.svg", width: 20)),
                                  ),
                                ).paddingRight(8),
                                SizedBox(
                                  width: getValueForScreenType(
                                      context: context,
                                      desktop: widget.maxWidth * 0.25 - 18,
                                      tablet: widget.maxWidth * 0.25 - 18,
                                      mobile: widget.maxWidth * 0.3 - 12,
                                      watch: widget.maxWidth * 0.3 - 12),
                                  child: TextFormField(
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
                                    validator: (v) =>
                                        int.tryParse(v) < 20 || int.tryParse(v) > 99 ? "Invalid year" : null,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        hintText: "YY",
                                        suffixIcon: WebsafeSvg.asset("icons/calendar.svg", width: 20)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: getValueForScreenType(
                                context: context,
                                desktop: widget.maxWidth * 0.45 - 28,
                                tablet: widget.maxWidth * 0.45 - 28,
                                mobile: widget.maxWidth * 0.35 - 16,
                                watch: widget.maxWidth * 0.35 - 16),
                            child: TextFormField(
                              focusNode: focusCVC,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4)
                              ],
                              controller: _cvcController,
                              validator: (v) => v.length < 3 || v.length > 4 ? "Please enter a valid CVC number" : null,
                              autovalidateMode: validateCC ? AutovalidateMode.always : AutovalidateMode.disabled,
                              decoration: InputDecoration(border: OutlineInputBorder(), isDense: true, hintText: "CVC"),
                            ),
                          ),
                        ],
                      ),
                    ).paddingBottom(MyTheme.elementSpacing),
                    SizedBox(
                      width: widget.maxWidth,
                      child: Row(
                        children: [
                          Checkbox(
                            value: _saveCreditCard,
                            onChanged: (v) {
                              setState(() {
                                _saveCreditCard = v;
                              });
                            },
                          ).paddingRight(8).paddingLeft(4),
                          Text(
                            "Save my credit card details",
                            style: widget.textTheme.bodyText2,
                          ),
                        ],
                      ),
                    ).paddingBottom(MyTheme.elementSpacing),
                    ResponsiveBuilder(builder: (context, constraints) {
                      if (constraints.deviceScreenType == DeviceScreenType.mobile ||
                          constraints.deviceScreenType == DeviceScreenType.watch) {
                        return SizedBox(
                          width: widget.maxWidth,
                          child: Column(
                            children: [
                              SizedBox(
                                width: widget.maxWidth,
                                height: 38,
                                child: RaisedButton(
                                  color: MyTheme.appolloGreen,
                                  onPressed: () async {
                                    try {
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
                                      bloc.add(EventConfirmSetupIntent(pm, _saveCreditCard));
                                    } catch (_) {
                                      setState(() {
                                        validateCC = true;
                                      });
                                    }
                                  },
                                  child: Text(
                                    "Use Credit Card",
                                    style: widget.textTheme.button,
                                  ),
                                ),
                              ).paddingBottom(8),
                              SizedBox(
                                height: 38,
                                width: widget.maxWidth,
                                child: OutlineButton(
                                  borderSide: BorderSide(color: MyTheme.appolloGreen, width: 1.1),
                                  color: MyTheme.appolloGreen,
                                  onPressed: () {
                                    bloc.add(EventCancelPayment());
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: widget.textTheme.button,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return SizedBox(
                          width: widget.maxWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 38,
                                width: widget.maxWidth * 0.3,
                                child: RaisedButton(
                                  color: MyTheme.appolloGreen,
                                  onPressed: () {
                                    bloc.add(EventCancelPayment());
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: widget.textTheme.button,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: widget.maxWidth * 0.35,
                                height: 38,
                                child: RaisedButton(
                                  color: MyTheme.appolloGreen,
                                  onPressed: () async {
                                    try {
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
                                      print(pm.id);
                                      bloc.add(EventConfirmSetupIntent(pm, _saveCreditCard));
                                    } catch (_) {
                                      setState(() {
                                        validateCC = true;
                                      });
                                    }
                                  },
                                  child: Text(
                                    "Use Credit Card",
                                    style: widget.textTheme.button,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }),
                  ],
                ),
              );
            } else if (state is StatePaymentOptionAvailable) {
              return _buildTicketOverview(state);
            } else if (state is StateNoTicketsAvailable) {
              return Text("Sorry, there are no more tickets available");
            } else if (state is StateLoadingPaymentMethod) {
              return Column(
                children: [
                  Text("Fetching payment methods", style: widget.textTheme.bodyText2),
                  SizedBox(
                    height: 8,
                  ),
                  CircularProgressIndicator(),
                ],
              );
            } else if (state is StateLoadingPaymentIntent) {
              return Column(
                children: [
                  Text(
                    "Finalizing your payment",
                    style: widget.textTheme.bodyText2,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  CircularProgressIndicator(),
                ],
              );
            } else {
              return Column(
                children: [
                  Text(
                    "Setting up secure payment",
                    style: widget.textTheme.bodyText2,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  CircularProgressIndicator(),
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
        return SizedBox(
          width: widget.maxWidth - 8,
          child: Container(
            child: Padding(
              padding:
                  EdgeInsets.all(getValueForScreenType(context: context, desktop: 20, tablet: 20, mobile: 8, watch: 8)),
              child: data,
            ),
          ).appolloCard,
        );
      } else {
        return SizedBox(
          width: widget.maxWidth,
          child: data,
        );
      }
    });
  }

  Widget _buildTicketOverview(StatePaymentOptionAvailable state) {
    print(state);
    return Column(
        crossAxisAlignment: getValueForScreenType(
            context: context,
            watch: CrossAxisAlignment.center,
            mobile: CrossAxisAlignment.center,
            tablet: CrossAxisAlignment.start,
            desktop: CrossAxisAlignment.start),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Select Your Ticket Type",
            style: widget.textTheme.headline6,
          ).paddingBottom(MyTheme.elementSpacing),
          LayoutBuilder(builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: constraints.maxWidth,
                  height: 50,
                  child: DropdownButtonFormField(
                    isDense: true,
                    itemHeight: 50,
                    iconEnabledColor: getValueForScreenType(
                        context: context,
                        watch: MyTheme.appolloWhite,
                        mobile: MyTheme.appolloWhite,
                        tablet: MyTheme.appolloBlack,
                        desktop: MyTheme.appolloBlack),
                    decoration: InputDecoration(
                      hintText: 'Choose your ticket',
                      isDense: true,
                    ),
                    items: state.managers
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text("${e.name} - \$${(e.getActiveRelease().price / 100).toStringAsFixed(2)}"),
                            ))
                        .toList(),
                    value: selectedManager,
                    onChanged: (ReleaseManager value) {
                      setState(() {
                        selectedManager = value;
                      });
                      bloc.add(EventTicketSelected(state.managers, value.getActiveRelease()));
                    },
                  ),
                ).paddingBottom(12),
                Divider(
                  color: getValueForScreenType(
                      context: context,
                      watch: MyTheme.appolloWhite,
                      mobile: MyTheme.appolloWhite,
                      tablet: MyTheme.appolloGrey,
                      desktop: MyTheme.appolloGrey),
                  height: 1.5,
                ).paddingBottom(8),
              ],
            );
          }),
          _buildPaymentWidgets(state),
        ]);
  }

  double _calculateDiscount(StatePaymentOptionAvailable state) {
    if (discount == null) {
      return 0.0;
    } else if (discount.type == DiscountType.value) {
      return discount.amount.toDouble() * selectedQuantity / 100;
    } else {
      return (selectedManager.getActiveRelease().price.toDouble() * selectedQuantity) * discount.amount / 100 / 100;
    }
  }

  double _calculateAppolloFees(StatePaymentOptionAvailable state) {
    if (selectedManager.getActiveRelease().price == 0) {
      return 0.0;
    } else {
      double fee = (((selectedManager.getActiveRelease().price * selectedQuantity) / 100) *
          widget.linkType.event.feePercent /
          100);
      if (fee < 1.0) {
        fee = 1.0;
      }
      return fee;
    }
  }

  Widget _buildPaymentWidgets(StatePaymentOptionAvailable state) {
    if (state is StateFreeTicketSelected) {
      return Column(
        crossAxisAlignment: getValueForScreenType(
            context: context,
            watch: CrossAxisAlignment.center,
            mobile: CrossAxisAlignment.center,
            tablet: CrossAxisAlignment.start,
            desktop: CrossAxisAlignment.start),
        children: [
          Text(
            "This ticket is free!",
            style: widget.textTheme.headline6,
          ).paddingBottom(MyTheme.elementSpacing),
          _buildTAndC().paddingBottom(MyTheme.elementSpacing).paddingTop(8),
          SizedBox(
            width: widget.maxWidth,
            height: 34,
            child: RaisedButton(
              color: MyTheme.appolloGreen,
              onPressed: () {
                if (!_termsConditions) {
                  AlertGenerator.showAlert(
                      context: context,
                      title: "Please accept our T & C",
                      content: "To proceed with your purchase, you have to agree to our terms and conditions",
                      buttonText: "Ok",
                      popTwice: false);
                } else {
                  AlertGenerator.showAlert(
                          context: context,
                          title: "Ticket Sent",
                          content:
                              "We have issued your ticket and sent it to ${UserRepository.instance.currentUser.email}",
                          buttonText: "Ok",
                          popTwice: false)
                      .then((_) {
                    widget.ticketBloc
                        .add(ticket.EventAcceptInvitation(widget.linkType, selectedManager.getActiveRelease()));
                  });
                }
              },
              child: Text(
                "Proceed to your ticket",
                style: widget.textTheme.button,
              ),
            ),
          ).paddingBottom(MyTheme.elementSpacing),
        ],
      );
    } else if (state is StatePaidTicketSelected) {
      return Column(
        crossAxisAlignment: getValueForScreenType(
            context: context,
            watch: CrossAxisAlignment.center,
            mobile: CrossAxisAlignment.center,
            tablet: CrossAxisAlignment.start,
            desktop: CrossAxisAlignment.start),
        children: [
          Divider(
            color: getValueForScreenType(
                context: context,
                watch: MyTheme.appolloWhite,
                mobile: MyTheme.appolloWhite,
                tablet: MyTheme.appolloGrey,
                desktop: MyTheme.appolloGrey),
            height: 1.5,
          ).paddingBottom(8),
          _buildPriceBreakdown(state).paddingBottom(MyTheme.elementSpacing),
          Text(
            "Payment Method",
            style: widget.textTheme.headline6,
          ).paddingBottom(MyTheme.elementSpacing),
          SizedBox(
            width: widget.maxWidth,
            height: 50,
            child: PaymentRepository.instance.last4 != null
                ? DropdownButtonFormField(
                    iconEnabledColor: getValueForScreenType(
                        context: context,
                        watch: MyTheme.appolloWhite,
                        mobile: MyTheme.appolloWhite,
                        tablet: MyTheme.appolloBlack,
                        desktop: MyTheme.appolloBlack),
                    decoration: InputDecoration(isDense: true),
                    value: 1,
                    itemHeight: 50,
                    isDense: true,
                    items: [
                      DropdownMenuItem(
                        child: Text("Use your card ending in ${PaymentRepository.instance.last4}"),
                        value: 1,
                      ),
                      DropdownMenuItem(
                        child: Text("Add Payment Method"),
                        value: 0,
                      ),
                    ],
                    onChanged: (value) {
                      if (value == 0) {
                        _saveCreditCard = false;
                        bloc.add(EventAddPaymentMethod());
                      } else {
                        _saveCreditCard = true;
                      }
                    },
                  )
                : DropdownButtonFormField(
                    iconEnabledColor: getValueForScreenType(
                        context: context,
                        watch: MyTheme.appolloWhite,
                        mobile: MyTheme.appolloWhite,
                        tablet: MyTheme.appolloBlack,
                        desktop: MyTheme.appolloBlack),
                    isDense: true,
                    itemHeight: 50,
                    decoration: InputDecoration(isDense: true),
                    items: [
                      DropdownMenuItem(
                        child: Text("Add Payment Method"),
                        value: 0,
                      ),
                    ],
                    onChanged: (value) {
                      if (value == 0) {
                        bloc.add(EventAddPaymentMethod());
                      }
                    },
                  ),
          ).paddingBottom(MyTheme.elementSpacing),
          Text(
            "Booking Fee",
            style: widget.textTheme.headline6,
          ).paddingBottom(MyTheme.elementSpacing * 0.5),
          Text(
            "The Booking Fee is non refundable",
            style: widget.textTheme.bodyText2,
          ).paddingBottom(MyTheme.elementSpacing),
          Text(
            "Refund Policy",
            style: widget.textTheme.headline6,
          ).paddingBottom(MyTheme.elementSpacing * 0.5),
          Text(
            "Please contact the event organiser for refund enquiries",
            style: widget.textTheme.bodyText2,
            textAlign: TextAlign.center,
          ).paddingBottom(MyTheme.elementSpacing),
          _buildTAndC().paddingBottom(MyTheme.elementSpacing),
          SizedBox(
            width: widget.maxWidth,
            height: 38,
            child: RaisedButton(
              color: MyTheme.appolloGreen,
              onPressed: () {
                if (!_termsConditions) {
                  AlertGenerator.showAlert(
                      context: context,
                      title: "Please accept our T & C",
                      content: "To proceed with your purchase, you have to agree to our terms and conditions",
                      buttonText: "Ok",
                      popTwice: false);
                } else if (PaymentRepository.instance.last4 == null) {
                  AlertGenerator.showAlert(
                      context: context,
                      title: "Missing payment method",
                      content: "Please provide a valid payment method",
                      buttonText: "Ok",
                      popTwice: false);
                } else {
                  AlertGenerator.showAlertWithChoice(
                          context: context,
                          title: "Confirm Payment",
                          content:
                              "Please confirm your payment with your credit card ending in ${PaymentRepository.instance.last4}",
                          buttonText1: "Confirm",
                          buttonText2: "Cancel")
                      .then((value) {
                    if (value != null && value) {
                      bloc.add(EventRequestPI(selectedManager.getActiveRelease(), 1, discount));
                    }
                  });
                }
              },
              child: Text(
                "Proceed to payment",
                style: widget.textTheme.button,
              ),
            ),
          ),
        ],
      );
    } else if (state is StatePaidTicketQuantitySelected) {
      return Column(
        crossAxisAlignment: getValueForScreenType(
            context: context,
            watch: CrossAxisAlignment.center,
            mobile: CrossAxisAlignment.center,
            tablet: CrossAxisAlignment.start,
            desktop: CrossAxisAlignment.start),
        children: [
          SizedBox(
            width: widget.maxWidth,
            height: 50,
            child: DropdownButtonFormField(
              iconEnabledColor: getValueForScreenType(
                  context: context,
                  watch: MyTheme.appolloWhite,
                  mobile: MyTheme.appolloWhite,
                  tablet: MyTheme.appolloBlack,
                  desktop: MyTheme.appolloBlack),
              isDense: true,
              itemHeight: 50,
              decoration: InputDecoration(hintText: 'Quantity', isDense: true),
              items: [1, 2, 3, 4, 5, 6, 7, 8, 9]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text("${e.toString()} tickets"),
                      ))
                  .toList(),
              value: selectedQuantity,
              onChanged: (int value) {
                setState(() {
                  selectedQuantity = value;
                });
              },
            ),
          ).paddingBottom(12),
          BlocConsumer<PaymentBloc, PaymentState>(
              cubit: bloc,
              listener: (c, state) {},
              buildWhen: (c, state) {
                if (state is StateDiscountCodeInvalid) {
                  return false;
                }
                return true;
              },
              builder: (context, state) {
                if (state is StatePaymentOptionAvailable || state is StateDiscountCodeLoading) {
                  return SizedBox(
                    height: 50,
                    width: widget.maxWidth,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Flexible(
                          flex: 3,
                          child: SizedBox(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(), hintText: "Discount Code", isDense: true),
                              controller: _discountController,
                            ),
                          ).paddingRight(8),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: FlatButton(
                              color: MyTheme.appolloGreen,
                              onPressed: () {
                                if (state is StatePaymentOptionAvailable && _discountController.text != "") {
                                  bloc.add(
                                      EventApplyDiscount(_discountController.text, selectedManager.getActiveRelease()));
                                }
                              },
                              child: state is StateDiscountCodeLoading
                                  ? CircularProgressIndicator()
                                  : Text(
                                      "Apply",
                                      style: widget.textTheme.button,
                                    ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ).paddingBottom(8);
                } else {
                  return SizedBox.shrink();
                }
              }),
          Divider(
            color: getValueForScreenType(
                context: context,
                watch: MyTheme.appolloWhite,
                mobile: MyTheme.appolloWhite,
                tablet: MyTheme.appolloGrey,
                desktop: MyTheme.appolloGrey),
            height: 1.5,
          ).paddingBottom(8),
          _buildPriceBreakdown(state).paddingBottom(MyTheme.elementSpacing),
          Text(
            "Payment Method",
            style: widget.textTheme.headline6,
          ).paddingBottom(MyTheme.elementSpacing),
          SizedBox(
            width: widget.maxWidth,
            height: 50,
            child: PaymentRepository.instance.last4 != null
                ? DropdownButtonFormField(
                    iconEnabledColor: getValueForScreenType(
                        context: context,
                        watch: MyTheme.appolloWhite,
                        mobile: MyTheme.appolloWhite,
                        tablet: MyTheme.appolloBlack,
                        desktop: MyTheme.appolloBlack),
                    decoration: InputDecoration(isDense: true),
                    isDense: true,
                    itemHeight: 50,
                    value: 1,
                    items: [
                      DropdownMenuItem(
                        child: Text("Use your card ending in ${PaymentRepository.instance.last4}"),
                        value: 1,
                      ),
                      DropdownMenuItem(
                        child: Text("Add Payment Method"),
                        value: 0,
                      ),
                    ],
                    onChanged: (value) {
                      if (value == 0) {
                        bloc.add(EventAddPaymentMethod());
                      }
                    },
                  )
                : DropdownButtonFormField(
                    iconEnabledColor: getValueForScreenType(
                        context: context,
                        watch: MyTheme.appolloWhite,
                        mobile: MyTheme.appolloWhite,
                        tablet: MyTheme.appolloBlack,
                        desktop: MyTheme.appolloBlack),
                    decoration: InputDecoration(isDense: true),
                    isDense: true,
                    itemHeight: 50,
                    items: [
                      DropdownMenuItem(
                        child: Text("Add Payment Method"),
                        value: 0,
                      ),
                    ],
                    onChanged: (value) {
                      if (value == 0) {
                        bloc.add(EventAddPaymentMethod());
                      }
                    },
                  ),
          ).paddingBottom(MyTheme.elementSpacing),
          Text(
            "Booking Fee",
            style: widget.textTheme.headline6,
          ).paddingBottom(MyTheme.elementSpacing * 0.5),
          Text(
            "The Booking Fee is non refundable",
            style: widget.textTheme.bodyText2,
          ).paddingBottom(MyTheme.elementSpacing),
          Text(
            "Refund Policy",
            style: widget.textTheme.headline6,
            textAlign: TextAlign.center,
          ).paddingBottom(MyTheme.elementSpacing * 0.5),
          Text(
            "Please contact the event organiser for refund enquiries",
            style: widget.textTheme.bodyText2,
            textAlign: TextAlign.center,
          ).paddingBottom(MyTheme.elementSpacing),
          _buildTAndC().paddingBottom(MyTheme.elementSpacing),
          SizedBox(
            height: 38,
            width: widget.maxWidth,
            child: RaisedButton(
              color: MyTheme.appolloGreen,
              onPressed: () {
                if (_termsConditions) {
                  AlertGenerator.showAlertWithChoice(
                          context: context,
                          title: "Confirm Payment",
                          content:
                              "Please confirm your payment with your credit card ending in ${PaymentRepository.instance.last4}",
                          buttonText1: "Confirm",
                          buttonText2: "Cancel")
                      .then((value) {
                    if (value != null && value) {
                      bloc.add(EventRequestPI(selectedManager.getActiveRelease(), selectedQuantity, discount));
                    }
                  });
                } else {
                  AlertGenerator.showAlert(
                      context: context,
                      title: "Please accept our T & C",
                      content: "To proceed with your purchase, you have to agree to our terms and conditions",
                      buttonText: "Ok",
                      popTwice: false);
                }
              },
              child: Text(
                "Proceed to payment",
                style: widget.textTheme.button,
              ),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _buildPriceBreakdown(StatePaymentOptionAvailable state) {
    return Column(
      children: [
        SizedBox(
          width: widget.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(selectedManager.name, style: widget.textTheme.bodyText2),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                          "\$${(selectedManager.getActiveRelease().price * selectedQuantity / 100).toStringAsFixed(2)}",
                          style: widget.textTheme.bodyText2)))
            ],
          ),
        ).paddingBottom(8),
        if (discount != null && discount.enoughLeft(selectedQuantity))
          SizedBox(
            width: widget.maxWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Discount (${discount.type == DiscountType.value ? "\$" + (discount.amount / 100).toStringAsFixed(2) + " x $selectedQuantity" : discount.amount.toString() + "%"})",
                  style: widget.textTheme.bodyText2,
                ),
                SizedBox(
                    width: 70,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Text("-\$${_calculateDiscount(state).toStringAsFixed(2)}",
                            style: widget.textTheme.bodyText2)))
              ],
            ),
          ).paddingBottom(8),
        SizedBox(
          width: widget.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Booking Fee",
                style: widget.textTheme.bodyText2,
              ),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("\$${_calculateAppolloFees(state).toStringAsFixed(2)}",
                          style: widget.textTheme.bodyText2)))
            ],
          ),
        ).paddingBottom(8),
        SizedBox(
          width: widget.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Total", style: widget.textTheme.bodyText2),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                          "\$${(selectedManager.getActiveRelease().price * selectedQuantity / 100 - _calculateDiscount(state) + _calculateAppolloFees(state)).toStringAsFixed(2)}",
                          style: widget.textTheme.bodyText2)))
            ],
          ),
        ).paddingBottom(8),
      ],
    );
  }

  Widget _buildTAndC() {
    return SizedBox(
      width: widget.maxWidth,
      child: Row(
        children: [
          Checkbox(
            value: _termsConditions,
            onChanged: (v) {
              setState(() {
                _termsConditions = v;
              });
            },
          ).paddingRight(8).paddingLeft(4),
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
                style: widget.textTheme.bodyText2.copyWith(decoration: TextDecoration.underline),
              )),
        ],
      ),
    );
  }
}
