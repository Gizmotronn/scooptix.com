import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/ticket_release.dart';
import 'package:webapp/pages/accept_invitation/bloc/ticket_bloc.dart' as ticket;
import 'package:webapp/pages/payment/bloc/payment_bloc.dart';
import 'package:webapp/UI/theme.dart';
import 'package:webapp/repositories/payment_repository.dart';
import 'package:webapp/repositories/user_repository.dart';
import 'package:webapp/utilities/alertGenerator.dart';

class PaymentPage extends StatefulWidget {
  final LinkType linkType;
  final ticket.TicketBloc ticketBloc;

  const PaymentPage(this.linkType, this.ticketBloc, {Key key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentBloc bloc;
  TextEditingController _ccnumberController = TextEditingController();
  TextEditingController _monthController = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  TextEditingController _cvcController = TextEditingController();

  bool _termsConditions = false;
  int selectedQuantity = 1;

  @override
  void initState() {
    bloc = PaymentBloc();
    bloc.add(EventLoadAvailableReleases(widget.linkType.event));
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MyTheme.maxWidth,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(getValueForScreenType(context: context, desktop: 20, tablet: 20, mobile: 8, watch: 8)),
          child: Column(
            children: [
              BlocConsumer<PaymentBloc, PaymentState>(
                listener: (c, state) {
                  if (state is StatePaymentCompleted) {
                    AlertGenerator.showAlert(
                            context: context,
                            title: "Payment successful",
                            content: state.message,
                            buttonText: "Ok",
                            popTwice: false)
                        .then((_) {
                      widget.ticketBloc.add(ticket.EventPaymentSuccessful(widget.linkType, state.release, state.quantity));
                    });
                  }
                },
                cubit: bloc,
                builder: (c, state) {
                  if (state is StatePaymentError) {
                    return Text(state.message);
                  } else if (state is StatePaymentCompleted) {
                    return Text("Payment Successful");
                  } else if (state is StateFinalizePayment) {
                    return Column(
                      children: [
                        Text("Please confirm this payment with your credit card ending in ${state.last4}"),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                            "You are buying ${state.quantity} ticket(s) and will be charged \$${(state.price / 100).toStringAsFixed(2)}"),
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
                                style: MyTheme.mainTT.button,
                              ),
                            ),
                            RaisedButton(
                              onPressed: () {
                                bloc.add(EventChangePaymentMethod());
                              },
                              child: Text(
                                "Change Payment Method",
                                style: MyTheme.mainTT.button,
                              ),
                            ),
                            RaisedButton(
                              onPressed: () {
                                bloc.add(EventConfirmPayment(state.clientSecret, state.paymentMethodId));
                              },
                              child: Text(
                                "Pay",
                                style: MyTheme.mainTT.button,
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  } else if (state is StateAddPaymentMethod) {
                    return SizedBox(
                      width: MyTheme.maxWidth - 16,
                      child: Column(
                        children: [
                          Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Add a Payment Method",
                                style: MyTheme.mainTT.headline6,
                              )),
                          SizedBox(
                            height: 24,
                          ),
                          Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Card Details",
                                style: MyTheme.mainTT.headline6,
                              )),
                          SizedBox(
                            height: 24,
                          ),
                          SizedBox(
                            width: MyTheme.maxWidth,
                            child: TextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(16)
                              ],
                              controller: _ccnumberController,
                              decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Credit Card Number"),
                            ),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          SizedBox(
                            width: MyTheme.maxWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: MyTheme.maxWidth * 0.55 - 28,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: MyTheme.maxWidth * 0.25 - 14,
                                        child: TextFormField(
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            LengthLimitingTextInputFormatter(2)
                                          ],
                                          controller: _monthController,
                                          decoration: InputDecoration(border: OutlineInputBorder(), hintText: "MM"),
                                        ),
                                      ),
                                      SizedBox(
                                        width: MyTheme.maxWidth * 0.05,
                                        child: Center(child: Text("/")),
                                      ),
                                      SizedBox(
                                        width: MyTheme.maxWidth * 0.25 - 14,
                                        child: TextFormField(
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            LengthLimitingTextInputFormatter(2)
                                          ],
                                          controller: _yearController,
                                          decoration: InputDecoration(border: OutlineInputBorder(), hintText: "YY"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: MyTheme.maxWidth * 0.4 - 28,
                                  child: TextFormField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(3)
                                    ],
                                    controller: _cvcController,
                                    decoration: InputDecoration(border: OutlineInputBorder(), hintText: "CVC"),
                                  ),
                                ),
                              ],
                            ),
                          ).paddingBottom(MyTheme.elementSpacing),
                          SizedBox(
                           width: MyTheme.maxWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RaisedButton(
                                  color: MyTheme.appolloGreen,
                                  onPressed: () {
                                    bloc.add(EventCancelPayment());
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: MyTheme.mainTT.button,
                                  ),
                                ),
                                RaisedButton(
                                  color: MyTheme.appolloGreen,
                                  onPressed: () async {
                                    if (_ccnumberController.text.length == 16 &&
                                        _monthController.text.length > 0 &&
                                        _yearController.text.length > 0 &&
                                        _cvcController.text.length == 3) {
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
                                      bloc.add(EventConfirmSetupIntent(pm));
                                    }
                                  },
                                  child: Text(
                                    "Confirm",
                                    style: MyTheme.mainTT.button,
                                  ),
                                ),
                              ],
                            ),
                          )
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
                        Text("Fetching payment methods"),
                        SizedBox(
                          height: 8,
                        ),
                        CircularProgressIndicator(),
                      ],
                    );
                  } else if (state is StateLoadingPaymentIntent) {
                    return Column(
                      children: [
                        Text("Finalizing your payment"),
                        SizedBox(
                          height: 8,
                        ),
                        CircularProgressIndicator(),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Text("Setting up secure payment"),
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
          ),
        ),
      ).appolloCard,
    );
  }

  Widget _buildTicketOverview(StatePaymentOptionAvailable state) {
    print(state);
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
        "Your Order",
        style: MyTheme.mainTT.headline6,
      ).paddingBottom(MyTheme.elementSpacing),
      SizedBox(
          width: MyTheme.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MyTheme.maxWidth - 32,
                child: DropdownButtonFormField(
                  isDense: true,
                  decoration: InputDecoration(hintText: 'Choose your ticket'),
                  items: state.releases
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text("${e.name} - \$${(e.price / 100).toStringAsFixed(2)}"),
                          ))
                      .toList(),
                  value: state.selectedRelease,
                  onChanged: (TicketRelease value) {
                    bloc.add(EventTicketSelected(state.releases, value));
                  },
                ),
              ).paddingBottom(12),
              Divider(
                height: 1.5,
              ).paddingBottom(8),
            ],
          )),
      _buildPaymentWidgets(state),

    ]);
  }

  double _calculateAppolloFees(StatePaymentOptionAvailable state) {
    if (state.selectedRelease.price == 0) {
      return 0.0;
    } else {
      return (((state.selectedRelease.price * selectedQuantity + 300) / 100) * 0.05);
    }
  }

  Widget _buildPaymentWidgets(StatePaymentOptionAvailable state) {
    if (state is StateFreeTicketSelected) {
      return Column(
        children: [
          Text(
            "This ticket is free!",
            style: MyTheme.mainTT.headline6,
          ).paddingBottom(MyTheme.elementSpacing),
          _buildTAndC().paddingBottom(MyTheme.elementSpacing),
          SizedBox(
            width: MyTheme.maxWidth,
            child: RaisedButton(
              color: MyTheme.appolloGreen,
              onPressed: () {
                AlertGenerator.showAlert(
                    context: context,
                    title: "Ticket Issued",
                    content: "We have issued your ticket and sent it to ${UserRepository.instance.currentUser.email}",
                    buttonText: "Ok",
                    popTwice: false)
                    .then((_) {
                  widget.ticketBloc.add(ticket.EventAcceptInvitation(widget.linkType, state.selectedRelease));
                });              },
              child: Text(
                "Proceed to your ticket",
                style: MyTheme.mainTT.button,
              ),
            ),
          ).paddingBottom(MyTheme.elementSpacing),
        ],
      );
    } else if (state is StatePaidTicketSelected) {
      return Column(
        children: [
          _buildPriceBreakdown(state).paddingBottom(MyTheme.elementSpacing),
          _buildTAndC().paddingBottom(MyTheme.elementSpacing),
          Text(
            "Payment Method",
            style: MyTheme.mainTT.headline6,
          ).paddingBottom(MyTheme.elementSpacing),
          SizedBox(
            width: MyTheme.maxWidth,
            child: PaymentRepository.instance.last4 != null
                ? DropdownButtonFormField(
                    value: 1,
                    items: [
                      DropdownMenuItem(
                        child: Text("Use saved card ending in ${PaymentRepository.instance.last4}"),
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
          SizedBox(
            width: MyTheme.maxWidth,
            child: RaisedButton(
              color: MyTheme.appolloGreen,
              onPressed: () {
                if(_termsConditions) {
                  bloc.add(EventRequestPI(state.selectedRelease, 1));
                } else {
                  AlertGenerator.showAlert(context: context, title: "Please accept our T & C", content: "To proceed with your purchase, you have to agree to our terms and conditions", buttonText: "Ok", popTwice: false);
                }
              },
              child: Text(
                "Proceed to payment",
                style: MyTheme.mainTT.button,
              ),
            ),
          ),
        ],
      );
    } else if (state is StatePaidTicketQuantitySelected) {
      return Column(
        children: [
          SizedBox(
            width: MyTheme.maxWidth,
            child: DropdownButtonFormField(
              isDense: true,
              decoration: InputDecoration(hintText: 'Quantity'),
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
          Divider(
            height: 1.5,
          ).paddingBottom(8),
          _buildPriceBreakdown(state).paddingBottom(MyTheme.elementSpacing),
          _buildTAndC().paddingBottom(MyTheme.elementSpacing),
          Text(
            "Payment Method",
            style: MyTheme.mainTT.headline6,
          ).paddingBottom(MyTheme.elementSpacing),
          SizedBox(
            width: MyTheme.maxWidth,
            child: PaymentRepository.instance.last4 != null
                ? DropdownButtonFormField(
                    value: 1,
                    items: [
                      DropdownMenuItem(
                        child: Text("Use saved card ending in ${PaymentRepository.instance.last4}"),
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
          SizedBox(
            width: MyTheme.maxWidth,
            child: RaisedButton(
              color: MyTheme.appolloGreen,
              onPressed: () {
                if(_termsConditions) {
                  bloc.add(EventRequestPI(state.selectedRelease, selectedQuantity));
                } else {
                  AlertGenerator.showAlert(context: context, title: "Please accept our T & C", content: "To proceed with your purchase, you have to agree to our terms and conditions", buttonText: "Ok", popTwice: false);
                }
              },
              child: Text(
                "Proceed to payment",
                style: MyTheme.mainTT.button,
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
          width: MyTheme.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(state.selectedRelease.name),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("\$${(state.selectedRelease.price * selectedQuantity / 100).toStringAsFixed(2)}")))
            ],
          ),
        ).paddingBottom(8),
        SizedBox(
          width: MyTheme.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Booking Fee"),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("\$${_calculateAppolloFees(state).toStringAsFixed(2)}")))
            ],
          ),
        ).paddingBottom(8),
        SizedBox(
          width: MyTheme.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Total"),
              SizedBox(
                  width: 70,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                          "\$${(state.selectedRelease.price * selectedQuantity / 100 + _calculateAppolloFees(state)).toStringAsFixed(2)}")))
            ],
          ),
        ).paddingBottom(8),
      ],
    );
  }

  Widget _buildTAndC() {
    return       SizedBox(
      width: MyTheme.maxWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
              onTap: () async {
                const url = 'https://appollo.io/terms-of-service.html';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: Text("I accept the terms & conditions", style: TextStyle().copyWith(decoration: TextDecoration.underline),)),
          Checkbox(
            value: _termsConditions,
            onChanged: (v) {
              setState(() {
                _termsConditions = v;
              });
            },
          ),
        ],
      ),
    );
  }
}
