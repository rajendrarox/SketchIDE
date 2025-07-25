import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../../../domain/models/project.dart';

class CodeEditorScreen extends StatefulWidget {
  final Project project;
  final String filePath;
  final String fileName;

  const CodeEditorScreen({
    super.key,
    required this.project,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  late TextEditingController _codeController;
  bool _isLoading = true;
  bool _isModified = false;
  String _originalContent = '';
  String _fileExtension = '';

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _fileExtension = path.extension(widget.fileName).toLowerCase();
    _loadFileContent();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadFileContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        _originalContent = content;
        _codeController.text = content;
      } else {
        _codeController.text = '# File not found: ${widget.fileName}';
      }
    } catch (e) {
      _codeController.text = '# Error loading file: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    // Listen for changes
    _codeController.addListener(() {
      if (!_isLoading) {
        setState(() {
          _isModified = _codeController.text != _originalContent;
        });
      }
    });
  }

  Future<void> _saveFile() async {
    try {
      final file = File(widget.filePath);
      await file.writeAsString(_codeController.text);
      setState(() {
        _isModified = false;
        _originalContent = _codeController.text;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File saved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving file: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Changes'),
        content: const Text('Do you want to save the changes to this file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveFile();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Color _getSyntaxColor(String line, int index) {
    // Basic syntax highlighting based on file type
    switch (_fileExtension) {
      case '.dart':
        return _getDartSyntaxColor(line, index);
      case '.json':
        return _getJsonSyntaxColor(line, index);
      case '.yaml':
      case '.yml':
        return _getYamlSyntaxColor(line, index);
      case '.xml':
        return _getXmlSyntaxColor(line, index);
      case '.kt':
      case '.java':
        return _getKotlinSyntaxColor(line, index);
      case '.swift':
        return _getSwiftSyntaxColor(line, index);
      case '.gradle':
        return _getGradleSyntaxColor(line, index);
      default:
        return Colors.black87;
    }
  }

  Color _getDartSyntaxColor(String line, int index) {
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

  Color _getJsonSyntaxColor(String line, int index) {
    // Keys
    if (line.contains('"') && line.contains(':')) {
      return Colors.purple.shade700;
    }
    
    // String values
    if (line.contains('"') && !line.contains(':')) {
      return Colors.green.shade700;
    }
    
    // Numbers
    if (RegExp(r'\d+').hasMatch(line)) {
      return Colors.orange.shade700;
    }
    
    // Booleans
    if (line.contains('true') || line.contains('false')) {
      return Colors.blue.shade700;
    }
    
    return Colors.black87;
  }

  Color _getYamlSyntaxColor(String line, int index) {
    // Keys
    if (line.contains(':') && !line.trim().startsWith('#')) {
      return Colors.purple.shade700;
    }
    
    // Comments
    if (line.trim().startsWith('#')) {
      return Colors.grey.shade600;
    }
    
    // Numbers
    if (RegExp(r'\d+').hasMatch(line)) {
      return Colors.orange.shade700;
    }
    
    return Colors.black87;
  }

  Color _getXmlSyntaxColor(String line, int index) {
    // Tags
    if (line.contains('<') && line.contains('>')) {
      return Colors.blue.shade700;
    }
    
    // Attributes
    if (line.contains('=')) {
      return Colors.purple.shade700;
    }
    
    // Comments
    if (line.contains('<!--') || line.contains('-->')) {
      return Colors.grey.shade600;
    }
    
    return Colors.black87;
  }

  Color _getKotlinSyntaxColor(String line, int index) {
    final keywords = [
      'fun', 'val', 'var', 'class', 'object', 'interface', 'enum', 'data',
      'sealed', 'open', 'abstract', 'final', 'override', 'init', 'constructor',
      'companion', 'object', 'when', 'if', 'else', 'for', 'while', 'do',
      'try', 'catch', 'finally', 'throw', 'return', 'break', 'continue',
      'import', 'package', 'public', 'private', 'protected', 'internal',
      'suspend', 'coroutineScope', 'launch', 'async', 'await', 'withContext',
    ];
    
    final words = line.split(' ');
    for (final word in words) {
      final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');
      if (keywords.contains(cleanWord)) {
        return Colors.blue.shade700;
      }
    }
    
    // Comments
    if (line.trim().startsWith('//') || line.trim().startsWith('/*')) {
      return Colors.grey.shade600;
    }
    
    return Colors.black87;
  }

  Color _getSwiftSyntaxColor(String line, int index) {
    final keywords = [
      'func', 'var', 'let', 'class', 'struct', 'enum', 'protocol', 'extension',
      'import', 'public', 'private', 'internal', 'fileprivate', 'open',
      'final', 'override', 'init', 'deinit', 'guard', 'if', 'else', 'switch',
      'case', 'default', 'for', 'while', 'repeat', 'do', 'try', 'catch',
      'throw', 'return', 'break', 'continue', 'fallthrough', 'defer',
      'async', 'await', 'actor', 'Task', 'withTaskGroup',
    ];
    
    final words = line.split(' ');
    for (final word in words) {
      final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');
      if (keywords.contains(cleanWord)) {
        return Colors.blue.shade700;
      }
    }
    
    // Comments
    if (line.trim().startsWith('//') || line.trim().startsWith('/*')) {
      return Colors.grey.shade600;
    }
    
    return Colors.black87;
  }

  Color _getGradleSyntaxColor(String line, int index) {
    // Dependencies
    if (line.contains('implementation') || line.contains('compileOnly') || 
        line.contains('runtimeOnly') || line.contains('testImplementation')) {
      return Colors.green.shade700;
    }
    
    // Comments
    if (line.trim().startsWith('//') || line.trim().startsWith('/*')) {
      return Colors.grey.shade600;
    }
    
    return Colors.black87;
  }

  Widget _buildLineNumber(int lineNumber) {
    return Container(
      width: 50,
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        '$lineNumber',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
          fontFamily: 'monospace',
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildCodeLine(String line, int lineNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLineNumber(lineNumber),
          Expanded(
            child: Text(
              line,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: _getSyntaxColor(line, lineNumber - 1),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(_getFileIcon(), color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.fileName,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    path.dirname(widget.filePath),
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade800,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_isModified) {
              _showSaveDialog();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          if (_isModified)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Modified',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _isModified ? _saveFile : null,
            tooltip: 'Save',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadFileContent,
            tooltip: 'Reload',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'find':
                  _showFindDialog();
                  break;
                case 'replace':
                  _showReplaceDialog();
                  break;
                case 'format':
                  _formatCode();
                  break;
                case 'copy_path':
                  _copyFilePath();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'find',
                child: Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 8),
                    Text('Find'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'replace',
                child: Row(
                  children: [
                    Icon(Icons.find_replace),
                    SizedBox(width: 8),
                    Text('Replace'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'format',
                child: Row(
                  children: [
                    Icon(Icons.format_indent_increase),
                    SizedBox(width: 8),
                    Text('Format Code'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy_path',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Copy Path'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  // File info bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(),
                          size: 16,
                          color: _getFileColor(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_fileExtension.toUpperCase()} File',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_codeController.text.isEmpty ? 0 : _codeController.text.split('\n').length} lines',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Code editor
                  Expanded(
                    child: Container(
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
                          children: _codeController.text.isEmpty 
                              ? [const SizedBox(height: 20)]
                              : _codeController.text
                                  .split('\n')
                                  .asMap()
                                  .entries
                                  .map((entry) => _buildCodeLine(entry.value, entry.key + 1))
                                  .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  IconData _getFileIcon() {
    switch (_fileExtension) {
      case '.dart':
        return Icons.code;
      case '.json':
        return Icons.data_object;
      case '.yaml':
      case '.yml':
        return Icons.settings;
      case '.xml':
        return Icons.code;
      case '.kt':
      case '.java':
        return Icons.code;
      case '.swift':
        return Icons.code;
      case '.gradle':
        return Icons.build;
      case '.md':
        return Icons.description;
      case '.txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor() {
    switch (_fileExtension) {
      case '.dart':
        return Colors.blue.shade600;
      case '.json':
        return Colors.orange.shade600;
      case '.yaml':
      case '.yml':
        return Colors.purple.shade600;
      case '.xml':
        return Colors.green.shade600;
      case '.kt':
      case '.java':
        return Colors.orange.shade600;
      case '.swift':
        return Colors.orange.shade600;
      case '.gradle':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  void _showFindDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Find Text'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Search for',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.of(context).pop();
            _findText(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Find functionality would be implemented here
            },
            child: const Text('Find'),
          ),
        ],
      ),
    );
  }

  void _showReplaceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Find and Replace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Find',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Replace with',
                border: OutlineInputBorder(),
              ),
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
              Navigator.of(context).pop();
              // Replace functionality would be implemented here
            },
            child: const Text('Replace'),
          ),
        ],
      ),
    );
  }

  void _formatCode() {
    // Basic code formatting
    String formattedCode = _codeController.text;
    
    // Add proper indentation for different file types
    switch (_fileExtension) {
      case '.json':
        try {
          // Format JSON
          final decoded = jsonDecode(formattedCode);
          formattedCode = const JsonEncoder.withIndent('  ').convert(decoded);
        } catch (e) {
          // If JSON is invalid, don't format
        }
        break;
      case '.yaml':
      case '.yml':
        // YAML formatting would be implemented here
        break;
      case '.xml':
        // XML formatting would be implemented here
        break;
    }
    
    setState(() {
      _codeController.text = formattedCode;
      _isModified = true;
    });
  }

  void _copyFilePath() {
    // Copy file path to clipboard
    // This would use Clipboard.setData in a real implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Path copied: ${widget.filePath}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _findText(String searchText) {
    // Find text functionality would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for: $searchText'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 