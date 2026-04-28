import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:malist/config/router/app_router.dart';
import 'package:malist/config/utils/functions.dart';
import 'package:malist/config/utils/quill_helper.dart';
import 'package:malist/providers/notes/notes_provider.dart';
import 'package:malist/providers/notes/state/notes_state.dart';
import 'package:malist/views/widgets/dialogs/add_note_dialog.dart';
import 'package:malist/views/widgets/no_data_widget.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notesNotifierProvider.notifier).getNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("NOTES", style: TextStyle(letterSpacing: 5)),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: "Add Note",
            transitionDuration: const Duration(milliseconds: 250),
            pageBuilder: (context, anim1, anim2) => const AddNoteDialog(),
            transitionBuilder: (context, anim1, anim2, child) {
              return Transform.scale(
                scale: 0.95 + (0.05 * anim1.value),
                child: FadeTransition(opacity: anim1, child: child),
              );
            },
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
        child: const Icon(Iconsax.add, size: 35),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Consumer(
          builder: (context, ref, child) {
            final notesState = ref.watch(notesNotifierProvider);
            return notesState.when(
              initial: () => SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (message) => Center(
                child: NoDataWidget(
                  message: message,
                  widgetSize: null,
                  icon: Icons.error_outline_rounded,
                ),
              ),
              loaded: (notes) => Column(
                children: [
                  if (notes.isEmpty)
                    NoDataWidget(message: "No notes found!")
                  else
                    // Notes Preview Card
                    ...List.generate(notes.length, (index) {
                      final note = notes[index];

                      Future<void> togglePinned() {
                        return ref
                            .read(notesNotifierProvider.notifier)
                            .updateNote(
                              note.copyWith(isPinned: !note.isPinned),
                            );
                      }

                      return GestureDetector(
                        onTap: () {
                          context.push(RoutePathHelper.noteDetail, extra: note);
                        },
                        onLongPress: () => togglePinned(),
                        child: notesPreviewCard(
                          context,
                          theme,
                          id: note.id,
                          title: note.title,
                          description: note.description,
                          date: note.dateTime,
                          isPinned: note.isPinned,
                          onTogglePinned: () => togglePinned(),
                        ),
                      );
                    }),

                  // Scroll Overhead
                  SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget notesPreviewCard(
    BuildContext context,
    ThemeData theme, {
    required String id,
    required String title,
    required String description,
    required DateTime date,
    required bool isPinned,
    required VoidCallback onTogglePinned,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.all(20),
      margin: .all(20),
      width: .infinity,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).primaryColor.withValues(alpha: isPinned ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(1),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: isPinned ? 0.34 : 0.08),
        ),
        boxShadow: [
          if (isPinned)
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.08),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall!.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onTogglePinned,
                tooltip: isPinned ? "Unpin" : "Pin",
                icon: AnimatedScale(
                  scale: isPinned ? 1.1 : 1,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: theme.primaryColor.withValues(
                      alpha: isPinned ? 0.9 : 0.35,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Transform.rotate(
                angle: -180 / 4,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.primaryColor.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            QuillHelper.deltaStringToPlainText(description),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                getFormattedDate(date),
                style: theme.textTheme.bodySmall!.copyWith(
                  color: theme.primaryColor.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showConfirmDeleteDialog(context, id: id),
                icon: Icon(
                  Iconsax.trash,
                  color: theme.primaryColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmDeleteDialog(BuildContext context, {required String id}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                ref.read(notesNotifierProvider.notifier).deleteNote(id);
                context.pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
