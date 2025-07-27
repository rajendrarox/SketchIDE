enum ProjectComplexity {
  simple, // ≤3 widgets, single file
  medium, // 4-10 widgets, main + screens
  complex, // >10 widgets, full structure
}

enum ProjectTemplate {
  helloWorld, // Single main.dart
  multiScreen, // main.dart + screens/
  fullApp, // Complete structure
  custom, // User-defined
}

class ProjectComplexityDetector {
  static ProjectComplexity detectComplexity({
    required int totalWidgets,
    required int totalScreens,
    required int customWidgets,
    required int totalServices,
  }) {
    // Simple: ≤3 widgets, ≤1 screen, no custom widgets
    if (totalWidgets <= 3 && totalScreens <= 1 && customWidgets == 0) {
      return ProjectComplexity.simple;
    }

    // Medium: ≤15 widgets, ≤3 screens, ≤2 services
    if (totalWidgets <= 15 && totalScreens <= 3 && totalServices <= 2) {
      return ProjectComplexity.medium;
    }

    // Complex: Everything else
    return ProjectComplexity.complex;
  }

  static String getComplexityDescription(ProjectComplexity complexity) {
    switch (complexity) {
      case ProjectComplexity.simple:
        return 'Simple app with basic widgets in a single file';
      case ProjectComplexity.medium:
        return 'Multi-screen app with organized file structure';
      case ProjectComplexity.complex:
        return 'Full-featured app with complete project structure';
    }
  }

  static String getComplexityIcon(ProjectComplexity complexity) {
    switch (complexity) {
      case ProjectComplexity.simple:
        return '🏠';
      case ProjectComplexity.medium:
        return '📱';
      case ProjectComplexity.complex:
        return '🚀';
    }
  }
}

class ProjectTemplateInfo {
  final ProjectTemplate template;
  final String name;
  final String description;
  final String icon;
  final ProjectComplexity complexity;

  const ProjectTemplateInfo({
    required this.template,
    required this.name,
    required this.description,
    required this.icon,
    required this.complexity,
  });

  static const Map<ProjectTemplate, ProjectTemplateInfo> templates = {
    ProjectTemplate.helloWorld: ProjectTemplateInfo(
      template: ProjectTemplate.helloWorld,
      name: 'Hello World',
      description: 'Single file, perfect for beginners',
      icon: '🏠',
      complexity: ProjectComplexity.simple,
    ),
    ProjectTemplate.multiScreen: ProjectTemplateInfo(
      template: ProjectTemplate.multiScreen,
      name: 'Multi-Screen App',
      description: 'Multiple screens with navigation',
      icon: '📱',
      complexity: ProjectComplexity.medium,
    ),
    ProjectTemplate.fullApp: ProjectTemplateInfo(
      template: ProjectTemplate.fullApp,
      name: 'Full App (Advanced)',
      description: 'Complete structure with services',
      icon: '🚀',
      complexity: ProjectComplexity.complex,
    ),
  };
}
