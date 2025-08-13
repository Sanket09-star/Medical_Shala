import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:medical_shala/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';
import 'screens/appointment_screen.dart';
import 'screens/main_screens/inbox_screen.dart';
import 'screens/main_screens/ask_ai_screen.dart';
import 'screens/encounter_screen.dart';
import 'screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const ProviderScope(child: MyApp()));
}

class ConnectionGate extends StatefulWidget {
  final Widget child;
  const ConnectionGate({required this.child, super.key});

  @override
  State<ConnectionGate> createState() => _ConnectionGateState();
}

class _ConnectionGateState extends State<ConnectionGate> {
  late Stream<InternetStatus> _stream;
  InternetStatus _status = InternetStatus.connected;

  @override
  void initState() {
    super.initState();
    _stream = InternetConnection().onStatusChange;
    _stream.listen((status) {
      setState(() {
        _status = status;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_status == InternetStatus.disconnected)
          Scaffold(
            backgroundColor: const Color(0xFF20406A),
            body: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.wifi_off, size: 64, color: Color(0xFF20406A)),
                      SizedBox(height: 24),
                      Text(
                        'No Internet Connection',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF20406A),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Please check your connection and try again.',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      CircularProgressIndicator(color: Color(0xFF20406A)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Shala',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      builder: (context, child) => ConnectionGate(child: child ?? const SizedBox()),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return const AppointmentScreen();
          }
          return const SignInScreen();
        },
      ),
      routes: {
        '/main': (context) => const AppointmentScreen(),
        '/inbox': (context) => const InboxScreen(),
        '/askai': (context) => const AskAIScreen(),
        '/encounter': (context) => EncounterScreen(),
      },
    );
  }
}
// Main app class ends here