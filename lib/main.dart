import 'package:energychat/screens/chat_screen.dart';
import 'package:energychat/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GPTChatApp());
}

class GPTChatApp extends StatelessWidget {
  const GPTChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/',
      debugShowCheckedModeBanner: false,
      title: 'GPT Chat Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (context) => const ChatScreen(),
        '/sign-in': (context) => SignInScreen(
              providers: [
                EmailAuthProvider(),
                GoogleProvider(clientId: ''),
              ],
              actions: [
                AuthStateChangeAction<SigningUp>(
                  (context, state) {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
                AuthStateChangeAction<SignedIn>(
                  (context, state) {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ],
            )
      },
    );
  }
}
