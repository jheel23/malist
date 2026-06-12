import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';

import 'package:malist/data/models/files/user_file.dart';
import 'package:malist/providers/files/files_provider.dart';

class FileViewScreen extends ConsumerStatefulWidget {
  final UserFile file;
  const FileViewScreen({super.key, required this.file});

  @override
  ConsumerState<FileViewScreen> createState() => _FileViewScreenState();
}

class _FileViewScreenState extends ConsumerState<FileViewScreen> {
  late UserFile _file;

  @override
  void initState() {
    super.initState();
    _file = widget.file;
  }

  bool get _isImage => [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
    'bmp',
    'heic',
  ].contains(_file.fileExtension.toLowerCase());

  bool get _isPdf => _file.fileExtension.toLowerCase() == 'pdf';

  bool get _isVideo =>
      ['mp4', 'mov', 'avi', 'mkv'].contains(_file.fileExtension.toLowerCase());

  bool get _isAudio =>
      ['mp3', 'wav', 'aac', 'm4a'].contains(_file.fileExtension.toLowerCase());

  bool get _isText => [
    'txt',
    'csv',
    'json',
    'xml',
    'rtf',
  ].contains(_file.fileExtension.toLowerCase());

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: _file.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Rename"),
        content: TextField(
          controller: controller,
          maxLength: 100,
          decoration: const InputDecoration(labelText: "Title"),
        ),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(filesNotifierProvider.notifier)
                    .renameFile(_file, controller.text.trim());
                setState(
                  () => _file = _file.copyWith(title: controller.text.trim()),
                );
                ctx.pop();
              }
            },
            child: const Text("Rename"),
          ),
        ],
      ),
    );
  }

  void _deleteFile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete"),
        content: const Text("Are you sure you want to delete this file?"),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      ref
          .read(filesNotifierProvider.notifier)
          .deleteFile(_file.id, _file.filePath);
      context.pop();
    }
  }

  void _shareFile() {
    Share.shareXFiles([XFile(_file.filePath)]);
  }

  void _openExternally() {
    OpenFilex.open(_file.filePath);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileExists = File(_file.filePath).existsSync();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: Text(_file.title, style: theme.textTheme.titleMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _showRenameDialog,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: fileExists ? _shareFile : null,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: fileExists ? _openExternally : null,
          ),
          IconButton(
            icon: Icon(Iconsax.trash, color: theme.colorScheme.error),
            onPressed: _deleteFile,
          ),
        ],
      ),
      body: !fileExists
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: theme.colorScheme.error.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'File not found on device.',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : _buildPreview(theme),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    if (_isImage) return _ImageViewer(filePath: _file.filePath);
    if (_isPdf) return _PdfViewer(filePath: _file.filePath);
    if (_isVideo) return _VideoViewer(filePath: _file.filePath);
    if (_isAudio) return _AudioViewer(filePath: _file.filePath, file: _file);
    if (_isText) return _TextViewer(filePath: _file.filePath);
    return _UnsupportedViewer(
      file: _file,
      formatFileSize: _formatFileSize,
      onOpen: _openExternally,
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final String filePath;
  const _ImageViewer({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      maxScale: 5,
      child: Center(child: Image.file(File(filePath), fit: BoxFit.contain)),
    );
  }
}

class _PdfViewer extends StatelessWidget {
  final String filePath;
  const _PdfViewer({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.file(
      File(filePath),
      canShowScrollHead: true,
      canShowScrollStatus: true,
    );
  }
}

class _VideoViewer extends StatefulWidget {
  final String filePath;
  const _VideoViewer({required this.filePath});

  @override
  State<_VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<_VideoViewer> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        if (mounted) setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        const SizedBox(height: 16),
        VideoProgressIndicator(_controller, allowScrubbing: true),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _AudioViewer extends StatefulWidget {
  final String filePath;
  final UserFile file;
  const _AudioViewer({required this.filePath, required this.file});

  @override
  State<_AudioViewer> createState() => _AudioViewerState();
}

class _AudioViewerState extends State<_AudioViewer> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _isPlaying = s == PlayerState.playing);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.audiotrack_outlined,
              size: 80,
              color: theme.primaryColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(widget.file.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '.${widget.file.fileExtension.toUpperCase()}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            Slider(
              value: _position.inMilliseconds.toDouble(),
              max: _duration.inMilliseconds > 0
                  ? _duration.inMilliseconds.toDouble()
                  : 1,
              onChanged: (v) => _player.seek(Duration(milliseconds: v.toInt())),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(_position), style: theme.textTheme.bodySmall),
                Text(_fmt(_duration), style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 16),
            IconButton(
              iconSize: 56,
              icon: Icon(
                _isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                if (_isPlaying) {
                  _player.pause();
                } else {
                  _player.play(DeviceFileSource(widget.filePath));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TextViewer extends StatefulWidget {
  final String filePath;
  const _TextViewer({required this.filePath});

  @override
  State<_TextViewer> createState() => _TextViewerState();
}

class _TextViewerState extends State<_TextViewer> {
  String? _content;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final text = await File(widget.filePath).readAsString();
      if (mounted) setState(() => _content = text);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not read file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_error != null) {
      return Center(child: Text(_error!, style: theme.textTheme.bodyLarge));
    }
    if (_content == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SelectableText(
        _content!,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          height: 1.6,
        ),
      ),
    );
  }
}

class _UnsupportedViewer extends StatelessWidget {
  final UserFile file;
  final String Function(int) formatFileSize;
  final VoidCallback onOpen;

  const _UnsupportedViewer({
    required this.file,
    required this.formatFileSize,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file_outlined,
              size: 80,
              color: theme.primaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(file.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '.${file.fileExtension.toUpperCase()}',
              style: theme.textTheme.bodyMedium?.copyWith(
                letterSpacing: 2,
                color: theme.primaryColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatFileSize(file.fileSize),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            Text(
              'Preview not available for this file type.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new),
              label: const Text("OPEN WITH DEVICE"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
