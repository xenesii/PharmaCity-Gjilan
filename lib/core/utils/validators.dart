class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email-i është i detyrueshëm';
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Ju lutem shkruani një email valid';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Fjalëkalimi është i detyrueshëm';
    if (value.length < 6) return 'Fjalëkalimi duhet të ketë të paktën 6 karaktere';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Ju lutem konfirmoni fjalëkalimin';
    if (value != password) return 'Fjalëkalimet nuk përputhen';
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Emri i plotë është i detyrueshëm';
    if (value.trim().length < 2) return 'Emri duhet të ketë të paktën 2 karaktere';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Numri i telefonit është i detyrueshëm';
    final phoneRegex = RegExp(r'^[\+0-9\s\-]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) return 'Ju lutem shkruani një numër telefoni valid';
    return null;
  }

  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) return 'Adresa është e detyrueshme';
    if (value.trim().length < 5) return 'Ju lutem shkruani një adresë të plotë';
    return null;
  }

  static String? required(String? value, [String field = 'Kjo fushë']) {
    if (value == null || value.trim().isEmpty) return '$field është e detyrueshme';
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vlera është e detyrueshme';
    final num? n = double.tryParse(value);
    if (n == null || n <= 0) return 'Duhet të jetë një numër pozitiv';
    return null;
  }
}
