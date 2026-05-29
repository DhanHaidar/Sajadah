import 'dart:io' show Platform;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidDocumentPicker {
  static const MethodChannel _channel = MethodChannel(
    'sajadah/document_picker',
  );

  static Future<PickedDocument?> pickDocument() async {
    if (!kIsWeb && Platform.isAndroid) {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'pickDocument',
      );

      if (result != null) {
        final path = result['path'] as String?;
        final name = result['name'] as String?;
        if (path != null &&
            path.isNotEmpty &&
            name != null &&
            name.isNotEmpty) {
          return PickedDocument(path: path, name: name);
        }
      }
    }

    final picked = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'Documents',
          extensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
        ),
      ],
    );

    if (picked == null) return null;

    if (picked.path.isEmpty) {
      return null;
    }

    return PickedDocument(path: picked.path, name: picked.name);
  }
}

class PickedDocument {
  final String path;
  final String name;

  const PickedDocument({required this.path, required this.name});
}
