import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:share_plus/share_plus.dart';

/// Builds a UTF-8 (with BOM, so Excel reads Arabic correctly) CSV file and
/// hands it to the system share sheet.
class CsvExporter {
  const CsvExporter._();

  static String escape(String value) {
    final needsQuotes = value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    final safe = value.replaceAll('"', '""');
    return needsQuotes ? '"$safe"' : safe;
  }

  static String build(List<String> headers, List<List<String>> rows) {
    final buffer = StringBuffer()..writeln(headers.map(escape).join(','));
    for (final row in rows) {
      buffer.writeln(row.map(escape).join(','));
    }
    return buffer.toString();
  }

  static Uint8List encode(String csv) =>
      Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]);

  /// Returns false when the user dismissed the share sheet.
  static Future<bool> share({
    required String fileName,
    required List<String> headers,
    required List<List<String>> rows,
    String? title,
    Rect? sharePositionOrigin,
  }) async {
    final bytes = encode(build(headers, rows));
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: 'text/csv')],
        fileNameOverrides: [fileName],
        text: title,
        subject: title,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
    return result.status != ShareResultStatus.dismissed;
  }

  static String stamp([DateTime? now]) {
    final t = now ?? DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}${two(t.month)}${two(t.day)}_${two(t.hour)}${two(t.minute)}';
  }
}
