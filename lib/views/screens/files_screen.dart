import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:malist/config/router/app_router.dart';
import 'package:malist/data/models/files/user_file.dart';
import 'package:malist/providers/files/files_provider.dart';
import 'package:malist/providers/files/state/files_state.dart';
import 'package:malist/views/widgets/dialogs/upload_file_dialog.dart';
import 'package:malist/views/widgets/no_data_widget.dart';

class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  FileCategory _selectedCategory = FileCategory.all;
  _SortMode _sortMode = _SortMode.newestFirst;
  bool _multiSelect = false;
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _searchQuery = value.trim().toLowerCase());
    });
  }

  List<UserFile> _applyFilters(List<UserFile> files) {
    var filtered = files.where((f) {
      if (_selectedCategory != FileCategory.all) {
        if (FileCategory.fromExtension(f.fileExtension) != _selectedCategory) {
          return false;
        }
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery;
        return f.title.toLowerCase().contains(q) ||
            f.originalFileName.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    switch (_sortMode) {
      case _SortMode.newestFirst:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortMode.oldestFirst:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _SortMode.nameAZ:
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case _SortMode.nameZA:
        filtered.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
      case _SortMode.sizeDesc:
        filtered.sort((a, b) => b.fileSize.compareTo(a.fileSize));
    }
    return filtered;
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) return;
      final picked = result.files.first;
      if (picked.path == null) return;

      final ext = p.extension(picked.path!).replaceAll('.', '').toLowerCase();
      final mime = lookupMimeType(picked.path!) ?? 'application/octet-stream';

      final appDir = await getApplicationDocumentsDirectory();
      final destDir = Directory('${appDir.path}/malist_files');
      if (!await destDir.exists()) await destDir.create(recursive: true);
      final destPath =
          '${destDir.path}/${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      await File(picked.path!).copy(destPath);

      if (!mounted) return;
      _showUploadDialog(
        filePath: destPath,
        originalFileName: picked.name,
        fileExtension: ext,
        mimeType: mime,
        fileSize: picked.size,
        source: FileSource.device,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick file: $e')));
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;

      final ext = p.extension(photo.path).replaceAll('.', '').toLowerCase();
      final mime = lookupMimeType(photo.path) ?? 'image/jpeg';
      final file = File(photo.path);
      final size = await file.length();

      final appDir = await getApplicationDocumentsDirectory();
      final destDir = Directory('${appDir.path}/malist_files');
      if (!await destDir.exists()) await destDir.create(recursive: true);
      final destPath =
          '${destDir.path}/${DateTime.now().millisecondsSinceEpoch}_${photo.name}';
      await file.copy(destPath);

      if (!mounted) return;
      _showUploadDialog(
        filePath: destPath,
        originalFileName: photo.name,
        fileExtension: ext,
        mimeType: mime,
        fileSize: size,
        source: FileSource.camera,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera unavailable: $e')));
    }
  }

  void _showUploadDialog({
    required String filePath,
    required String originalFileName,
    required String fileExtension,
    required String mimeType,
    required int fileSize,
    required FileSource source,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Upload File",
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => UploadFileDialog(
        filePath: filePath,
        originalFileName: originalFileName,
        fileExtension: fileExtension,
        mimeType: mimeType,
        fileSize: fileSize,
        source: source,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * anim1.value),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  void _showRenameDialog(UserFile file) {
    final controller = TextEditingController(text: file.title);
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
                    .renameFile(file, controller.text.trim());
                ctx.pop();
              }
            },
            child: const Text("Rename"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete"),
        content: Text("Delete ${_selectedIds.length} selected file(s)?"),
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
    if (confirm != true) return;
    final state = ref.read(filesNotifierProvider);
    state.whenOrNull(
      loaded: (files) {
        for (final f in files.where((f) => _selectedIds.contains(f.id))) {
          ref.read(filesNotifierProvider.notifier).deleteFile(f.id, f.filePath);
        }
      },
    );
    setState(() {
      _selectedIds.clear();
      _multiSelect = false;
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  bool _isImageExt(String ext) {
    return [
      'jpg',
      'jpeg',
      'png',
      'webp',
      'gif',
      'bmp',
      'heic',
    ].contains(ext.toLowerCase());
  }

  IconData _iconForExt(String ext) {
    final e = ext.toLowerCase();
    if (_isImageExt(e)) return Icons.image_outlined;
    if (e == 'pdf') return Icons.picture_as_pdf_outlined;
    if (['mp4', 'mov', 'avi', 'mkv'].contains(e))
      return Icons.videocam_outlined;
    if (['mp3', 'wav', 'aac', 'm4a'].contains(e))
      return Icons.audiotrack_outlined;
    if (['doc', 'docx', 'txt', 'rtf'].contains(e))
      return Icons.description_outlined;
    if (['xls', 'xlsx', 'csv'].contains(e)) return Icons.table_chart_outlined;
    if (['ppt', 'pptx'].contains(e)) return Icons.slideshow_outlined;
    if (['zip', 'rar', '7z'].contains(e)) return Icons.folder_zip_outlined;
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'camera',
            onPressed: _capturePhoto,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(1),
            ),
            child: const Icon(Icons.camera_alt_outlined, size: 22),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'upload',
            onPressed: _pickFile,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(1),
            ),
            child: const Icon(Iconsax.add, size: 35),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            expandedHeight: 100,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Files', style: theme.textTheme.displayMedium),
                        Text(
                          'SECURE STORAGE',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (_multiSelect) ...[
                      IconButton(
                        onPressed: _deleteSelected,
                        icon: Icon(
                          Iconsax.trash,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _multiSelect = false;
                            _selectedIds.clear();
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ] else ...[
                      PopupMenuButton<_SortMode>(
                        icon: const Icon(Icons.sort),
                        onSelected: (v) => setState(() => _sortMode = v),
                        itemBuilder: (_) => _SortMode.values
                            .map(
                              (s) =>
                                  PopupMenuItem(value: s, child: Text(s.label)),
                            )
                            .toList(),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _multiSelect = true),
                        icon: const Icon(Icons.checklist_outlined),
                      ),
                    ],
                  ],
                ),
              ),
              background: Container(color: theme.colorScheme.surface),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search files...',
                  prefixIcon: const Icon(Iconsax.search_normal),
                  filled: true,
                  fillColor: theme.primaryColor.withValues(alpha: 0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: FileCategory.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final cat = FileCategory.values[index];
                  final selected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat.label),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: theme.colorScheme.primary.withValues(
                      alpha: 0.2,
                    ),
                    side: BorderSide(
                      color: selected
                          ? theme.colorScheme.primary.withValues(alpha: 0.4)
                          : theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(filesNotifierProvider);
              return state.maybeWhen(
                loaded: (files) {
                  final filtered = _applyFilters(files);
                  final totalSize = filtered.fold<int>(
                    0,
                    (sum, f) => sum + f.fileSize,
                  );
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            '${filtered.length} files',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.primaryColor.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatFileSize(totalSize),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.primaryColor.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                orElse: () =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(filesNotifierProvider);
              return state.when(
                initial: () => SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: theme.primaryColor,
                    ),
                  ),
                ),
                loading: () => SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
                loaded: (files) {
                  final filtered = _applyFilters(files);
                  if (filtered.isEmpty) {
                    return SliverToBoxAdapter(
                      child: NoDataWidget(
                        icon: Iconsax.document,
                        message:
                            _searchQuery.isNotEmpty ||
                                _selectedCategory != FileCategory.all
                            ? 'No files match your filters'
                            : 'No files uploaded yet',
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.78,
                          ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final file = filtered[index];
                        final isSelected = _selectedIds.contains(file.id);
                        return _FileGridCard(
                          file: file,
                          isMultiSelect: _multiSelect,
                          isSelected: isSelected,
                          onTap: () {
                            if (_multiSelect) {
                              setState(() {
                                isSelected
                                    ? _selectedIds.remove(file.id)
                                    : _selectedIds.add(file.id);
                              });
                            } else {
                              context.push(
                                RoutePathHelper.fileView,
                                extra: file,
                              );
                            }
                          },
                          onLongPress: () {
                            if (!_multiSelect) {
                              setState(() {
                                _multiSelect = true;
                                _selectedIds.add(file.id);
                              });
                            }
                          },
                          onRename: () => _showRenameDialog(file),
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Delete"),
                                content: const Text(
                                  "Are you sure you want to delete this file?",
                                ),
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
                            if (confirm == true) {
                              ref
                                  .read(filesNotifierProvider.notifier)
                                  .deleteFile(file.id, file.filePath);
                            }
                          },
                          onToggleFavorite: () {
                            ref
                                .read(filesNotifierProvider.notifier)
                                .toggleFavorite(file);
                          },
                          formatFileSize: _formatFileSize,
                          formatDate: _formatDate,
                          isImageExt: _isImageExt,
                          iconForExt: _iconForExt,
                        );
                      },
                    ),
                  );
                },
                error: (error) => SliverToBoxAdapter(
                  child: Center(
                    child: NoDataWidget(
                      message: error,
                      icon: Iconsax.info_circle,
                    ),
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 150)),
        ],
      ),
    );
  }
}

