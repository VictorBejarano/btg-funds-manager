import 'package:equatable/equatable.dart';
import '../../models/subscription.dart';

abstract class SubscriptionsState extends Equatable {
  const SubscriptionsState();

  @override
  List<Object?> get props => [];
}

class SubscriptionsInitial extends SubscriptionsState {}

class SubscriptionsLoadInProgress extends SubscriptionsState {}

class SubscriptionsLoadSuccess extends SubscriptionsState {
  final List<Subscription> subscriptions;

  const SubscriptionsLoadSuccess(this.subscriptions);

  @override
  List<Object?> get props => [subscriptions];
}

class SubscriptionsLoadFailure extends SubscriptionsState {
  final String error;

  const SubscriptionsLoadFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class UnsubscriptionInProgress extends SubscriptionsState {}

class UnsubscriptionSuccess extends SubscriptionsState {
  final String message;

  const UnsubscriptionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UnsubscriptionFailure extends SubscriptionsState {
  final String error;

  const UnsubscriptionFailure(this.error);

  @override
  List<Object?> get props => [error];
}
