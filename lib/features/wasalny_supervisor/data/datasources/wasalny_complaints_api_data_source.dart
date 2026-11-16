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

  @override
  Future<List<WasalnyComplaintModel>> getComplaints() async {
    final response = await apiConsumer.get<Object>(
      ApiEndpoints.usedComplaints,
      queryParameters: {'page': 1, 'pageSize': 100},
    );
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    if (data is! List) {
      throw const FormatException('The complaints response must hold a list.');
    }
    return [
      for (final row in data)
        if (row is Map<String, dynamic>) _fromRow(row),
    ];
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
    final created =
        DateTime.tryParse(_text(row['createdAt']))?.toLocal() ?? DateTime.now();
    final price = (row['itemPrice'] as num?)?.toDouble() ?? 0;
    final escalated = row['escalated'] == true;
    final closed = _text(row['status']) == 'Closed';
    final note = escalated
        ? _text(row['escalationReason'])
        : _text(row['resolutionNote']);
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
      status: closed
          ? WasalnyComplaintStatus.resolved
          : escalated
          ? WasalnyComplaintStatus.escalatedToChief
          : WasalnyComplaintStatus.underReview,
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
