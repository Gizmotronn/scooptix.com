import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:webapp/model/event.dart';
import 'package:webapp/model/ticket_release.dart';
import 'package:webapp/pages/payment/bloc/payment_bloc.dart';
import 'package:webapp/UI/theme.dart';

class PaymentPage extends StatefulWidget {
  final Event event;

  const PaymentPage(this.event, {Key key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentBloc bloc;
  int quantityValue = 0;
  TextEditingController _ccnumberController = TextEditingController();
  TextEditingController _monthController = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  TextEditingController _cvcController = TextEditingController();

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
              Text(
                "Secure your ticket by following the instructions below",
                style: MyTheme.mainTT.subtitle1,
              ),
              SizedBox(
                height: 30,
              ),
              BlocBuilder<PaymentBloc, PaymentState>(
                cubit: bloc,
                builder: (c, state) {
                  if (state is StatePaymentError) {
                    return Text(state.message);
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
                  } else if (state is StateSIRequiresPaymentMethod) {
                    return SizedBox(
                      width: MyTheme.maxWidth - 40,
                      child: Column(
                        children: [
                          Align(
                              alignment:Alignment.centerLeft,
                              child: Text("Credit or Debit Card")),
                          SizedBox(
                            height: 24,
                          ),
                          SizedBox(
                            width: MyTheme.maxWidth - 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: (MyTheme.maxWidth - 40) * 0.7 - 10,
                                  child: TextFormField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(16)
                                    ],
                                    controller: _ccnumberController,
                                    decoration:
                                        InputDecoration.collapsed(hintText: "Credit Card Number"),
                                  ),
                                ),
                                SizedBox(
                                  width: (MyTheme.maxWidth - 40) * 0.08 - 10,
                                  child: TextFormField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2)
                                    ],
                                    controller: _monthController,
                                    decoration:
                                    InputDecoration.collapsed(hintText: "MM"),
                                  ),
                                ),
                                SizedBox(width: (MyTheme.maxWidth - 40) * 0.04,
                                child: Text("/"),),
                                SizedBox(
                                  width: (MyTheme.maxWidth - 40) * 0.08 - 10,
                                  child: TextFormField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2)
                                    ],
                                    controller: _yearController,
                                    decoration:
                                    InputDecoration.collapsed(hintText: "YY"),
                                  ),
                                ),
                                SizedBox(
                                  width: (MyTheme.maxWidth - 40) * 0.1 - 10,
                                  child: TextFormField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(3)
                                    ],
                                    controller: _cvcController,
                                    decoration: InputDecoration.collapsed(hintText: "CVC"),
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
                                  if(_ccnumberController.text.length == 16 && _monthController.text.length > 0 && _yearController.text.length > 0 && _cvcController.text.length == 3) {
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
                                    bloc.add(EventConfirmSetupIntent(pm, state.setupIntentId));
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
                  } else if (state is StateReleasesLoaded) {
                    return _buildTicketOverview(state.releases);
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

  Widget _buildTicketOverview(List<TicketRelease> releases) {
    List<Widget> ticketWidgets = [];
    releases.forEach((release) {
      ticketWidgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${release.name} - \$${(release.price / 100).toStringAsFixed(2)}"),
            SizedBox(
              width: 80,
              child: DropdownButtonFormField(
                itemHeight: kMinInteractiveDimension,
                decoration: InputDecoration.collapsed(hintText: 'Number of tickets'),
                isDense: true,
                items: [0, 1]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.toString()),
                        ))
                    .toList(),
                value: quantityValue,
                onChanged: (int value) {
                  setState(() {
                    quantityValue = value;
                  });
                },
              ),
            ),
          ],
        ),
      );
    });

    ticketWidgets.add(
      Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: RaisedButton(
            onPressed: () {
              bloc.add(EventStartPaymentProcess(releases[0], 1));
            },
            child: Text(
              "Proceed to payment",
              style: MyTheme.mainTT.button,
            ),
          ),
        ),
      ),
    );

    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: ticketWidgets);
  }
}
