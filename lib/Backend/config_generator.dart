import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

/// Enum for different compilation types
enum CompileType {
  executable,      // .exe on Windows, binary on Linux/Mac
  sharedLibrary,   // .dll on Windows, .so on Linux, .dylib on Mac
  staticLibrary,   // .lib on Windows, .a on Linux/Mac
  object,          // .obj on Windows, .o on Linux/Mac
}

/// Enum for different architectures
enum Architecture {
  x86,             // 32-bit x86
  x64,             // 64-bit x86-64
}

/// Enum for different compilers
enum Compiler {
  gcc,
  gxx,             // g++
  clang,
  clangxx,         // clang++
}

/// Class representing compile settings for a single file
class FileCompileSettings {
  /// Relative path to the source file (e.g., "main.c", "src/utils.cpp")
  final String filePath;
  
  /// Compiler to use for this file
  final Compiler compiler;
  
  /// Target architecture
  final Architecture architecture;
  
  /// Type of compilation output
  final CompileType compileType;
  
  /// List of packages/libraries to link (e.g., ["gtk+-3.0", "sdl2"])
  final List<String> packages;
  
  /// Output path for the compiled file (relative to project root)
  final String outputPath;
  
  /// Language standard (e.g., "c11", "c++17", "c++20")
  final String? languageStandard;
  
  /// Additional compiler flags
  final List<String> additionalFlags;
  
  /// Enable compilation warnings
  final bool enableWarnings;
  
  /// Enable debug symbols
  final bool enableDebug;
  
  /// Optimization level (0-3, or "s" for size, "fast" for speed)
  final String? optimizationLevel;
  
  /// Include directories
  final List<String> includeDirs;
  
  /// Library directories
  final List<String> libraryDirs;
  
  /// Additional libraries to link
  final List<String> libraries;
  
  /// Preprocessor definitions
  final Map<String, String> defines;
  
  /// Environment variables for compilation
  final Map<String, String> environment;
  
  /// Whether to use pkg-config for package management
  final bool usePkgConfig;
  
  /// Custom output filename (if different from default)
  final String? customOutputName;
  
  /// Linker flags
  final List<String> linkerFlags;
  
  /// Whether to strip symbols from output
  final bool stripSymbols;
  
  /// Position Independent Code (for shared libraries)
  final bool positionIndependentCode;
  
  /// Custom compiler path (if not using system default)
  final String? customCompilerPath;

  FileCompileSettings({
    required this.filePath,
    required this.compiler,
    required this.architecture,
    required this.compileType,
    required this.packages,
    required this.outputPath,
    this.languageStandard,
    this.additionalFlags = const [],
    this.enableWarnings = false,
    this.enableDebug = false,
    this.optimizationLevel,
    this.includeDirs = const [],
    this.libraryDirs = const [],
    this.libraries = const [],
    this.defines = const {},
    this.environment = const {},
    this.usePkgConfig = true,
    this.customOutputName,
    this.linkerFlags = const [],
    this.stripSymbols = false,
    this.positionIndependentCode = false,
    this.customCompilerPath,
  });

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'compiler': compiler.name,
      'architecture': architecture.name,
      'compileType': compileType.name,
      'packages': packages,
      'outputPath': outputPath,
      'languageStandard': languageStandard,
      'additionalFlags': additionalFlags,
      'enableWarnings': enableWarnings,
      'enableDebug': enableDebug,
      'optimizationLevel': optimizationLevel,
      'includeDirs': includeDirs,
      'libraryDirs': libraryDirs,
      'libraries': libraries,
      'defines': defines,
      'environment': environment,
      'usePkgConfig': usePkgConfig,
      'customOutputName': customOutputName,
      'linkerFlags': linkerFlags,
      'stripSymbols': stripSymbols,
      'positionIndependentCode': positionIndependentCode,
      'customCompilerPath': customCompilerPath,
    };
  }

  /// Create from JSON map
  factory FileCompileSettings.fromJson(Map<String, dynamic> json) {
    return FileCompileSettings(
      filePath: json['filePath'],
      compiler: Compiler.values.firstWhere((e) => e.name == json['compiler']),
      architecture: Architecture.values.firstWhere((e) => e.name == json['architecture']),
      compileType: CompileType.values.firstWhere((e) => e.name == json['compileType']),
      packages: List<String>.from(json['packages'] ?? []),
      outputPath: json['outputPath'],
      languageStandard: json['languageStandard'],
      additionalFlags: List<String>.from(json['additionalFlags'] ?? []),
      enableWarnings: json['enableWarnings'] ?? false,
      enableDebug: json['enableDebug'] ?? false,
      optimizationLevel: json['optimizationLevel'],
      includeDirs: List<String>.from(json['includeDirs'] ?? []),
      libraryDirs: List<String>.from(json['libraryDirs'] ?? []),
      libraries: List<String>.from(json['libraries'] ?? []),
      defines: Map<String, String>.from(json['defines'] ?? {}),
      environment: Map<String, String>.from(json['environment'] ?? {}),
      usePkgConfig: json['usePkgConfig'] ?? true,
      customOutputName: json['customOutputName'],
      linkerFlags: List<String>.from(json['linkerFlags'] ?? []),
      stripSymbols: json['stripSymbols'] ?? false,
      positionIndependentCode: json['positionIndependentCode'] ?? false,
      customCompilerPath: json['customCompilerPath'],
    );
  }
}

