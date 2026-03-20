import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import 'user_event.dart';
import 'user_state.dart';

export 'user_event.dart';
export 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirebaseFunctions _functions;

  UserBloc({required FirebaseFunctions functions})
      : _functions = functions,
        super(UserInitial()) {
    on<LoadUserDataRequested>(_onLoadUserDataRequested);
    on<UpdateUserDataRequested>(_onUpdateUserDataRequested);
  }

  Future<void> _onLoadUserDataRequested(
    LoadUserDataRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoadInProgress());
    try {
      final HttpsCallable callable = _functions.httpsCallable('getuserdata');
      final result = await callable.call({'userId': event.userId});
      
      final Map<String, dynamic> data = Map<String, dynamic>.from(result.data);
      // userFromJson expects string but we have map, so let's use User.fromJson directly
      final user = User.fromJson(data);
      
      emit(UserLoadSuccess(user));
    } on FirebaseFunctionsException catch (e) {
      emit(UserLoadFailure(e.message ?? 'Error desconocido de Firebase Functions'));
    } catch (e) {
      emit(UserLoadFailure(e.toString()));
    }
  }

  Future<void> _onUpdateUserDataRequested(
    UpdateUserDataRequested event,
    Emitter<UserState> emit,
  ) async {
    // Para recargar los datos despues, necesitamos el userId
    final String userId = event.userId;
    
    emit(UserUpdateInProgress());
    try {
      final HttpsCallable callable = _functions.httpsCallable('updateuserdata');
      final result = await callable.call({
        'userId': event.userId,
        'userData': event.data,
      });

      final message = result.data['message'] as String? ?? 'Actualizado Correctamente';
      emit(UserUpdateSuccess(message));
      
      // Se añade el evento para volver a cargar la información actualizada
      add(LoadUserDataRequested(userId));
    } on FirebaseFunctionsException catch (e) {
      emit(UserUpdateFailure(e.message ?? 'Error actualizando datos'));
      add(LoadUserDataRequested(userId)); // Reload even on failure to restore view
    } catch (e) {
      emit(UserUpdateFailure(e.toString()));
      add(LoadUserDataRequested(userId));
    }
  }
}
