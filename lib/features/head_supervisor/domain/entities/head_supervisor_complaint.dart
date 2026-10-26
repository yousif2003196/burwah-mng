import 'package:flutter/material.dart';

class HeadSupervisorComplaintAction {
  final String title;
  final String detail;
  final int iconCodePoint;
  final bool summon;
  final bool unblockInvestigation;

  const HeadSupervisorComplaintAction({
    required this.title,
    required this.detail,
    required this.iconCodePoint,
    this.summon = false,
    this.unblockInvestigation = false,
  });

  // ignore: non_const_argument_for_const_parameter
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Map<String, Object?> toJson() => {
        'title': title,
        'detail': detail,
        'iconCodePoint': iconCodePoint,
        'summon': summon,
        'unblockInvestigation': unblockInvestigation,
      };

  factory HeadSupervisorComplaintAction.fromJson(Map<String, dynamic> json) =>
      HeadSupervisorComplaintAction(
        title: json['title'] as String,
        detail: json['detail'] as String,
        iconCodePoint: (json['iconCodePoint'] as num).toInt(),
        summon: json['summon'] as bool? ?? false,
        unblockInvestigation: json['unblockInvestigation'] as bool? ?? false,
      );
}

class HeadSupervisorComplaint {
  final String id;
  final String status;
  final String statusLabel;
  final String title;
  final String description;
  final String merchant;
  final String merchantCode;
  final String supervisor;
  final String supervisorCode;
  final String department;
  final String recipient;
  final String evidence;
  final String urgency;
  final bool warning;
  final DateTime createdAt;
  final List<HeadSupervisorComplaintAction> actions;
  final bool reopenedForReview;
  final String assignedSupervisorId;
  final String assignedSupervisorName;

  const HeadSupervisorComplaint({
    required this.id,
    required this.status,
    required this.statusLabel,
    required this.title,
    required this.description,
    required this.merchant,
    required this.merchantCode,
    required this.supervisor,
    required this.supervisorCode,
    required this.department,
    required this.recipient,
    required this.evidence,
    required this.urgency,
    required this.warning,
    required this.createdAt,
    required this.actions,
    this.reopenedForReview = false,
    this.assignedSupervisorId = '',
    this.assignedSupervisorName = '',
  });

  HeadSupervisorComplaint copyWith({
    String? statusLabel,
    bool? reopenedForReview,
    String? assignedSupervisorId,
    String? assignedSupervisorName,
  }) =>
      HeadSupervisorComplaint(
        id: id,
        status: status,
        statusLabel: statusLabel ?? this.statusLabel,
        title: title,
        description: description,
        merchant: merchant,
        merchantCode: merchantCode,
        supervisor: supervisor,
        supervisorCode: supervisorCode,
        department: department,
        recipient: recipient,
        evidence: evidence,
        urgency: urgency,
        warning: warning,
        createdAt: createdAt,
        actions: actions,
        reopenedForReview: reopenedForReview ?? this.reopenedForReview,
        assignedSupervisorId: assignedSupervisorId ?? this.assignedSupervisorId,
        assignedSupervisorName: assignedSupervisorName ?? this.assignedSupervisorName,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'status': status,
        'statusLabel': statusLabel,
        'title': title,
        'description': description,
        'merchant': merchant,
        'merchantCode': merchantCode,
        'supervisor': supervisor,
        'supervisorCode': supervisorCode,
        'department': department,
        'recipient': recipient,
        'evidence': evidence,
        'urgency': urgency,
        'warning': warning,
        'createdAt': createdAt.toIso8601String(),
        'actions': actions.map((action) => action.toJson()).toList(),
        'reopenedForReview': reopenedForReview,
        'assignedSupervisorId': assignedSupervisorId,
        'assignedSupervisorName': assignedSupervisorName,
      };

  factory HeadSupervisorComplaint.fromJson(Map<String, dynamic> json) {
    final actions = json['actions'];
    if (actions is! List<dynamic>) {
      throw const FormatException('Invalid head supervisor complaint actions.');
    }
    return HeadSupervisorComplaint(
      id: json['id'] as String,
      status: json['status'] as String,
      statusLabel: json['statusLabel'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      merchant: json['merchant'] as String,
      merchantCode: json['merchantCode'] as String,
      supervisor: json['supervisor'] as String,
      supervisorCode: json['supervisorCode'] as String,
      department: json['department'] as String,
      recipient: json['recipient'] as String,
      evidence: json['evidence'] as String,
      urgency: json['urgency'] as String,
      warning: json['warning'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      actions: actions.map((value) {
        if (value is! Map<String, dynamic>) {
          throw const FormatException('Invalid head supervisor complaint action.');
        }
        return HeadSupervisorComplaintAction.fromJson(value);
      }).toList(),
      reopenedForReview: json['reopenedForReview'] as bool? ?? false,
      assignedSupervisorId: json['assignedSupervisorId'] as String? ?? '',
      assignedSupervisorName: json['assignedSupervisorName'] as String? ?? '',
    );
  }
}
