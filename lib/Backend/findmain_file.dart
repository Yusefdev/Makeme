// import 'dart:io';

// Future<File?> findMainCFile(String dirPath, {bool recursive = true}) async {
//   final directory = Directory(dirPath);

//   if (!await directory.exists()) {
//     throw FileSystemException("Directory does not exist", dirPath);
//   }

//   // List all .c and .cpp files
//   final files = await directory
//       .list(recursive: recursive) 
//       .where((entity) =>
//           entity is File &&
//           (entity.path.endsWith('.c') || entity.path.endsWith('.cpp')))
//       .cast<File>()
//       .toList();

//   // 1. Try to find a file whose name starts with 'main' and ends with .c or .cpp
//   for (final file in files) {
//     final name = file.uri.pathSegments.last;
//     if (name.startsWith('main') && (name.endsWith('.c') || name.endsWith('.cpp'))) {
//       return file;
//     }
//   }

//   // 2. Try to find file that contains 'int main'
//   for (final file in files) {
//     final content = await file.readAsString();
//     if (RegExp(r'\bint\s+main\s*\(').hasMatch(content)) {
//       return file;
//     }
//   }

//   // If not found
//   return null;
// }

// import 'dart:io';

// Future<dynamic> findMainCFile(String dirPath) async {
//   final directory = Directory(dirPath);

//   if (!await directory.exists()) {
//     throw FileSystemException("Directory does not exist", dirPath);
//   }

//   Future<bool> isMainCandidate(File file) async {
//     final name = file.uri.pathSegments.last;
//     if (name.startsWith('main') && (name.endsWith('.c') || name.endsWith('.cpp'))) {
//       return true;
//     }
//     final content = await file.readAsString();
//     return RegExp(r'\bint\s+main\s*\(').hasMatch(content);
//   }

//   // Step 1: Look for candidate files in root directory (non-recursive)
//   final entitiesInDir = await directory.list(recursive: false).toList();
//   final filesInDir = entitiesInDir.where((e) =>
//       e is File &&
//       (e.path.endsWith('.c') || e.path.endsWith('.cpp'))).cast<File>();

//   final mainCandidatesInDir = <File>[];
//   for (final file in filesInDir) {
//     if (await isMainCandidate(file)) {
//       mainCandidatesInDir.add(file);
//     }
//   }

//   if (mainCandidatesInDir.isNotEmpty) {
//     if (mainCandidatesInDir.length == 1) {
//       return mainCandidatesInDir.first;
//     } else {
//       return mainCandidatesInDir.map((f) => f.uri.pathSegments.last).toList();
//     }
//   }

//   // Step 2: No files in root, check subdirectories (one level down)
//   final subDirs = entitiesInDir.where((e) => e is Directory).cast<Directory>();

//   final mainCandidatesInSubdirs = <String>[];

//   for (final subdir in subDirs) {
//     final subEntities = await subdir.list(recursive: false).toList();
//     final filesInSubdir = subEntities.where((e) =>
//         e is File &&
//         (e.path.endsWith('.c') || e.path.endsWith('.cpp'))).cast<File>();

//     for (final file in filesInSubdir) {
//       if (await isMainCandidate(file)) {
//         final relativePath = file.path.substring(directory.path.length + 1);
//         mainCandidatesInSubdirs.add(relativePath);
//       }
//     }
//   }

//   if (mainCandidatesInSubdirs.isEmpty) {
//     return null;
//   }

//   if (mainCandidatesInSubdirs.length == 1) {
//     return File('${directory.path}/${mainCandidatesInSubdirs.first}');
//   } else {
//     return mainCandidatesInSubdirs;
//   }
// }



import 'dart:io';

Future<dynamic> findMainCFile(String dirPath) async {
  final directory = Directory(dirPath);

  if (!await directory.exists()) {
    throw FileSystemException("Directory does not exist", dirPath);
  }

  Future<bool> isMainCandidate(File file) async {
    final name = file.uri.pathSegments.last;
    if (name.startsWith('main') && (name.endsWith('.c') || name.endsWith('.cpp'))) {
      return true;
    }
    final content = await file.readAsString();
    return RegExp(r'\bint\s+main\s*\(').hasMatch(content);
  }

  // Step 1: Search root directory
  final entitiesInDir = await directory.list(recursive: false).toList();
  final filesInDir = entitiesInDir.where((e) =>
      e is File &&
      (e.path.endsWith('.c') || e.path.endsWith('.cpp'))).cast<File>();

  final mainCandidatesInDir = <String>[];

  for (final file in filesInDir) {
    if (await isMainCandidate(file)) {
      mainCandidatesInDir.add(file.path);
    }
  }

  if (mainCandidatesInDir.isNotEmpty) {
    return mainCandidatesInDir.length == 1 ? mainCandidatesInDir.first : mainCandidatesInDir;
  }

  // Step 2: Check subdirectories (non-recursive, one level down)
  final subDirs = entitiesInDir.whereType<Directory>();

  final mainCandidatesInSubdirs = <String>[];

  for (final subdir in subDirs) {
    final subEntities = await subdir.list(recursive: false).toList();
    final filesInSubdir = subEntities.where((e) =>
        e is File &&
        (e.path.endsWith('.c') || e.path.endsWith('.cpp'))).cast<File>();

    for (final file in filesInSubdir) {
      if (await isMainCandidate(file)) {
        mainCandidatesInSubdirs.add(file.path);
      }
    }
  }

  if (mainCandidatesInSubdirs.isEmpty) {
    return null;
  }

  return mainCandidatesInSubdirs.length == 1
      ? mainCandidatesInSubdirs.first
      : mainCandidatesInSubdirs;
}