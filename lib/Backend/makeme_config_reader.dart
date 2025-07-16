import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> loadConfigFile(String pathToWorkingDir) async {
  final configFile = File('$pathToWorkingDir/makeme_config.json');

  if (!await configFile.exists()) {
    print('Config file not found.');
    return {};
  }

  try {
    final content = await configFile.readAsString();
    final Map<String, dynamic> jsonData = jsonDecode(content);
    return jsonData;
  } catch (e) {
    print('Error reading or decoding config file: $e');
    return {};
  }
}

List<Map<String, dynamic>> getFileConfigs(Map<String, dynamic> config) {
  final fileSettings = config['fileSettings'] as Map<String, dynamic>?;

  if (fileSettings == null || fileSettings.isEmpty) {
    print('No file settings found.');
    return [];
  }

  final List<Map<String, dynamic>> result = [];

  fileSettings.forEach((fileName, settings) {
    result.add({
      'fileName': fileName,
      'config': settings,
    });
  });

  return result;
}

/* Usage */

/*
void main() async {
  final workingDir = 'C:/Projects/MyCppApp';
  final config = await loadConfigFile(workingDir);

  final fileConfigs = getFileConfigs(config);

  for (final file in fileConfigs) {
    print('File: ${file['fileName']}');
    print('Compiler: ${file['config']['compiler']}');
    print('Architecture: ${file['config']['architecture']}');
    print('---');
  }
}
*/