import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserDataRequested extends UserEvent {
  final String userId;
  const LoadUserDataRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateUserDataRequested extends UserEvent {
  final String userId;
  final Map<String, dynamic> data;

  const UpdateUserDataRequested({required this.userId, required this.data});

  @override
  List<Object?> get props => [userId, data];
}
