/// Validation utilities for patient registration forms
class PatientValidators {
  /// Validates patient name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmed)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  /// Validates email address
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmed = value.trim();
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates phone number (10 or 11 digits)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length != 10 && digitsOnly.length != 11) {
      return 'Phone number must be 10 or 11 digits';
    }

    return null;
  }

  /// Validates date of birth
  static String? validateDateOfBirth(DateTime? date) {
    if (date == null) {
      return 'Date of birth is required';
    }

    final age = calculateAge(date);
    if (age < 0 || age > 150) {
      return 'Please enter a valid date of birth';
    }

    return null;
  }

  /// Validates insurance ID format
  static String? validateInsuranceId(String? value, bool hasInsurance) {
    if (!hasInsurance) {
      return null;
    }

    if (value == null || value.trim().isEmpty) {
      return 'Insurance ID is required';
    }

    final trimmed = value.trim();
    if (trimmed.length < 5) {
      return 'Insurance ID must be at least 5 characters';
    }

    if (!RegExp(r'^[A-Z]{2}\d{6,10}$').hasMatch(trimmed.toUpperCase())) {
      return 'Invalid insurance ID format (e.g., AB123456)';
    }

    return null;
  }

  /// Calculates age from date of birth
  static int calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;

    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }

    return age;
  }
}
