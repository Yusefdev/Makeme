import 'dart:ui';
import 'package:flutter/material.dart';

class MainFileSelectorOverlay extends StatelessWidget {
  final List<String> candidates;
  final void Function(String selectedFile) onSelected;
  final VoidCallback? onCancel;

  const MainFileSelectorOverlay({
    Key? key,
    required this.candidates,
    required this.onSelected,
    this.onCancel,
  }) : super(key: key);

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
                width: MediaQuery.of(context).size.width * 0.8,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 51, 51, 51),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select Main File',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: candidates.length,
                        itemBuilder: (context, index) {
                          final file = candidates[index];
                          return Material(color: Colors.transparent,
                            child: ListTile(hoverColor: Colors.white38,
                              title: Text(file, style: const TextStyle(fontSize: 16)),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                onSelected(file);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        if (onCancel != null) {
                          onCancel!();
                        }
                      },
                      child: const Text('Cancel'),
                    ),
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