import 'dart:io';

void main() {
  final dir = Directory('/Users/rasol/DevsTools/codes/flutter/watt/frontend/lib/src/features');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    // Replace DateTime.tryParse(json['...']) with safeParseDate(json['...'])
    final tryParseRegex = RegExp(r"DateTime\.tryParse\((json\['[^']+'])(?:\?.toString\(\))?(?:\s*\?\?\s*'')?\)");
    if (tryParseRegex.hasMatch(content)) {
      content = content.replaceAllMapped(tryParseRegex, (match) {
        return "safeParseDate(${match.group(1)})";
      });
      modified = true;
    }

    // Replace DateTime.tryParse(json['...'].toString()) with safeParseDate(json['...'])
    final tryParseStringRegex = RegExp(r"DateTime\.tryParse\((json\['[^']+'])\.toString\(\)\)");
    if (tryParseStringRegex.hasMatch(content)) {
      content = content.replaceAllMapped(tryParseStringRegex, (match) {
        return "safeParseDate(${match.group(1)})";
      });
      modified = true;
    }

    // Add import if modified
    if (modified && !content.contains("import 'package:solar_hub/src/core/utils/date_parser.dart';")) {
      content = "import 'package:solar_hub/src/core/utils/date_parser.dart';\n" + content;
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
