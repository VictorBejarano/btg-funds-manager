import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    // Ejecutar la redirección después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    // Obtener el estado de autenticación actual de forma asíncrona
    final user = await FirebaseAuth.instance.authStateChanges().first;

    if (!mounted) return;

    if (user != null) {
      // Redirigir a Home sin opción de regresar
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomePage.route,
        (route) => false,
      );
    } else {
      // Redirigir a Login sin opción de regresar
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginPage.route,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
