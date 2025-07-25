import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/project_viewmodel.dart';
import 'features/project/screens/project_list_screen.dart';

void main() {
  runApp(const SketchIDEApp());
}

class SketchIDEApp extends StatelessWidget {
  const SketchIDEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProjectViewModel()..initialize(),
      child: MaterialApp(
        title: 'SketchIDE',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AppStartupScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppStartupScreen extends StatefulWidget {
  const AppStartupScreen({super.key});

  @override
  State<AppStartupScreen> createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends State<AppStartupScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final viewModel = context.read<ProjectViewModel>();
      await viewModel.initialize();
    } catch (e) {
      // Handle initialization error
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading SketchIDE...'),
            ],
          ),
        ),
      );
    }

    return Consumer<ProjectViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.hasProjects) {
          return const ProjectListScreen();
        } else {
          return const EmptyStateScreen();
        }
      },
    );
  }
}

class EmptyStateScreen extends StatelessWidget {
  const EmptyStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SketchIDE'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to SketchIDE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first project to get started',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const ProjectListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Project'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 