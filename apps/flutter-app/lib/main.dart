import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes/routes.dart';
import 'bloc/bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(auth: FirebaseAuth.instance),
      child: MaterialApp(
        initialRoute: AuthWrapper.route,
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case AuthWrapper.route:
              return MaterialPageRoute(
                builder: (context) => const AuthWrapper(),
              );
            case HomePage.route:
              return MaterialPageRoute(builder: (context) => const HomePage());
            case LoginPage.route:
              return MaterialPageRoute(builder: (context) => const LoginPage());
            case '/profile':
              return MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              );
            default:
              return MaterialPageRoute(builder: (context) => const ErrorPage());
          }
        },
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Page')),
      body: const Center(child: Text('Welcome to the Profile Page!')),
    );
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Page')),
      body: const Center(child: Text('Oops! Page not found.')),
    );
  }
}
