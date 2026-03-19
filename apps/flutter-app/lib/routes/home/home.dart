import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../login/login.dart';

class HomePage extends StatelessWidget {
  static const String route = '/home';
  
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: const Text('Go to Profile'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    LoginPage.route,
                    (route) => false,
                  );
                }
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}