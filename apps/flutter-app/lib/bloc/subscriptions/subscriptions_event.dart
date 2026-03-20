import 'package:equatable/equatable.dart';

abstract class SubscriptionsEvent extends Equatable {
  const SubscriptionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscriptionsRequested extends SubscriptionsEvent {
  final String userId;

  const LoadSubscriptionsRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}