/// Class representing a complete compilation configuration
class CompileConfig {
  /// Version of the configuration format
  final String version;
  
  /// Project name
  final String projectName;
  
  /// Project root directory
  final String projectRoot;
  
  /// Default build directory
  final String buildDir;
  
  /// Default compiler settings
  final FileCompileSettings defaultSettings;
  
  /// Individual file settings (overrides default)
  final Map<String, FileCompileSettings> fileSettings;
  
  /// Global environment variables
  final Map<String, String> globalEnvironment;
  
  /// Build profiles (Debug, Release, etc.)
  final Map<String, Map<String, dynamic>> buildProfiles;
  
  /// Pre-build scripts
  final List<String> preBuildScripts;
  
  /// Post-build scripts
  final List<String> postBuildScripts;
  
  /// Dependencies between files
  final Map<String, List<String>> dependencies;

  CompileConfig({
    required this.version,
    required this.projectName,
    required this.projectRoot,
    required this.buildDir,
    required this.defaultSettings,
    required this.fileSettings,
    this.globalEnvironment = const {},
    this.buildProfiles = const {},
    this.preBuildScripts = const [],
    this.postBuildScripts = const [],
    this.dependencies = const {},
  });

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'projectName': projectName,
      'projectRoot': projectRoot,
      'buildDir': buildDir,
      'defaultSettings': defaultSettings.toJson(),
      'fileSettings': fileSettings.map((key, value) => MapEntry(key, value.toJson())),
      'globalEnvironment': globalEnvironment,
      'buildProfiles': buildProfiles,
      'preBuildScripts': preBuildScripts,
      'postBuildScripts': postBuildScripts,
      'dependencies': dependencies,
    };
  }

  /// Create from JSON map
  factory CompileConfig.fromJson(Map<String, dynamic> json) {
    return CompileConfig(
      version: json['version'],
      projectName: json['projectName'],
      projectRoot: json['projectRoot'],
      buildDir: json['buildDir'],
      defaultSettings: FileCompileSettings.fromJson(json['defaultSettings']),
      fileSettings: (json['fileSettings'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, FileCompileSettings.fromJson(value))),
      globalEnvironment: Map<String, String>.from(json['globalEnvironment'] ?? {}),
      buildProfiles: Map<String, Map<String, dynamic>>.from(json['buildProfiles'] ?? {}),
      preBuildScripts: List<String>.from(json['preBuildScripts'] ?? []),
      postBuildScripts: List<String>.from(json['postBuildScripts'] ?? []),
      dependencies: (json['dependencies'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, List<String>.from(value))),
    );
  }
}

