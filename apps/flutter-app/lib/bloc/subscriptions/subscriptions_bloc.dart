import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/subscription.dart';
import 'subscriptions_event.dart';
import 'subscriptions_state.dart';

export 'subscriptions_event.dart';
export 'subscriptions_state.dart';

class SubscriptionsBloc extends Bloc<SubscriptionsEvent, SubscriptionsState> {
  final FirebaseFunctions _functions;

  SubscriptionsBloc({required FirebaseFunctions functions})
    : _functions = functions,
      super(SubscriptionsInitial()) {
    on<LoadSubscriptionsRequested>(_onLoadSubscriptionsRequested);
  }

  Future<void> _onLoadSubscriptionsRequested(
    LoadSubscriptionsRequested event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(SubscriptionsLoadInProgress());
    try {
      final HttpsCallable callable = _functions.httpsCallable('getusersubscriptions');
      
      // Se pasa el userId recibido en el evento como entrada a la Firebase Function
      final result = await callable.call({
        'userId': event.userId,
      });

      final List<dynamic> data = result.data as List<dynamic>;
      final subscriptions = data.map((json) {
        return Subscription.fromJson(Map<String, dynamic>.from(json as Map));
      }).toList();

      emit(SubscriptionsLoadSuccess(subscriptions));
    } on FirebaseFunctionsException catch (e) {
      emit(
        SubscriptionsLoadFailure(
          e.message ?? 'Error desconocido de Firebase Functions',
        ),
      );
    } catch (e) {
      emit(SubscriptionsLoadFailure(e.toString()));
    }
  }
}
