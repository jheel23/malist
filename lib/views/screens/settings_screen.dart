import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:malist/providers/core/core_service_provider.dart';
import 'package:malist/providers/notes/notes_provider.dart';
import 'package:malist/providers/passwords/passwords_provider.dart';
import 'package:malist/providers/todo/todo_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showNukeWarningDialog(BuildContext context, ThemeData theme) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Nuke Data",
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SYSTEM PURGE",
                  style: theme.textTheme.headlineSmall!.copyWith(
                    letterSpacing: 2,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Warning: This action is permanent and cannot be undone. All tasks, history, and preferences will be obliterated.",
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        "CANCEL",
                        style: TextStyle(letterSpacing: 1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        context.pop();
                        await ref.read(coreServiceProvider.notifier).nukeData();
                        await ref.read(todoProvider.notifier).getTodos();
                        await ref
                            .read(notesNotifierProvider.notifier)
                            .getNotes();
                        await ref
                            .read(passwordsNotifierProvider.notifier)
                            .getPasswords();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('System completely purged.'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      child: const Text(
                        "NUKE",
                        style: TextStyle(
                          letterSpacing: 1,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * anim1.value),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  void _showAIslopSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Working on it, dont want to deliver some AI slop brody !!",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "M A L I S T",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Settings",
              style: theme.textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "PREFERENCES & DATA CONTROL",
              style: theme.textTheme.labelMedium!.copyWith(
                letterSpacing: 1.5,
                color: theme.primaryColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                const Icon(Icons.layers, size: 20),
                const SizedBox(width: 10),
                Text(
                  "Data Management",
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      "Import Data",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      "Restore from a previous backup",
                      style: TextStyle(
                        color: theme.primaryColor.withValues(alpha: 0.5),
                      ),
                    ),
                    trailing: const Icon(Iconsax.import),
                    onTap: _showAIslopSnackbar,
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  ListTile(
                    title: const Text(
                      "Export Data",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      "Download your data as JSON",
                      style: TextStyle(
                        color: theme.primaryColor.withValues(alpha: 0.5),
                      ),
                    ),
                    trailing: const Icon(Iconsax.export),
                    onTap: _showAIslopSnackbar,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(5),
                border: Border(
                  left: BorderSide(
                    color: Colors.redAccent.withValues(alpha: 0.6),
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Danger Zone",
                    style: theme.textTheme.titleLarge!.copyWith(
                      color: Colors.redAccent.shade100,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "This action is permanent and cannot be undone. All tasks, history, and preferences will be obliterated.",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      height: 1.5,
                      color: theme.primaryColor.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => _showNukeWarningDialog(context, theme),
                    icon: const Icon(
                      Iconsax.trash,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    label: const Text(
                      "NUKE DATA",
                      style: TextStyle(
                        color: Colors.redAccent,
                        letterSpacing: 1,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.redAccent.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            _buildAboutWidget(theme),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutWidget(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "bash v0.99 — About",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DefaultTextStyle(
            style: const TextStyle(
              color: Color(0xFF00FF41),
              fontFamily: 'Courier',
              fontSize: 13,
              height: 1.4,
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  ">> user@malist:~\$ whoami\n"
                  ">> echo \"I AM THE MUSIC is here! 𝄞 𝄫\";\n"
                  ">> GitHub: github.com/jheel23\n"
                  ">> --------------------------------\n"
                  ">> System: Malist OS v1.0.1\n"
                  ">> Uptime: ${DateTime.now().toIso8601String().split('.')[0]}\n"
                  "Encryption: AES-256 ACTIVE\n"
                  "--------------------------------\n"
                  "Ready to capture your thoughts...",
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
              displayFullTextOnTap: true,
            ),
          ),
        ],
      ),
    );
  }
}
