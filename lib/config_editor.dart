import 'dart:collection';
import 'package:flutter/material.dart';

// Custom color palette
const kPrimaryColor = Color.fromARGB(255, 184, 184, 184);
const kAccentColor = Color(0xFF01B4E4);
const kBackgroundColor = Color(0xFFF3F5F8);
const kWarningColor = Color(0xFFFFA000);
const kPanelColor = Color(0xFFF6F9FB);
const kTextColor = Color.fromARGB(255, 255, 255, 255);
const kSecondaryTextColor = Color.fromARGB(255, 191, 191, 191);

/// Placeholder. You must add real logic for getting default output path.
String getDefaultOutputPath(String fileName) {
  return 'build/'; // TODO: Replace with your own logic
}

class FileSettings {
  int? order;
  String compiler;
  String architecture;
  String compileType;
  String outputPath;
  String customOutputName;
  String languageStandard;
  bool copyAlongBinaries;
  String copyBinariesPath;

  FileSettings({
    this.order,
    this.compiler = 'gcc',
    this.architecture = 'x64',
    this.compileType = '.exe (debug)',
    this.outputPath = '',
    this.customOutputName = '',
    this.languageStandard = 'c11',
    this.copyAlongBinaries = false,
    this.copyBinariesPath = '',
  });

  FileSettings.clone(FileSettings other)
      : order = other.order,
        compiler = other.compiler,
        architecture = other.architecture,
        compileType = other.compileType,
        outputPath = other.outputPath,
        customOutputName = other.customOutputName,
        languageStandard = other.languageStandard,
        copyAlongBinaries = other.copyAlongBinaries,
        copyBinariesPath = other.copyBinariesPath;

  bool get hasOrder => order != null && order! > 0;
  bool get shouldSave => hasOrder || (copyAlongBinaries && copyBinariesPath.isNotEmpty);
}

class ConfigEditorScreen extends StatefulWidget {
  final List<String> files;
  const ConfigEditorScreen({super.key, required this.files});

  @override
  State<ConfigEditorScreen> createState() => _ConfigEditorScreenState();
}

class _ConfigEditorScreenState extends State<ConfigEditorScreen> {
  final Map<String, FileSettings> _fileSettings = HashMap();
  String? _selectedFile;
  bool _saveButtonEnabled = false;
  String? _orderConflictWarning;

  @override
  void initState() {
    super.initState();
    for (var file in widget.files) {
      _fileSettings[file] = FileSettings();
    }
  }

  void _onFileSelected(String file) {
    setState(() {
      _selectedFile = file;
      _checkOrderConflict();
    });
  }

  void _onSettingsChanged() {
    // Quick validation and UI update
    setState(() {
      final fs = _selectedFile != null ? _fileSettings[_selectedFile!] : null;
      _saveButtonEnabled = fs?.shouldSave ?? false;
      _checkOrderConflict();
    });
  }

  void _onOrderChanged(int? value) {
    if (_selectedFile == null) return;
    setState(() {
      _fileSettings[_selectedFile!]!.order = value;
      _checkOrderConflict();
      _onSettingsChanged();
    });
  }

  void _checkOrderConflict() {
    if (_selectedFile == null) return;
    final int? order = _fileSettings[_selectedFile!]!.order;
    String? conflictFile;
    if (order != null && order > 0) {
      for (final entry in _fileSettings.entries) {
        if (entry.key != _selectedFile && entry.value.order == order) {
          conflictFile = entry.key;
          break;
        }
      }
    }
    _orderConflictWarning = conflictFile == null
        ? null
        : 'Order $order already used by "$conflictFile"! Choose a unique value.';
    if (_orderConflictWarning != null) _saveButtonEnabled = false;
  }

