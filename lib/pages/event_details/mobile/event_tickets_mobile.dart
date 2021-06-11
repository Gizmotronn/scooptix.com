import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/widgets/appollo/appolloDivider.dart';
import 'package:ticketapp/UI/widgets/cards/appollo_bg_card.dart';
import 'package:ticketapp/UI/widgets/cards/tickets_card.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/pages/order_summary/order_summary_sheet.dart';
import 'package:ticketapp/repositories/payment_repository.dart';
import '../../../UI/theme.dart';
import 'get_tickets_sheet.dart';

class EventTicketsMobile extends StatefulWidget {
  final Event event;
  final ScrollController scrollController;

  EventTicketsMobile({
    Key key,
    @required this.event,
    @required this.scrollController,
  }) : super(key: key);

  @override
  _EventTicketsMobileState createState() => _EventTicketsMobileState();
}

class _EventTicketsMobileState extends State<EventTicketsMobile> {
  final Map<TicketRelease, int> selectedTickets = {};
  final double height = 580;
  double position = 0.0;

  final List<Color> ticketColor = [
    MyTheme.appolloGreen,
    MyTheme.appolloOrange,
    MyTheme.appolloYellow,
  ];

  @override
  void initState() {
    PaymentRepository.instance.releaseDataUpdatedStream.stream.listen((data) {
      if (data) {
        setState(() {
          selectedTickets.clear();
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.event.preSaleEnabled ||
          widget.event.preSale.registrationStartDate.isAfter(DateTime.now()) ||
          widget.event.preSale.registrationEndDate.isBefore(DateTime.now())) {
        showBottomSheet(
            context: context,
            builder: (c) => QuickAccessSheet(
                  controller: widget.scrollController,
                  mainText: widget.event.name,
                  buttonText: "Get Tickets",
                  position: position,
                ));
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BoxOffset(
      boxOffset: (offset) {
        if (position == 0.0) {
          setState(() => position = offset.dy);
        }
      },
      child: Column(
        children: [
          AutoSizeText(
            'Tickets',
            style: MyTheme.textTheme.headline4.copyWith(color: MyTheme.appolloGreen, fontWeight: FontWeight.w600),
          ).paddingBottom(MyTheme.elementSpacing),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 500,
            child: buildTickets(context),
          ),
          AppolloDivider(),
        ],
      ),
    );
  }

  Widget buildTickets(BuildContext context) {
    if (widget.event.releaseManagers.length == 1) {
      return Center(
        child: TicketCard(
            release: widget.event.releaseManagers[0],
            color: ticketColor[0],
            onQuantityChanged: (q) {
              if (q == 0 && selectedTickets.containsKey(widget.event.releaseManagers[0].getActiveRelease())) {
                setState(() {
                  selectedTickets.remove(widget.event.releaseManagers[0].getActiveRelease());
                });
              } else if (q != 0) {
                setState(() {
                  selectedTickets[widget.event.releaseManagers[0].getActiveRelease()] = q;
                });
              }
              if (selectedTickets.isNotEmpty) {
                OrderSummarySheet.openOrderSummarySheetCollapsed(
                  context: context,
                  selectedTickets: selectedTickets,
                  event: widget.event,
                );
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!widget.event.preSaleEnabled ||
                      widget.event.preSale.registrationStartDate.isAfter(DateTime.now()) ||
                      widget.event.preSale.registrationEndDate.isBefore(DateTime.now())) {
                    showBottomSheet(
                        context: context,
                        builder: (c) => QuickAccessSheet(
                              controller: widget.scrollController,
                              mainText: widget.event.name,
                              buttonText: "Get Tickets",
                              position: position,
                            ));
                  }
                });
              }
            }),
      );
    } else {
      return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(right: 8),
          itemCount: widget.event.releaseManagers.length,
          itemBuilder: (c, index) {
            final Color color = ticketColor[index % ticketColor.length];
            return TicketCard(
                release: widget.event.releaseManagers[index],
                color: color,
                onQuantityChanged: (q) {
                  if (q == 0 && selectedTickets.containsKey(widget.event.releaseManagers[index].getActiveRelease())) {
                    setState(() {
                      selectedTickets.remove(widget.event.releaseManagers[index].getActiveRelease());
                    });
                  } else if (q != 0) {
                    setState(() {
                      selectedTickets[widget.event.releaseManagers[index].getActiveRelease()] = q;
                    });
                  }
                  if (selectedTickets.isNotEmpty) {
                    OrderSummarySheet.openOrderSummarySheetCollapsed(
                      context: context,
                      selectedTickets: selectedTickets,
                      event: widget.event,
                    );
                  } else {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!widget.event.preSaleEnabled ||
                          widget.event.preSale.registrationStartDate.isAfter(DateTime.now()) ||
                          widget.event.preSale.registrationEndDate.isBefore(DateTime.now())) {
                        showBottomSheet(
                            context: context,
                            builder: (c) => QuickAccessSheet(
                                  controller: widget.scrollController,
                                  mainText: widget.event.name,
                                  buttonText: "Get Tickets",
                                  position: position,
                                ));
                      }
                    });
                  }
                });
          });
    }
  }
}
