class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (!RegExp(r"^[a-zA-Z .'-]{2,50}").hasMatch(value.trim())) {
      return 'Enter a valid name';
    }
    return null;
  }
   static String? validateSpecialization(String? value) {
    if (value == null || value.trim().isEmpty) return 'Specialization is required';
    if (!RegExp(r"^[a-zA-Z .'-]{2,50}").hasMatch(value.trim())) {
      return 'Enter a valid specialization';
    }
    return null;
  }
     static String? validateHospitalName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Hospital name is required';
    if (!RegExp(r"^[a-zA-Z .'-]{2,50}").hasMatch(value.trim())) {
      return 'Enter a valid hospital name';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final phone = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.length < 10) return 'Enter a valid phone number';
    return null;
  }

  static String? validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }
} 