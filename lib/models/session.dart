class Session {
  final String email;
  final List<String> roles;

  const Session({required this.email, required this.roles});

  bool get isAdmin => roles.contains('Admin');
}
