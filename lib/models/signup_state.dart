class SignupState {
  String fullName;
  String email;
  String phone;
  String password;
  String confirmPassword;
  bool obscurePassword;
  bool obscureConfirmPassword;
  bool acceptedTerms;
  bool isLoading;
  String specialization;
  String hospitalname;
  String? error;
 

  SignupState({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.confirmPassword = '',
    this.obscurePassword = false,
    this.obscureConfirmPassword = false,
    this.acceptedTerms = false,
    this.isLoading = false,
    this.hospitalname = '',
    this.specialization = '',
    this.error,
   
  });

  SignupState copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? confirmPassword,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool? acceptedTerms,
    bool? isLoading,
    String? error,
    String? specialization, // fixed spelling
    String? hospitalname,
  }) {
    return SignupState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      specialization: specialization ?? this.specialization,
      hospitalname: hospitalname ?? this.hospitalname,
    );
  }
} 