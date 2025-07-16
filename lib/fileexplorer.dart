import 'dart:io';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class FileExplorer extends StatefulWidget {
  final String path;
  final Map<String, String> fileIcons;
  final Function(String)? openexplorer;
  final Function(String)? setasmain;

  const FileExplorer({
    super.key,
    required this.path,
    required this.fileIcons, this.openexplorer, this.setasmain,
  });

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  final ScrollController _scrollController = ScrollController();

  Future<List<FileSystemEntity>> _getEntities(String path) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      final List<FileSystemEntity> entities = await dir.list().toList();
      entities.sort((a, b) {
        if (a is Directory && b is File) return -1;
        if (a is File && b is Directory) return 1;
        return a.path.compareTo(b.path);
      });
      return entities;
    }
    return [];
  }

  void _showContextMenu(BuildContext context, Offset position, String itemName) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40), // small rect at click location
        Offset.zero & overlay.size,
      ),
      items: [
        if(itemName.endsWith(".c") ||itemName.endsWith(".cpp")) PopupMenuItem(child: const Text('select as main file'),value: "${widget.path}\\${itemName},{m}"),
        PopupMenuItem(value: "${widget.path}\\${itemName},{o}", child: Text('show in explorer')),
      ],
    ).then((value) {
      if (value != null) {
        print('$value selected on $itemName');
        if(value.endsWith(",{m}")){
          widget.setasmain!(value.substring(0,value.length-4));
        }
        else{
          widget.openexplorer!(value.substring(0,value.length-4));
        }
        // Handle actions here
      }
    });
  }

  Widget _buildTree(String path, {int depth = 0}) {
    return FutureBuilder<List<FileSystemEntity>>(
      future: _getEntities(path),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("No files found"),
          );
        }

        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: snapshot.data!.map((entity) {
                if (entity is Directory) {
                  return _DirectoryTile(
                    entity: entity,
                    depth: depth,
                    fileIcons: widget.fileIcons,
                  );
                } else if (entity is File) {
                  return _buildFileTile(entity, depth);
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFileTile(File file, int depth) {
    final ext = p.extension(file.path).toLowerCase();
    final iconPath = widget.fileIcons[ext];

    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, bottom: 4),
      child: Listener(onPointerDown: (event) {
        if (event.kind == PointerDeviceKind.mouse &&
                event.buttons == kSecondaryMouseButton) {
              _showContextMenu(context, event.position, p.basename(file.path));
            }
      },
        child: Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: iconPath != null
                ? Image.asset(iconPath, width: 24, height: 24)
                : const Icon(Icons.insert_drive_file_outlined, color: Colors.grey),
            title: Text(p.basename(file.path)),
            visualDensity: VisualDensity.compact,
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            onTap: () {
              // Implement file tap logic here (if needed)
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTree(widget.path);
  }
}


class _DirectoryTile extends StatefulWidget {
  final Directory entity;
  final int depth;
  final Map<String, String> fileIcons;

  const _DirectoryTile({
    required this.entity,
    required this.depth,
    required this.fileIcons,
  });

  @override
  State<_DirectoryTile> createState() => __DirectoryTileState();
}

class __DirectoryTileState extends State<_DirectoryTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: widget.depth * 16.0, bottom: 4),
            child: Card(
              elevation: 1.5,
              color: const Color.fromARGB(255, 68, 68, 68),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: const Icon(Icons.folder_open, color: Colors.amber),
                title: Text(
                  p.basename(widget.entity.path),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                visualDensity: VisualDensity.compact,
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                onTap: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: FileExplorer(
                path: widget.entity.path,
                fileIcons: widget.fileIcons
              ),
            ),
        ],
      ),
    );
  }
}