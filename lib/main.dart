import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/project_viewmodel.dart';
import 'viewmodels/design_viewmodel.dart';
import 'views/project_list_view.dart';

void main() {
  runApp(const SketchIDEApp());
}

class SketchIDEApp extends StatelessWidget {
  const SketchIDEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProjectViewModel()),
        ChangeNotifierProvider(create: (context) => DesignViewModel()),
      ],
      child: MaterialApp(
        title: 'SketchIDE',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const ProjectListView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
