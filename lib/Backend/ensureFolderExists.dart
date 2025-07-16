import 'dart:io';

bool ensureFolderExistsSync(String folderPath) {
  try {
    final dir = Directory(folderPath);

    if (dir.existsSync()) {
      return true;
    } else {
      dir.createSync(recursive: true);
      return true;
    }
  } catch (e) {
    print('Failed to create folder: $e');
    return false;
  }
}