class _FileGridCard extends StatelessWidget {
  final UserFile file;
  final bool isMultiSelect;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;
  final String Function(int) formatFileSize;
  final String Function(DateTime) formatDate;
  final bool Function(String) isImageExt;
  final IconData Function(String) iconForExt;

  const _FileGridCard({
    required this.file,
    required this.isMultiSelect,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onRename,
    required this.onDelete,
    required this.onToggleFavorite,
    required this.formatFileSize,
    required this.formatDate,
    required this.isImageExt,
    required this.iconForExt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: isSelected ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(1),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : theme.primaryColor.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(1),
                      ),
                      child:
                          isImageExt(file.fileExtension) &&
                              File(file.filePath).existsSync()
                          ? Image.file(File(file.filePath), fit: BoxFit.cover)
                          : Center(
                              child: Icon(
                                iconForExt(file.fileExtension),
                                size: 48,
                                color: theme.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                    ),
                  ),

                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onToggleFavorite,
                      child: Icon(
                        file.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: file.isFavorite
                            ? Colors.amber
                            : theme.primaryColor.withValues(alpha: 0.4),
                        size: 22,
                      ),
                    ),
                  ),

                  if (isMultiSelect)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.white12,
                          border: Border.all(color: Colors.white38),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.black,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 6, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          file.title,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onSelected: (v) {
                          if (v == 'rename') onRename();
                          if (v == 'delete') onDelete();
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'rename',
                            child: Text('Rename'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '.${file.fileExtension.toUpperCase()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor.withValues(alpha: 0.5),
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatFileSize(file.fileSize),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDate(file.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: theme.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SortMode {
  newestFirst('Newest First'),
  oldestFirst('Oldest First'),
  nameAZ('Name A-Z'),
  nameZA('Name Z-A'),
  sizeDesc('Size ↓');

  final String label;
  const _SortMode(this.label);
}
