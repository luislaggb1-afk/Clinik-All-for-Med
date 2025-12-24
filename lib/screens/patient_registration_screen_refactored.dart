import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';

/// REFACTORED VERSION - Clean, maintainable, and testable
/// Improvements:
/// 1. Separated validation logic into validators
/// 2. Extracted formatting logic into formatters
/// 3. Created a service layer for business logic
/// 4. Used a model class for data encapsulation
/// 5. Shorter, more focused methods
/// 6. Better error handling
/// 7. Improved testability
class PatientRegistrationScreenRefactored extends StatefulWidget {
  const PatientRegistrationScreenRefactored({Key? key}) : super(key: key);

  @override
  State<PatientRegistrationScreenRefactored> createState() =>
      _PatientRegistrationScreenRefactoredState();
}

class _PatientRegistrationScreenRefactoredState
    extends State<PatientRegistrationScreenRefactored> {
  final _formKey = GlobalKey<FormState>();
  final _patientService = PatientService();

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _insuranceIdController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  // Form state
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
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _insuranceIdController.dispose();
    _medicalHistoryController.dispose();
  }

  /// Handles form submission with clean, focused logic
  Future<void> _submitForm() async {
    _clearError();
    _setSubmitting(true);

    if (!_validateForm()) {
      _setSubmitting(false);
      return;
    }

    try {
      final patient = _buildPatientFromForm();
      await _patientService.registerPatient(patient);
      _handleSuccess();
    } catch (e) {
      _handleError('Failed to register patient: ${e.toString()}');
    }
  }

  /// Validates the entire form
  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      _setError('Please fill all required fields correctly');
      return false;
    }

    final dateOfBirthError = PatientValidators.validateDateOfBirth(_dateOfBirth);
    if (dateOfBirthError != null) {
      _setError(dateOfBirthError);
      return false;
    }

    if (_selectedGender == null) {
      _setError('Please select a gender');
      return false;
    }

    if (_selectedBloodType == null) {
      _setError('Please select a blood type');
      return false;
    }

    return true;
  }

  /// Builds a Patient object from form data
  Patient _buildPatientFromForm() {
    return Patient(
      name: _nameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      phone: PatientFormatters.formatPhoneNumber(_phoneController.text),
      address: _addressController.text.trim(),
      dateOfBirth: _dateOfBirth!,
      age: PatientValidators.calculateAge(_dateOfBirth!),
      gender: _selectedGender!,
      bloodType: _selectedBloodType!,
      hasInsurance: _hasInsurance,
      insuranceId: _hasInsurance ? _insuranceIdController.text.trim().toUpperCase() : null,
      emergencyContact: _emergencyContactController.text.trim(),
      hasAllergies: _hasAllergies,
      allergies: _hasAllergies ? _allergies : [],
      currentMedications: _currentMedications,
      medicalHistory: _medicalHistoryController.text.trim(),
      registrationDate: DateTime.now(),
    );
  }

  void _handleSuccess() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Patient registered successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void _handleError(String message) {
    _setError(message);
    _setSubmitting(false);
  }

  void _setSubmitting(bool value) {
    setState(() => _isSubmitting = value);
  }

  void _setError(String message) {
    setState(() => _errorMessage = message);
  }

  void _clearError() {
    setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isSubmitting ? _buildLoadingIndicator() : _buildForm(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Patient Registration'),
      backgroundColor: Colors.teal,
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) _buildErrorMessage(),
            _buildNameField(),
            const SizedBox(height: 16),
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildPhoneField(),
            const SizedBox(height: 16),
            _buildGenderDropdown(),
            const SizedBox(height: 16),
            _buildBloodTypeDropdown(),
            const SizedBox(height: 16),
            _buildInsuranceCheckbox(),
            if (_hasInsurance) ...[
              const SizedBox(height: 16),
              _buildInsuranceIdField(),
            ],
            const SizedBox(height: 16),
            _buildEmergencyContactField(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
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
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Full Name *',
        border: OutlineInputBorder(),
      ),
      validator: PatientValidators.validateName,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email *',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: PatientValidators.validateEmail,
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      decoration: const InputDecoration(
        labelText: 'Phone Number *',
        border: OutlineInputBorder(),
        hintText: '(555) 123-4567',
      ),
      keyboardType: TextInputType.phone,
      validator: PatientValidators.validatePhone,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: const InputDecoration(
        labelText: 'Gender *',
        border: OutlineInputBorder(),
      ),
      items: ['Male', 'Female', 'Other']
          .map((gender) => DropdownMenuItem(
                value: gender,
                child: Text(gender),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedGender = value),
    );
  }

  Widget _buildBloodTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodType,
      decoration: const InputDecoration(
        labelText: 'Blood Type *',
        border: OutlineInputBorder(),
      ),
      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedBloodType = value),
    );
  }

  Widget _buildInsuranceCheckbox() {
    return CheckboxListTile(
      title: const Text('Has Insurance'),
      value: _hasInsurance,
      onChanged: (value) => setState(() => _hasInsurance = value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildInsuranceIdField() {
    return TextFormField(
      controller: _insuranceIdController,
      decoration: const InputDecoration(
        labelText: 'Insurance ID *',
        border: OutlineInputBorder(),
        hintText: 'AB123456',
      ),
      validator: (value) =>
          PatientValidators.validateInsuranceId(value, _hasInsurance),
    );
  }

  Widget _buildEmergencyContactField() {
    return TextFormField(
      controller: _emergencyContactController,
      decoration: const InputDecoration(
        labelText: 'Emergency Contact *',
        border: OutlineInputBorder(),
        hintText: '(555) 123-4567',
      ),
      keyboardType: TextInputType.phone,
      validator: PatientValidators.validatePhone,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.teal,
      ),
      child: const Text(
        'Register Patient',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
