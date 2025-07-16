// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'dart:io';
import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:makeme/Backend/FileSizeFromPath.dart';
import 'package:makeme/Backend/compressor.dart';
import 'package:makeme/Backend/detectpkgconfig.dart';
import 'package:makeme/Backend/ensureFolderExists.dart';
import 'package:makeme/Backend/extractincludes.dart';
import 'package:makeme/Backend/findmain_file.dart';
import 'package:makeme/Backend/formatduration.dart';
import 'package:makeme/Backend/global_shortcuts_wrapper.dart';
import 'package:makeme/Backend/makeme_config_reader.dart';
import 'package:makeme/Backend/restartapp.dart';
import 'package:makeme/Backend/runMsys2Command.dart';
import 'package:makeme/Backend/runexcutable.dart';
import 'package:makeme/Backend/runmsysshell.dart';
import 'package:makeme/config_editor.dart';
import 'package:makeme/debugterminalbox.dart';
import 'package:makeme/fileexplorer.dart';
import 'package:makeme/mainfileselector.dart';
import 'package:makeme/project%20path%20selector.dart';
import 'package:makeme/settingspage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(750, 500)); // Minimum width: 800, height: 600
  }
  print(args);
  runApp(GlobalShortcutHandler(
      triggerKeys: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK),
      child: CBuilderApp(arguments: args,)));
}

