import 'package:flutter/material.dart';

/// COMPLEX VERSION - This screen has multiple code smells:
/// 1. God class - too many responsibilities
/// 2. Long methods with nested conditionals
/// 3. Mixed concerns (validation, formatting, business logic, UI)
/// 4. Hard to test and maintain
class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<PatientRegistrationScreen> createState() => _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
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

  // OVERLY COMPLEX METHOD - Multiple responsibilities and nested logic
  Future<void> _submitForm() async {
    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    if (_formKey.currentState!.validate()) {
      // Validate name
      String name = _nameController.text.trim();
      if (name.isEmpty || name.length < 2 || !RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
        setState(() {
          _errorMessage = 'Invalid name format';
          _isSubmitting = false;
        });
        return;
      }

      // Validate email
      String email = _emailController.text.trim();
      if (!email.contains('@') || !email.contains('.') || email.length < 5) {
        setState(() {
          _errorMessage = 'Invalid email format';
          _isSubmitting = false;
        });
        return;
      }

      // Validate phone with complex formatting logic
      String phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      if (phone.length != 10 && phone.length != 11) {
        setState(() {
          _errorMessage = 'Phone must be 10 or 11 digits';
          _isSubmitting = false;
        });
        return;
      }
      String formattedPhone;
      if (phone.length == 10) {
        formattedPhone = '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6)}';
      } else {
        formattedPhone = '+${phone.substring(0, 1)} (${phone.substring(1, 4)}) ${phone.substring(4, 7)}-${phone.substring(7)}';
      }

      // Validate date of birth with complex age calculation
      if (_dateOfBirth == null) {
        setState(() {
          _errorMessage = 'Date of birth is required';
          _isSubmitting = false;
        });
        return;
      }
      DateTime now = DateTime.now();
      int age = now.year - _dateOfBirth!.year;
      if (now.month < _dateOfBirth!.month || (now.month == _dateOfBirth!.month && now.day < _dateOfBirth!.day)) {
        age--;
      }
      if (age < 0 || age > 150) {
        setState(() {
          _errorMessage = 'Invalid date of birth';
          _isSubmitting = false;
        });
        return;
      }

      // Validate gender and blood type
      if (_selectedGender == null || _selectedGender!.isEmpty) {
        setState(() {
          _errorMessage = 'Please select a gender';
          _isSubmitting = false;
        });
        return;
      }
      if (_selectedBloodType == null || _selectedBloodType!.isEmpty) {
        setState(() {
          _errorMessage = 'Please select a blood type';
          _isSubmitting = false;
        });
        return;
      }

      // Complex insurance validation
      if (_hasInsurance) {
        String insuranceId = _insuranceIdController.text.trim();
        if (insuranceId.isEmpty || insuranceId.length < 5) {
          setState(() {
            _errorMessage = 'Insurance ID must be at least 5 characters';
            _isSubmitting = false;
          });
          return;
        }
        // Validate insurance ID format (complex pattern)
        if (!RegExp(r'^[A-Z]{2}\d{6,10}$').hasMatch(insuranceId.toUpperCase())) {
          setState(() {
            _errorMessage = 'Invalid insurance ID format (e.g., AB123456)';
            _isSubmitting = false;
          });
          return;
        }
      }

      // Complex emergency contact validation
      String emergencyContact = _emergencyContactController.text.trim();
      if (emergencyContact.isNotEmpty) {
        String emergencyPhone = emergencyContact.replaceAll(RegExp(r'[^\d]'), '');
        if (emergencyPhone.length != 10 && emergencyPhone.length != 11) {
          setState(() {
            _errorMessage = 'Emergency contact must be 10 or 11 digits';
            _isSubmitting = false;
          });
          return;
        }
      } else {
        setState(() {
          _errorMessage = 'Emergency contact is required';
          _isSubmitting = false;
        });
        return;
      }

      // Simulate API call with complex error handling
      try {
        await Future.delayed(const Duration(seconds: 2));

        // Complex business logic for patient record creation
        Map<String, dynamic> patientData = {
          'name': name,
          'email': email.toLowerCase(),
          'phone': formattedPhone,
          'address': _addressController.text.trim(),
          'dateOfBirth': _dateOfBirth!.toIso8601String(),
          'age': age,
          'gender': _selectedGender,
          'bloodType': _selectedBloodType,
          'hasInsurance': _hasInsurance,
          'insuranceId': _hasInsurance ? _insuranceIdController.text.trim().toUpperCase() : null,
          'emergencyContact': emergencyContact,
          'hasAllergies': _hasAllergies,
          'allergies': _hasAllergies ? _allergies : [],
          'currentMedications': _currentMedications,
          'medicalHistory': _medicalHistoryController.text.trim(),
          'registrationDate': DateTime.now().toIso8601String(),
        };

        print('Patient registered: $patientData');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient registered successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to register patient: ${e.toString()}';
          _isSubmitting = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Please fill all required fields';
        _isSubmitting = false;
      });
    }
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
