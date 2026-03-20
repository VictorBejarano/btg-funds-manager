import 'package:equatable/equatable.dart';
import '../../models/fund.dart';

abstract class FundsEvent extends Equatable {
  const FundsEvent();

  @override
  List<Object?> get props => [];
}

class LoadFundsRequested extends FundsEvent {}

class FundDetailRequested extends FundsEvent {
  final String fundId;

  const FundDetailRequested(this.fundId);

  @override
  List<Object?> get props => [fundId];
}

class ModifyFundRequested extends FundsEvent {
  final Fund fund;

  const ModifyFundRequested(this.fund);

  @override
  List<Object?> get props => [fund];
}

class SubscribeFundRequested extends FundsEvent {
  final String fundId;
  final String userId;
  final double amount;

  const SubscribeFundRequested({
    required this.fundId,
    required this.userId,
    required this.amount,
  });

  @override
  List<Object?> get props => [fundId, userId, amount];
}
