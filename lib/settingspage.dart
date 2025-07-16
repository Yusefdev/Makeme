import 'package:flutter/material.dart';
import 'package:makeme/Backend/restartapp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart'; // Required for FlexScheme

class SettingsOverlay extends StatefulWidget {
  final Function(Map<String, dynamic>) onClose;
  final dynamic mainappcontext;

  const SettingsOverlay({super.key, required this.onClose,required this.mainappcontext});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}


class _SettingsOverlayState extends State<SettingsOverlay> {
  final TextEditingController _buildFolderController = TextEditingController();
  final TextEditingController _msys2PathController = TextEditingController();

  int _buildHistoryCount = 5;
  bool _backupBuild = true;
  bool _createClangd = true;
  bool _autoDetectPackage = true;
  bool _isReleaseMode = true;
  bool _msys2vscodeshell = true;
  bool _runexcutableafbuild = true;
  bool _useEnvMsys2 = true;
  bool _isDarkMode = true;
  FlexScheme _theme = FlexScheme.material;
  String _mainFileStrategy = "prefer_main_c_cpp";

  bool _showRestart = false;

  late SharedPreferences _prefs;

  final _mainFileOptions = {
    "prefer_main_c_cpp": "Prefer main.c/cpp first",
    "any_with_main": "Any file with int main()",
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _buildFolderController.text = _prefs.getString('buildFolder') ?? 'build/';
      _msys2PathController.text = _prefs.getString('msys2Path') ?? '';
      _buildHistoryCount = _prefs.getInt('buildHistoryCount') ?? 5;
      _backupBuild = _prefs.getBool('backupBuild') ?? true;
      _createClangd = _prefs.getBool('createClangd') ?? true;
      _autoDetectPackage = _prefs.getBool('autoDetectPackage') ?? true;
      _isReleaseMode = _prefs.getBool('isReleaseMode') ?? true;
      _useEnvMsys2 = _prefs.getBool('useEnvMsys2') ?? true;
      _isDarkMode = _prefs.getBool('isDarkMode') ?? true;
      _msys2vscodeshell = _prefs.getBool('msys2vscodeshell') ?? true;
      _runexcutableafbuild = _prefs.getBool('runexcutableafbuild') ?? true;

      _mainFileStrategy = _prefs.getString('mainFileStrategy') ?? 'prefer_main_c_cpp';
      _theme = FlexScheme.values.firstWhere(
        (e) => e.name == (_prefs.getString('theme') ?? FlexScheme.material.name),
        orElse: () => FlexScheme.material,
      );
    });
  }

  Future<void> _saveSettings() async {
    await _prefs.setString('buildFolder', _buildFolderController.text);
    await _prefs.setString('msys2Path', _msys2PathController.text);
    await _prefs.setInt('buildHistoryCount', _buildHistoryCount);
    await _prefs.setBool('backupBuild', _backupBuild);
    await _prefs.setBool('createClangd', _createClangd);
    await _prefs.setBool('autoDetectPackage', _autoDetectPackage);
    await _prefs.setBool('isReleaseMode', _isReleaseMode);
    await _prefs.setBool('useEnvMsys2', _useEnvMsys2);
    await _prefs.setBool('isDarkMode', _isDarkMode);
    await _prefs.setBool('msys2vscodeshell', _msys2vscodeshell);
    await _prefs.setBool('runexcutableafbuild', _runexcutableafbuild);
    await _prefs.setString('theme', _theme.name);
  }

  void _closeAndReturn() async {
    await _saveSettings();
    widget.onClose({
      'buildFolder': _buildFolderController.text,
      'msys2Path': _msys2PathController.text,
      'buildHistoryCount': _buildHistoryCount,
      'backupBuild': _backupBuild,
      'createClangd': _createClangd,
      'autoDetectPackage': _autoDetectPackage,
      'isReleaseMode': _isReleaseMode,
      'useEnvMsys2': _useEnvMsys2,
      'isDarkMode': _isDarkMode,
      'msys2vscodeshell': _msys2vscodeshell,
      'runexcutableafbuild': _runexcutableafbuild,
      'theme': _theme.name,
      'mainFileStrategy': _mainFileStrategy,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Settings",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _closeAndReturn,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Main File Detection Strategy:"),
                        DropdownButton<String>(
                          value: _mainFileStrategy,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _mainFileStrategy = value);
                            }
                          },
                          items: _mainFileOptions.entries
                              .map((e) => DropdownMenuItem(
                                    value: e.key,
                                    child: Text(e.value),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 16),

                        const Text("Build Folder Path:"),
                        TextField(
                          controller: _buildFolderController,
                          decoration: const InputDecoration(
                            hintText: "e.g., build/",
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const Divider(height: 16),

                        const Text("MSYS2 Path:"),
                        SwitchListTile(
                          title: const Text("Use Environment Path for MSYS2"),
                          value: _useEnvMsys2,
                          onChanged: (val) {
                            setState(() {
                              _useEnvMsys2 = val;
                            });
                          },
                        ),
                        TextField(
                          controller: _msys2PathController,
                          enabled: !_useEnvMsys2,
                          decoration: const InputDecoration(
                            hintText: "e.g., C:/msys64/usr/bin",
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text("Build History Count:"),
                        Slider(
                          min: 1,
                          max: 20,
                          divisions: 19,
                          value: _buildHistoryCount.toDouble(),
                          label: _buildHistoryCount.toString(),
                          onChanged: (value) => setState(() => _buildHistoryCount = value.toInt()),
                        ),
                        const Divider(height: 16),

                        SwitchListTile(
                          title: const Text("Backup build in .zst"),
                          value: _backupBuild,
                          onChanged: (val) => setState(() => _backupBuild = val),
                        ),

                        SwitchListTile(
                          title: const Text("Create .clangd file if missing"),
                          value: _createClangd,
                          onChanged: (val) => setState(() => _createClangd = val),
                        ),

                        SwitchListTile(
                          title: const Text("Auto-detect package name"),
                          value: _autoDetectPackage,
                          onChanged: (val) => setState(() => _autoDetectPackage = val),
                        ),

                        SwitchListTile(
                          title: const Text("Build Mode"),
                          subtitle: Text(_isReleaseMode
                              ? "Release (optimized)"
                              : "Debug (with logs)"),
                          value: _isReleaseMode,
                          onChanged: (val) => setState(() => _isReleaseMode = val),
                        ),

                        SwitchListTile(
                          title: const Text("vscode Msys2 shell"),
                          subtitle: Text(_msys2vscodeshell
                              ? "Enabled (can use it in terminal,launch profile,and then select Msys2)"
                              : "Disabled"),
                          value: _msys2vscodeshell,
                          onChanged: (val) => setState(() => _msys2vscodeshell = val),
                        ),

                        SwitchListTile(
                          title: const Text("run excutable after build"),
                          subtitle: Text(_runexcutableafbuild
                              ? "Enabled"
                              : "Disabled"),
                          value: _runexcutableafbuild,
                          onChanged: (val) => setState(() => _runexcutableafbuild = val),
                        ),

                        const Divider(height: 32),

                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButton<FlexScheme>(
                                value: _theme,
                                isExpanded: true,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _theme = val;
                                      _showRestart = true;
                                    });
                                  }
                                },
                                items: FlexScheme.values.map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(e.name),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SwitchListTile(
                                title: const Text("Dark Mode"),
                                value: _isDarkMode,
                                onChanged: (val) {
                                  setState(() {
                                    _isDarkMode = val;
                                    _showRestart = true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_showRestart)
                              ElevatedButton.icon(
                                onPressed: () {
                                  _saveSettings().then((_) async {
                                    await _saveSettings();
                                    RestartWidget.restartApp(widget.mainappcontext);
                                  });
                                },
                                icon: const Icon(Icons.restart_alt),
                                label: const Text("Restart"),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}