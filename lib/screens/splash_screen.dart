import 'package:flutter/material.dart';
import 'signin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToSignIn();
  }

  Future<void> _navigateToSignIn() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF20406A), // Top dark blue
              Color(0xFF3576B7), // Bottom lighter blue
            ],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 100),
                  Text(
                    'Streamline Your Practice\nwith Ease!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Simplify your workflow, manage\npatient data, and enhance\ncommunication: all in one\ncomprehensive platform tailored\nfor doctors.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // Bottom-right graphic
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(33, 150, 243, 0.15), // Replaced withOpacity with RGBO
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(200),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.waves, size: 100, color: Colors.white24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}