/// Utility class for generating configuration files
class ConfigGenerator {
  /// Generate a default configuration file in the specified directory
  static Future<void> generateDefaultConfig(String directory) async {
    final configPath = p.join(directory, 'makeme_config.json');
    
    // Create default settings
    final defaultSettings = FileCompileSettings(
      filePath: 'main.c',
      compiler: Compiler.gcc,
      architecture: Architecture.x64,
      compileType: CompileType.executable,
      packages: [],
      outputPath: 'build/',
      languageStandard: 'c11',
      enableWarnings: true,
      enableDebug: true,
      optimizationLevel: '0',
      usePkgConfig: true,
    );

    // Create sample file-specific settings
    final fileSettings = <String, FileCompileSettings>{
      'main.c': FileCompileSettings(
        filePath: 'main.c',
        compiler: Compiler.gcc,
        architecture: Architecture.x64,
        compileType: CompileType.executable,
        packages: ['gtk+-3.0'],
        outputPath: 'build/',
        languageStandard: 'c11',
        enableWarnings: true,
        enableDebug: true,
        optimizationLevel: '0',
        customOutputName: 'myapp.exe',
      ),
      'utils.cpp': FileCompileSettings(
        filePath: 'utils.cpp',
        compiler: Compiler.gxx,
        architecture: Architecture.x64,
        compileType: CompileType.object,
        packages: [],
        outputPath: 'build/obj/',
        languageStandard: 'c++17',
        enableWarnings: true,
        enableDebug: true,
        optimizationLevel: '0',
      ),
      'lib/mylib.c': FileCompileSettings(
        filePath: 'lib/mylib.c',
        compiler: Compiler.gcc,
        architecture: Architecture.x64,
        compileType: CompileType.sharedLibrary,
        packages: ['sdl2'],
        outputPath: 'build/lib/',
        languageStandard: 'c11',
        enableWarnings: true,
        enableDebug: false,
        optimizationLevel: '2',
        positionIndependentCode: true,
        customOutputName: 'libmylib.dll',
      ),
    };

    // Create build profiles
    final buildProfiles = <String, Map<String, dynamic>>{
      'Debug': {
        'enableDebug': true,
        'optimizationLevel': '0',
        'enableWarnings': true,
        'defines': {'DEBUG': '1', '_DEBUG': '1'},
      },
      'Release': {
        'enableDebug': false,
        'optimizationLevel': '3',
        'enableWarnings': false,
        'stripSymbols': true,
        'defines': {'NDEBUG': '1', 'RELEASE': '1'},
      },
      'MinSizeRel': {
        'enableDebug': false,
        'optimizationLevel': 's',
        'enableWarnings': false,
        'stripSymbols': true,
        'defines': {'NDEBUG': '1'},
      },
    };

    // Create the configuration
    final config = CompileConfig(
      version: '1.0.0',
      projectName: p.basename(directory),
      projectRoot: directory,
      buildDir: 'build',
      defaultSettings: defaultSettings,
      fileSettings: fileSettings,
      globalEnvironment: {
        'CC': 'gcc',
        'CXX': 'g++',
        'CFLAGS': '-Wall -Wextra',
        'CXXFLAGS': '-Wall -Wextra',
      },
      buildProfiles: buildProfiles,
      preBuildScripts: ['echo "Starting build..."'],
      postBuildScripts: ['echo "Build completed!"'],
      dependencies: {
        'main.c': ['utils.cpp', 'lib/mylib.c'],
        'utils.cpp': [],
        'lib/mylib.c': [],
      },
    );

    // Write to file
    await _writeConfigFile(configPath, config);
    print('Configuration file generated at: $configPath');
  }

  /// Generate a configuration file with specific settings
  static Future<void> generateCustomConfig({
    required String directory,
    required String projectName,
    required List<String> sourceFiles,
    Compiler defaultCompiler = Compiler.gcc,
    Architecture defaultArch = Architecture.x64,
    CompileType defaultCompileType = CompileType.executable,
    List<String> defaultPackages = const [],
    String buildDir = 'build',
  }) async {
    final configPath = p.join(directory, 'makeme_config.json');
    
    // Create default settings
    final defaultSettings = FileCompileSettings(
      filePath: sourceFiles.isNotEmpty ? sourceFiles.first : 'main.c',
      compiler: defaultCompiler,
      architecture: defaultArch,
      compileType: defaultCompileType,
      packages: defaultPackages,
      outputPath: '$buildDir/',
      languageStandard: _getDefaultLanguageStandard(defaultCompiler),
      enableWarnings: true,
      enableDebug: true,
      optimizationLevel: '0',
      usePkgConfig: true,
    );

    // Create file-specific settings for each source file
    final fileSettings = <String, FileCompileSettings>{};
    for (final file in sourceFiles) {
      final isMainFile = file.toLowerCase().contains('main') || file == sourceFiles.first;
      final compiler = _getCompilerForFile(file, defaultCompiler);
      final compileType = isMainFile ? CompileType.executable : 
                         file.endsWith('.cpp') || file.endsWith('.c') ? CompileType.object : 
                         CompileType.executable;
      
      fileSettings[file] = FileCompileSettings(
        filePath: file,
        compiler: compiler,
        architecture: defaultArch,
        compileType: compileType,
        packages: isMainFile ? defaultPackages : [],
        outputPath: isMainFile ? '$buildDir/' : '$buildDir/obj/',
        languageStandard: _getDefaultLanguageStandard(compiler),
        enableWarnings: true,
        enableDebug: true,
        optimizationLevel: '0',
        customOutputName: isMainFile ? '${p.basenameWithoutExtension(file)}.exe' : null,
      );
    }

    // Create the configuration
    final config = CompileConfig(
      version: '1.0.0',
      projectName: projectName,
      projectRoot: directory,
      buildDir: buildDir,
      defaultSettings: defaultSettings,
      fileSettings: fileSettings,
      globalEnvironment: {
        'CC': defaultCompiler.name,
        'CXX': defaultCompiler == Compiler.gcc ? 'g++' : 'clang++',
      },
      buildProfiles: _getDefaultBuildProfiles(),
    );

    // Write to file
    await _writeConfigFile(configPath, config);
    print('Custom configuration file generated at: $configPath');
  }