class CBuilderApp extends StatelessWidget {
  final List<String>? arguments;
  const CBuilderApp({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {

    return RestartWidget(
      child: MaterialApp(debugShowCheckedModeBanner: false,
        title: 'Makeme',
        // theme: ThemeData(
        //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        //   useMaterial3: true,
        // ),
        theme: FlexThemeData.light(scheme: FlexScheme.aquaBlue),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.aquaBlue),
        themeMode: ThemeMode.system,
        home: homepage(arguments: arguments),
      ),
    );
  }
}


class homepage extends StatefulWidget {
  final List<String>? arguments;
  const homepage({super.key, this.arguments});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> with TickerProviderStateMixin {
  List<String> installedPackages = [];
  List<String> multipleMainFileList = [];
  List<String> detectedpackages = [];
  final List<String> compilers = ['gcc', 'g++', 'clang', 'clang++'];
  String? selectedCompiler = 'gcc';
  final ScrollController _scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  TextEditingController project_path_text_controller = TextEditingController();
  List<String>? filtered_pkg_configs;
  String finalcompilecommand = '';
  List<String>? pkg_configs;
  String build_logs = '';
  String? buildcommands;
  String Msys2_path = r'D:\Msys2';
  String Project_path = r'C:\Users\Yusef\Documents\C\pvulkan\';
  String? project_main_file;
  String? selectedArch = '64';
  bool showprojectpathselector = true;
  bool showSettings = false;
  bool enable_build_Warnings = false;
  bool _narrow_the_list = false;
  Map<String, dynamic>? settings;
  Msys2Command? msys2Command;
  FileExplorer? projectview;
  List<dynamic> info = [];
  late SharedPreferences _settings;

  // Tabs related
  late TabController _tabController;
  final List<Tab> tabs = [
    const Tab(text: 'project view',icon: Icon(Icons.folder_open)),
    const Tab(text: 'pkg-config',icon: Icon(Icons.settings)),
    const Tab(text: 'build',icon: Icon(Icons.build)),
    const Tab(text: 'info',icon: Icon(Icons.info_outline)),
  ];




  @override
  void initState() {
    super.initState();
    // add automatic msys 2 search and if not found ask user
    Reloader(sectionList: [true,true,true,true]);
    _tabController = TabController(length: tabs.length, vsync: this);
    registerShortcutHandler();
  }
  // void startcompiling() {
  //   setState(() {
  //     if (msys2Command == null) {
  //       final stopwatch = Stopwatch()..start();
  //       String cleanProjectPath =
  //           Project_path.replaceAll(RegExp(r'[\/\\]+$'), '');
  //       ensureFolderExistsSync(
  //           "$cleanProjectPath\\${_settings.getString("buildFolder") ?? 'build/'}");
  //       msys2Command = Msys2Command();
  //       msys2Command!
  //           .run(
  //         msys2Path: Msys2_path,
  //         command: buildcommands!,
  //         shellEnv: 'mingw64',
  //         workingDirectory: Project_path,
  //       )
  //           .then(
  //         (result) {
  //           if (result.toString().contains(
  //                   "bash: cannot set terminal process group (-1): Inappropriate ioctl for device") &&
  //               result.exitCode == 0) {
  //             setState(() {
  //               build_logs += '\n\x1B[32m\x1B[1m✅ Build was successful\x1B[0m\n'
  //                   '\x1B[36mBuild Command:\x1B[0m $buildcommands\n'
  //                   '\x1B[36mExecutable Name:\x1B[0m ${p.basenameWithoutExtension(project_main_file!)}_${selectedArch == '64' ? 'x86_64-w64-windows-gnu' : 'i686-w64-windows-gnu'}.exe\n';
  //               msys2Command = null;
  //               Duration buildtime = stopwatch.elapsed;
  //               if (_settings.getBool('runexcutableafbuild') ?? true) {
  //                 runExecutable(
  //                     "${cleanProjectPath}\\${_settings.getString("buildFolder") ?? 'build/'}//${p.basenameWithoutExtension(project_main_file!)}_${selectedArch == '64' ? 'x86_64-w64-windows-gnu' : 'i686-w64-windows-gnu'}.exe",
  //                     [],
  //                     "${cleanProjectPath}\\${_settings.getString("buildFolder") ?? 'build/'}");
  //               }
  //               String filesize = formatFileSizeFromPath(
  //                   "${cleanProjectPath}\\${_settings.getString("buildFolder") ?? "build/"}${p.basenameWithoutExtension(project_main_file!)}_${selectedArch == '64' ? 'x86_64-w64-windows-gnu' : 'i686-w64-windows-gnu'}.exe");
  //               packAndCompressFolder(
  //                       folderPath:
  //                           "$cleanProjectPath\\${_settings.getString("buildFolder") ?? 'build/'}",
  //                       outputFolderPath:
  //                           "$cleanProjectPath\\${_settings.getString("buildFolder") ?? 'build/'}")
  //                   .then((_) {
  //                 setState(() {
  //                   info.addAll([
  //                     true,
  //                     buildtime,
  //                     detectedpackages,
  //                     '${p.basenameWithoutExtension(project_main_file!)}_${selectedArch == '64' ? 'x86_64-w64-windows-gnu' : 'i686-w64-windows-gnu'}.exe',
  //                     filesize,
  //                   ]);
  //                 });
  //               });
  //             });
  //             InteractiveToast.slide(
  //               context: context,
  //               leading:
  //                   const Icon(Icons.check_box, color: Colors.lightGreenAccent),
  //               title: const Text(
  //                 "successfully built the project",
  //               ),
  //               // trailing: const Icon(Icons.check_box),
  //               toastStyle: const ToastStyle(
  //                   titleLeadingGap: 10,
  //                   backgroundColor: Color.fromARGB(255, 0, 95, 27),
  //                   backgroundColorOpacity: .1),
  //               toastSetting: const SlidingToastSetting(
  //                 animationDuration: Duration(seconds: 1),
  //                 displayDuration: Duration(seconds: 1),
  //                 toastStartPosition: ToastPosition.top,
  //                 toastAlignment: Alignment.topCenter,
  //               ),
  //             );
  //           } else {
  //             print(result);
  //             InteractiveToast.slide(
  //               context: context,
  //               leading: const Icon(Icons.close, color: Colors.red),
  //               title: const Text(
  //                 "some errors accourd while building",
  //               ),
  //               // trailing: const Icon(Icons.check_box),
  //               toastStyle: const ToastStyle(
  //                   titleLeadingGap: 10,
  //                   backgroundColor: Color.fromARGB(255, 95, 0, 0),
  //                   backgroundColorOpacity: .1),
  //               toastSetting: const SlidingToastSetting(
  //                 animationDuration: Duration(seconds: 1),
  //                 displayDuration: Duration(seconds: 1),
  //                 toastStartPosition: ToastPosition.top,
  //                 toastAlignment: Alignment.topCenter,
  //               ),
  //             );
  //             msys2Command = null;
  //             setState(() {
  //               // Filter unwanted lines from stderr
  //               final filteredStderr = result.stderr
  //                   .split('\n')
  //                   .where((line) =>
  //                       !line.contains(
  //                           'bash: cannot set terminal process group') &&
  //                       !line.contains('bash: no job control in this shell'))
  //                   .join('\n')
  //                   .trim();

  //               // Clean stdout if it's just whitespace or empty
  //               final trimmedStdout = result.stdout.toString().trim();
  //               final showStdout = trimmedStdout.isNotEmpty;

  //               build_logs +=
  //                   '\n\x1B[31m\x1B[1m❌ Errors occurred while building:\x1B[0m\n'
  //                   '\x1B[33mStderr:\x1B[0m\n$filteredStderr\n';

  //               if (showStdout) {
  //                 build_logs += '\x1B[33mStdout:\x1B[0m\n$trimmedStdout\n';
  //               }

  //               build_logs += '\x1B[33mExit Code:\x1B[0m ${result.exitCode}\n';
  //             });
  //           }
  //         },
  //       );
  //     } else {
  //       setState(() {
  //         msys2Command!.cancel();
  //         build_logs +=
  //             '\n\x1B[33m\x1B[1m⚠️ Build job was canceled by the user.\x1B[0m\n';
  //         msys2Command = null;
  //       });
  //     }
  //   });
  // }


/* new clean up */
  void startCompiling() {
    if (project_main_file == null) {
      _showToastFailure(message: "please set a file as main");
      return;
    }
    setState(() {
      if (msys2Command != null) {
        _cancelCurrentBuild();
        return;
      }

      final stopwatch = Stopwatch()..start();
      final cleanPath = _getCleanProjectPath();
      final buildFolderPath = _getBuildFolderPath(cleanPath);
      ensureFolderExistsSync(buildFolderPath);

      msys2Command = Msys2Command();
      msys2Command!.run(
        msys2Path: Msys2_path,
        command: buildcommands!,
        shellEnv: 'mingw64',
        workingDirectory: Project_path,
      ).then((result) => _handleBuildResult(result, stopwatch, cleanPath, buildFolderPath));
    });
  }

  void startCompilingFromJsonConfig() async {
    final configFile = File('${Project_path}/makeme_config.json');

    if (!configFile.existsSync()) {
      _showToastFailure(message: "makeme_config.json not found");
      return;
    }

    setState(() {
      if (msys2Command != null) {
        _cancelCurrentBuild();
        return;
      }

      final stopwatch = Stopwatch()..start();
      final cleanPath = _getCleanProjectPath();
      final buildFolderPath = _getBuildFolderPath(cleanPath);
      ensureFolderExistsSync(buildFolderPath);

      final json = jsonDecode(configFile.readAsStringSync());
      final fileSettings = json['fileSettings'] as Map<String, dynamic>;
      if (fileSettings.isEmpty) {
        _showToastFailure(message: "No files configured in makeme_config.json");
        return;
      }

      // Sort entries by compileOrder
      final sortedFiles = fileSettings.entries.toList()
        ..sort((a, b) =>
            (a.value['compileOrder'] ?? 1).compareTo(b.value['compileOrder'] ?? 1));

      // Generate all commands
      List<String> commands = [];
      for (final entry in sortedFiles) {
        final file = entry.key;
        final settings = entry.value;
        final command = _generateCommandForFile(file, settings);
        if (command != null) {
          commands.add(command);
        }
      }

      if (commands.isEmpty) {
        _showToastFailure(message: "No valid commands generated");
        return;
      }

      // Join all commands into one shell command (semicolon separated)
      final joinedCommand = commands.join(' && ');

      msys2Command = Msys2Command();
      msys2Command!.run(
        msys2Path: Msys2_path,
        command: joinedCommand,
        shellEnv: 'mingw64',
        workingDirectory: Project_path,
      ).then((result) =>
          _handleBuildResult(result, stopwatch, cleanPath, buildFolderPath));
    });
  }

  String? _generateCommandForFile(String fileName, Map<String, dynamic> settings) {
    final compiler = settings['compiler'] ?? 'gcc';
    final architecture = settings['architecture'] ?? 'x64';
    final compileType = settings['compileType'] ?? '.exe (debug)';
    final outputPath = settings['outputPath'] ?? 'build/';
    final customOutputName = settings['customOutputName'] ?? '';
    final languageStandard = settings['languageStandard'] ?? 'c11';
    final packages = List<String>.from(settings['packages'] ?? []);

    final targetArch = (architecture == 'x64')
        ? 'x86_64-w64-mingw32'
        : 'i686-w64-mingw32';

    List<String> parts = [compiler];

    parts.addAll(['-target', targetArch]);
    if (languageStandard.isNotEmpty) {
      parts.add('-std=$languageStandard');
    }

    switch (compileType) {
      case '.exe (debug)':
        parts.addAll(['-g', '-O0']);
        break;
      case '.exe (release)':
        parts.addAll(['-O2', '-DNDEBUG']);
        break;
      case '.dll':
        parts.add('-shared');
        break;
      case '.lib':
        parts.add('-static');
        break;
      case '.obj':
        parts.add('-c');
        break;
      case '.so':
        parts.addAll(['-shared', '-fPIC']);
        break;
    }

    if (packages.isNotEmpty) {
      final pkgString = packages.join(' ');
      parts.add('`pkg-config --cflags --libs $pkgString`');
    }

    final baseName = customOutputName.isNotEmpty
        ? customOutputName
        : fileName.split(Platform.pathSeparator).last.split('.').first;

    String outputFile;
    switch (compileType) {
      case '.exe (debug)':
      case '.exe (release)':
        outputFile = '$baseName\_$targetArch.exe';
        break;
      case '.dll':
        outputFile = '$baseName.dll';
        break;
      case '.lib':
        outputFile = '$baseName.lib';
        break;
      case '.obj':
        outputFile = '$baseName.o';
        break;
      case '.so':
        outputFile = '$baseName.so';
        break;
      default:
        outputFile = baseName;
    }

    parts.addAll(['-o', "'$outputPath$outputFile'"]);
    parts.add("'$fileName'");

    return parts.join(' ');
  }

  String _getCleanProjectPath() {
    return Project_path.replaceAll(RegExp(r'[\/\\]+$'), '');
  }

  String _getBuildFolderPath(String cleanPath) {
    return "$cleanPath\\${_settings.getString("buildFolder") ?? 'build/'}";
  }

  void _cancelCurrentBuild() {
    msys2Command!.cancel();
    build_logs += '\n\x1B[33m\x1B[1m⚠️ Build job was canceled by the user.\x1B[0m\n';
    msys2Command = null;
  }

  void _handleBuildResult(Msys2Result result, Stopwatch stopwatch, String cleanPath, String buildFolderPath) {
    final isTerminalWarningOnly = result.toString().contains("bash: cannot set terminal process group")
        && result.exitCode == 0;

    if (isTerminalWarningOnly) {
      _onBuildSuccess(stopwatch, cleanPath, buildFolderPath);
    } else {
      _onBuildFailure(result);
    }
  }

  void _onBuildSuccess(Stopwatch stopwatch, String cleanPath, String buildFolderPath) {
    final exeName = _getExecutableName();
    final exePath = "$buildFolderPath//$exeName";

    setState(() {
      build_logs += '\n\x1B[32m\x1B[1m✅ Build was successful\x1B[0m\n'
                    '\x1B[36mBuild Command:\x1B[0m $buildcommands\n'
                    '\x1B[36mExecutable Name:\x1B[0m $exeName\n';
      msys2Command = null;
    });

    final buildTime = stopwatch.elapsed;

    if (_settings.getBool('runexcutableafbuild') ?? true) {
      runExecutable(exePath, [], buildFolderPath);
    }

    final fileSize = formatFileSizeFromPath(exePath);

    packAndCompressFolder(
      folderPath: buildFolderPath,
      outputFolderPath: buildFolderPath,
    ).then((_) {
      setState(() {
        info.addAll([
          true,
          buildTime,
          detectedpackages,
          exeName,
          fileSize,
        ]);
      });
    });

    _showToastSuccess();
  }

  void _onBuildFailure(Msys2Result result) {
    print(result);
    final filteredStderr = result.stderr
        .split('\n')
        .where((line) =>
            !line.contains('bash: cannot set terminal process group') &&
            !line.contains('bash: no job control in this shell'))
        .join('\n')
        .trim();

    final trimmedStdout = result.stdout.toString().trim();
    final showStdout = trimmedStdout.isNotEmpty;

    setState(() {
      build_logs += '\n\x1B[31m\x1B[1m❌ Errors occurred while building:\x1B[0m\n'
                    '\x1B[33mStderr:\x1B[0m\n$filteredStderr\n';

      if (showStdout) {
        build_logs += '\x1B[33mStdout:\x1B[0m\n$trimmedStdout\n';
      }

      build_logs += '\x1B[33mExit Code:\x1B[0m ${result.exitCode}\n';
      msys2Command = null;
    });

    _showToastFailure();
  }

  void _showToastSuccess({String? message}) {
    InteractiveToast.slide(
      context: context,
      leading: const Icon(Icons.check_box, color: Colors.lightGreenAccent),
      title: Text(message??"successfully built the project"),
      toastStyle: const ToastStyle(
        titleLeadingGap: 10,
        backgroundColor: Color.fromARGB(255, 0, 95, 27),
        backgroundColorOpacity: .1,
      ),
      toastSetting: const SlidingToastSetting(
        animationDuration: Duration(seconds: 1),
        displayDuration: Duration(seconds: 1),
        toastStartPosition: ToastPosition.top,
        toastAlignment: Alignment.topCenter,
      ),
    );
  }

  void _showToastFailure({String? message}) {
    InteractiveToast.slide(
      context: context,
      leading: const Icon(Icons.close, color: Colors.red),
      title: Text(message ?? "some errors occurred while building"),
      toastStyle: const ToastStyle(
        titleLeadingGap: 10,
        backgroundColor: Color.fromARGB(255, 95, 0, 0),
        backgroundColorOpacity: .1,
      ),
      toastSetting: const SlidingToastSetting(
        animationDuration: Duration(seconds: 1),
        displayDuration: Duration(seconds: 1),
        toastStartPosition: ToastPosition.top,
        toastAlignment: Alignment.topCenter,
      ),
    );
  }

  String _getExecutableName() {
    final baseName = p.basenameWithoutExtension(project_main_file!);
    final archSuffix = selectedArch == '64'
        ? 'x86_64-w64-windows-gnu'
        : 'i686-w64-windows-gnu';
    return '${baseName}_$archSuffix.exe';
  }

  Future<void> Reloader({List<bool>? sectionList}) async {
    // If no section list is provided, run everything
    sectionList ??= List.filled(4, true); // Adjust size based on number of sections

    if (sectionList[0]) {
      loadsave();
    }

    if (sectionList[1]) {
      jsonconfigloader();
    }

    if (sectionList[2]) {
      final value = await getPcFileNamesWithoutExtension(
        "$Msys2_path\\mingw$selectedArch\\lib\\pkgconfig"
      );
      setState(() {
        pkg_configs = value;
        filtered_pkg_configs = List.from(pkg_configs!);
        searchController.clear();
      });
    }

    if (sectionList[3]) {
      project_path_text_controller.text = Project_path;
        setState(() {
          projectview = FileExplorer(
            path: Project_path,
            fileIcons: const {
              ".png": "assets/png.png",
              ".c": "assets/c.png",
              ".cpp": "assets/cpp.png",
              ".clangd": "assets/clangd.png",
              ".sh": "assets/console.png",
              ".exe": "assets/exe.png",
              ".json":"assets/json.png",
              ".hpp":"assets/hpp.png",
              ".h":"assets/h.png"
            },
            openexplorer: (p0) => Process.run('explorer', ['/select,$p0']),
            setasmain: (p0){
              project_main_file = p0;
                  setState(() {
                    extractIncludes(p0).then((Value) {
                      update_build_command();
                      detectedpackages = detectPkgConfig(Value.join("\n").replaceAll(RegExp(r'\\'), '/'));
                      build_logs += "\ndetected packages are:\n\x1B[44m$detectedpackages\x1B[0m";
                    });
                  });
            },
          );
        });
        find_main_file();
    }
  }

  Future<void> find_main_file() async {
    final mainFileResult = await findMainCFile(Project_path);

    if (mainFileResult == null) {
      print('No main file found.');
    } else if (mainFileResult is File) {
      // Single main file found - behave normally
      print('Found main file: ${mainFileResult.path}');
      build_logs += '\n\x1B[32mFound main file:\x1B[0m ${mainFileResult.path}';
      build_logs += '\n\x1B[34mchanging compiler\x1B[0m';
      project_main_file = mainFileResult.path;
      if (multipleMainFileList.isEmpty) {
        await extractIncludes(project_main_file!).then((Value) {
          detectedpackages = detectPkgConfig(Value.join("\n").replaceAll(RegExp(r'\\'), '/'));
          build_logs += "\ndetected packages are:\n\x1B[44m$detectedpackages\x1B[0m";
          print("detected packages are $detectedpackages");
        });
      } else {
        
      }

      if (project_main_file!.endsWith(".c")) {
        setState(() {
          selectedCompiler = compilers[2];
        });
      } else {
        setState(() {
          selectedCompiler = compilers[3];
        });
      }
      update_build_command();
      // await generateCompileCommand(
      //   architecture: selectedArch == '64'
      //       ? 'x86_64-w64-windows-gnu'
      //       : 'i686-w64-windows-gnu',
      //   compiler: selectedCompiler!,
      //   enableWarnings: enable_build_Warnings,
      //   mainFilePath: project_main_file!,
      //   packageFlags: installedPackages.isEmpty ? null : installedPackages,
      // ).then((value) => print("command update result $value"));

      if (detectedpackages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          InteractiveToast.slide(
            context: context,
            leading: const Icon(Icons.inventory, color: Colors.blue),
            title: const Text(
                "we detected some packages.\ncheck the build page for more info"),
            trailing: const Icon(Icons.build),
            toastStyle: const ToastStyle(
              titleLeadingGap: 10,
              backgroundColor: Colors.black,
            ),
            toastSetting: const SlidingToastSetting(
              animationDuration: Duration(seconds: 1),
              displayDuration: Duration(seconds: 3),
              toastStartPosition: ToastPosition.top,
              toastAlignment: Alignment.topCenter,
            ),
          );
        });
      }
    } else if (mainFileResult is List<String>) {
      // Multiple candidates found — store them in the global list
      setState(() {
        multipleMainFileList = mainFileResult;
        print('Multiple main files found:');
        for (var f in multipleMainFileList) {
          print(' - $f');
        }
      });
      // You may want to notify the user or UI here about the multiple options
    }
  }

