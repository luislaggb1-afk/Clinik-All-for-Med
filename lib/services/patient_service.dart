import '../models/patient.dart';

/// Service class to handle patient registration business logic
class PatientService {
  /// Registers a new patient
  /// In a real application, this would make an API call
  Future<void> registerPatient(Patient patient) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Log patient data (in production, this would be an API call)
    print('Patient registered: ${patient.toJson()}');

    // Simulate potential errors
    // In production, handle actual API errors
  }
}
