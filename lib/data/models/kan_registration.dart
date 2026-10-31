/// Request contract from auth/register-value in kanoct3.postman_collection.json.
/// Passwords belong only to the request and are never copied into AppUser.
class KanRegistration {
  const KanRegistration({
    required this.username,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.password,
    required this.dateOfBirth,
    required this.genderValue,
    required this.genderLabel,
    required this.branchValue,
    required this.branchLabel,
  });
  final String username, firstName, middleName, lastName, email, mobile;
  final String password, dateOfBirth, genderLabel, branchLabel;
  final int genderValue, branchValue;

  String get fullName =>
      [firstName, middleName, lastName].where((s) => s.isNotEmpty).join(' ');

  Map<String, Object?> toJson() => {
        'username': username,
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'email': email,
        'mobno': mobile,
        'password': password,
        'dateofbirth': dateOfBirth,
        'gender': {'value': genderValue, 'label': genderLabel},
        'status': null,
        'usertype': null,
        'branch': {'value': branchValue, 'label': branchLabel},
      };
}
