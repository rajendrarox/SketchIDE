import 'package:flutter/material.dart';

/// Property Validation Service - EXACTLY matches Sketchware Pro's validation system
/// Handles property edit safety with comprehensive validation rules
class PropertyValidationService {
  // SKETCHWARE PRO STYLE: Reserved keywords (like Sketchware Pro)
  static const List<String> _reservedKeywords = [
    'abstract', 'assert', 'boolean', 'break', 'byte', 'case', 'catch', 'char',
    'class', 'const', 'continue', 'default', 'do', 'double', 'else', 'enum',
    'extends', 'final', 'finally', 'float', 'for', 'goto', 'if', 'implements',
    'import', 'instanceof', 'int', 'interface', 'long', 'native', 'new',
    'package', 'private', 'protected', 'public', 'return', 'short', 'static',
    'strictfp', 'super', 'switch', 'synchronized', 'this', 'throw', 'throws',
    'transient', 'try', 'void', 'volatile', 'while', 'true', 'false', 'null',
    // Flutter/Dart specific
    'var', 'dynamic', 'const', 'final', 'late', 'required', 'async', 'await',
    'yield', 'sync', 'external', 'factory', 'get', 'set', 'operator', 'typedef',
    'mixin', 'with', 'on', 'implements', 'extends', 'abstract', 'sealed',
  ];

  // SKETCHWARE PRO STYLE: Reserved method names
  static const List<String> _reservedMethodNames = [
    'onCreate',
    'onStart',
    'onResume',
    'onPause',
    'onStop',
    'onDestroy',
    'onRestart',
    'onSaveInstanceState',
    'onRestoreInstanceState',
    'onActivityResult',
    'onRequestPermissionsResult',
    'onBackPressed',
    'onCreateOptionsMenu',
    'onOptionsItemSelected',
    'onContextItemSelected',
    'onCreateContextMenu',
    'onPrepareOptionsMenu',
    'onOptionsMenuClosed',
    'onCreatePanelMenu',
    'onPreparePanel',
    'onMenuOpened',
    'onPanelClosed',
    'onUserInteraction',
    'onUserLeaveHint',
    'onNewIntent',
    'onRestoreInstanceState',
    'onPostCreate',
    'onPostResume',
    'onTitleChanged',
    'onChildTitleChanged',
    'onSearchRequested',
    'onKeyDown',
    'onKeyUp',
    'onKeyLongPress',
    'onKeyMultiple',
    'onTouchEvent',
    'onTrackballEvent',
    'onGenericMotionEvent',
    'onWindowFocusChanged',
    'onAttachedToWindow',
    'onDetachedFromWindow',
    'onWindowAttributesChanged',
    'onContentChanged',
    'onWindowFocusChanged',
    'onAttachedToWindow',
    'onDetachedFromWindow',
    'onWindowAttributesChanged',
    'onContentChanged',
  ];

  // SKETCHWARE PRO STYLE: Pattern for valid property names
  static final RegExp _validNamePattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');

