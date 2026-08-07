/// From SampleTrackerAPIs' UserAccountController.ListUsers, which projects
/// only { id, userName, email } off the ASP.NET Identity user.
class AppUser {
  final String id;
  final String userName;
  final String? email;

  const AppUser({required this.id, required this.userName, this.email});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      userName: json['userName'] as String? ?? '',
      email: json['email'] as String?,
    );
  }
}
