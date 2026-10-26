import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_record.dart';

class HeadSupervisorRosterStore {
  static const _storageKey = 'head_supervisor_roster_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static const defaultRoster = <HeadSupervisorRecord>[
    HeadSupervisorRecord(
      id: '#SUP-409', name: 'سعد العتيبي', department: 'قسم التجار والمتاجر المعتمدة', status: 'نشط ميدانياً', metric: '85 فحص مواصفات', score: '4.9 تقييم الرقابة الميدانية', avatar: 'سع', color: AppPalette.green537A61, accountId: 'merchant',
    ),
    HeadSupervisorRecord(
      id: '#SUP-302', name: 'مازن الشهري', department: 'قسم المنتجات الجديدة', status: 'نشط ميدانياً', metric: '85 فحص مواصفات', score: '4.9 تقييم الرقابة الميدانية', avatar: 'مش', color: AppPalette.orange806747, accountId: 'products',
    ),
    HeadSupervisorRecord(
      id: '#SUP-215', name: 'خالد الدوسري', department: 'قسم المستعمل وخدمة وصلي', status: 'معلق مؤقتاً', metric: 'إجازة رسمية مجدولة', score: '', avatar: 'خد', color: AppPalette.amber8A8370, suspended: true, accountId: 'wasalny',
    ),
    HeadSupervisorRecord(
      id: '#SUP-108', name: 'م. فهد الزهراني', department: 'قسم طلبات الخدمات الميدانية والصيانة', status: 'نشط ميدانياً', metric: '48 إسناد فني', score: 'استجابة: 11 دقيقة', avatar: 'فز', color: AppPalette.blue425B76, accountId: 'services',
    ),
  ];

  Future<List<HeadSupervisorRecord>> getAll() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) {
      await saveAll(defaultRoster);
      return defaultRoster;
    }
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid head supervisor roster.');
    }
    final records = decoded.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid supervisor roster entry.');
      }
      return HeadSupervisorRecord.fromJson(value);
    }).toList();
    if (records.isEmpty) {
      await saveAll(defaultRoster);
      return defaultRoster;
    }
    return records;
  }

  Future<List<HeadSupervisorRecord>> getActive() async =>
      (await getAll())
          .where((supervisor) =>
              !supervisor.suspended && !supervisor.deletionPending)
          .toList();

  Future<void> saveAll(List<HeadSupervisorRecord> supervisors) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(supervisors.map((supervisor) => supervisor.toJson()).toList()),
    );
    if (!saved) throw StateError('Could not save the head supervisor roster.');
    revision.value++;
  }
}
