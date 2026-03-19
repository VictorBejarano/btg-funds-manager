import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginBloc(auth: FirebaseAuth.instance),
        ),
        BlocProvider(
          create: (context) => FundsBloc(functions: FirebaseFunctions.instance),
        ),
      ],
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
            default:
              return MaterialPageRoute(builder: (context) => const ErrorPage());
          }
        },
      ),
    );
  }
}


