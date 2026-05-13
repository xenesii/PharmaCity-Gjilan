class User {
  String name;
  String phone;
  String email;
  String password;

  User({
    this.name = '',
    this.phone = '',
    this.email = '',
    this.password = '',
  });

  // Update user data
  void update({
    String? name,
    String? phone,
    String? email,
    String? password,
  }) {
    if (name != null) this.name = name;
    if (phone != null) this.phone = phone;
    if (email != null) this.email = email;
    if (password != null) this.password = password;
  }
}