import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:highlight/highlight.dart';

class SourceCodeViewerScreen extends StatefulWidget {
  final String projectId;

  const SourceCodeViewerScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<SourceCodeViewerScreen> createState() => _SourceCodeViewerScreenState();
}

class _SourceCodeViewerScreenState extends State<SourceCodeViewerScreen> {
  String? _selectedFile;
  String _codeContent = '';
  List<String> _availableFiles = [];
  int _fontSize = 14;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableFiles();
  }

  Future<void> _loadAvailableFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final libDir =
          '/storage/emulated/0/.sketchide/data/${widget.projectId}/files/lib';
      final directory = Directory(libDir);

      if (await directory.exists()) {
        final files = await directory
            .list()
            .where((entity) => entity is File && entity.path.endsWith('.dart'))
            .map((entity) => path.basename(entity.path))
            .toList();

        setState(() {
          _availableFiles = files;
          if (files.isNotEmpty) {
            _selectedFile = files.first;
            _loadFileContent(files.first);
          }
        });
      } else {
        setState(() {
          _availableFiles = [];
          _codeContent = 'No generated files found.';
        });
      }
    } catch (e) {
      setState(() {
        _codeContent = 'Error loading files: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFileContent(String fileName) async {
    try {
      final filePath =
          '/storage/emulated/0/.sketchide/data/${widget.projectId}/files/lib/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          _codeContent = content;
        });
      } else {
        setState(() {
          _codeContent = 'File not found: $fileName';
        });
      }
    } catch (e) {
      setState(() {
        _codeContent = 'Error reading file: $e';
      });
    }
  }

  void _showFileSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select File'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _availableFiles.length,
            itemBuilder: (context, index) {
              final fileName = _availableFiles[index];
              return ListTile(
                leading: const Icon(Icons.code),
                title: Text(fileName),
                onTap: () {
                  setState(() {
                    _selectedFile = fileName;
                  });
                  _loadFileContent(fileName);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    int tempFontSize = _fontSize;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editor Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Font Size: '),
                  Expanded(
                    child: Slider(
                      value: tempFontSize.toDouble(),
                      min: 10,
                      max: 24,
                      divisions: 14,
                      label: tempFontSize.toString(),
                      onChanged: (value) {
                        setDialogState(() {
                          tempFontSize = value.round();
                        });
                      },
                    ),
                  ),
                  Text('$tempFontSize'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _fontSize = tempFontSize;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeViewer() {
    if (_codeContent.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.code, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No code to display',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText.rich(
          TextSpan(
            children: _buildHighlightedSpans(),
          ),
          style: TextStyle(
            fontFamily: 'Fira Code, Consolas, monospace',
            fontSize: _fontSize.toDouble(),
            height: 1.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  List<TextSpan> _buildHighlightedSpans() {
    try {
      final highlighted = highlight.parse(_codeContent, language: 'dart');
      final spans = <TextSpan>[];

      for (final node in highlighted.nodes!) {
        if (node.value != null) {
          final className = node.className;
          Color textColor = Theme.of(context).colorScheme.onSurface;

          if (className != null) {
            switch (className) {
              case 'keyword':
                textColor = Theme.of(context).colorScheme.primary;
                break;
              case 'string':
                textColor = Theme.of(context).colorScheme.secondary;
                break;
              case 'comment':
                textColor = Theme.of(context).colorScheme.onSurfaceVariant;
                break;
              case 'number':
                textColor = Theme.of(context).colorScheme.tertiary;
                break;
              case 'class':
                textColor = Theme.of(context).colorScheme.primary;
                break;
              case 'function':
                textColor = Theme.of(context).colorScheme.secondary;
                break;
              case 'operator':
                textColor = Theme.of(context).colorScheme.onSurface;
                break;
              case 'punctuation':
                textColor = Theme.of(context).colorScheme.onSurface;
                break;
              default:
                textColor = Theme.of(context).colorScheme.onSurface;
            }
          }

          spans.add(TextSpan(
            text: node.value,
            style: TextStyle(color: textColor),
          ));
        }
      }

      return spans;
    } catch (e) {
      return [TextSpan(text: _codeContent)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Container(
          constraints: const BoxConstraints(maxWidth: 160),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                _showFileSelector();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.code,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _selectedFile ?? 'Select File',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading source code...'),
                ],
              ),
            )
          : Container(
              margin: const EdgeInsets.all(16),
              child: _buildCodeViewer(),
            ),
    );
  }
}
