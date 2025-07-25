import 'package:flutter/material.dart';

class ExportLocationDialog extends StatelessWidget {
  const ExportLocationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Export Location'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Where would you like to save your project backup?',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildLocationOption(
            context,
            'app_documents',
            'App Documents',
            'Save to app\'s internal storage (most reliable)',
            Icons.folder,
          ),
          const SizedBox(height: 8),
          _buildLocationOption(
            context,
            'downloads',
            'Downloads Folder',
            'Save to device Downloads folder (easy to find)',
            Icons.download,
          ),
          const SizedBox(height: 8),
          _buildLocationOption(
            context,
            'external_storage',
            'External Storage',
            'Save to external storage/SD card',
            Icons.sd_storage,
          ),
          const SizedBox(height: 8),
          _buildLocationOption(
            context,
            'custom_location',
            'Choose Location',
            'Select custom folder location',
            Icons.folder_open,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildLocationOption(
    BuildContext context,
    String location,
    String title,
    String description,
    IconData icon,
  ) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(location),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
} 