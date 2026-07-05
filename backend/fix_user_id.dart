import 'dart:io';

void main() {
  final dir = Directory('/Users/rasol/DevsTools/codes/flutter/watt/backend/solarhub-nestjs/src');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.ts'));

  int replacedFiles = 0;
  for (final file in files) {
    String content = file.readAsStringSync();
    
    if (content.contains('req.user.sub') || content.contains('req.user?.sub')) {
      content = content.replaceAll('req.user.sub', 'req.user.id');
      content = content.replaceAll('req.user?.sub', 'req.user?.id');
      file.writeAsStringSync(content);
      print('Fixed \${file.path}');
      replacedFiles++;
    }
  }
  print('Total files fixed: \$replacedFiles');
}
