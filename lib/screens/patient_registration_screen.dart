import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';

/// REFACTORED VERSION - Improved separation of concerns and reduced complexity
/// Uses utility classes for validation, formatting, and business logic
class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<PatientRegistrationScreen> createState() => _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientService = PatientService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _insuranceIdController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  String? _selectedBloodType;
  String? _selectedGender;
  DateTime? _dateOfBirth;
  bool _hasInsurance = false;
  bool _hasAllergies = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<String> _allergies = [];
  List<String> _currentMedications = [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _insuranceIdController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  /// Validates all form fields using utility validators
  /// Returns error message if validation fails, null otherwise
  String? _validateFormFields() {
    // Validate name
    final nameError = PatientValidators.validateName(_nameController.text);
    if (nameError != null) return nameError;

    // Validate email
    final emailError = PatientValidators.validateEmail(_emailController.text);
    if (emailError != null) return emailError;

    // Validate phone
    final phoneError = PatientValidators.validatePhone(_phoneController.text);
    if (phoneError != null) return phoneError;

    // Validate date of birth
    final dobError = PatientValidators.validateDateOfBirth(_dateOfBirth);
    if (dobError != null) return dobError;

    // Validate gender
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      return 'Please select a gender';
    }

    // Validate blood type
    if (_selectedBloodType == null || _selectedBloodType!.isEmpty) {
      return 'Please select a blood type';
    }

    // Validate insurance ID if insurance is selected
    final insuranceError = PatientValidators.validateInsuranceId(
      _insuranceIdController.text,
      _hasInsurance,
    );
    if (insuranceError != null) return insuranceError;

    // Validate emergency contact
    final emergencyError = PatientValidators.validatePhone(_emergencyContactController.text);
    if (emergencyError != null) return 'Emergency contact: $emergencyError';

    return null;
  }

  /// Builds a Patient object from form data
  Patient _buildPatientFromForm() {
    final phone = PatientFormatters.formatPhoneNumber(_phoneController.text);
    final emergencyContact = PatientFormatters.formatPhoneNumber(_emergencyContactController.text);
    final age = PatientValidators.calculateAge(_dateOfBirth!);

    return Patient(
      name: _nameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      phone: phone,
      address: _addressController.text.trim(),
      dateOfBirth: _dateOfBirth!,
      age: age,
      gender: _selectedGender!,
      bloodType: _selectedBloodType!,
      hasInsurance: _hasInsurance,
      insuranceId: _hasInsurance ? _insuranceIdController.text.trim().toUpperCase() : null,
      emergencyContact: emergencyContact,
      hasAllergies: _hasAllergies,
      allergies: _hasAllergies ? _allergies : [],
      currentMedications: _currentMedications,
      medicalHistory: _medicalHistoryController.text.trim(),
      registrationDate: DateTime.now(),
    );
  }

  /// Simplified submit form method with clear separation of concerns
  Future<void> _submitForm() async {
    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      // Validate form
      if (!_formKey.currentState!.validate()) {
        _setError('Please fill all required fields');
        return;
      }

      // Validate all fields using validators
      final validationError = _validateFormFields();
      if (validationError != null) {
        _setError(validationError);
        return;
      }

      // Build patient object from form data
      final patient = _buildPatientFromForm();

      // Submit to service
      await _patientService.registerPatient(patient);

      // Show success and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient registered successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _setError('Failed to register patient: ${e.toString()}');
    }
  }

  /// Helper method to set error message and stop submission
  void _setError(String message) {
    setState(() {
      _errorMessage = message;
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Registration'),
        backgroundColor: Colors.teal,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name *'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email *'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number *'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(labelText: 'Gender *'),
                      items: ['Male', 'Female', 'Other']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedGender = value),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedBloodType,
                      decoration: const InputDecoration(labelText: 'Blood Type *'),
                      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                          .map((bt) => DropdownMenuItem(value: bt, child: Text(bt)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedBloodType = value),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Has Insurance'),
                      value: _hasInsurance,
                      onChanged: (value) => setState(() => _hasInsurance = value ?? false),
                    ),
                    if (_hasInsurance)
                      TextFormField(
                        controller: _insuranceIdController,
                        decoration: const InputDecoration(labelText: 'Insurance ID'),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emergencyContactController,
                      decoration: const InputDecoration(labelText: 'Emergency Contact *'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: const Text('Register Patient'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
