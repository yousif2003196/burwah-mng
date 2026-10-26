import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class FinanceProfileReportExporter {
  const FinanceProfileReportExporter._();

  static Future<bool> shareExcel({
    required List<List<String>> rows,
    required String fileName,
    required String shareText,
    Rect? sharePositionOrigin,
  }) async {
    final workbook = Excel.createExcel();
    final sheetName = workbook.getDefaultSheet() ?? 'Sheet1';
    final sheet = workbook[sheetName];
    for (final row in rows) {
      sheet.appendRow(row.map(TextCellValue.new).toList());
    }

    final bytes = workbook.encode();
    if (bytes == null || bytes.isEmpty) {
      throw StateError('The finance report could not be generated.');
    }

    final result = await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(bytes),
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
        fileNameOverrides: [fileName],
        text: shareText,
        subject: shareText,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
    return result.status != ShareResultStatus.dismissed;
  }

  static Future<bool> printPdf({
    required String fileName,
    required String title,
    required List<List<String>> rows,
  }) async {
    if (rows.length < 2) {
      throw StateError('No approved finance operations are available.');
    }

    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 19,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated: ${DateTime.now().toUtc().toIso8601String()}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.blueGrey200),
            children: [
              for (var rowIndex = 0; rowIndex < rows.length; rowIndex++)
                pw.TableRow(
                  decoration: rowIndex == 0
                      ? const pw.BoxDecoration(color: PdfColors.blueGrey800)
                      : null,
                  children: [
                    for (final value in rows[rowIndex])
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(7),
                        child: pw.Text(
                          value,
                          style: pw.TextStyle(
                            fontSize: rowIndex == 0 ? 9 : 8,
                            fontWeight: rowIndex == 0
                                ? pw.FontWeight.bold
                                : pw.FontWeight.normal,
                            color: rowIndex == 0
                                ? PdfColors.white
                                : PdfColors.blueGrey900,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );

    return Printing.layoutPdf(
      name: fileName,
      onLayout: (_) => document.save(),
    );
  }
}
