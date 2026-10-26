import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the unified theme: screens must take colours from `AppColors`
/// (the admin account palette) instead of hard-coded literals.
void main() {
  // Files that legitimately own raw colours.
  const allowed = <String>{
    'lib/core/theme/app_palette.dart',
    'lib/core/theme/app_colors.dart',
    'lib/core/theme/app_component_themes.dart',
    'lib/core/theme/app_theme.dart',
    'lib/core/widgets/app_launch_splash.dart',
    'lib/core/widgets/app_brand_mark.dart',
  };

  final literal = RegExp(r'Color\(0x[0-9A-Fa-f]{8}\)');
  final material = RegExp(
    r'(?<![A-Za-z_.])Colors\.(grey|gray|blueGrey|red|redAccent|green|greenAccent|'
    r'blue|blueAccent|orange|orangeAccent|amber|teal|purple|indigo|yellow|cyan|pink|'
    r'deepOrange|deepPurple|lightBlue|lightGreen|lime|black87|black54|black45|black38)\b',
  );
  final palette = RegExp(r'AppPalette\.(?!overlay)\w+');

  List<File> dartFiles() => Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.contains('${Platform.pathSeparator}l10n${Platform.pathSeparator}'))
      .where((f) => !f.path.contains('${Platform.pathSeparator}generated${Platform.pathSeparator}'))
      .where((f) => !allowed.contains(f.path.replaceAll('\\', '/')))
      .toList();

  test('screens use AppColors instead of hard-coded colours', () {
    final offenders = <String>[];
    for (final file in dartFiles()) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (literal.hasMatch(line) ||
            material.hasMatch(line) ||
            palette.hasMatch(line)) {
          offenders.add('${file.path}:${i + 1}: ${line.trim()}');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason: 'Use AppColors tokens (core/theme/app_colors.dart):\n'
          '${offenders.take(40).join('\n')}',
    );
  });
}
