import 'package:flutter_test/flutter_test.dart';

import 'package:barwah_app/core/utils/csv_exporter.dart';

void main() {
  test('escapes commas, quotes and newlines', () {
    final csv = CsvExporter.build(
      ['a', 'b'],
      [
        ['x,y', 'say "hi"'],
        ['line1\nline2', 'plain'],
      ],
    );
    expect(csv, 'a,b\n"x,y","say ""hi"""\n"line1\nline2",plain\n');
  });

  test('encode prefixes a UTF-8 BOM', () {
    final bytes = CsvExporter.encode('م');
    expect(bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
  });
}
