part of 'accept_invitation_bloc.dart';

abstract class AcceptInvitationEvent extends Equatable {
  const AcceptInvitationEvent();

  @override
  List<Object> get props => [];
}

class EventCheckInvitationStatus extends AcceptInvitationEvent {
  final String uid;
  final Event event;

  const EventCheckInvitationStatus(this.uid, this.event);
}

class EventAcceptInvitation extends AcceptInvitationEvent {
  final LinkType linkType;

  const EventAcceptInvitation(this.linkType);
}
