class InterestSubmission {
  final String id;
  final String propertyId;
  final String propertyName;
  final String name;
  final String mobile;
  final String email;
  final String message;
  final DateTime submittedAt;

  const InterestSubmission({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.name,
    required this.mobile,
    required this.email,
    required this.message,
    required this.submittedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterestSubmission &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
