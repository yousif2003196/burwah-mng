/// محاولة دخول إلى حساب الأدمن (ناجحة أو فاشلة).
class AdminLoginAttempt {
  final String email;
  final bool success;
  final String note;
  final DateTime at;

  const AdminLoginAttempt({
    required this.email,
    required this.success,
    required this.note,
    required this.at,
  });

  Map<String, Object?> toJson() => {
        'email': email,
        'success': success,
        'note': note,
        'at': at.toIso8601String(),
      };

  factory AdminLoginAttempt.fromJson(Map<String, dynamic> json) =>
      AdminLoginAttempt(
        email: json['email'] as String? ?? '',
        success: json['success'] as bool? ?? false,
        note: json['note'] as String? ?? '',
        at: DateTime.tryParse(json['at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}
