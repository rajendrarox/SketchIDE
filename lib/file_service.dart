import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';

class FileService {
  final _logger = Logger('FileService'); // Create a Logger instance

  // Function to get the app's directory path
  Future<Directory> getAppDirectory() async {
    // Get the top-level external storage directory
    final Directory? directory = await getExternalStorageDirectory();

    if (directory != null) {
      // Create a specific subdirectory path in external storage
      final Directory appDirectory =
          Directory('${directory.path}/Download/SketchIDE');

      // Check if the directory exists; if not, create it
      if (!await appDirectory.exists()) {
        await appDirectory.create(recursive: true);
      }

      return appDirectory; // Return the app directory
    } else {
      throw Exception("Could not access the external storage directory.");
    }
  }

  // Function to save project data
  Future<void> saveProjectData(
      String appName, String projectName, String packageName) async {
    try {
      // Get the app's directory
      final Directory appDirectory = await getAppDirectory();

      // Define the file path where the project data will be saved
      final File projectFile = File('${appDirectory.path}/$projectName.txt');

      // Prepare the content to be saved
      final projectData =
          'App Name: $appName\nProject Name: $projectName\nPackage Name: $packageName';

      // Write the data to the file
      await projectFile.writeAsString(projectData);

      _logger.info('Project saved at ${projectFile.path}'); // Log success
    } catch (e) {
      _logger.severe('Error saving project data: $e'); // Log error
    }
  }
}
