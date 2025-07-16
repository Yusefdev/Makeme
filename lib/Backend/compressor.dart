import 'dart:io';
import 'package:path/path.dart' as p;

Future<void> packAndCompressFolder({
  required String folderPath,
  required String outputFolderPath,
}) async {
  final inputDir = Directory(folderPath);
  final outputDir = Directory(outputFolderPath);

  if (!inputDir.existsSync()) {
    throw Exception('Input folder does not exist: $folderPath');
  }
  if (!outputDir.existsSync()) {
    throw Exception('Output folder does not exist: $outputFolderPath');
  }

  // Executable directory
  final scriptDir = File(Platform.resolvedExecutable).parent;

  final tarPath = p.join(scriptDir.path, 'tar.exe');
  final zstdPath = p.join(scriptDir.path, 'zstd.exe');

  if (!await File(tarPath).exists() || !await File(zstdPath).exists()) {
    throw Exception('Missing tar.exe or zstd.exe in app directory.');
  }

  // Output file paths
  final folderName = p.basename(folderPath);
  final tarFilePath = p.join(outputDir.path, '$folderName.tar');
  final zstFilePath = '$tarFilePath.zst';

  // Create tar archive
  final tarResult = await Process.run(
    tarPath,
    ['--exclude', p.basename(tarFilePath), '-cf', tarFilePath, '-C', p.dirname(folderPath), folderName],
    runInShell: true,
  );

  if (tarResult.exitCode != 0) {
    throw Exception('Tar failed: ${tarResult.stderr}');
  }

  // Compress with zstd (keep .tar extension)
  final zstdResult = await Process.run(
    zstdPath,
    ['-19' ,'--rm', '-f', tarFilePath, '-o', zstFilePath],
    runInShell: true,
  );

  if (zstdResult.exitCode != 0) {
    throw Exception('Zstd compression failed: ${zstdResult.stderr}');
  }

  print('Compression complete: $zstFilePath');
}
