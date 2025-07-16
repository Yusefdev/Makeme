import 'dart:io';

Future<bool> _inPath(String exe) async {
  final res = await Process.run('where', [exe], runInShell: true);
  return res.exitCode == 0 && (res.stdout as String).trim().isNotEmpty;
}

/// Launch MSYS2 shell in wt.exe or fallback to PowerShell.
Future<void> runMsys2Shell(String msysPath,String workingDirectory) async {
  final hasWt = await _inPath('wt.exe');

  const exe = 'msys2_shell.cmd';
  final msysArgs = ['-defterm', '-here', '-no-start', '-mingw'];
  final fullScript = '$msysPath\\$exe ${msysArgs.join(' ')}';

  if (hasWt) {
    final args = [
      '-d',
      workingDirectory,
      'cmd.exe',
      '/k',
      fullScript,
    ];
    await Process.start('wt.exe', args, runInShell: true);
    print('✅ Launched via Windows Terminal (wt.exe)');
  }
  else{
    print("no wt.exe detected");
  }
}