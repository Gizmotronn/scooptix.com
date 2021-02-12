import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:webapp/model/event.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/ticket.dart';
import 'package:webapp/model/ticket_release.dart';
import 'package:webapp/repositories/customer_repository.dart';
import 'package:webapp/repositories/ticket_repository.dart';

part 'ticket_event.dart';
part 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  TicketBloc() : super(StateLoading(message: "Fetching your invitation data, this won't take long ..."));

  @override
  Stream<TicketState> mapEventToState(
    TicketEvent event,
  ) async* {
    if (event is EventCheckInvitationStatus) {
      yield* _checkInvitationStatus(event.uid, event.event);
    } else if (event is EventAcceptInvitation) {
      yield* _acceptInvitation(event.linkType, event.release);
    } else if (event is EventPaymentSuccessful) {
      yield* _processTickets(event.linkType, event.release, event.quantity);
    } else if (event is EventGoToPayment) {
      yield StateWaitForPayment(event.releases);
    }
  }

  Stream<TicketState> _checkInvitationStatus(String uid, Event event) async* {
    yield StateLoading(message: "Fetching your invitation data, this won't take long");
    if (!DateTime.now().difference(event.date.subtract(Duration(hours: event.cutoffTimeOffset))).isNegative) {
      yield StatePastCutoffTime();
    } else {
      List<TicketRelease> releasesWithSingleTicketRestriction = event.getReleasesWithSingleTicketRestriction();
      List<TicketRelease> releasesWithRegularTickets = event.getReleasesWithoutRestriction();
      List<Ticket> tickets = await TicketRepository.instance.loadTickets(uid, event);
      List<Ticket> restrictedTickets = tickets.where((element) => element.release.singleTicketRestriction).toList();

      print("tickets ${tickets.length}");

      if (restrictedTickets.length > 0) {
        yield StateTicketAlreadyIssued(tickets[0]);
      }
      // If the current user does not yet have a ticket
      else {
        if (releasesWithRegularTickets.length == 0 && releasesWithSingleTicketRestriction.length == 0) {
          yield StateNoTicketsLeft();
        } else {
          if (releasesWithSingleTicketRestriction.length > 0) {
            yield StatePaymentRequired(releasesWithSingleTicketRestriction, tickets);
          } else {
            yield StatePaymentRequired(releasesWithRegularTickets, tickets);
          }
        }
      }
    }
  }

  Stream<TicketState> _acceptInvitation(LinkType linkType, TicketRelease release) async* {
    yield StateLoading(message: "Processing your ticke ...");

    Ticket ticket = await TicketRepository.instance.acceptInvitation(linkType, release);
    CustomerRepository.instance.addCustomerAttendingAction(linkType);
    if (ticket == null) {
      yield StateError();
    } else {
      yield StateInvitationAccepted([ticket]);
    }
  }

  Stream<TicketState> _processTickets(LinkType linkType, TicketRelease release, int quantity) async* {
    yield StateLoading(message: "Processing your tickets ...");

    List<Ticket> tickets = await TicketRepository.instance.issueTickets(linkType, release, quantity);
    CustomerRepository.instance.addCustomerAttendingAction(linkType);
    if (tickets.isEmpty) {
      yield StateError();
    } else {
      yield StateInvitationAccepted(tickets);
    }
  }
}
