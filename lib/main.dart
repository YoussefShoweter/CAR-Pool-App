
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'welcome.dart';
import 'homepage.dart';
import 'signup.dart';
import 'firebase_options.dart';
import 'helpers/usertype.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Replace 'yourUserCredential' with the actual UserCredential when available
  UserCredential? userCredential;

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserTypeProvider(),
      child: MaterialApp(
        initialRoute: '/welcome',
        routes: {
          '/home': (context) => HomePage(),
          '/signup': (context) => SignupPage(),
          '/welcome': (context) => WelcomeScreen(),

        },
      ),
    ),
  );
}
