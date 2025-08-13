import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_shala/models/signup_state.dart';

final signupProvider = StateProvider<SignupState>((ref) => SignupState());

// Helper functions for updating SignupState
void updateFullName(WidgetRef ref, String value) {
  ref.read(signupProvider.notifier).state =
      ref.read(signupProvider).copyWith(fullName: value);
}

void updateSpecialization(WidgetRef ref, String value){
  ref.read(signupProvider.notifier).state = 
      ref.read(signupProvider).copyWith(specialization: value);
}

void updateHospitalName(WidgetRef ref, String value){
  ref.read(signupProvider.notifier).state = 
        ref.read(signupProvider).copyWith(hospitalname: value);
}

void updateEmail(WidgetRef ref, String value) {
  ref.read(signupProvider.notifier).state =
      ref.read(signupProvider).copyWith(email: value);
}

void updatePhone(WidgetRef ref, String value) {
  ref.read(signupProvider.notifier).state =
      ref.read(signupProvider).copyWith(phone: value);
}

void updatePassword(WidgetRef ref, String value) {
  ref.read(signupProvider.notifier).state =
      ref.read(signupProvider).copyWith(password: value);
}

void updateConfirmPassword(WidgetRef ref, String value) {
  ref.read(signupProvider.notifier).state =
      ref.read(signupProvider).copyWith(confirmPassword: value);
}

void togglePasswordVisibility(WidgetRef ref) {
  final current = ref.read(signupProvider);
  ref.read(signupProvider.notifier).state =
      current.copyWith(obscurePassword: !current.obscurePassword);
}

void toggleConfirmPasswordVisibility(WidgetRef ref) {
  final current = ref.read(signupProvider);
  ref.read(signupProvider.notifier).state =
      current.copyWith(obscureConfirmPassword: !current.obscureConfirmPassword);
}

void toggleTermsAccepted(WidgetRef ref, bool value) {
  ref.read(signupProvider.notifier).state =
      ref.read(signupProvider).copyWith(acceptedTerms: value);
} 