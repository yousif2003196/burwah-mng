/// كائن `data` في رد تسجيل الدخول، ويُحفظ بنفس الشكل لاستعادة الجلسة.
class SessionUserModel {
  const SessionUserModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    this.lastLogin,
  });

  final String userId;
  final String email;
  final String name;

  /// دور الباك إند كما وصل (مثل `SupervisorForAd`).
  final String role;
  final DateTime? lastLogin;

  factory SessionUserModel.fromJson(Map<String, dynamic> json) {
    return SessionUserModel(
      userId: '${json['userId'] ?? ''}',
      email: '${json['email'] ?? ''}'.trim(),
      name: '${json['name'] ?? ''}'.trim(),
      role: '${json['role'] ?? ''}',
      lastLogin: DateTime.tryParse('${json['lastLogin'] ?? ''}'),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'name': name,
        'role': role,
        'lastLogin': lastLogin?.toIso8601String(),
      };
}
