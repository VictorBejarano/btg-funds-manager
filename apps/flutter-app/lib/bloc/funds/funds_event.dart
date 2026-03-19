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
