import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../domain/models/project.dart';

class DartSourceViewerScreen extends StatefulWidget {
  final Project project;

  const DartSourceViewerScreen({
    super.key,
    required this.project,
  });

  @override
  State<DartSourceViewerScreen> createState() => _DartSourceViewerScreenState();
}

class _DartSourceViewerScreenState extends State<DartSourceViewerScreen> {
  List<DartSourceFile> _dartFiles = [];
  DartSourceFile? _selectedFile;
  bool _isLoading = true;
  double _fontSize = 12.0;

  @override
  void initState() {
    super.initState();
    _loadDartFiles();
  }

  Future<void> _loadDartFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final libDir = Directory('${widget.project.projectPath}/lib');
      if (await libDir.exists()) {
        _dartFiles = await _scanDartFiles(libDir);
        if (_dartFiles.isNotEmpty) {
          _selectedFile = _dartFiles.first;
        }
      }
    } catch (e) {
      print('Error loading Dart files: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<DartSourceFile>> _scanDartFiles(Directory dir) async {
    final List<DartSourceFile> files = [];
    
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File && path.extension(entity.path) == '.dart') {
          final relativePath = path.relative(entity.path, from: dir.path);
          final content = await entity.readAsString();
          
          files.add(DartSourceFile(
            fileName: relativePath,
            fullPath: entity.path,
            content: content,
          ));
        }
      }
      
      // Sort files alphabetically
      files.sort((a, b) => a.fileName.compareTo(b.fileName));
    } catch (e) {
      print('Error scanning Dart files: $e');
    }
    
    return files;
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Font Size'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: _fontSize,
                min: 8.0,
                max: 30.0,
                divisions: 22,
                label: _fontSize.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
              ),
              Text(
                'Font Size: ${_fontSize.round()}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _fontSize = _fontSize;
              });
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dart Source Code - ${widget.project.name}'),
        backgroundColor: Colors.grey.shade800,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDartFiles,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dartFiles.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Header with file selector and font size
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        children: [
                          // File selector dropdown
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<DartSourceFile>(
                                  value: _selectedFile,
                                  isExpanded: true,
                                  hint: const Text('Select Dart file'),
                                  items: _dartFiles.map((file) {
                                    return DropdownMenuItem<DartSourceFile>(
                                      value: file,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.code,
                                            size: 16,
                                            color: Colors.blue.shade600,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              file.fileName,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (file) {
                                    setState(() {
                                      _selectedFile = file;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Font size button
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.format_size,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              onPressed: _showFontSizeDialog,
                              tooltip: 'Font Size',
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Code viewer
                    Expanded(
                      child: _selectedFile != null
                          ? _buildCodeViewer()
                          : const Center(
                              child: Text('Select a Dart file to view'),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.code_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Dart files found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dart files should be in the lib/ directory',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadDartFiles,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeViewer() {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _selectedFile!.content
              .split('\n')
              .asMap()
              .entries
              .map((entry) => _buildCodeLine(entry.value, entry.key + 1))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildCodeLine(String line, int lineNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line number
          Container(
            width: 50,
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '$lineNumber',
              style: TextStyle(
                fontSize: _fontSize - 2,
                color: Colors.grey.shade500,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.right,
            ),
          ),
          // Code content
          Expanded(
            child: Text(
              line,
              style: TextStyle(
                fontSize: _fontSize,
                fontFamily: 'monospace',
                color: _getDartSyntaxColor(line),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDartSyntaxColor(String line) {
    final keywords = [
      'import', 'export', 'class', 'void', 'int', 'String', 'bool', 'double',
      'var', 'final', 'const', 'static', 'abstract', 'extends', 'implements',
      'super', 'this', 'new', 'return', 'if', 'else', 'for', 'while', 'do',
      'switch', 'case', 'default', 'break', 'continue', 'try', 'catch',
      'finally', 'throw', 'async', 'await', 'Future', 'Stream', 'Widget',
      'StatefulWidget', 'StatelessWidget', 'BuildContext', 'MaterialApp',
      'Scaffold', 'AppBar', 'Container', 'Column', 'Row', 'Text', 'Icon',
      'ElevatedButton', 'TextField', 'ListView', 'setState', 'initState',
      'dispose', 'build', 'context', 'child', 'children', 'mainAxisAlignment',
      'crossAxisAlignment', 'padding', 'margin', 'decoration', 'color',
      'fontSize', 'fontWeight', 'onPressed', 'onChanged', 'controller',
    ];

    final words = line.split(' ');
    
    for (final word in words) {
      final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');
      if (keywords.contains(cleanWord)) {
        return Colors.blue.shade700;
      }
    }

    // String literals
    if (line.contains("'") || line.contains('"')) {
      return Colors.green.shade700;
    }

    // Numbers
    if (RegExp(r'\d+').hasMatch(line)) {
      return Colors.orange.shade700;
    }

    // Comments
    if (line.trim().startsWith('//') || line.trim().startsWith('/*')) {
      return Colors.grey.shade600;
    }

    return Colors.black87;
  }
}

class DartSourceFile {
  final String fileName;
  final String fullPath;
  final String content;

  DartSourceFile({
    required this.fileName,
    required this.fullPath,
    required this.content,
  });
} 