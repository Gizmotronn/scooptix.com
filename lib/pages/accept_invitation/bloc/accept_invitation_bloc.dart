import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:webapp/model/event.dart';
import 'package:webapp/model/link_type/link_type.dart';
import 'package:webapp/model/ticket.dart';
import 'package:webapp/model/ticket_release.dart';
import 'package:webapp/repositories/customer_repository.dart';
import 'package:webapp/repositories/ticket_repository.dart';

part 'accept_invitation_event.dart';
part 'accept_invitation_state.dart';

class AcceptInvitationBloc extends Bloc<AcceptInvitationEvent, AcceptInvitationState> {
  AcceptInvitationBloc() : super(StateLoading(message: "Fetching your invitation data, this won't take long ..."));

  @override
  Stream<AcceptInvitationState> mapEventToState(
    AcceptInvitationEvent event,
  ) async* {
    if (event is EventCheckInvitationStatus) {
      yield* _checkInvitationStatus(event.uid, event.event);
    } else if (event is EventAcceptInvitation) {
      yield* _acceptInvitation(event.linkType);
    }
  }

  Stream<AcceptInvitationState> _checkInvitationStatus(String uid, Event event) async* {
    yield StateLoading(message: "Fetching your invitation data, this won't take long ...");
    if (!DateTime.now().difference(event.date.subtract(Duration(hours: event.cutoffTimeOffset))).isNegative) {
      yield StatePastCutoffTime();
    } else {
      List<Ticket> tickets = await TicketRepository.instance.loadTickets(uid, event);
      List<Ticket> freeTickets = tickets.where((element) => element.release.price == 0).toList();

      // If the current user does not yet have a free ticket
      if (freeTickets.length == 0) {
        List<TicketRelease> freeTicketRelease = event.getReleasesWithFreeTickets();

        // If there is a release with free tickets
        if(freeTicketRelease.length == 0){
          yield StateNoTicketsLeft();
        } else {
          bool ticketsLeft = await TicketRepository.instance.freeTicketsLeft(event.docID, freeTicketRelease[0]);
          if (ticketsLeft) {
            yield StateInvitationPending(freeTicketRelease[0]);
          } else {
            yield StateNoTicketsLeft();
          }
        }
      } else {
        yield StateTicketAlreadyIssued(freeTickets[0]);
      }
    }
  }

  Stream<AcceptInvitationState> _acceptInvitation(LinkType linkType) async* {
    yield StateLoading(message: "Putting your name on the guestlist ...");
    List<TicketRelease> freeTicketRelease = linkType.event.getReleasesWithFreeTickets();
    if(freeTicketRelease.length == 0){
      yield StateError();
    } else {
      Ticket ticket = await TicketRepository.instance.acceptInvitation(linkType, freeTicketRelease[0]);
      CustomerRepository.instance.addCustomerAttendingAction(linkType);
      if (ticket == null) {
        yield StateError();
      } else {
        yield StateInvitationAccepted();
      }
    }
  }
}
