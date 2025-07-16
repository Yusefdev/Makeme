import 'dart:io';

String formatFileSizeFromPath(String filePath) {
  final file = File(filePath);

  if (!file.existsSync()) {
    throw FileSystemException('File not found', filePath);
  }

  final bytes = file.lengthSync();

  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  double size = bytes.toDouble();
  int index = 0;

  while (size >= 1024 && index < suffixes.length - 1) {
    size /= 1024;
    index++;
  }

  return '${size.toStringAsFixed(2)} ${suffixes[index]}';
}