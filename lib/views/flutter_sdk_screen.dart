import 'package:flutter/material.dart';

class FlutterSDKScreen extends StatefulWidget {
  final String projectId;

  const FlutterSDKScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<FlutterSDKScreen> createState() => _FlutterSDKScreenState();
}

class _FlutterSDKScreenState extends State<FlutterSDKScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dartSdkController = TextEditingController();
  final _flutterSdkController = TextEditingController();
  bool _enableWeb = true;
  bool _enableAndroid = true;
  bool _enableIOS = true;
  bool _enableDesktop = false;

  @override
  void initState() {
    super.initState();
    _loadSDKSettings();
  }

  @override
  void dispose() {
    _dartSdkController.dispose();
    _flutterSdkController.dispose();
    super.dispose();
  }

  void _loadSDKSettings() {
    // TODO: Load from service
    _dartSdkController.text = '>=3.0.0 <4.0.0';
    _flutterSdkController.text = '>=3.0.0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Flutter SDK'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSDKSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SDK Constraints',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _dartSdkController,
                label: 'Dart SDK',
                hint: 'e.g., >=3.0.0 <4.0.0',
                icon: Icons.code,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Dart SDK constraint';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _flutterSdkController,
                label: 'Flutter SDK',
                hint: 'e.g., >=3.0.0',
                icon: Icons.flutter_dash,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Flutter SDK constraint';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Platform Support',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildPlatformCard(
                'Web',
                'Enable web platform support',
                Icons.web,
                Colors.blue,
                _enableWeb,
                (value) => setState(() => _enableWeb = value),
              ),
              const SizedBox(height: 12),
              _buildPlatformCard(
                'Android',
                'Enable Android platform support',
                Icons.android,
                Colors.green,
                _enableAndroid,
                (value) => setState(() => _enableAndroid = value),
              ),
              const SizedBox(height: 12),
              _buildPlatformCard(
                'iOS',
                'Enable iOS platform support',
                Icons.phone_iphone,
                Colors.grey,
                _enableIOS,
                (value) => setState(() => _enableIOS = value),
              ),
              const SizedBox(height: 12),
              _buildPlatformCard(
                'Desktop',
                'Enable desktop platform support',
                Icons.desktop_windows,
                Colors.purple,
                _enableDesktop,
                (value) => setState(() => _enableDesktop = value),
              ),
              const SizedBox(height: 32),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: color,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'SDK Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'SDK constraints define which versions of Dart and Flutter your project supports. '
              'Platform support determines which platforms your app can be built for.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            _buildConstraintExample(),
          ],
        ),
      ),
    );
  }

  Widget _buildConstraintExample() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Example Constraints:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dart SDK: >=3.0.0 <4.0.0\n'
            'Flutter SDK: >=3.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
        ],
      ),
    );
  }

  void _saveSDKSettings() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save to service
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SDK settings saved successfully!')),
      );
      Navigator.pop(context);
    }
  }
}
