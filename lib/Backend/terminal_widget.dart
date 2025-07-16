import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTerminalEmulator extends StatefulWidget {
  final double width;
  final double height;

  const CustomTerminalEmulator({super.key, this.width = 600, this.height = 400});

  @override
  State<CustomTerminalEmulator> createState() => _CustomTerminalEmulatorState();
}

class _CustomTerminalEmulatorState extends State<CustomTerminalEmulator> {
  late Process _process;
  late StreamSubscription _stdoutSub;
  late StreamSubscription _stderrSub;

  final ScrollController _scrollController = ScrollController();

  final List<String> _outputLines = [];

  String _cwd = Directory.current.path;

  final List<int> _inputBuffer = [];
  int _cursorPos = 0;

  TextSelection inputSelection = const TextSelection.collapsed(offset: -1);

  bool _showCursor = true;
  Timer? _cursorTimer;

  FocusNode focusNode = FocusNode();

  final List<String> _commandHistory = [];

  List<String> _suggestions = [];
  int _selectedSuggestionIndex = -1;
  int _suggestionScrollOffset = 0;
  static const int _visibleSuggestionCount = 1;

  @override
  void initState() {
    super.initState();
    _startShell();
    _startCursorTimer();
    focusNode.requestFocus();
  }

  void _startCursorTimer() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        _showCursor = !_showCursor;
      });
    });
  }

  Future<void> _startShell() async {
    _process = await Process.start('powershell.exe', [], runInShell: true);
    _stdoutSub = _process.stdout.listen(_onStdoutData);
    _stderrSub = _process.stderr.listen(_onStdoutData);
    _process.stdin.writeln('pwd');
  }

  void _onStdoutData(List<int> data) {
    final text = utf8.decode(data);
    final lines = text.split('\n');
    setState(() {
      for (var line in lines) {
        line = line.trimRight();
        if (line.isEmpty) continue;
        if (line.startsWith('Path') || line.startsWith('Directory') || line.startsWith(r'C:\') || line.startsWith('/')) {
          final pathCandidate = line.trim();
          final dir = Directory(pathCandidate);
          if (dir.existsSync()) {
            _cwd = dir.path;
            continue;
          }
        }
        _outputLines.add(line);
      }
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _isControlCharacter(String ch) {
    return ch.codeUnitAt(0) < 32;
  }

  void _deleteSelectedText() {
    if (inputSelection.isValid && !inputSelection.isCollapsed) {
      final start = inputSelection.start;
      final end = inputSelection.end;
      _inputBuffer.removeRange(start, end);
      _cursorPos = start;
      inputSelection = TextSelection.collapsed(offset: _cursorPos);
    }
  }

  void _handleKey(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    final key = event.logicalKey;
    final ctrl = event.isControlPressed;

    if (ctrl && key == LogicalKeyboardKey.keyV) {
      Clipboard.getData('text/plain').then((clipData) {
        if (clipData != null && clipData.text != null) {
          final pasted = clipData.text!;
          setState(() {
            if (inputSelection.isValid && !inputSelection.isCollapsed) {
              _deleteSelectedText();
            }
            for (var rune in pasted.runes) {
              _inputBuffer.insert(_cursorPos, rune);
              _cursorPos++;
            }
            inputSelection = TextSelection.collapsed(offset: _cursorPos);
            _updateSuggestions();
          });
        }
      });
      return;
    }

    if (ctrl && key == LogicalKeyboardKey.keyC) {
      _process.stdin.add([3]);
      setState(() {
        _inputBuffer.clear();
        _cursorPos = 0;
        inputSelection = TextSelection.collapsed(offset: 0);
        _suggestions.clear();
        _selectedSuggestionIndex = -1;
        _suggestionScrollOffset = 0;
      });
      return;
    }

    if (key == LogicalKeyboardKey.tab) {
      if (_suggestions.isNotEmpty) {
        setState(() {
          _selectedSuggestionIndex = (_selectedSuggestionIndex + 1) % _suggestions.length;
          if (_selectedSuggestionIndex >= _suggestionScrollOffset + _visibleSuggestionCount) {
            _suggestionScrollOffset = _selectedSuggestionIndex - _visibleSuggestionCount + 1;
          }
        });
      }
      return;
    }

    if (_suggestions.isNotEmpty) {
      if (key == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _scrollToBottom();
          if (_selectedSuggestionIndex > 0) {
            _selectedSuggestionIndex--;
            if (_selectedSuggestionIndex < _suggestionScrollOffset) {
              _suggestionScrollOffset--;
            }
          }

        });
        return;
      }

      if (key == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _scrollToBottom();
          if (_selectedSuggestionIndex < _suggestions.length - 1) {
            _selectedSuggestionIndex++;
            if (_selectedSuggestionIndex >= _suggestionScrollOffset + _visibleSuggestionCount) {
              _suggestionScrollOffset++;
            }
          }
        });
        return;
      }
    }

    setState(() {
      switch (key) {
        case LogicalKeyboardKey.enter:
          if (_selectedSuggestionIndex >= 0 && _selectedSuggestionIndex < _suggestions.length) {
            final selected = _suggestions[_selectedSuggestionIndex];
            _inputBuffer
              ..clear()
              ..addAll(selected.codeUnits);
            _cursorPos = _inputBuffer.length;
            _suggestions.clear();
            _selectedSuggestionIndex = -1;
            _suggestionScrollOffset = 0;
          } else {
            final inputStr = String.fromCharCodes(_inputBuffer);
            if (inputStr.trim().isNotEmpty) {
              _commandHistory.add(inputStr);
            }
            _sendInput();
          }
          break;
        case LogicalKeyboardKey.backspace:
          if (inputSelection.isValid && !inputSelection.isCollapsed) {
            _deleteSelectedText();
          } else if (_cursorPos > 0) {
            _inputBuffer.removeAt(_cursorPos - 1);
            _cursorPos--;
          }
          break;
        case LogicalKeyboardKey.delete:
          if (inputSelection.isValid && !inputSelection.isCollapsed) {
            _deleteSelectedText();
          } else if (_cursorPos < _inputBuffer.length) {
            _inputBuffer.removeAt(_cursorPos);
          }
          break;
        case LogicalKeyboardKey.arrowLeft:
          if (_cursorPos > 0) _cursorPos--;
          break;
        case LogicalKeyboardKey.arrowRight:
          if (_cursorPos < _inputBuffer.length) _cursorPos++;
          break;
        default:
          if (event.character != null &&
              event.character!.isNotEmpty &&
              !_isControlCharacter(event.character!)) {
            if (inputSelection.isValid && !inputSelection.isCollapsed) {
              _deleteSelectedText();
            }
            _inputBuffer.insert(_cursorPos, event.character!.codeUnitAt(0));
            _cursorPos++;
          }
      }
      inputSelection = TextSelection.collapsed(offset: _cursorPos);
      _updateSuggestions();
    });
  }

  void _updateSuggestions() {
    final typed = String.fromCharCodes(_inputBuffer);
    _suggestions = _generateSuggestions(typed);
    _selectedSuggestionIndex = -1;
    _suggestionScrollOffset = 0;
  }

  List<String> _generateSuggestions(String input) {
    final parts = input.trim().split(' ');
    if (parts.isEmpty) return [];

    final cmd = parts[0].toLowerCase();

    final Set<String> matches = {};

    if (cmd == 'cd') {
      final dirPrefix = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      final dir = Directory(_cwd);
      try {
        for (final entity in dir.listSync()) {
          if (entity is Directory) {
            final name = entity.path.split(Platform.pathSeparator).last;
            if (name.startsWith(dirPrefix)) {
              matches.add('cd $name');
            }
          }
        }
      } catch (_) {}
    }

    for (final h in _commandHistory) {
      if (h.startsWith(input)) matches.add(h);
    }

    return matches.toList();
  }

  void _sendInput() {
    final input = String.fromCharCodes(_inputBuffer);
    _outputLines.add('$_cwd> $input');

    final trimmed = input.trim();

    if (trimmed.startsWith('cd ')) {
      final pathArg = trimmed.substring(3).trim();
      _handleLocalCd(pathArg);
    }

    if (trimmed == 'cls' || trimmed == 'clear') {
      _outputLines.clear();
    } else {
      _process.stdin.writeln(input);
      if (!trimmed.startsWith('cd ')) {
        _process.stdin.writeln('pwd');
      }
    }

    _inputBuffer.clear();
    _cursorPos = 0;
    inputSelection = TextSelection.collapsed(offset: 0);
    _suggestions.clear();
    _selectedSuggestionIndex = -1;
    _suggestionScrollOffset = 0;
    _scrollToBottom();
  }

  void _handleLocalCd(String pathArg) {
    try {
      final newUri = Directory(_cwd).uri.resolve(pathArg + (pathArg.endsWith(Platform.pathSeparator) ? '' : Platform.pathSeparator));
      final newPath = newUri.toFilePath();
      final dir = Directory(newPath);
      if (dir.existsSync()) {
        setState(() {
          _cwd = dir.path;
        });
      } else {
        _outputLines.add("The system cannot find the path specified: $pathArg");
      }
    } catch (e) {
      _outputLines.add("Error processing cd command: $e");
    }
  }

  TextSpan _buildInputLine() {
    final text = String.fromCharCodes(_inputBuffer);
    final beforeCursor = text.substring(0, _cursorPos);
    final afterCursor = text.substring(_cursorPos);
    final sel = inputSelection;
    List<InlineSpan> children = [];

    children.add(TextSpan(
      text: '$_cwd> ',
      style: const TextStyle(color: Color.fromARGB(255, 105, 240, 125), fontFamily: 'Courier', fontSize: 14, fontWeight: FontWeight.bold),
    ));

    if (sel.isValid && !sel.isCollapsed) {
      children.add(TextSpan(text: beforeCursor.substring(0, sel.start), style: const TextStyle(color: Colors.greenAccent, fontFamily: 'Courier', fontSize: 14)));
      children.add(TextSpan(text: beforeCursor.substring(sel.start), style: TextStyle(backgroundColor: Colors.greenAccent.withOpacity(0.4), color: Colors.black, fontFamily: 'Courier', fontSize: 14)));
      children.add(TextSpan(text: afterCursor.substring(0, sel.end - sel.start), style: TextStyle(backgroundColor: Colors.greenAccent.withOpacity(0.4), color: Colors.black, fontFamily: 'Courier', fontSize: 14)));
      children.add(TextSpan(text: afterCursor.substring(sel.end - sel.start), style: const TextStyle(color: Colors.greenAccent, fontFamily: 'Courier', fontSize: 14)));
    } else {
      children.add(TextSpan(text: beforeCursor, style: const TextStyle(color: Colors.greenAccent, fontFamily: 'Courier', fontSize: 14)));
      if (_showCursor) {
        children.add(const TextSpan(text: '|', style: TextStyle(backgroundColor: Colors.greenAccent, color: Colors.black)));
      }
      children.add(TextSpan(text: afterCursor, style: const TextStyle(color: Colors.greenAccent, fontFamily: 'Courier', fontSize: 14)));
    }

    return TextSpan(children: children);
  }

  Map<String, bool> checkMoreUpDown({
    required int suggestionScrollOffset,
    required int visibleSuggestionsCount,
    required int totalSuggestionsCount,
  }) {
    final bool moreUp = suggestionScrollOffset > 0;
    final bool moreDown = (suggestionScrollOffset + visibleSuggestionsCount) <
        totalSuggestionsCount;

    return {
      'moreUp': moreUp,
      'moreDown': moreDown,
    };
  }

  @override
  void dispose() {
    _stdoutSub.cancel();
    _stderrSub.cancel();
    _process.kill();
    _cursorTimer?.cancel();
    focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outputSpans = <TextSpan>[];
    for (final line in _outputLines) {
      outputSpans.add(TextSpan(text: line + '\n', style: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontSize: 14)));
    }

    final visibleSuggestions = _suggestions
        .skip(_suggestionScrollOffset)
        .take(_visibleSuggestionCount)
        .toList();


    // 
    final result = checkMoreUpDown(
      suggestionScrollOffset: _suggestionScrollOffset,
      visibleSuggestionsCount: visibleSuggestions.length,
      totalSuggestionsCount: _suggestions.length,
    );

    bool upArrowVisible = result['moreUp']!;
    bool downArrowVisible = result['moreDown']!;
    // 

    final suggestionWidgets = visibleSuggestions.asMap().entries.map((entry) {
      final idx = _suggestionScrollOffset + entry.key;
      final suggestion = entry.value;
      final selected = idx == _selectedSuggestionIndex;

      return Container(
        width: double.infinity,
        color: selected ? const Color.fromARGB(255, 16, 126, 6) : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          suggestion,
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: 14,
            color: selected ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 132, 0, 255),
          ),
        ),
      );
    }).toList();

    return GestureDetector(
      onTap: () => focusNode.requestFocus(),
      child: Expanded(
        child: Container(decoration: BoxDecoration(color: Colors.black,borderRadius: BorderRadius.circular(12)),
          // width: widget.width,
          // height: widget.height,
          padding: const EdgeInsets.all(8),
          child: Focus(
            focusNode: focusNode,
            onKey: (FocusNode node, RawKeyEvent event) {
              if (event is RawKeyDownEvent) {
                final key = event.logicalKey;
                if (key == LogicalKeyboardKey.arrowLeft ||
                    key == LogicalKeyboardKey.arrowRight ||
                    key == LogicalKeyboardKey.arrowUp ||
                    key == LogicalKeyboardKey.arrowDown ||
                    key == LogicalKeyboardKey.tab) {
                  _handleKey(event);
                  return KeyEventResult.handled;
                }
                _handleKey(event);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
                        children: outputSpans,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(text: _buildInputLine()),
                    upArrowVisible? Center(child: Icon(Icons.arrow_drop_up)):const SizedBox(height: 24),
                    ...suggestionWidgets,
                    downArrowVisible? Center(child: Icon(Icons.arrow_drop_down)):const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}