  void _onSavePressed() {
    final file = _selectedFile;
    if (file == null) return;
    final settings = _fileSettings[file]!;
    if (!settings.shouldSave) return;
    if (_orderConflictWarning != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_orderConflictWarning!, style: const TextStyle(color: Colors.black)), backgroundColor: kWarningColor),
      );
      return;
    }
    // Save logic placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings for $file saved (in memory).'), backgroundColor: kAccentColor),
    );
    setState(() {
      _saveButtonEnabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 40, 40, 40),
      appBar: AppBar(
        title: const Text('Config Editor'),
        backgroundColor: const Color.fromARGB(255, 62, 62, 62),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Row(
        children: [
          // Left: file picker
          Container(
            width: 270,
            color: const Color.fromARGB(255, 20, 20, 20),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 18, top: 24, right: 18, bottom: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Files:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: kTextColor)),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                    itemCount: widget.files.length,
                    itemBuilder: (context, idx) {
                      final file = widget.files[idx];
                      final selected = file == _selectedFile;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        color: selected ? kAccentColor : kPanelColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          visualDensity: VisualDensity.compact,
                          dense: true,
                          title: Text(file, style: TextStyle(
                            color: selected ? Colors.white : Colors.black,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          )),
                          onTap: () => _onFileSelected(file),
                          selected: selected,
                          selectedTileColor: kAccentColor.withOpacity(0.16),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Right: editor panel
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: _selectedFile == null
                ? const Center(child: Text('No file selected', style: TextStyle(fontSize: 18, color: kSecondaryTextColor)))
                : _buildSettingsPanel(_selectedFile!, _fileSettings[_selectedFile!]!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel(String file, FileSettings settings) {
    TextStyle label = const TextStyle(fontSize: 15, color: kTextColor, fontWeight: FontWeight.w500);
    TextStyle inputText = const TextStyle(fontSize: 15, color: kPrimaryColor, letterSpacing: 0.1);
    TextEditingController compileOrderController = TextEditingController(text: settings.order?.toString() ?? '');
    TextEditingController outputPathController = TextEditingController(text: settings.outputPath.isEmpty ? getDefaultOutputPath(file) : settings.outputPath);
    TextEditingController customOutputNameController = TextEditingController(text: settings.customOutputName);
    TextEditingController copyBinariesPathController = TextEditingController(text: settings.copyBinariesPath);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(file, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kPrimaryColor)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 51, 51, 51),
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.04), offset: const Offset(0,2), blurRadius: 6)]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 140, child: Text('Compile Order:', style: label)),
                      SizedBox(
                        width: 70,
                        child: TextFormField(
                          controller: compileOrderController,
                          style: inputText,
                          keyboardType: TextInputType.number,
                          autocorrect: false,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            hintText: 'none',
                            hintStyle: TextStyle(color: kSecondaryTextColor.withOpacity(0.60)),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            final v = int.tryParse(val);
                            _onOrderChanged(v);
                          },
                        ),
                      ),
                      if (_orderConflictWarning != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Tooltip(child: Icon(Icons.warning_amber_rounded, color: kWarningColor, size: 19),message: _orderConflictWarning,)
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 140, child: Text('Compiler:', style: label)),
                      DropdownButton<String>(
                        value: settings.compiler,
                        dropdownColor: const Color.fromARGB(255, 37, 37, 37),
                        items: const [
                          DropdownMenuItem(value: 'gcc', child: Text('gcc')),
                          DropdownMenuItem(value: 'clang', child: Text('clang')),
                          DropdownMenuItem(value: 'g++', child: Text('g++')),
                          DropdownMenuItem(value: 'clang++', child: Text('clang++')),
                        ],
                        onChanged: (val) {
                          setState(() => settings.compiler = val ?? 'gcc');
                          _onSettingsChanged();
                        },
                        style: inputText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 140, child: Text('Architecture:', style: label)),
                      DropdownButton<String>(
                        value: settings.architecture,
                        dropdownColor: const Color.fromARGB(255, 37, 37, 37),
                        items: const [
                          DropdownMenuItem(value: 'x86', child: Text('x86')),
                          DropdownMenuItem(value: 'x64', child: Text('x64')),
                        ],
                        onChanged: (val) {
                          setState(() => settings.architecture = val ?? 'x64');
                          _onSettingsChanged();
                        },
                        style: inputText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 140, child: Text('Compile Type:', style: label)),
                      DropdownButton<String>(
                        value: settings.compileType,
                        dropdownColor: const Color.fromARGB(255, 37, 37, 37),
                        items: const [
                          DropdownMenuItem(value: '.exe (debug)', child: Text('.exe (debug)')),
                          DropdownMenuItem(value: '.exe (release)', child: Text('.exe (release)')),
                          DropdownMenuItem(value: '.dll', child: Text('.dll')),
                          DropdownMenuItem(value: '.lib', child: Text('.lib')),
                          DropdownMenuItem(value: '.obj', child: Text('.obj')),
                          DropdownMenuItem(value: '.so', child: Text('.so')),
                        ],
                        onChanged: (val) {
                          setState(() => settings.compileType = val ?? '.exe (debug)');
                          _onSettingsChanged();
                        },
                        style: inputText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 140, child: Text('Output Path:', style: label)),
                      Expanded(
                        child: TextFormField(
                          controller: outputPathController,
                          style: inputText,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            hintText: getDefaultOutputPath(file),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            setState(() => settings.outputPath = val);
                            _onSettingsChanged();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 140, child: Text('Custom Output Name:', style: label)),
                      Expanded(
                        child: TextFormField(
                          controller: customOutputNameController,
                          style: inputText,
                          decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                          onChanged: (val) {
                            setState(() => settings.customOutputName = val);
                            _onSettingsChanged();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 140, child: Text('Language Standard:', style: label)),
                        DropdownButton<String>(
                        value: _getLanguageStandards(settings.compiler).contains(settings.languageStandard)
                            ? settings.languageStandard
                            : _getLanguageStandards(settings.compiler).isNotEmpty
                                ? _getLanguageStandards(settings.compiler).first
                                : null,
                        dropdownColor: const Color.fromARGB(255, 37, 37, 37),
                        items: _getLanguageStandards(settings.compiler)
                            .map((std) => DropdownMenuItem(value: std, child: Text(std)))
                            .toList(),
                        onChanged: (v) {
                          setState(() => settings.languageStandard = v ?? _getLanguageStandards(settings.compiler).first);
                          _onSettingsChanged();
                        },
                        style: inputText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: settings.copyAlongBinaries,
                        activeColor: kAccentColor,
                        onChanged: (v) {
                          setState(() => settings.copyAlongBinaries = v ?? false);
                          if (!settings.copyAlongBinaries) settings.copyBinariesPath = '';
                          _onSettingsChanged();
                          if (!settings.copyAlongBinaries) copyBinariesPathController.text = '';
                        },
                      ),
                      const SizedBox(width: 4),
                      Text('Copy Along Binaries', style: label.copyWith(fontSize: 14)),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: copyBinariesPathController,
                          style: inputText,
                          enabled: settings.copyAlongBinaries,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Relative path',
                            border: const OutlineInputBorder(),
                            fillColor: settings.copyAlongBinaries ? Colors.white : kPanelColor,
                            filled: true,
                          ),
                          onChanged: (val) {
                            setState(() => settings.copyBinariesPath = val);
                            _onSettingsChanged();
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _saveButtonEnabled ? _onSavePressed : null,
                        icon: const Icon(Icons.save, size: 19),
                        label: const Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _saveButtonEnabled ? kAccentColor : kPanelColor,
                          foregroundColor: _saveButtonEnabled ? Colors.white : kSecondaryTextColor,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 19),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                          elevation: _saveButtonEnabled ? 1 : 0,
                          minimumSize: const Size(90, 44),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildGeneratedCommand(file, settings),
          ],
        ),
      ),
    );
  }

  List<String> _getLanguageStandards(String compiler) {
    const c = ['c89', 'c99', 'c11', 'gnu99'];
    const cpp = ['c++03', 'c++11', 'c++14', 'c++17', 'c++20'];
    switch (compiler) {
      case 'gcc':
      case 'clang':
        return [...c, ...cpp];
      case 'g++':
      case 'clang++':
        return cpp;
      default:
        return c;
    }
  }

  Widget _buildGeneratedCommand(String file, FileSettings settings) {
    String archStr = settings.architecture == 'x64' ? 'x86_64-w64-mingw32' : 'i686-w64-mingw32';
    String baseName = settings.customOutputName.isNotEmpty
        ? settings.customOutputName
        : file.split('.').first;
    String outputName;
    switch (settings.compileType) {
      case '.exe (debug)':
      case '.exe (release)':
        outputName = '${baseName}_$archStr.exe';
        break;
      case '.dll':
        outputName = '$baseName.dll';
        break;
      case '.lib':
        outputName = '$baseName.lib';
        break;
      case '.obj':
        outputName = '$baseName.o';
        break;
      case '.so':
        outputName = '$baseName.so';
        break;
      default:
        outputName = baseName;
    }
    String outputPath = settings.outputPath.isEmpty ? getDefaultOutputPath(file) : settings.outputPath;
    String cmd = [
      settings.compiler,
      '-target',
      archStr,
      if (settings.languageStandard.isNotEmpty) '-std=${settings.languageStandard}',
      // Add compile type flags
      if (settings.compileType == '.exe (debug)') ...['-g', '-O0'],
      if (settings.compileType == '.exe (release)') ...['-O2', '-DNDEBUG'],
      if (settings.compileType == '.dll') ...['-shared'],
      if (settings.compileType == '.lib') ...['-static'],
      if (settings.compileType == '.obj') ...['-c'],
      if (settings.compileType == '.so') ...['-shared', '-fPIC'],
      '-o', "'${outputPath}${outputName}'",
      "'${file.split('/').last}'"
    ].join(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(child: const Text('Generated Command:')),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          width: double.infinity,
          color: const Color.fromARGB(255, 51, 51, 51),
          child: Text(cmd, style: const TextStyle(fontFamily: 'monospace')),
        ),
      ],
    );
  }
}