  Future<bool> generateCompileCommand({
    required String compiler, // "clang", "gcc", etc.
    required String mainFilePath, // e.g., "main.c"
    required String architecture, // e.g., "x86_64-w64-windows-gnu"
    String? outputName, // Optional
    String? languageVersion, // Optional, e.g. "c11" or "c++17"
    bool enableWarnings = false, // Optional, default false
    List<String>? customFlags, // Optional
    List<String>? packageFlags, // Optional, just names like ["gtk+-3.0"]
  }) async {
    try {
      // Validate main file
      if (!mainFilePath.endsWith('.c') && !mainFilePath.endsWith('.cpp')) {
        throw Exception('Unsupported file type: $mainFilePath');
      }
      outputName ??= "'${_settings.getString('buildFolder')??"build/"}${p.basenameWithoutExtension(mainFilePath)}_$architecture.exe'";

      // Determine language standard
      String stdFlag = '';
      if (languageVersion != null) {
        if (mainFilePath.endsWith('.c')) {
          stdFlag = '-std=$languageVersion';
        } else if (mainFilePath.endsWith('.cpp')) {
          stdFlag = '-std=$languageVersion';
        }
      }

      // pkg-config packages
      String pkgConfigFlags = (packageFlags != null && packageFlags.isNotEmpty)
          ? '`pkg-config --cflags --libs ${packageFlags.join(' ')}`'
          : '';

      // Build the command
      List<String> parts = [
        compiler,
        '-target',
        architecture,
        if (stdFlag.isNotEmpty) stdFlag,
        if (enableWarnings) ...['-Wall', '-Werror'],
        if (customFlags != null && customFlags.isNotEmpty) ...customFlags,
        '-o',
        outputName,
        "'${p.basename(mainFilePath)}'",
        if (pkgConfigFlags.isNotEmpty) pkgConfigFlags,
      ];
      setState(() {
        buildcommands = parts.join(' ');
      });
      print(buildcommands);
      return true;
    } catch (e) {
      print('Error generating compile command: $e');
      buildcommands = '';
      return false;
    }
  }

