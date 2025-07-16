import 'dart:ui';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class ProjectpathSelectorOverlay extends StatelessWidget {
  final void Function(String selectedpath) onSelected;

  const ProjectpathSelectorOverlay({
    super.key,
    required this.onSelected,
  });

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

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(color: Colors.transparent,
        child: Stack(
          children: [
            // Blurred transparent background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
        
            // Center dialog box
            Center(
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 51, 51, 51),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select project path',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: () {
                      pickDirectory().then((onValue){
                        if (onValue != null) {
                          onSelected(onValue);
                        }
                      });
                    }, child: const Text("browse"))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}