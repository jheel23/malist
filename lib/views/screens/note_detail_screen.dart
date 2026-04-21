import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:malist/config/utils/functions.dart';
import 'package:malist/data/models/notes/notes_model.dart';
import 'package:malist/views/widgets/quill_toolbar_widget.dart';

class NoteDetailScreen extends StatefulWidget {
  final NotesModel? note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final doc = quill.Document()..insert(0, '''${widget.note?.description}''');

    _controller = quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
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
                  // ToDo : Implement manual save operation
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
