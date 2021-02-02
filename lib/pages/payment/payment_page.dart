import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:webapp/model/event.dart';
import 'package:webapp/model/ticket_release.dart';
import 'package:webapp/pages/payment/bloc/payment_bloc.dart';
import 'package:webapp/UI/theme.dart';
import 'package:webapp/repositories/payment_repository.dart';

class PaymentPage extends StatefulWidget {
  final Event event;

  const PaymentPage(this.event, {Key key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentBloc bloc;
  TicketRelease selectedRelease;
  TextEditingController _ccnumberController = TextEditingController();
  TextEditingController _monthController = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  TextEditingController _cvcController = TextEditingController();

  bool _termsConditions = false;

  @override
  void initState() {
    bloc = PaymentBloc();
    bloc.add(EventLoadAvailableReleases(widget.event));
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              BlocBuilder<PaymentBloc, PaymentState>(
                cubit: bloc,
                builder: (c, state) {
                  if (state is StatePaymentError) {
                    return Text(state.message);
                  } else if(state is PaymentCompletedState){
                    return Text("Done");
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
                      width: MyTheme.maxWidth - 40,
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
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: RaisedButton(
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
                            ),
                          )
                        ],
                      ),
                    );
                  } else if (state is StatePaymentRequired) {
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
                        Text("Fetching payment info"),
                        SizedBox(
                          height: 8,
                        ),
                        CircularProgressIndicator(),
                      ],
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
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

  Widget _buildTicketOverview(StatePaymentRequired state) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
        "Your Order",
        style: MyTheme.mainTT.headline6,
      ).paddingBottom(20),
      SizedBox(
        width: MyTheme.maxWidth,
        child: DropdownButtonFormField(
          isDense: true,
          decoration: InputDecoration(hintText: 'Choose your ticket'),
          items: state.releases
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text("${e.name} - \$${(e.price / 100).toStringAsFixed(2)}"),
                  ))
              .toList(),
          value: selectedRelease,
          onChanged: (TicketRelease value) {
            setState(() {
              selectedRelease = value;
            });
          },
        ),
      ).paddingBottom(12),
      Divider(
        height: 1.5,
      ).paddingBottom(8),
      if (selectedRelease != null)
        Column(
          children: [
            SizedBox(
              width: MyTheme.maxWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(selectedRelease.name),
                  SizedBox(
                      width: 70,
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Text("\$${(selectedRelease.price / 100).toStringAsFixed(2)}")))
                ],
              ),
            ).paddingBottom(8),
            SizedBox(
              width: MyTheme.maxWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Booking Fee"),
                  SizedBox(width: 70, child: Align(alignment: Alignment.centerRight, child: Text("\$1.00")))
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
                          child: Text("\$${((selectedRelease.price + 100) / 100).toStringAsFixed(2)}")))
                ],
              ),
            ).paddingBottom(8),
          ],
        ),
      SizedBox(
          width: MyTheme.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("I accept the terms & conditions"),
              Checkbox(
                value: _termsConditions,
                onChanged: (v) {
                  setState(() {
                    _termsConditions = v;
                  });
                },
              )
            ],
          )),
      Text(
        "Payment Method",
        style: MyTheme.mainTT.headline6,
      ).paddingBottom(20),
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
                  if(value == 0){
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
                  if(value == 0){
                    bloc.add(EventAddPaymentMethod());
                  }
                },
              ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: RaisedButton(
            onPressed: () {
              bloc.add(EventRequestPI(selectedRelease, 1));
            },
            child: Text(
              "Proceed to payment",
              style: MyTheme.mainTT.button,
            ),
          ),
        ),
      ),
    ]);
  }
}
