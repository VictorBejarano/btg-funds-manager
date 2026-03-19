import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/home.dart';

class LoginPage extends StatelessWidget {
  static const String route = '/login';

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: 'alejandrobjrn4@gmail.com',
                password: '1024534034',
              );
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  HomePage.route,
                  (route) => false,
                );
              }
            } on FirebaseAuthException catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to sign in: ${e.message}')),
                );
              }
            }
          },
          child: const Text('Sign In (Test User 02)'),
        ),
      ),
    );
  }
}
