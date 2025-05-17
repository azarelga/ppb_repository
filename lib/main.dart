import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:expense_tracker/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/screen/login_page.dart';
import 'package:expense_tracker/screen/homepage.dart';
import 'package:expense_tracker/utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notifications
  await NotificationService().initialize();

  runApp(MaterialApp(home: AuthGate()));
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return HomePage();
        }
        return LoginPage();
      },
    );
  }
}

