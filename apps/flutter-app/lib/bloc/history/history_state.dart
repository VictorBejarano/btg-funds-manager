import 'package:equatable/equatable.dart';
import '../../models/transaction.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoadInProgress extends HistoryState {}

class HistoryLoadSuccess extends HistoryState {
  final List<Transaction> transactions;

  const HistoryLoadSuccess(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class HistoryLoadFailure extends HistoryState {
  final String error;

  const HistoryLoadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
