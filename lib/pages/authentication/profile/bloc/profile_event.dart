part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class EventUploadProfileImage extends ProfileEvent {
  final Uint8List image;

  const EventUploadProfileImage(this.image);
}
