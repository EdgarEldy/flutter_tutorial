/// Authenticated user returned by the backend after sign-in or profile fetch.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class User {
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.enabled,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final bool enabled;
}
