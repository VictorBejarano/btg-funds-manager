import 'package:equatable/equatable.dart';
import '../../models/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoadInProgress extends UserState {}

class UserLoadSuccess extends UserState {
  final User user;
  const UserLoadSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class UserLoadFailure extends UserState {
  final String error;
  const UserLoadFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class UserUpdateInProgress extends UserState {}

class UserUpdateSuccess extends UserState {
  final String message;
  const UserUpdateSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class UserUpdateFailure extends UserState {
  final String error;
  const UserUpdateFailure(this.error);
  @override
  List<Object?> get props => [error];
}
