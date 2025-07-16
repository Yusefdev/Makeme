import 'dart:async';
import 'dart:convert';
import 'dart:io';

class Msys2Result {
  final int exitCode;
  final String stdout;
  final String stderr;
  final bool wasKilled;

  Msys2Result({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.wasKilled,
  });

  @override
  String toString() {
    return '''
Exit Code: $exitCode
Killed: $wasKilled
--- STDOUT ---
$stdout
--- STDERR ---
$stderr
''';
  }
}

class Msys2Command {
  late final Process _process;
  final _stdoutBuffer = StringBuffer();
  final _stderrBuffer = StringBuffer();
  bool _killed = false;

  Future<Msys2Result> run({
    required String msys2Path,
    required String command,
    String shellEnv = 'msys',
    String? workingDirectory,
  }) async {
    final bashPath = '$msys2Path/usr/bin/bash.exe';
    final bashFile = File(bashPath);

    if (!bashFile.existsSync()) {
      throw Exception('bash.exe not found at: $bashPath');
    }

    _process = await Process.start(
      bashPath,
      ['--login', '-i', '-c', command],
      environment: {
        'MSYSTEM': shellEnv.toUpperCase(),
        'CHERE_INVOKING': '1',
      },
      workingDirectory: workingDirectory,
      runInShell: true,
    );

    // Listen to stdout and stderr
    _process.stdout.transform(utf8.decoder).listen(_stdoutBuffer.write);
    _process.stderr.transform(utf8.decoder).listen(_stderrBuffer.write);

    final exitCode = await _process.exitCode;

    return Msys2Result(
      exitCode: exitCode,
      stdout: _stdoutBuffer.toString().trim(),
      stderr: _stderrBuffer.toString().trim(),
      wasKilled: _killed,
    );
  }

  void cancel() {
    _killed = true;
    _process.kill(ProcessSignal.sigterm); // or sigkill
  }
}