  List<String> getAllPackageNames(String pkgConfigOutput) {
    // Split the input into lines
    final lines = pkgConfigOutput.split('\n');

    // Extract first token (package name) from each line, skipping empty lines
    final packageNames = lines
        .map((line) {
          final trimmedLine = line.trim();
          if (trimmedLine.isEmpty) return null; // skip empty lines
          final parts = trimmedLine.split(RegExp(r'\s+'));
          return parts[0];
        }).whereType<String>().toList();

    return packageNames;
  }

  Future<List<String>> getPcFileNamesWithoutExtension(String path) async {
    final directory = Directory(path);

    if (!await directory.exists()) {
      throw Exception("Directory does not exist: $path");
    }

    final entities = await directory.list().toList();

    final pcFileNames = entities
        .whereType<File>()
        .where((file) => file.path.endsWith('.pc'))
        .map((file) {
      final fileName = file.uri.pathSegments.last; // get file name with extension
      return fileName.substring(0, fileName.length - 3); // remove ".pc"
    }).toList();

    return pcFileNames;
  }

  void _filterPackages(String query) {
    if (pkg_configs == null) return;

    setState(() {
      List<String> baseList = List.from(pkg_configs!);

      if (_narrow_the_list) {
        final allowedPackages = {
          ...detectedpackages.map((e) => e.toLowerCase()),
          ...installedPackages.map((e) => e.toLowerCase())
        };

        baseList = baseList
            .where((pkg) => allowedPackages.contains(pkg.toLowerCase()))
            .toList();
      }

      if (query.isEmpty) {
        filtered_pkg_configs = baseList;
      } else {
        filtered_pkg_configs = baseList
            .where((pkg) => pkg.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void update_build_command() {
    generateCompileCommand(
            architecture: selectedArch == '64'
                ? 'x86_64-w64-windows-gnu'
                : 'i686-w64-windows-gnu',
            compiler: selectedCompiler!,
            enableWarnings: enable_build_Warnings,
            mainFilePath: project_main_file!,
            packageFlags: installedPackages == [] ? null : installedPackages)
        .then((value) => print("command update result $value"));
  }

  Future<void> loadsave()async{
    _settings = await SharedPreferences.getInstance();
    print(_settings.getString('buildFolder')??"build");
  }

  Future<void> jsonconfigloader() async {
    final config = await loadConfigFile(Project_path);
    final fileConfigs = getFileConfigs(config);

    for (final file in fileConfigs) {
      print('File: ${file['fileName']}');
      print('Compiler: ${file['config']['compiler']}');
      print('Architecture: ${file['config']['architecture']}');
      print('---');
    }
  }


 /* callbacks */
  void onCompilerSelected(String compiler) {
    print('Selected compiler: $compiler');
    selectedCompiler = compiler;
    update_build_command();
  }

  void onArchSelected(String newValue) {
    print('Selected architect: $newValue');
    selectedArch = newValue;
  }

  Future<void> onpathchange(String value) async {
    Project_path = value;
    projectview = FileExplorer(path: Project_path, fileIcons: const {
      ".png": "assets/png.png",
      ".c": "assets/c.png",
      ".cpp": "assets/cpp.png",
      ".clangd": "assets/clangd.png",
      ".sh": "assets/console.png",
      ".exe": "assets/exe.png",
      ".json":"assets/json.png",
      ".hpp":"assets/hpp.png",
      ".h":"assets/h.png"
    },
    openexplorer: (p0) => Process.run('explorer', ['/select,$p0']),
    setasmain: (p0){
      project_main_file = p0;
          setState(() {
            extractIncludes(p0).then((Value) {
              update_build_command();
              detectedpackages = detectPkgConfig(Value.join("\n").replaceAll(RegExp(r'\\'), '/'));
              build_logs += "\ndetected packages are:\n\x1B[44m$detectedpackages\x1B[0m";
            });
          });
    },
    );
    await find_main_file();
    setState(() {});
  }
  
  void registerShortcutHandler(){
    GlobalShortcutHandler.of(context)?.registerShortcutCallback((keys) {
      runMsys2Shell(r'D:\Msys2',Project_path);
      // Navigator.push(context,MaterialPageRoute(builder: (context)=>Material(child: ConfigEditorWidget(workingDirectory: Project_path))));
      debugPrint('🎯 Ctrl+K detected in MyPage');
    });
  }

  Future<String?> pickDirectory() async {
    final String? directoryPath = await getDirectoryPath();
    if (directoryPath != null) {
      print('Selected directory: $directoryPath');
      return directoryPath;
    } else {
      print('No directory selected.');
      return null;
    }
  }
/* end of callbacks */


  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(decoration: const BoxDecoration(color:  Color.fromARGB(255, 30, 30, 30)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Controls
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Project path:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(controller: project_path_text_controller,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (value) {
                            onpathchange(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          pickDirectory().then((_){
                            if(_!=null){
                              Project_path = _;
                              project_path_text_controller.text = Project_path;
                              Reloader(sectionList: [true,true,false,true]);
                            }
                          });
                        },
                        child: const Text("Browse"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(onPressed: (){
                        print("\n$detectedpackages,\n$Project_path,\n$project_main_file");
                      }, child: const Text("show data")),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        hint: const Text("Choose a compiler"),
                        value: selectedCompiler,
                        items: compilers.map((String compiler) {
                          return DropdownMenuItem<String>(
                            value: compiler,
                            child: Text(compiler),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedCompiler = newValue;
                            });
                            onCompilerSelected(newValue);
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        hint: const Text("Select architecture"),
                        value: selectedArch,
                        items: ['64', '32'].map((String arch) {
                          return DropdownMenuItem<String>(
                            value: arch,
                            child: Text(arch),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedArch = newValue;
                            });
                            onArchSelected(newValue);
                          }
                        },
                      ),
                    ],
                  ),
                ),
            
                // Horizontal Scroll Display
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            const Text(
                              "final command: ",
                              style: TextStyle(color: Colors.amber),
                            ),
                            Text("$buildcommands"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            
                // TabBar
                TabBar(
                  controller: _tabController,
                  tabs: tabs,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                ),
            
                // TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: tabs.map((Tab tab) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            if (tab.text == 'project view') ...[
                              Expanded(
                                child: projectview != null ? projectview! : const Text("set the path for project to see the view"),
                              ),
                            ] else if (tab.text == 'pkg-config') ...[
                              Row(mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      getPcFileNamesWithoutExtension("$Msys2_path\\mingw$selectedArch\\lib\\pkgconfig").then((value) {
                                        setState(() {
                                          pkg_configs = value;
                                          filtered_pkg_configs = List.from(pkg_configs!); // Initialize filtered
                                          searchController.clear();
                                        });
                                      });
                                      _showToastSuccess(message: "reloaded");
                                    },
                                    child: const Text("fetch packages"),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text("narrow the list"),
                                  Tooltip(message: "it will narrow the list to only installed or detected packages",
                                    child: Checkbox(
                                      value: _narrow_the_list,
                                      onChanged: (value) {
                                        setState(() {
                                          _narrow_the_list = !_narrow_the_list;
                                          if (_narrow_the_list) {
                                            List<String> baseList =
                                                List.from(pkg_configs!);
                                            if (_narrow_the_list) {
                                              final allowedPackages = {
                                                ...detectedpackages
                                                    .map((e) => e.toLowerCase()),
                                                ...installedPackages
                                                    .map((e) => e.toLowerCase())
                                              };
                                    
                                              baseList = baseList
                                                  .where((pkg) =>
                                                      allowedPackages.contains(
                                                          pkg.toLowerCase()))
                                                  .toList();
                                              filtered_pkg_configs = baseList;
                                            }
                                          } else {
                                            filtered_pkg_configs = pkg_configs;
                                          }
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                              if (pkg_configs != null) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: searchController,
                                          decoration: const InputDecoration(
                                            hintText: "Search packages...",
                                            border: OutlineInputBorder(),
                                            prefixIcon: Icon(Icons.search),
                                          ),
                                          onChanged: _filterPackages,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: filtered_pkg_configs!.isNotEmpty
                                      ? ListView.builder(
                                          itemCount: filtered_pkg_configs!.length,
                                          itemBuilder:
                                              (BuildContext context, int index) {
                                            final pkg = filtered_pkg_configs![index];
                                            final bool isInstalled = installedPackages.contains(pkg); // You manage this list
                        
                                            return Card(
                                              margin: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: ListTile(
                                                leading: Icon(
                                                  Icons.inventory,
                                                  color: isInstalled
                                                      ? Colors.green
                                                      : Colors.grey,
                                                ),
                                                title: Text(
                                                  pkg
                                                ),
                                                trailing: IconButton(
                                                  icon: Icon(
                                                    isInstalled
                                                        ? Icons.delete_forever
                                                        : Icons.system_update_alt,
                                                    color: isInstalled
                                                        ? Colors.red
                                                        : Colors.green,
                                                  ),
                                                  tooltip: isInstalled
                                                      ? 'Uninstall'
                                                      : 'Install',
                                                  onPressed: () {
                                                    setState(() {
                                                      if (isInstalled) {
                                                        installedPackages.remove(pkg); // Uninstall
                                                        update_build_command();
                                                      } else {
                                                        installedPackages.add(pkg); // Install
                                                        update_build_command();
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : const Center(
                                          child: Text(
                                            "No packages match your search",
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                )
                              ] else
                                const Text("no packages are available",style: TextStyle(color: Colors.red),),
                            ] else if (tab.text == "build") ...[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child:
                                  DebugTerminalBox(
                                          debugText: build_logs,
                                          onClear: () {
                                            setState(() {
                                              build_logs = '';
                                            });
                                          },
                                          onLoad: (loadedText) {
                                            setState(() {
                                              build_logs = loadedText;
                                            });
                                          },
                                        ),
                                  // SizedBox.expand(child: Padding(
                                  //   padding: const EdgeInsets.symmetric(horizontal: 12),
                                  //   child: CustomTerminalEmulator(),
                                  // )),
                                ),
                              ),
                            ]
                            else if (tab.text == "info") ...[
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    children: [
                                      _infoTile(
                                        context,
                                        icon: Icons.account_tree_outlined,
                                        title: "Project Architect",
                                        value: selectedArch ?? "?",
                                      ),
                                      _infoTile(
                                        context,
                                        icon: Icons.build_circle_outlined,
                                        title: "Compiler",
                                        value: selectedCompiler ?? "?",
                                      ),
                                      _infoTile(
                                        context,
                                        icon: Icons.insert_drive_file_outlined,
                                        title: "Main File",
                                        value: project_main_file ?? "?",
                                      ),
                                      _infoTile(
                                        context,
                                        icon: Icons.check_circle_outline,
                                        title: "Last Build Status",
                                        value: info.isNotEmpty ? info[0] ? "successful":"Failed":"?",
                                        valueColor: Colors
                                            .orange, // can change based on success/fail
                                      ),
                                      _infoTile(
                                        context,
                                        icon: Icons.timer_outlined,
                                        title: "Last Build Duration",
                                        value: info.isNotEmpty ? formatDuration((info[1] as Duration),useSmartFormat: true):"?",
                                      ),
                                      Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        elevation: 2,
                                        child: ExpansionTile(
                                          leading: const Icon(Icons.library_books_outlined,color: Colors.blue),
                                          title: const Text("Packages Used"),
                                          children: info.isEmpty?[const ListTile(title: Text('No package used'))]:(info[2] as List)
                                              .map((pkg) => ListTile(
                                                    title: SelectableText(pkg),
                                                    trailing: Tooltip(
                                                      message:
                                                          "Copy package name",
                                                      child: IconButton(
                                                        icon: const Icon(Icons.copy),
                                                        onPressed: () {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text: pkg));
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    "Copied: $pkg")),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                      Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        elevation: 2,
                                        child: ListTile(
                                          leading: const Tooltip(
                                            message: "executablePath",
                                            child: Icon(Icons.terminal_rounded,
                                                color: Colors.deepPurple),
                                          ),
                                          title: const Text("Executable Name"),
                                          subtitle: SelectableText("${info.isNotEmpty?info[3]:"?"}"),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Tooltip(
                                                message: "Copy executable path",
                                                child: IconButton(
                                                  icon: const Icon(Icons.copy),
                                                  onPressed: () {
                                                    Clipboard.setData(ClipboardData(text:"executablePath"));
                                                    _showToastSuccess(message: "Path Copied!");
                                                  },
                                                ),
                                              ),
                                              Tooltip(
                                                message: "Launch executable",
                                                child: IconButton(
                                                  icon: const Icon(
                                                      Icons.play_circle_fill,
                                                      color: Colors.green),
                                                  onPressed: () {
                                                    // launchExecutable(); // Define this
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      _infoTile(
                                        context,
                                        icon: Icons.sd_storage_outlined,
                                        title: "Build Size",
                                        value: info.isNotEmpty? info[4]:"?",
                                      ),
                                      _infoTile(
                                        context,
                                        icon: Icons.compress_outlined,
                                        title: "Zstd Package Size",
                                        value: "?",
                                      ),
                                      _infoTile(
                                        context,
                                        icon: Icons.system_update_alt_outlined,
                                        title: "Self-Compilable Installer Size",
                                        value: "?",
                                      ),
                                      _infoTile(
                                        context,
                                        icon: Icons.system_update_alt,
                                        title:
                                            "Self-Compilable Installer Size (Zstd)",
                                        value: "?",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        
            // Floating action button in bottom right
            Positioned(
              bottom: 10,
              right: 20,
              child: IconButton(
                onPressed: () {
                  // startCompiling();
                  // startCompilingFromJsonConfig();
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ConfigEditorScreen(files: ["main.c","2.c","3.c",])));
                  },
                icon: msys2Command == null ? const Icon(Icons.play_arrow,color: Colors.lightGreenAccent,) : const Icon(Icons.stop,color: Colors.redAccent,),
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Color.fromARGB(255, 36, 36, 36),
                  ),
                  iconColor: WidgetStatePropertyAll(Colors.white),
                ),
              ),
            ),
            Positioned(
                bottom: 50,
                right: 20,
                child: IconButton(onPressed: () {
                  setState(() {
                    showSettings = true;
                  });
                }, icon: const Icon(Icons.settings))),
            if (showSettings)SettingsOverlay(mainappcontext: context,
                onClose: (Map<String, dynamic> value) {
                  setState(() {
                    loadsave().then((value) => update_build_command(),);
                    showSettings = false;
                    settings = value;
                  });
                },
              ),
            if (multipleMainFileList.isNotEmpty && !showprojectpathselector)
              MainFileSelectorOverlay(
                candidates: multipleMainFileList,
                onSelected: (selectedFile) {
                  print(selectedFile);
                  multipleMainFileList = [];
                  project_main_file = selectedFile;
                  setState(() {
                    extractIncludes(selectedFile).then((Value) {
                      update_build_command();
                      detectedpackages = detectPkgConfig(Value.join("\n").replaceAll(RegExp(r'\\'), '/'));
                      build_logs += "\ndetected packages are:\n\x1B[44m$detectedpackages\x1B[0m";
                    });
                  });
                },
                onCancel: () {
                  print("canceled");
                  multipleMainFileList = [];
                  setState(() {});
                },
              ),
            if(showprojectpathselector)
            ProjectpathSelectorOverlay(onSelected: (selectedpath) {
              setState(() {
                showprojectpathselector = false;
                Project_path = selectedpath;
                project_path_text_controller.text = selectedpath;
                Reloader(sectionList: [true,true,true,true]);
              });
            },)
          ],
        ),
      ),
    );
  }
}






Widget _infoTile(BuildContext context, {
  required IconData icon,
  required String title,
  required String value,
  Color? valueColor,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    elevation: 2,
    child: ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      subtitle: SelectableText(
        value,
        style: TextStyle(
          color: valueColor ?? Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}