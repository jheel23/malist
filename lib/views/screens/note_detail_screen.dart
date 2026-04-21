import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:malist/config/utils/functions.dart';
import 'package:malist/config/utils/quill_helper.dart';
import 'package:malist/data/models/notes/notes_model.dart';
import 'package:malist/providers/notes/notes_provider.dart';
import 'package:malist/views/widgets/quill_toolbar_widget.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final NotesModel? note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  late quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  late NotesModel _currentNote;

  @override
  void initState() {
    super.initState();

    _currentNote =
        widget.note ??
        NotesModel(
          id: '',
          title: 'Untitled',
          description: '',
          dateTime: DateTime.now(),
        );

    final doc = QuillHelper.deltaStringToDocument(_currentNote.description);

    _controller = quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _controller.document.changes.listen((event) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 1000), () {
        _saveNote();
      });
    });
  }

  void _saveNote({bool showSnackbar = false}) {
    if (widget.note == null) return;

    final currentDeltaString = QuillHelper.documentToDeltaString(
      _controller.document,
    );

    if (currentDeltaString != _currentNote.description) {
      setState(() {
        _currentNote = _currentNote.copyWith(
          description: currentDeltaString,
          dateTime: DateTime.now(),
        );
      });
      ref.read(notesNotifierProvider.notifier).updateNote(_currentNote);

      if (showSnackbar && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Note Saved')));
      }
    } else if (showSnackbar && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No changes to save')));
    }
  }

  @override
  void dispose() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      _saveNote();
    }
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          _buildContent(theme),
          QuillToolbarWidget(controller: _controller),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        controller: _scrollController,
        children: [
          Row(
            mainAxisAlignment: .start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: .circle,
                    border: Border.all(color: Colors.white38),
                  ),
                  child: const Icon(Icons.close, color: Colors.white38),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Tooltip(
                  message: widget.note?.title,
                  child: Text(
                    widget.note?.title ?? '',
                    style: theme.textTheme.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _saveNote(showSnackbar: true);
                },
                icon: const Icon(Iconsax.archive, color: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            getFormattedDate(widget.note!.dateTime),
            style: theme.textTheme.titleSmall!.copyWith(
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          quill.QuillEditor(
            controller: _controller,
            focusNode: _focusNode,
            scrollController: _scrollController,
            config: const quill.QuillEditorConfig(
              padding: EdgeInsets.zero,
              autoFocus: false,
              expands: false,
              scrollable: false,
            ),
          ),

          const SizedBox(height: 200),
        ],
      ),
    );
  }
}
