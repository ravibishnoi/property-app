class AppUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'user' | 'owner'

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isOwner => role == 'owner';
  bool get isUser => role == 'user';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