  /// Load configuration from file
  static Future<CompileConfig> loadConfig(String configPath) async {
    final file = File(configPath);
    if (!await file.exists()) {
      throw Exception('Configuration file not found: $configPath');
    }

    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    return CompileConfig.fromJson(json);
  }

  /// Write configuration to file
  static Future<void> _writeConfigFile(String path, CompileConfig config) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    
    const encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(config.toJson());
    await file.writeAsString(jsonString);
  }

  /// Get default language standard for a compiler
  static String _getDefaultLanguageStandard(Compiler compiler) {
    switch (compiler) {
      case Compiler.gcc:
      case Compiler.clang:
        return 'c11';
      case Compiler.gxx:
      case Compiler.clangxx:
        return 'c++17';
    }
  }

  /// Get appropriate compiler for file extension
  static Compiler _getCompilerForFile(String fileName, Compiler defaultCompiler) {
    final ext = p.extension(fileName).toLowerCase();
    switch (ext) {
      case '.c':
        return [Compiler.gcc, Compiler.clang].contains(defaultCompiler) 
            ? defaultCompiler : Compiler.gcc;
      case '.cpp':
      case '.cxx':
      case '.cc':
        return [Compiler.gxx, Compiler.clangxx].contains(defaultCompiler) 
            ? defaultCompiler : Compiler.gxx;
      default:
        return defaultCompiler;
    }
  }

  /// Get default build profiles
  static Map<String, Map<String, dynamic>> _getDefaultBuildProfiles() {
    return {
      'Debug': {
        'enableDebug': true,
        'optimizationLevel': '0',
        'enableWarnings': true,
        'defines': {'DEBUG': '1', '_DEBUG': '1'},
      },
      'Release': {
        'enableDebug': false,
        'optimizationLevel': '3',
        'enableWarnings': false,
        'stripSymbols': true,
        'defines': {'NDEBUG': '1', 'RELEASE': '1'},
      },
      'RelWithDebInfo': {
        'enableDebug': true,
        'optimizationLevel': '2',
        'enableWarnings': true,
        'defines': {'NDEBUG': '1'},
      },
      'MinSizeRel': {
        'enableDebug': false,
        'optimizationLevel': 's',
        'enableWarnings': false,
        'stripSymbols': true,
        'defines': {'NDEBUG': '1'},
      },
    };
  }

  /// Generate configuration for a single file
  static Map<String, dynamic> generateSingleFileConfig({
    required String filePath,
    Compiler compiler = Compiler.gcc,
    Architecture architecture = Architecture.x64,
    CompileType compileType = CompileType.executable,
    List<String> packages = const [],
    String outputPath = 'build/',
    String? languageStandard,
    bool enableWarnings = true,
    bool enableDebug = true,
    String? optimizationLevel = '0',
    List<String> additionalFlags = const [],
    List<String> includeDirs = const [],
    List<String> libraries = const [],
    Map<String, String> defines = const {},
    String? customOutputName,
  }) {
    final settings = FileCompileSettings(
      filePath: filePath,
      compiler: compiler,
      architecture: architecture,
      compileType: compileType,
      packages: packages,
      outputPath: outputPath,
      languageStandard: languageStandard ?? _getDefaultLanguageStandard(compiler),
      enableWarnings: enableWarnings,
      enableDebug: enableDebug,
      optimizationLevel: optimizationLevel,
      additionalFlags: additionalFlags,
      includeDirs: includeDirs,
      libraries: libraries,
      defines: defines,
      customOutputName: customOutputName,
    );

    return settings.toJson();
  }
}
