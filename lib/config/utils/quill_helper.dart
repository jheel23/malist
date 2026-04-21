import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';

class QuillHelper {
  /// Converts a Quill Document into a JSON string representing the Delta.
  static String documentToDeltaString(Document document) {
    return jsonEncode(document.toDelta().toJson());
  }

  /// Converts a JSON string representing a Delta back into a Quill Document.
  /// If the string is not valid JSON (e.g., an older plain text note), it wraps the plain text in a new Document.
  static Document deltaStringToDocument(String deltaString) {
    if (deltaString.trim().isEmpty) {
      return Document();
    }

    try {
      final decoded = jsonDecode(deltaString);
      return Document.fromJson(decoded);
    } catch (e) {
      // Fallback for raw text created before JSON Deltas were used
      return Document()..insert(0, deltaString);
    }
  }

  /// Extracts plain text from a Delta string for preview purposes.
  static String deltaStringToPlainText(String deltaString) {
    final doc = deltaStringToDocument(deltaString);
    return doc.toPlainText().trim();
  }
}
