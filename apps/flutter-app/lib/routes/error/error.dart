import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  static const String route = '/error';

  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Page')),
      body: const Center(child: Text('Oops! Page not found.')),
    );
  }
}
