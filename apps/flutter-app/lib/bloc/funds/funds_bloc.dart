import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/fund.dart';
import 'funds_event.dart';
import 'funds_state.dart';

export 'funds_event.dart';
export 'funds_state.dart';

class FundsBloc extends Bloc<FundsEvent, FundsState> {
  final FirebaseFunctions _functions;

  FundsBloc({required FirebaseFunctions functions})
      : _functions = functions,
        super(FundsInitial()) {
    on<LoadFundsRequested>(_onLoadFundsRequested);
    on<FundDetailRequested>(_onFundDetailRequested);
    on<ModifyFundRequested>(_onModifyFundRequested);
  }

  Future<void> _onLoadFundsRequested(
    LoadFundsRequested event,
    Emitter<FundsState> emit,
  ) async {
    emit(FundsLoadInProgress());
    try {
      final HttpsCallable callable = _functions.httpsCallable('getFunds');
      final result = await callable.call();
      
      final List<dynamic> data = result.data as List<dynamic>;
      final funds = data
          .map((json) => Fund.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
          
      emit(FundsLoadSuccess(funds));
    } on FirebaseFunctionsException catch (e) {
      emit(FundsLoadFailure(e.message ?? 'Error desconocido de Firebase Functions'));
    } catch (e) {
      emit(FundsLoadFailure(e.toString()));
    }
  }

  Future<void> _onFundDetailRequested(
    FundDetailRequested event,
    Emitter<FundsState> emit,
  ) async {
    emit(FundDetailLoadInProgress());
    try {
      final HttpsCallable callable = _functions.httpsCallable('getFundDetail');
      final result = await callable.call({'fundId': event.fundId});
      
      final fund = Fund.fromJson(Map<String, dynamic>.from(result.data as Map));
      emit(FundDetailLoadSuccess(fund));
    } on FirebaseFunctionsException catch (e) {
      emit(FundDetailLoadFailure(e.message ?? 'Error desconocido de Firebase Functions'));
    } catch (e) {
      emit(FundDetailLoadFailure(e.toString()));
    }
  }

  Future<void> _onModifyFundRequested(
    ModifyFundRequested event,
    Emitter<FundsState> emit,
  ) async {
    emit(FundModificationInProgress());
    try {
      final HttpsCallable callable = _functions.httpsCallable('modifyFund');
      await callable.call(event.fund.toJson());
      
      emit(FundModificationSuccess());
    } on FirebaseFunctionsException catch (e) {
      emit(FundModificationFailure(e.message ?? 'Error desconocido de Firebase Functions'));
    } catch (e) {
      emit(FundModificationFailure(e.toString()));
    }
  }
}
