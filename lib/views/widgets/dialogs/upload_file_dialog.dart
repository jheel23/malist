import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:malist/data/models/files/user_file.dart';
import 'package:malist/providers/files/files_provider.dart';

class UploadFileDialog extends ConsumerStatefulWidget {
  const UploadFileDialog({
    super.key,
    required this.filePath,
    required this.originalFileName,
    required this.fileExtension,
    required this.mimeType,
    required this.fileSize,
    required this.source,
    required this.checksum,
  });

  final String filePath;
  final String originalFileName;
  final String fileExtension;
  final String mimeType;
  final int fileSize;
  final FileSource source;
  final String checksum;

  @override
  ConsumerState<UploadFileDialog> createState() => _UploadFileDialogState();
}

class _UploadFileDialogState extends ConsumerState<UploadFileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final name = widget.originalFileName;
    final dotIndex = name.lastIndexOf('.');
    _titleController.text = dotIndex > 0 ? name.substring(0, dotIndex) : name;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  bool get _isImage => [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
    'bmp',
    'heic',
  ].contains(widget.fileExtension.toLowerCase());

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newFile = UserFile(
        id: "",
        title: _titleController.text.trim(),
        originalFileName: widget.originalFileName,
        filePath: widget.filePath,
        fileExtension: widget.fileExtension,
        mimeType: widget.mimeType,
        fileSize: widget.fileSize,
        createdAt: DateTime.now(),
        source: widget.source,
        checksum: widget.checksum,
      );
      ref.read(filesNotifierProvider.notifier).addFile(newFile);
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File uploaded successfully'),
          backgroundColor: Colors.green.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SAVE FILE",
                style: theme.textTheme.headlineSmall!.copyWith(
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              if (_isImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: Image.file(
                    File(widget.filePath),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insert_drive_file_outlined,
                          size: 40,
                          color: theme.primaryColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '.${widget.fileExtension.toUpperCase()}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            letterSpacing: 2,
                            color: theme.primaryColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _infoRow(theme, 'File', widget.originalFileName),
              _infoRow(theme, 'Size', _formatFileSize(widget.fileSize)),
              _infoRow(theme, 'Type', '.${widget.fileExtension.toUpperCase()}'),
              _infoRow(
                theme,
                'Source',
                widget.source == FileSource.camera ? 'Camera' : 'Device',
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: "File Title",
                  hintText: "Enter a title for this file",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Title is required";
                  }
                  if (value.trim().length > 100) {
                    return "Title must be 100 characters or less";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text("CANCEL", style: TextStyle(letterSpacing: 1)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    child: Text("SAVE", style: TextStyle(letterSpacing: 1)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
