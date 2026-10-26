import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barwah_app/core/network/api_configuration.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_complaints_api_data_source.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';

void main() {
  group('WasalnyComplaintsApiDataSource', () {
    test('loads complaints from the documented API contract', () async {
      final adapter = _FakeAdapter([
        {
          'data': [_complaintJson()],
        },
      ]);
      final source = _createSource(adapter);

      final complaints = await source.getComplaints();

      expect(complaints, hasLength(1));
      expect(complaints.single.id, 'WS-CMP-4088');
      expect(complaints.single.status, WasalnyComplaintStatus.underReview);
      expect(
        adapter.requests.single.uri.path,
        '/api/v1/supervisor/wasalny/complaints',
      );
      expect(adapter.requests.single.method, 'GET');
    });

    test('posts mutation details and returns the updated complaint', () async {
      final adapter = _FakeAdapter([
        {'data': _complaintJson(status: 'escalated_to_chief')},
      ]);
      final source = _createSource(adapter);

      final complaint = await source.escalateComplaint(
        'WS-CMP/4088',
        reason: 'Needs central review',
      );

      expect(complaint.status, WasalnyComplaintStatus.escalatedToChief);
      expect(
        adapter.requests.single.uri.path,
        '/api/v1/supervisor/wasalny/complaints/WS-CMP%2F4088/escalation',
      );
      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.data, {'reason': 'Needs central review'});
    });

    test('posts resolution and inspection notes to their dedicated actions',
        () async {
      final adapter = _FakeAdapter([
        {'data': _complaintJson(status: 'resolved')},
        {'data': _complaintJson()},
      ]);
      final source = _createSource(adapter);

      final resolved = await source.resolveComplaint(
        'WS-CMP-4088',
        note: 'Refund issued',
      );
      final inspected = await source.inspectComplaint(
        'WS-CMP-4088',
        notes: 'Serial number verified',
      );

      expect(resolved.status, WasalnyComplaintStatus.resolved);
      expect(inspected.id, 'WS-CMP-4088');
      expect(
        adapter.requests.map((request) => request.uri.path),
        [
          '/api/v1/supervisor/wasalny/complaints/WS-CMP-4088/resolution',
          '/api/v1/supervisor/wasalny/complaints/WS-CMP-4088/inspection',
        ],
      );
      expect(adapter.requests[0].data, {'note': 'Refund issued'});
      expect(adapter.requests[1].data, {'notes': 'Serial number verified'});
    });

    test('rejects malformed response shapes rather than returning empty data',
        () async {
      final source = _createSource(_FakeAdapter([
        {'data': 'not a complaint list'},
      ]));

      await expectLater(source.getComplaints(), throwsFormatException);
    });

    test('adds a bearer token when an access token provider is configured',
        () async {
      final adapter = _FakeAdapter([
        {'data': <Object>[]},
      ]);
      final source = WasalnyComplaintsApiDataSource(
        apiConsumer: ApiConsumer(
          baseUrl: 'https://api.example.test/',
          accessTokenProvider: () async => 'supervisor-token',
          dio: Dio(BaseOptions(baseUrl: 'https://api.example.test/'))
            ..httpClientAdapter = adapter,
        ),
      );

      await source.getComplaints();

      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer supervisor-token',
      );
    });
  });

  group('ApiConfiguration', () {
    test('requires a valid URL when mock data is disabled', () {
      expect(
        () =>
            const ApiConfiguration(baseUrl: '', useMockData: false).validate(),
        throwsStateError,
      );
      expect(
        () => const ApiConfiguration(
          baseUrl: 'https://api.example.test',
          useMockData: false,
        ).validate(),
        returnsNormally,
      );
    });

    test('rejects URLs containing credentials or query parameters', () {
      expect(
        () => const ApiConfiguration(
          baseUrl: 'https://admin:password@api.example.test',
          useMockData: false,
        ).validate(),
        throwsStateError,
      );
      expect(
        () => const ApiConfiguration(
          baseUrl: 'https://api.example.test?token=secret',
          useMockData: false,
        ).validate(),
        throwsStateError,
      );
    });
  });
}

WasalnyComplaintsApiDataSource _createSource(_FakeAdapter adapter) {
  return WasalnyComplaintsApiDataSource(
    apiConsumer: ApiConsumer(
      baseUrl: 'https://api.example.test/',
      dio: Dio(BaseOptions(baseUrl: 'https://api.example.test/'))
        ..httpClientAdapter = adapter,
    ),
  );
}

Map<String, Object?> _complaintJson({String status = 'under_review'}) => {
      'id': 'WS-CMP-4088',
      'titleAr': 'شكوى تجريبية',
      'titleEn': 'Sample complaint',
      'descriptionAr': 'تفاصيل الشكوى',
      'descriptionEn': 'Complaint details',
      'timeAgoAr': 'منذ دقائق',
      'timeAgoEn': 'A few minutes ago',
      'status': status,
      'itemTitleAr': 'منتج',
      'itemTitleEn': 'Product',
    };

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._responses);

  final List<Object?> _responses;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (_responses.isEmpty) {
      throw StateError('No fake response was queued.');
    }
    final response = _responses.removeAt(0);
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
