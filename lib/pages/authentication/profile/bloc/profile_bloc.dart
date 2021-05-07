import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ticketapp/repositories/user_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(StateInitial());

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    if (event is EventUploadProfileImage) {
      yield* _uploadProfileImage(event.image);
    }
  }

  Stream<ProfileState> _uploadProfileImage(Uint8List image) async* {
    yield StateLoadingProfileImage();
    await UserRepository.instance.updateUserProfileImage(image);
    yield StateInitial();
  }
}
