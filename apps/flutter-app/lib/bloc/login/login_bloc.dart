import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

export 'login_event.dart';
export 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _auth;

  LoginBloc({required FirebaseAuth auth})
      : _auth = auth,
        super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginInProgress());
    final user = _auth.currentUser;
    if (user != null) {
      emit(LoginSuccess(user));
    } else {
      emit(LoginInitial());
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginInProgress());
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (userCredential.user != null) {
        emit(LoginSuccess(userCredential.user!));
      } else {
        emit(const LoginFailure('Error: No se pudo obtener el usuario.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(LoginFailure(e.message ?? 'Error desconocido de autenticación.'));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginState> emit,
  ) async {
    await _auth.signOut();
    emit(LoginInitial());
  }
}
