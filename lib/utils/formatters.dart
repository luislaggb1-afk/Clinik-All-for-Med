/// Formatting utilities for patient data
class PatientFormatters {
  /// Formats phone number to (XXX) XXX-XXXX or +X (XXX) XXX-XXXX
  static String formatPhoneNumber(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length == 10) {
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    } else if (digitsOnly.length == 11) {
      return '+${digitsOnly.substring(0, 1)} (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
    }

    return phone;
  }

  /// Extracts digits only from a string
  static String extractDigits(String input) {
    return input.replaceAll(RegExp(r'[^\d]'), '');
  }
}
