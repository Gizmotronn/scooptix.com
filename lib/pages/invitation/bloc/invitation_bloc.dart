import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ticketapp/model/discount.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/link_type/link_type.dart';
import 'package:ticketapp/model/ticket.dart';
import 'package:ticketapp/model/ticket_release.dart';
import 'package:ticketapp/repositories/customer_repository.dart';
import 'package:ticketapp/repositories/ticket_repository.dart';

part 'invitation_event.dart';
part 'invitation_state.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  InvitationBloc() : super(StateLoading(message: "Fetching your invitation data, this won't take long ..."));

  @override
  Stream<InvitationState> mapEventToState(
    InvitationEvent event,
  ) async* {
    if (event is EventCheckInvitationStatus) {
      yield* _checkInvitationStatus(event.uid, event.event, event.forwardToPayment);
    } else if (event is EventAcceptInvitation) {
      yield* _acceptInvitation(event.linkType, event.release);
    } else if (event is EventPaymentSuccessful) {
      yield* _processTickets(event.linkType, event.release, event.quantity, event.discount);
    } else if (event is EventGoToPayment) {
      yield StateWaitForPayment(event.releases);
    }
  }

  Stream<InvitationState> _checkInvitationStatus(String uid, Event event, bool forwardToPayment) async* {
    yield StateLoading(message: "Fetching your invitation data, this won't take long");
    if (!DateTime.now().difference(event.date.subtract(Duration(hours: event.cutoffTimeOffset))).isNegative) {
      yield StatePastCutoffTime();
    } else {
      List<TicketRelease> releasesWithSingleTicketRestriction = event.getReleasesWithSingleTicketRestriction();
      List<TicketRelease> releasesWithRegularTickets = event.getReleasesWithoutRestriction();
      List<Ticket> tickets = await TicketRepository.instance.loadTickets(uid, event);
      List<Ticket> restrictedTickets = tickets
          .where((t) => releasesWithSingleTicketRestriction.any((element) => t.release.docId == element.docId))
          .toList();

      if (restrictedTickets.length > 0) {
        yield StateTicketAlreadyIssued(tickets[0]);
      }
      // If the current user does not yet have a ticket
      else {
        if (releasesWithRegularTickets.length == 0 && releasesWithSingleTicketRestriction.length == 0) {
          yield StateNoTicketsLeft();
        } else {
          if (releasesWithSingleTicketRestriction.length > 0) {
            if (forwardToPayment) {
              yield StateWaitForPayment(releasesWithSingleTicketRestriction);
            } else {
              yield StatePaymentRequired(releasesWithSingleTicketRestriction, tickets);
            }
          } else {
            if (forwardToPayment) {
              yield StateWaitForPayment(releasesWithRegularTickets);
            } else {
              yield StatePaymentRequired(releasesWithRegularTickets, tickets);
            }
          }
        }
      }
    }
  }

  Stream<InvitationState> _acceptInvitation(LinkType linkType, TicketRelease release) async* {
    yield StateLoading(message: "Processing your ticket ...");

    Ticket ticket = await TicketRepository.instance.acceptInvitation(linkType, release);
    CustomerRepository.instance.addCustomerAttendingAction(linkType);
    if (ticket == null) {
      yield StateError();
    } else {
      yield StateInvitationAccepted([ticket]);
    }
  }

  Stream<InvitationState> _processTickets(
      LinkType linkType, TicketRelease release, int quantity, Discount discount) async* {
    yield StateLoading(message: "Processing your tickets ...");

    List<Ticket> tickets = await TicketRepository.instance.issueTickets(linkType, release, quantity, discount);
    CustomerRepository.instance.addCustomerAttendingAction(linkType);
    if (tickets.isEmpty) {
      yield StateError();
    } else {
      yield StateInvitationAccepted(tickets);
    }
  }
}
