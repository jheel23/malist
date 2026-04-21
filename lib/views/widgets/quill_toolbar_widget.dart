import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class QuillToolbarWidget extends StatelessWidget {
  const QuillToolbarWidget({super.key, required this.controller});
  final quill.QuillController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: quill.QuillSimpleToolbar(
          controller: controller,
          config: const quill.QuillSimpleToolbarConfig(
            showQuote: false,
            showAlignmentButtons: false,
            showUndo: true,
            showRedo: true,
            showFontFamily: false,
            showFontSize: false,
            showColorButton: false,
            showCenterAlignment: false,
            showLeftAlignment: false,
            showRightAlignment: false,
            showIndent: false,
            showSuperscript: false,
            showSubscript: false,
            showListCheck: false,
            showInlineCode: false,
            showCodeBlock: false,
            showListBullets: false,
            showSearchButton: false,
            showClearFormat: false,
            showBackgroundColorButton: false,
          ),
        ),
      ),
    );
  }
}
