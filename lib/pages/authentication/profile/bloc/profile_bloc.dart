import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ticketapp/repositories/user_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(StateInitial()) {
    on<EventUploadProfileImage>(_uploadProfileImage);
  }

  _uploadProfileImage(EventUploadProfileImage data, emit) async {
    emit(StateLoadingProfileImage());
    await UserRepository.instance.updateUserProfileImage(data.image);
    emit(StateInitial());
  }
}
