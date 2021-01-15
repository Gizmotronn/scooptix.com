import 'package:flutter/material.dart';
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
  TicketRelease release;

  @override
  void initState() {
    release = widget.event.getReleasesWithPaidTickets()[0];
    bloc = PaymentBloc();
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
              Text("Secure your ticket by following the instructions below"),
              SizedBox(height: 20,),
              BlocBuilder<PaymentBloc, PaymentState>(
                cubit: bloc,
                builder: (c, state){
                  if(state is StatePaymentError){
                    return Text(state.message);
                  } else if (state is StateFinalizePayment){
                    return Column(
                      children: [
                        Text("You will be charged \$${(state.price / 100).toStringAsFixed(2)}"),
                        RaisedButton(
                          onPressed: () {
                            bloc.add(EventConfirmPayment(state.clientSecret, state.paymentMethodId));
                          },
                          child: Text("Pay"),
                        )
                      ],
                    );
                  }else if (state is StateSIRequiresPaymentMethod){
                    return Column(
                      children: [
                        Text("Please enter your credit card details"),
                        RaisedButton(
                          onPressed: () async {
                            StripeCard card = StripeCard(number: "4111111111111111", cvc: "111", expMonth: 11, expYear: 22, last4: "1111");
                           Map<String, dynamic> data = await Stripe.instance.api.createPaymentMethodFromCard(card);
                           PaymentMethod pm = PaymentMethod(data["id"], data["card"]["last4"], data["card"]["brand"]);
                            bloc.add(EventConfirmSetupIntent(pm, state.setupIntentId));
                          },
                          child: Text("Confirm"),
                        )
                      ],
                    );
                  } else if (state is StateInitial){
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${release.name} x 1 - \$${(release.ticketTypes[0].price / 100).toStringAsFixed(2)}"),
                        RaisedButton(
                          onPressed: (){
                            bloc.add(EventGetSetupIntent());
                          },
                          child: Text("Proceed to payment"),
                        ),
                      ],
                    );
                  } else if (state is SetupIntentConfirmedState){
                    return Column(
                      children: [
                        Text("Your have a saved card ending in ${state.last4}"),
                        SizedBox(height: 12,),
                        RaisedButton(
                          onPressed: (){
                            bloc.add(EventRequestPI(widget.event.docID, release.docId, 1));
                          },
                          child: Text("Use saved card"),
                        ),
                        SizedBox(height: 12,),
                        RaisedButton(
                          onPressed: (){
                            bloc.add(EventRequestPI(widget.event.docID, release.docId, 1));
                          },
                          child: Text("Change card"),
                        ),
                      ],
                    );
                  }else {
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
}
