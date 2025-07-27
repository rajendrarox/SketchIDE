import 'package:flutter/material.dart';

enum DesignDrawerItem {
  libraryManager,
  viewManager,
  imageManager,
  soundManager,
  fontManager,
  javaManager,
  resourceManager,
  resourceEditor,
  assetsManager,
  permissionManager,
  appcompatManager,
  manifestManager,
  customBlocks,
  proguardManager,
  stringfogManager,
  sourceCode,
  xmlCommandManager,
  logcatReader,
  collectionManager,
}

class DesignDrawer extends StatelessWidget {
  final Function(DesignDrawerItem) onItemSelected;

  const DesignDrawer({
    Key? key,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.menu,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Project Tools',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Drawer items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.libraryManager,
                    Icons.category,
                    'Library Manager',
                    'Manage project dependencies and libraries',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.viewManager,
                    Icons.devices,
                    'View Manager',
                    'Manage custom views and layouts',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.imageManager,
                    Icons.image,
                    'Image Manager',
                    'Manage project images and drawables',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.soundManager,
                    Icons.music_note,
                    'Sound Manager',
                    'Manage audio files and sound effects',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.fontManager,
                    Icons.font_download,
                    'Font Manager',
                    'Manage custom fonts and typography',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.javaManager,
                    Icons.code,
                    'Java Manager',
                    'Manage Java files and classes',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.resourceManager,
                    Icons.folder,
                    'Resource Manager',
                    'Manage project resources and assets',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.resourceEditor,
                    Icons.folder_open,
                    'Resource Editor',
                    'Edit resource files and configurations',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.assetsManager,
                    Icons.file_present,
                    'Assets Manager',
                    'Manage project assets and files',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.permissionManager,
                    Icons.security,
                    'Permission Manager',
                    'Manage app permissions and security',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.appcompatManager,
                    Icons.integration_instructions,
                    'AppCompat Manager',
                    'Manage AppCompat and Material Design',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.manifestManager,
                    Icons.description,
                    'Manifest Manager',
                    'Edit Android manifest file',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.customBlocks,
                    Icons.block,
                    'Custom Blocks',
                    'Manage custom logic blocks',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.proguardManager,
                    Icons.lock,
                    'ProGuard Manager',
                    'Configure code obfuscation',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.stringfogManager,
                    Icons.text_fields,
                    'StringFog Manager',
                    'Configure string encryption',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.sourceCode,
                    Icons.source,
                    'Source Code',
                    'View generated source code',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.xmlCommandManager,
                    Icons.code,
                    'XML Commands',
                    'Manage XML commands and scripts',
                  ),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.logcatReader,
                    Icons.article,
                    'Logcat Reader',
                    'View app logs and debugging info',
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    DesignDrawerItem.collectionManager,
                    Icons.bookmark,
                    'Collection Manager',
                    'Manage saved collections and templates',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    DesignDrawerItem item,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onItemSelected(item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
