import 'dart:io';

void runExecutable(String exePath, List<String> arguments,String cwd) async {
  try {
    final result = await Process.start(
      exePath,
      arguments,
      runInShell: true,
      workingDirectory: cwd
    );

    // Optional: listen to stdout and stderr
    result.stdout.transform(const SystemEncoding().decoder).listen(print);
    result.stderr.transform(const SystemEncoding().decoder).listen(print);

    final exitCode = await result.exitCode;
    print('Process exited with code: $exitCode');
  } catch (e) {
    print('Failed to start process: $e');
  }
}