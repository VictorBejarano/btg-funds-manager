import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/transaction.dart';
import 'history_event.dart';
import 'history_state.dart';

export 'history_event.dart';
export 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final FirebaseFunctions _functions;

  HistoryBloc({required FirebaseFunctions functions})
    : _functions = functions,
      super(HistoryInitial()) {
    on<LoadHistoryRequested>(_onLoadHistoryRequested);
  }

  Future<void> _onLoadHistoryRequested(
    LoadHistoryRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoadInProgress());
    try {
      final HttpsCallable callable = _functions.httpsCallable('getusertransactions');
      
      final result = await callable.call({
        'userId': event.userId,
      });

      final List<dynamic> data = result.data as List<dynamic>;
      final transactions = data.map((json) {
        return Transaction.fromJson(Map<String, dynamic>.from(json as Map));
      }).toList();

      emit(HistoryLoadSuccess(transactions));
    } on FirebaseFunctionsException catch (e) {
      emit(
        HistoryLoadFailure(
          e.message ?? 'Error desconocido de Firebase Functions',
        ),
      );
    } catch (e) {
      emit(HistoryLoadFailure(e.toString()));
    }
  }
}
