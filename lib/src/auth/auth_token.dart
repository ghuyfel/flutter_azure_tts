///Holds values of the token used for authentication
class AuthToken {
  AuthToken({required this.token});

  final String token;
  final expiryDate = DateTime.now().add(Duration(minutes: 8));

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  @override
  String toString() {
    final map = Map<String, String>();
    map['expiry_date'] = expiryDate.toString();
    map['token'] = token;
    return map.toString();
  }
}
