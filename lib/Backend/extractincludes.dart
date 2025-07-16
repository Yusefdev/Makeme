import 'dart:io';

Future<List<String>> extractIncludes(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    throw Exception('File does not exist at path: $filePath');
  }

  final includes = <String>[];
  final includeRegex = RegExp(r'#include\s*([<"].+[>"])');

  // Read file line by line to avoid loading entire file at once
  final lines = await file.readAsLines();

  for (var line in lines) {
    final match = includeRegex.firstMatch(line);
    if (match != null) {
      // Extract the included file part (e.g., "<vulkan/vulkan.h>" or "myheader.h")
      includes.add(match.group(1)!);
    }
  }

  return includes;
}