import 'package:equatable/equatable.dart';
import '../../models/fund.dart';

abstract class FundsState extends Equatable {
  const FundsState();

  @override
  List<Object?> get props => [];
}

class FundsInitial extends FundsState {}

class FundsLoadInProgress extends FundsState {}

class FundsLoadSuccess extends FundsState {
  final List<Fund> funds;

  const FundsLoadSuccess(this.funds);

  @override
  List<Object?> get props => [funds];
}

class FundsLoadFailure extends FundsState {
  final String error;

  const FundsLoadFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class FundDetailLoadInProgress extends FundsState {}

class FundDetailLoadSuccess extends FundsState {
  final Fund fund;

  const FundDetailLoadSuccess(this.fund);

  @override
  List<Object?> get props => [fund];
}

class FundDetailLoadFailure extends FundsState {
  final String error;

  const FundDetailLoadFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class FundModificationInProgress extends FundsState {}

class FundModificationSuccess extends FundsState {}

class FundModificationFailure extends FundsState {
  final String error;

  const FundModificationFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class FundSubscriptionInProgress extends FundsState {}

class FundSubscriptionSuccess extends FundsState {
  final String message;

  const FundSubscriptionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class FundSubscriptionFailure extends FundsState {
  final String error;

  const FundSubscriptionFailure(this.error);

  @override
  List<Object?> get props => [error];
}
