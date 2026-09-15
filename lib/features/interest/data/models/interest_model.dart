import '../../domain/entities/interest_submission.dart';

class InterestModel {
  final String id;
  final String propertyId;
  final String propertyName;
  final String name;
  final String mobile;
  final String email;
  final String message;
  final String submittedAt;

  const InterestModel({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.name,
    required this.mobile,
    required this.email,
    required this.message,
    required this.submittedAt,
  });

  factory InterestModel.fromMap(Map<dynamic, dynamic> map) {
    return InterestModel(
      id: map['id']?.toString() ?? '',
      propertyId: map['propertyId']?.toString() ?? '',
      propertyName: map['propertyName']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      mobile: map['mobile']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      submittedAt: map['submittedAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'propertyName': propertyName,
      'name': name,
      'mobile': mobile,
      'email': email,
      'message': message,
      'submittedAt': submittedAt,
    };
  }

  InterestSubmission toEntity() {
    return InterestSubmission(
      id: id,
      propertyId: propertyId,
      propertyName: propertyName,
      name: name,
      mobile: mobile,
      email: email,
      message: message,
      submittedAt: DateTime.tryParse(submittedAt) ?? DateTime.now(),
    );
  }
}
