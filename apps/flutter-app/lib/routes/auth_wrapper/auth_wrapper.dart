import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/bloc.dart';
import '../home/home.dart';
import '../login/login.dart';

class AuthWrapper extends StatefulWidget {
  static const String route = '/';

  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Iniciar el chequeo de autenticación a través del Bloc
    context.read<LoginBloc>().add(AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          // Redirigir a Home sin opción de regresar
          Navigator.pushNamedAndRemoveUntil(
            context,
            HomePage.route,
            (route) => false,
          );
        } else if (state is LoginInitial || state is LoginFailure) {
          // Redirigir a Login si no hay sesión o falló la verificación
          Navigator.pushNamedAndRemoveUntil(
            context,
            LoginPage.route,  
            (route) => false,
          );
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
