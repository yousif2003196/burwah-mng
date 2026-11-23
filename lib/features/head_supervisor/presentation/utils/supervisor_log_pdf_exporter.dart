import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// سطر واحد في تقرير سجل المشرف.
class SupervisorLogPdfRow {
  const SupervisorLogPdfRow({
    required this.time,
    required this.category,
    required this.title,
    required this.details,
  });

  final String time;
  final String category;
  final String title;
  final String details;
}

/// يبني تقرير PDF عربي لسجل إجراءات مشرف ويفتح مشاركة/حفظ الملف.
abstract final class SupervisorLogPdfExporter {
  /// يرجع `false` لو المستخدم قفل نافذة المشاركة.
  static Future<bool> share({
    required String supervisorName,
    required String supervisorId,
    required String department,
    required String filterLabel,
    required List<SupervisorLogPdfRow> rows,
  }) async {
    // خط Cairo من Google Fonts (بيتحمّل مرة ويتخزن) عشان الحروف العربي تظهر صح.
    final regular = await PdfGoogleFonts.cairoRegular();
    final bold = await PdfGoogleFonts.cairoBold();
    final theme = pw.ThemeData.withFont(base: regular, bold: bold);

    final now = DateTime.now();
    final generated = '${now.year}-${_two(now.month)}-${_two(now.day)} '
        '${_two(now.hour)}:${_two(now.minute)}';

    final document = pw.Document(
      title: 'سجل إجراءات $supervisorName',
      author: 'برواح — رئيس المشرفين',
    );

    document.addPage(
      pw.MultiPage(
        theme: theme,
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('سجل إجراءات المشرف',
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey900)),
                pw.Text('برواح',
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green800)),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Text('$supervisorName  •  $supervisorId  •  $department',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey800)),
            pw.SizedBox(height: 2),
            pw.Text(
                'تاريخ التصدير: $generated  •  النطاق: $filterLabel  •  عدد الإجراءات: ${rows.length}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey600)),
            pw.SizedBox(height: 10),
          ],
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text('صفحة ${context.pageNumber} من ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey500)),
        ),
        build: (context) => [
          if (rows.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 30),
              child: pw.Center(
                child: pw.Text('لا توجد إجراءات مسجلة في هذا النطاق.',
                    style: const pw.TextStyle(fontSize: 12)),
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: const ['التاريخ والوقت', 'القسم / النوع', 'الإجراء', 'التفاصيل'],
              data: [
                for (final row in rows)
                  [row.time, row.category, row.title, row.details],
              ],
              columnWidths: const {
                0: pw.FixedColumnWidth(78),
                1: pw.FixedColumnWidth(80),
                2: pw.FlexColumnWidth(2),
                3: pw.FlexColumnWidth(3),
              },
              headerStyle: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              cellAlignment: pw.Alignment.topRight,
              headerAlignment: pw.Alignment.centerRight,
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
              border: pw.TableBorder.all(color: PdfColors.blueGrey200, width: .5),
              cellPadding: const pw.EdgeInsets.all(5),
            ),
        ],
      ),
    );

    final safeId = supervisorId.replaceAll(RegExp(r'[^A-Za-z0-9-]'), '');
    return Printing.sharePdf(
      bytes: await document.save(),
      filename: 'supervisor-log-${safeId.isEmpty ? 'report' : safeId}.pdf',
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
