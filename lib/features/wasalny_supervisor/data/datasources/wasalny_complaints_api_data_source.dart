import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_complaints_data_source.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/models/wasalny_complaint_model.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';

/// شكاوى وصلني من السيرفر (`api/SupervisorUsed/complaints`): الشكاوى هي تذاكر
/// المستخدمين على المنتجات المستعملة. التصعيد للرئيس والحل بيتسجلوا في السيرفر.
class WasalnyComplaintsApiDataSource implements WasalnyComplaintsDataSource {
  WasalnyComplaintsApiDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  static const _pageSize = 100;
  static const _maxPages = 10;

  /// كل الشكاوى صفحة ورا صفحة (مش أول 100 بس).
  @override
  Future<List<WasalnyComplaintModel>> getComplaints() async {
    final result = <WasalnyComplaintModel>[];
    for (var page = 1; page <= _maxPages; page++) {
      final response = await apiConsumer.get<Object>(
        ApiEndpoints.usedComplaints,
        queryParameters: {'page': page, 'pageSize': _pageSize},
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! List) {
        throw const FormatException('The complaints response must hold a list.');
      }
      for (final row in data) {
        if (row is Map<String, dynamic>) result.add(_fromRow(row));
      }
      if (data.length < _pageSize) break;
    }
    return result;
  }

  @override
  Future<WasalnyComplaintModel> escalateComplaint(
    String id, {
    required String reason,
  }) => _act(
    id,
    ApiEndpoints.usedComplaintEscalate(_number(id)),
    {'reason': reason},
  );

  @override
  Future<WasalnyComplaintModel> resolveComplaint(
    String id, {
    required String note,
  }) => _act(
    id,
    ApiEndpoints.usedComplaintResolve(_number(id)),
    {'reason': note},
  );

  @override
  Future<WasalnyComplaintModel> inspectComplaint(
    String id, {
    required String notes,
  }) => _act(
    id,
    ApiEndpoints.usedComplaintFollowUp(_number(id)),
    {'notes': notes},
  );

  Future<WasalnyComplaintModel> _act(
    String id,
    String path,
    Map<String, String> payload,
  ) async {
    await apiConsumer.post<Object>(path, data: payload);
    final complaints = await getComplaints();
    return complaints.firstWhere(
      (c) => c.id == id,
      orElse: () => throw StateError('Complaint $id not found after update.'),
    );
  }

  static int _number(String id) {
    final value = int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), ''));
    if (value == null) throw ArgumentError.value(id, 'id', 'Not a complaint id.');
    return value;
  }

  static String _text(Object? value) => value == null ? '' : '$value';

  static WasalnyComplaintModel _fromRow(Map<String, dynamic> row) {
    final id = _text(row['number']).isNotEmpty
        ? _text(row['number'])
        : 'CMP-${row['id']}';
    final title = _text(row['title']).isNotEmpty ? _text(row['title']) : id;
    final description = _text(row['description']);
    final item = _text(row['itemTitle']);
    final created = _utc(row['createdAt']) ?? DateTime.now();
    final price = (row['itemPrice'] as num?)?.toDouble() ?? 0;
    final escalated = row['escalated'] == true;
    final closed = _text(row['status']) == 'Closed';
    // قرار رئيس المشرفين على آخر تصعيد: returned / resolved / admin.
    final headDecision = _text(row['headDecision']);
    final headNote = _text(row['headNote']);
    final String note;
    if (headDecision.isNotEmpty && headNote.isNotEmpty) {
      note = 'رد رئيس المشرفين: $headNote';
    } else if (escalated) {
      note = _text(row['escalationReason']);
    } else {
      note = _text(row['resolutionNote']);
    }
    final status = closed
        ? WasalnyComplaintStatus.resolved
        : headDecision == 'admin'
        ? WasalnyComplaintStatus.escalatedToAdmin
        : escalated
        ? WasalnyComplaintStatus.escalatedToChief
        : headDecision == 'returned'
        ? WasalnyComplaintStatus.returnedByHead
        : WasalnyComplaintStatus.underReview;
    final buyer = _text(row['buyerName']);
    final seller = _text(row['sellerName']);
    return WasalnyComplaintModel(
      id: id,
      titleAr: title,
      titleEn: title,
      descriptionAr: description.isEmpty ? title : description,
      descriptionEn: description.isEmpty ? title : description,
      timeAgoAr: _ago(created, true),
      timeAgoEn: _ago(created, false),
      status: status,
      dealCode: id,
      itemTitleAr: item.isEmpty ? title : item,
      itemTitleEn: item.isEmpty ? title : item,
      heldAmount: price > 0
          ? price.toStringAsFixed(price % 1 == 0 ? 0 : 2)
          : null,
      buyerNameAr: buyer.isEmpty ? null : buyer,
      buyerNameEn: buyer.isEmpty ? null : buyer,
      sellerNameAr: seller.isEmpty ? null : seller,
      sellerNameEn: seller.isEmpty ? null : seller,
      actionNoteAr: note.isEmpty ? null : note,
      actionNoteEn: note.isEmpty ? null : note,
      sellerPhone: _text(row['sellerPhone']),
      buyerPhone: _text(row['buyerPhone']),
    );
  }

  /// تواريخ السيرفر UTC من غير "Z".
  static DateTime? _utc(Object? raw) {
    final text = raw == null ? '' : '$raw'.trim();
    if (text.isEmpty || text == 'null') return null;
    final hasZone = text.endsWith('Z') || RegExp(r'[+-]\d\d:?\d\d$').hasMatch(text);
    return DateTime.tryParse(hasZone ? text : '${text}Z')?.toLocal();
  }

  static String _ago(DateTime at, bool ar) {
    final span = DateTime.now().difference(at);
    if (span.inMinutes < 1) return ar ? 'الآن' : 'Just now';
    if (span.inMinutes < 60) {
      return ar ? 'منذ ${span.inMinutes} دقيقة' : '${span.inMinutes} min ago';
    }
    if (span.inHours < 24) {
      return ar ? 'منذ ${span.inHours} ساعة' : '${span.inHours} h ago';
    }
    return ar ? 'منذ ${span.inDays} يوم' : '${span.inDays} d ago';
  }
}
