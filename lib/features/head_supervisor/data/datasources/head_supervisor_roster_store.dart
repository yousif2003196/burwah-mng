import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_api_data_source.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_record.dart';

/// قائمة المشرفين.
///
/// عند دخول رئيس المشرفين (أو الأدمن) بحساب السيرفر تُقرأ القائمة من
/// `api/BossOfSupervisor/supervisors` (القسم = دور الحساب)، وتُدمج معها
/// التفاصيل المحلية التي لا يحفظها السيرفر (سبب التعليق ونطاق السوق). بدون
/// جلسة سيرفر تعمل القائمة المحلية كما هي.
class HeadSupervisorRosterStore {
  HeadSupervisorRosterStore({HeadSupervisorApiDataSource? api}) : _api = api;

  final HeadSupervisorApiDataSource? _api;

  HeadSupervisorApiDataSource? get _remote {
    if (!HeadSupervisorApiDataSource.canUse) return null;
    if (_api != null) return _api;
    return sl.isRegistered<HeadSupervisorApiDataSource>()
        ? sl<HeadSupervisorApiDataSource>()
        : null;
  }

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
    final remote = _remote;
    if (remote != null) return _getRemote(remote);
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

  Future<List<HeadSupervisorRecord>> _getRemote(
    HeadSupervisorApiDataSource remote,
  ) async {
    final server = await remote.getSupervisors();
    final cached = {
      for (final record in await _readCache()) record.id: record,
    };
    final merged = [
      for (final record in server) _merge(record, cached[record.id]),
    ];
    // نسخة محلية بدون رفع revision حتى لا تتكرر إعادة التحميل.
    await _writeCache(merged);
    return merged;
  }

  /// القسم والنطاق والتعليق وطلب الحذف من السيرفر؛ سبب التعليق وتفاصيل
  /// طلب الحذف ونطاق السوق من آخر نسخة محلية.
  static HeadSupervisorRecord _merge(
    HeadSupervisorRecord server,
    HeadSupervisorRecord? local,
  ) {
    if (local == null) return server;
    return HeadSupervisorRecord(
      id: server.id,
      name: server.name,
      department: server.department,
      status: server.status,
      metric: local.metric,
      score: local.score,
      avatar: server.avatar,
      color: server.color,
      suspended: server.suspended,
      email: server.email.isEmpty ? local.email : server.email,
      phone: server.phone.isEmpty ? local.phone : server.phone,
      reviewAds: local.reviewAds,
      hideAds: local.hideAds,
      suspensionDuration: server.suspended ? local.suspensionDuration : '',
      suspensionReason: server.suspended ? local.suspensionReason : '',
      deletionPending: server.deletionPending,
      deletionRequestId: server.deletionPending ? local.deletionRequestId : '',
      deletionReason: server.deletionPending ? local.deletionReason : '',
      deletionNotes: server.deletionPending ? local.deletionNotes : '',
      area: server.area,
      city: server.city,
      marketScope: local.marketScope,
      accountId: server.accountId,
    );
  }

  Future<List<HeadSupervisorRecord>> _readCache() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return const [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) return const [];
    return [
      for (final value in decoded)
        if (value is Map<String, dynamic>) HeadSupervisorRecord.fromJson(value),
    ];
  }

  Future<void> _writeCache(List<HeadSupervisorRecord> supervisors) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(supervisors.map((supervisor) => supervisor.toJson()).toList()),
    );
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
