import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistoryRequested extends HistoryEvent {
  final String userId;

  const LoadHistoryRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}