  /// SKETCHWARE PRO STYLE: Validate property name with comprehensive checks
  static PropertyValidationResult validatePropertyName(
    String name,
    List<String> existingNames, {
    String? currentValue,
    List<String>? additionalReservedNames,
  }) {
    String trimmedName = name.trim();

    // SKETCHWARE PRO STYLE: Length validation
    if (trimmedName.isEmpty) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Property name cannot be empty',
      );
    }

    if (trimmedName.length > 100) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Property name cannot exceed 100 characters',
      );
    }

    // SKETCHWARE PRO STYLE: Check if same as current value
    if (currentValue != null &&
        trimmedName.toLowerCase() == currentValue.toLowerCase()) {
      return PropertyValidationResult(isValid: true);
    }

    // SKETCHWARE PRO STYLE: Check for existing names
    if (existingNames.contains(trimmedName)) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Property name already exists',
      );
    }

    // SKETCHWARE PRO STYLE: Check reserved keywords
    if (_reservedKeywords.contains(trimmedName.toLowerCase())) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Property name is a reserved keyword',
      );
    }

    // SKETCHWARE PRO STYLE: Check reserved method names
    if (_reservedMethodNames.contains(trimmedName)) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Property name conflicts with reserved method name',
      );
    }

    // SKETCHWARE PRO STYLE: Check additional reserved names
    if (additionalReservedNames != null &&
        additionalReservedNames.contains(trimmedName)) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Property name is not available',
      );
    }

    // SKETCHWARE PRO STYLE: Check if starts with letter
    if (!trimmedName[0].contains(RegExp(r'[a-zA-Z]'))) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Property name must start with a letter',
      );
    }

    // SKETCHWARE PRO STYLE: Pattern validation
    if (!_validNamePattern.hasMatch(trimmedName)) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage:
            'Property name can only contain letters, numbers, and underscores',
      );
    }

    return PropertyValidationResult(isValid: true);
  }

  /// SKETCHWARE PRO STYLE: Validate numeric property values
  static PropertyValidationResult validateNumericValue(
    String value, {
    double? minValue,
    double? maxValue,
    bool allowNegative = false,
  }) {
    if (value.trim().isEmpty) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Value cannot be empty',
      );
    }

    double? numericValue = double.tryParse(value);
    if (numericValue == null) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid number',
      );
    }

    if (!allowNegative && numericValue < 0) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Value cannot be negative',
      );
    }

    if (minValue != null && numericValue < minValue) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Value must be at least $minValue',
      );
    }

    if (maxValue != null && numericValue > maxValue) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Value cannot exceed $maxValue',
      );
    }

    return PropertyValidationResult(isValid: true);
  }

  /// SKETCHWARE PRO STYLE: Validate color values
  static PropertyValidationResult validateColorValue(String value) {
    if (value.trim().isEmpty) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Color value cannot be empty',
      );
    }

    // Check for hex color format
    if (value.startsWith('#')) {
      if (value.length != 7 && value.length != 9) {
        return PropertyValidationResult(
          isValid: false,
          errorMessage: 'Invalid hex color format. Use #RRGGBB or #AARRGGBB',
        );
      }

      try {
        int.parse(value.substring(1), radix: 16);
        return PropertyValidationResult(isValid: true);
      } catch (e) {
        return PropertyValidationResult(
          isValid: false,
          errorMessage: 'Invalid hex color value',
        );
      }
    }

    // Check for named colors
    List<String> validColorNames = [
      'transparent',
      'black',
      'white',
      'red',
      'green',
      'blue',
      'yellow',
      'cyan',
      'magenta',
      'gray',
      'grey',
      'orange',
      'purple',
      'pink',
      'brown',
    ];

    if (validColorNames.contains(value.toLowerCase())) {
      return PropertyValidationResult(isValid: true);
    }

    return PropertyValidationResult(
      isValid: false,
      errorMessage:
          'Invalid color value. Use hex format (#RRGGBB) or named color',
    );
  }

  /// SKETCHWARE PRO STYLE: Validate text length
  static PropertyValidationResult validateTextLength(
    String text, {
    int minLength = 0,
    int maxLength = 1000,
  }) {
    int length = text.length;

    if (length < minLength) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Text must be at least $minLength characters long',
      );
    }

    if (length > maxLength) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Text cannot exceed $maxLength characters',
      );
    }

    return PropertyValidationResult(isValid: true);
  }

  /// SKETCHWARE PRO STYLE: Validate URL format
  static PropertyValidationResult validateUrl(String url) {
    if (url.trim().isEmpty) {
      return PropertyValidationResult(isValid: true); // Allow empty URLs
    }

    // Basic URL validation pattern
    RegExp urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlPattern.hasMatch(url)) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid URL (e.g., https://example.com)',
      );
    }

    return PropertyValidationResult(isValid: true);
  }

  /// SKETCHWARE PRO STYLE: Validate email format
  static PropertyValidationResult validateEmail(String email) {
    if (email.trim().isEmpty) {
      return PropertyValidationResult(isValid: true); // Allow empty emails
    }

    RegExp emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailPattern.hasMatch(email)) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid email address',
      );
    }

    return PropertyValidationResult(isValid: true);
  }

  /// SKETCHWARE PRO STYLE: Validate widget ID format
  static PropertyValidationResult validateWidgetId(
    String id,
    List<String> existingIds, {
    String? currentId,
  }) {
    // Check if same as current ID
    if (currentId != null && id == currentId) {
      return PropertyValidationResult(isValid: true);
    }

    // Check for duplicates
    if (existingIds.contains(id)) {
      return PropertyValidationResult(
        isValid: false,
        errorMessage: 'Widget ID already exists',
      );
    }

    // Validate ID format
    return validatePropertyName(id, existingIds, currentValue: currentId);
  }
}

/// Property Validation Result - Contains validation status and error message
class PropertyValidationResult {
  final bool isValid;
  final String? errorMessage;

  const PropertyValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  /// Show error message if validation failed
  void showErrorIfInvalid(BuildContext context) {
    if (!isValid && errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
