import 'dart:io';

void main() {
  final dir = Directory('lib/features');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    String content = file.readAsStringSync();
    if (!content.contains('AppTypography.')) continue;
    
    final regex = RegExp(r'AppTypography\.([a-zA-Z]+)\(([^)]*)\)');
    content = content.replaceAllMapped(regex, (match) {
      final styleName = match.group(1);
      final args = match.group(2)?.trim() ?? '';
      
      if (args.isEmpty) {
        return 'Theme.of(context).textTheme.$styleName';
      } else {
        return 'Theme.of(context).textTheme.$styleName?.copyWith($args)';
      }
    });
    
    file.writeAsStringSync(content);
    print('Updated ${file.path}');
  }
}
