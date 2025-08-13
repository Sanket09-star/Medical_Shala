import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_provider.dart';
import '../utils/validators.dart';
import 'signin_screen.dart';
import 'appointment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/auth_service.dart';
import 'dart:io' show Platform;


class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _specializationController = TextEditingController();
  final _hospitalControlller = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specializationController.dispose();
    _hospitalControlller.dispose();
    
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final state = ref.read(signupProvider);
    // Simple validation
    if (state.fullName.isEmpty ||
        state.email.isEmpty ||
        state.phone.isEmpty ||
        state.password.isEmpty ||
        state.confirmPassword.isEmpty ||
        state.specialization.isEmpty ||
        state.hospitalname.isEmpty) {
      ref.read(signupProvider.notifier).state =
          state.copyWith(error: 'All fields are required');
      return;
    }
    if (state.password != state.confirmPassword) {
      ref.read(signupProvider.notifier).state =
          state.copyWith(error: 'Passwords do not match');
      return;
    }
    if (!state.acceptedTerms) {
      ref.read(signupProvider.notifier).state =
          state.copyWith(error: 'Please accept the terms and conditions');
      return;
    }
    ref.read(signupProvider.notifier).state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Create user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: state.email,
        password: state.password,
      );
      User? user = userCredential.user;
      if (user == null) {
        throw Exception('User creation failed');
      }
      // 2. Save extra info in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': state.fullName,
        'email': state.email,
        'phone': state.phone,
        'specialization': state.specialization,
        'hospitalname': state.hospitalname,
        'pass' : state.confirmPassword,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // 3. Navigate to your main screen
      if (!mounted) return;
      ref.read(signupProvider.notifier).state = state.copyWith(isLoading: false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AppointmentScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ref.read(signupProvider.notifier).state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      ref.read(signupProvider.notifier).state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _navigateToSignIn() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  void _handleGoogleSignIn() async {
    try {
      final userCredential = await AuthService.signInWithGoogle();
      if (userCredential != null) {
        await AuthService.saveUserInfoIfNew(userCredential.user!);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AppointmentScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed: $e')),
        );
      }
    }
  }

  void _handleAppleSignIn() async {
    try {
      final userCredential = await AuthService.signInWithApple();
      if (userCredential != null) {
        await AuthService.saveUserInfoIfNew(userCredential.user!);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AppointmentScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Apple sign-in failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 1),
                      // Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            height: 60,
                            width: 180,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Join Our Healthcare Network',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Register to Continue',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      // Input fields
                      _buildTextField(
                        hintText: 'Full Name',
                        controller: _fullNameController,
                        onChanged: (val) => updateFullName(ref, val),
                        validator: Validators.validateName,
                      ),
                       const SizedBox(height: 18),
                      // Input fields
                      _buildTextField(
                        hintText: 'Specialization',
                        controller: _specializationController,
                        onChanged: (val) => updateSpecialization(ref, val),
                        validator: Validators.validateSpecialization,
                      ),
                          const SizedBox(height: 18),
                      // Input fields
                      _buildTextField(
                        hintText: "Hospitals's / Clinic's Name",
                        controller: _hospitalControlller,
                        onChanged: (val) => updateHospitalName(ref, val),
                        validator: Validators.validateHospitalName,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        hintText: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) => updateEmail(ref, val),
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        hintText: 'Phone Number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        onChanged: (val) => updatePhone(ref, val),
                        validator: Validators.validatePhone,
                      ),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        hintText: 'Password',
                        controller: _passwordController,
                        onChanged: (val) => updatePassword(ref, val),
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        hintText: 'Confirm Password',
                        controller: _confirmPasswordController,
                        onChanged: (val) => updateConfirmPassword(ref, val),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please confirm your password';
                          if (val != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      if (state.error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          state.error!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 4),
                      // Terms & Conditions
                      Row(
                        children: [
                          Checkbox(
                            value: state.acceptedTerms,
                            onChanged: (val) => toggleTermsAccepted(ref, val ?? false),
                            activeColor: Colors.blue,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          const Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: state.isLoading ? null : _handleSignUp,
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Register',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('Or Sign In with', style: TextStyle(fontSize: 13)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Icon-only Google and Apple sign-in buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _handleGoogleSignIn,
                            child: _buildSocialIconButton(
                              imageAsset: 'assets/google_logo.png',
                              backgroundColor: Colors.white,
                              borderColor: const Color(0xFFE0E0E0),
                            ),
                          ),
                          const SizedBox(width: 20),
                          if (Platform.isIOS)
                            GestureDetector(
                              onTap: _handleAppleSignIn,
                              child: _buildSocialIconButton(
                                icon: Icons.apple,
                                backgroundColor: Colors.white,
                                borderColor: const Color(0xFFE0E0E0),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an Account? ', style: TextStyle(fontSize: 13)),
                          GestureDetector(
                            onTap: _navigateToSignIn,
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    required Function(String) onChanged,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        isDense: true,
      ),
    );
  }

  Widget _buildPasswordField({
    required String hintText,
    required TextEditingController controller,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      obscureText: true,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        isDense: true,
      ),
    );
  }

  Widget _buildSocialIconButton({
    String? imageAsset,
    IconData? icon,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Container(
      width: 100,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: imageAsset != null
            ? Image.asset(imageAsset, height: 24, width: 24)
            : Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }
} 