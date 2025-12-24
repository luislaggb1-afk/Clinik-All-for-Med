/// Patient model to encapsulate patient data
class Patient {
  final String name;
  final String email;
  final String phone;
  final String address;
  final DateTime dateOfBirth;
  final int age;
  final String gender;
  final String bloodType;
  final bool hasInsurance;
  final String? insuranceId;
  final String emergencyContact;
  final bool hasAllergies;
  final List<String> allergies;
  final List<String> currentMedications;
  final String medicalHistory;
  final DateTime registrationDate;

  Patient({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.dateOfBirth,
    required this.age,
    required this.gender,
    required this.bloodType,
    required this.hasInsurance,
    this.insuranceId,
    required this.emergencyContact,
    required this.hasAllergies,
    required this.allergies,
    required this.currentMedications,
    required this.medicalHistory,
    required this.registrationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'age': age,
      'gender': gender,
      'bloodType': bloodType,
      'hasInsurance': hasInsurance,
      'insuranceId': insuranceId,
      'emergencyContact': emergencyContact,
      'hasAllergies': hasAllergies,
      'allergies': allergies,
      'currentMedications': currentMedications,
      'medicalHistory': medicalHistory,
      'registrationDate': registrationDate.toIso8601String(),
    };
  }
}
