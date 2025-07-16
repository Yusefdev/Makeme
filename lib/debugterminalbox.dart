import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:makeme/AnsiTextParser.dart';

class DebugTerminalBox extends StatelessWidget {
  final String debugText;
  final double? width;
  final double? height;
  final Color? BGcolor;
  final VoidCallback? onClear;
  final void Function(String)? onLoad;

  const DebugTerminalBox({
    super.key,
    required this.debugText,
    this.width,
    this.height,
    this.BGcolor,
    this.onClear,
    this.onLoad,
  });

  Future<void> _saveLogToFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save log as...',
        fileName: 'build_log.txt',
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(debugText);
        print("Saved to: ${file.path}");
      }
    } catch (e) {
        print("Failed to save: $e");
    }
  }

  Future<void> _loadLogFromFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final contents = await file.readAsString();
        if (onLoad != null) onLoad!(contents);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load file: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final spans = AnsiTextParser.parse(debugText);
    final vertical = ScrollController();
    final horizontal = ScrollController();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 400,
        decoration: BoxDecoration(
          color: BGcolor ?? Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Toolbar
            Row(
              children: [
                const Icon(Icons.terminal, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Build Logs",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: "Copy All",
                  icon: const Icon(Icons.copy, color: Colors.white70, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: debugText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Copied to clipboard")),
                    );
                  },
                ),
                IconButton(
                  tooltip: "Save as .txt",
                  icon: const Icon(Icons.save, color: Colors.white70, size: 18),
                  onPressed: () => _saveLogToFile(context),
                ),
                IconButton(
                  tooltip: "Load from file",
                  icon: const Icon(Icons.folder_open, color: Colors.white70, size: 18),
                  onPressed: () => _loadLogFromFile(context),
                ),
                IconButton(
                  tooltip: "Clear",
                  icon: const Icon(Icons.clear_all, color: Colors.white70, size: 18),
                  onPressed: onClear,
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 8),

            // Terminal content
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox.expand(
                  child: Scrollbar(
                    controller: vertical,
                    thumbVisibility: true,
                    radius: const Radius.circular(6),
                    thickness: 6,
                    child: Scrollbar(
                      controller: horizontal,
                      thumbVisibility: true,
                      radius: const Radius.circular(6),
                      thickness: 6,
                      child: SingleChildScrollView(
                        controller: vertical,
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          controller: horizontal,
                          scrollDirection: Axis.horizontal,
                          child: SelectableText.rich(
                            TextSpan(children: spans),
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontFamily: 'SourceCodePro',
                              fontSize: 13,
                              height: 1.4,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}